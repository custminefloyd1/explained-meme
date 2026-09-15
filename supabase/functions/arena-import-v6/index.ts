// Deploy as a Supabase Edge Function named arena-import-v6.
// Invoke from a server-side schedule, never from a visitor's browser.
// Required custom secret: ARENA_IMPORT_SECRET.
// Set function JWT verification OFF: this handler authenticates every request with
// the high-entropy x-arena-import-secret header before using the admin client.
import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { withSupabase } from "jsr:@supabase/server@1";

export default {
  fetch: withSupabase({ auth: "none" }, async (request, ctx) => {
    const secret = Deno.env.get("ARENA_IMPORT_SECRET");
    if (!secret || request.headers.get("x-arena-import-secret") !== secret) {
      return new Response("Unauthorized", { status: 401 });
    }
    if (request.method !== "POST") {
      return new Response("Method not allowed", { status: 405 });
    }

    const candidates = new Map<string, Record<string, string | number>>();
    const failures: string[] = [];

    for (const sub of ["memes", "dankmemes", "wholesomememes"]) {
      try {
        const response = await fetch("https://meme-api.com/gimme/" + sub + "/10", {
          signal: AbortSignal.timeout(10000),
        });
        if (!response.ok) throw new Error("Source status " + response.status);

        const data = await response.json();
        for (const post of data.memes || []) {
          if (
            post.nsfw ||
            post.spoiler ||
            typeof post.url !== "string" ||
            typeof post.postLink !== "string"
          ) continue;

          const image = new URL(post.url);
          const source = new URL(post.postLink);
          const redditId = source.pathname.match(/\/comments\/([a-z0-9]+)(?:\/|$)/i)?.[1];

          if (
            !redditId ||
            !/(^|\.)reddit\.com$/i.test(source.hostname) ||
            image.protocol !== "https:" ||
            !/\.(png|jpe?g|gif|webp)$/i.test(image.pathname) ||
            !["i.redd.it", "preview.redd.it", "i.imgur.com"].includes(image.hostname)
          ) continue;

          candidates.set(redditId, {
            id: "reddit-" + redditId,
            title: String(post.title || "Reddit meme").slice(0, 160),
            image_url: post.url,
            image_uri: post.url,
            kind: "trending",
            source: "reddit",
            reddit_id: redditId,
            reddit_score: Number(post.ups) || 0,
            elo: 1200,
            wins: 0,
            losses: 0,
          });
        }
      } catch (error) {
        const message = error instanceof Error ? error.message : String(error);
        failures.push(sub + ": " + message);
      }
    }

    if (!candidates.size) {
      return Response.json(
        { inserted: 0, failures },
        { status: failures.length === 3 ? 502 : 200 },
      );
    }

    const rows = [...candidates.values()]
      .sort((a, b) => Number(b.reddit_score) - Number(a.reddit_score))
      .slice(0, 15);

    const { data: inserted, error } = await ctx.supabaseAdmin
      .from("memes")
      .upsert(rows, { onConflict: "reddit_id", ignoreDuplicates: true })
      .select("id");

    if (error) {
      console.error("Arena import database error", error);
      return Response.json(
        { error: "Database rejected import. Check function logs.", failures },
        { status: 502 },
      );
    }

    return Response.json({ inserted: inserted?.length || 0, failures });
  }),
};
