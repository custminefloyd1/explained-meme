import {readFileSync} from "node:fs";
const html=readFileSync(new URL("../explained meme/contact.html",import.meta.url),"utf8");
const fn=readFileSync(new URL("../supabase/functions/contact-v1/index.ts",import.meta.url),"utf8");
const sql=readFileSync(new URL("../supabase/contact-v1.sql",import.meta.url),"utf8");
const checks=[
 ["real Edge Function endpoint",html.includes("/functions/v1/contact-v1")],
 ["response is checked before success",html.includes("if(!r.ok||data.accepted!==true)")&&html.includes('$("form").hidden=true')],
 ["fake Netlify flow absent",!html.includes("data-netlify")&&!html.includes('fetch("/",')],
 ["double submit blocked",html.includes("if(busy)return")&&html.includes('$("send").disabled=true')],
 ["Turnstile authenticated session",html.includes("gotrue_meta_security:{captcha_token:await captcha()}")&&html.includes('localStorage.getItem("arena-v6-session")')],
 ["honeypot included",html.includes('id="website"')&&fn.includes("if (website) return")],
 ["field limits client and server",html.includes('maxlength="4000"')&&fn.includes("message.length > 4000")&&fn.includes("name.length > 80")],
 ["JWT user validated",fn.includes("admin.auth.getUser(token)")],
 ["Resend key is server-only",fn.includes('Deno.env.get(key)')&&!html.includes("RESEND_API_KEY")],
 ["Resend result checked",fn.includes("if (!sent.ok")&&fn.includes('typeof result.id !== "string"')],
 ["Resend idempotency enabled",fn.includes('"Idempotency-Key": requestId')],
 ["reply routes to visitor",fn.includes("reply_to: email")],
 ["rate limits enforced",fn.includes(">= 3")&&fn.includes(">= 10")],
 ["message content not stored",!sql.includes("message text")&&!sql.includes("email text")&&!sql.includes("name text")],
 ["contact table locked",sql.includes("enable row level security")&&sql.includes("revoke all on table public.contact_deliveries_v1 from public, anon, authenticated")],
 ["CORS is restricted",fn.includes("ALLOWED_ORIGINS")&&!fn.includes('"Access-Control-Allow-Origin": "*"')]
];
for(const [name,pass] of checks){console.log((pass?"PASS ":"FAIL ")+name);if(!pass)process.exitCode=1}
for(const m of html.matchAll(/<script\b[^>]*>([\s\S]*?)<\/script>/g))new Function(m[1]);
