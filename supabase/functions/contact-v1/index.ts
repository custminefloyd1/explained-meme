import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "jsr:@supabase/supabase-js@2";

const ALLOWED_ORIGINS = new Set([
  "https://explained.meme",
  "https://www.explained.meme",
  "http://localhost:8000",
  "http://127.0.0.1:8000",
]);

function cors(request: Request) {
  const origin = request.headers.get("origin") || "";
  const allowed = ALLOWED_ORIGINS.has(origin) || /^https:\/\/[a-z0-9-]+\.explained-meme\.pages\.dev$/i.test(origin);
  return {
    "Access-Control-Allow-Origin": allowed ? origin : "https://explained.meme",
    "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
    "Access-Control-Allow-Methods": "POST, OPTIONS",
    "Vary": "Origin",
  };
}

function json(request: Request, body: unknown, status = 200) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...cors(request), "Content-Type": "application/json", "Cache-Control": "no-store" },
  });
}

function validEmail(value: string) {
  return value.length <= 254 && /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(value);
}

Deno.serve(async (request) => {
  if (request.method === "OPTIONS") return new Response(null, { status: 204, headers: cors(request) });
  if (request.method !== "POST") return json(request, { error: "Method not allowed." }, 405);

  const required = ["SUPABASE_URL", "SUPABASE_SERVICE_ROLE_KEY", "RESEND_API_KEY", "CONTACT_TO_EMAIL", "CONTACT_FROM_EMAIL"];
  const env = Object.fromEntries(required.map((key) => [key, Deno.env.get(key) || ""]));
  if (required.some((key) => !env[key])) {
    console.error("contact-v1 missing server configuration");
    return json(request, { error: "Contact service is not configured." }, 503);
  }

  const auth = request.headers.get("authorization") || "";
  const token = auth.replace(/^Bearer\s+/i, "");
  if (!token) return json(request, { error: "Authentication required." }, 401);

  const admin = createClient(env.SUPABASE_URL, env.SUPABASE_SERVICE_ROLE_KEY, {
    auth: { persistSession: false, autoRefreshToken: false },
  });
  const { data: userData, error: userError } = await admin.auth.getUser(token);
  const user = userData?.user;
  if (userError || !user) return json(request, { error: "Authentication failed." }, 401);

  let body: Record<string, unknown>;
  try {
    body = await request.json();
  } catch {
    return json(request, { error: "Invalid request." }, 400);
  }

  const requestId = String(body.request_id || "");
  const name = String(body.name || "").trim();
  const email = String(body.email || "").trim().toLowerCase();
  const subject = String(body.subject || "");
  const message = String(body.message || "").trim();
  const website = String(body.website || "").trim();
  const subjects = new Set(["Bug Report", "Idea", "Business", "Other"]);

  // Silent success wastes bot time without sending or storing anything.
  if (website) return json(request, { accepted: true });

  if (!/^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i.test(requestId)) {
    return json(request, { error: "Invalid request identifier." }, 400);
  }
  if (name.length < 2 || name.length > 80 || !validEmail(email) || !subjects.has(subject) || message.length < 10 || message.length > 4000) {
    return json(request, { error: "Check the form fields and try again." }, 400);
  }

  const { data: existing, error: existingError } = await admin
    .from("contact_deliveries_v1")
    .select("status,updated_at")
    .eq("request_id", requestId)
    .maybeSingle();
  if (existingError) {
    console.error("contact lookup failed", existingError);
    return json(request, { error: "Contact service is temporarily unavailable." }, 503);
  }
  if (existing?.status === "sent") return json(request, { accepted: true, duplicate: true });
  if (existing?.status === "pending" && Date.now() - new Date(existing.updated_at).getTime() < 60000) {
    return json(request, { error: "This message is already being sent." }, 409);
  }

  const fifteenMinutesAgo = new Date(Date.now() - 15 * 60 * 1000).toISOString();
  const dayAgo = new Date(Date.now() - 24 * 60 * 60 * 1000).toISOString();
  const [{ count: recent, error: recentError }, { count: daily, error: dailyError }] = await Promise.all([
    admin.from("contact_deliveries_v1").select("*", { count: "exact", head: true }).eq("sender_id", user.id).gte("created_at", fifteenMinutesAgo).in("status", ["pending", "sent"]),
    admin.from("contact_deliveries_v1").select("*", { count: "exact", head: true }).eq("sender_id", user.id).gte("created_at", dayAgo).in("status", ["pending", "sent"]),
  ]);
  if (recentError || dailyError) return json(request, { error: "Contact service is temporarily unavailable." }, 503);
  if ((recent || 0) >= 3 || (daily || 0) >= 10) {
    return json(request, { error: "Too many messages. Please try again later." }, 429);
  }

  const now = new Date().toISOString();
  const { error: reserveError } = await admin.from("contact_deliveries_v1").upsert({
    request_id: requestId,
    sender_id: user.id,
    status: "pending",
    provider_message_id: null,
    updated_at: now,
  }, { onConflict: "request_id" });
  if (reserveError) return json(request, { error: "Contact service is temporarily unavailable." }, 503);

  const text = [
    "New Explained Meme contact",
    "",
    "Name: " + name,
    "Email: " + email,
    "Subject: " + subject,
    "",
    message,
  ].join("\n");

  const sent = await fetch("https://api.resend.com/emails", {
    method: "POST",
    headers: {
      "Authorization": "Bearer " + env.RESEND_API_KEY,
      "Content-Type": "application/json",
      "Idempotency-Key": requestId,
    },
    body: JSON.stringify({
      from: env.CONTACT_FROM_EMAIL,
      to: [env.CONTACT_TO_EMAIL],
      reply_to: email,
      subject: "[Explained Meme] " + subject + " — " + name,
      text,
    }),
  });

  let result: Record<string, unknown> = {};
  try { result = await sent.json(); } catch {}
  if (!sent.ok || typeof result.id !== "string") {
    console.error("Resend rejected contact", sent.status, result);
    await admin.from("contact_deliveries_v1").update({ status: "failed", updated_at: new Date().toISOString() }).eq("request_id", requestId);
    return json(request, { error: "Email delivery failed. Please try again." }, 502);
  }

  const { error: finishError } = await admin.from("contact_deliveries_v1").update({
    status: "sent",
    provider_message_id: result.id,
    updated_at: new Date().toISOString(),
  }).eq("request_id", requestId);
  if (finishError) console.error("Contact sent but metadata update failed", finishError);

  return json(request, { accepted: true });
});
