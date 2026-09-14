# HANDOFF — explained.meme — V5.2 Trending Battle (Stable)

**Date:** 2026-01-15 (approx) — Last stable: V5.2-TRENDING-working
**Site:** explained.meme (Cloudflare Pages)
**Supabase:** https://locumfwdacdrqgxputou.supabase.co — key: sb_publishable_uaC5S2o9Yk2m9uF7YhK8rA... (publishable)
**Repo/bundle:** Single HTML file `index.html` (React build) deployed via zip

---

## 1. What is explained.meme?

- **EXPLAINED (/)** — Evergreen classic memes with meaning/origin, searchable grid
- **TRENDING BATTLE (Battle Arena)** — Now *trending-only* viral memes from Reddit, rolling 7-day window, ELO battle to crown weekly GOAT
- **CERTIFIED FUNNY?** — Rate 1-10 funny ranking
- **SCREENSAVER / LIVE / CONTACT** — other sections untouched

Goal: EXPLAINED = classics, BATTLE = what's viral NOW.

---

## 2. Where we are now — V5.2

**Preview file:** V5.2-TRENDING-working.html
**Deploy zip:** V5.2-TRENDING-working-deploy.zip (contains index.html)

### What works:
- ✅ Logo: Explained.meme image + "Funny Forever" right-aligned, bottom-aligned, NO yellow hover border
- ✅ Grid: images `object-fit: contain` black bg (no crop), yellow glow on hover (`border #d4ff00 + glow + lift`), like/dislike under title, share button top-right
- ✅ Image modal (click meme): aspect unset, max-height 65vh, contain, no jump/crop — fixed from original 16/9 crop
- ✅ Tags next to search bar hidden (search only, not shown)
- ✅ Share: shares **exact image file** via `navigator.canShare({files})` — native sheet on phone + modern Chrome/Edge PC. Fallback PC modal: Download Image, Copy Image (clipboard), WhatsApp, X/Twitter, Facebook, Reddit, Copy Image Link (direct supabase/reddit URL, not broken ?meme= param)
- ✅ Battle Arena → renamed **TRENDING BATTLE**
  - Title: `TRENDING BATTLE` (yellow BATTLE)
  - Subtitle: `🔴 LIVE • Auto-sourced from Reddit • Rolling 7-day window • Vote to crown this week's GOAT`
  - Badges: `TRENDING ONLY`, `r/memes + r/dankmemes + r/wholesomememes`, `Auto-import • No old memes`, `7-day rolling window`
  - Description: "What is this? This arena is for viral memes right now, not classics from EXPLAINED..."
  - **Filter tabs REMOVED:** Mix / Hall of Fame / Trending Now pill hidden (your screenshot) + "14 legends + 2 trending • 16 total" hidden, because now only trending
  - Battle cards: contain (no crop), black bg, tier badges (see ranking)
  - Right side: **Ranking Explained** exactly like your image_b27db8.png + **Trending Leaderboard Top 20 This Week**
  - Leaderboard: live from Supabase, top 20 by elo, shows #Rank, thumbnail, title, tier badge (GOAT/ELITE/HOT/MID/ROOKIE/FELL OFF), W/L, ELO
  - Auto-import: pulls trending memes via meme-api.com

### Known issue fixed in V5.2:
- **Reddit direct JSON blocked (2026)**: `https://www.reddit.com/r/memes/hot.json` now returns 403 without auth (CORS). V5.0 failed. V5.2 uses **https://meme-api.com/gimme/{sub}/{count}** — free, CORS-enabled wrapper, returns Reddit memes with upvotes, url, etc.

---

## 3. Battle Arena — Current MVP Spec (Trending Only)

**Decision:** Battle Arena = trending memes only, not old EXPLAINED memes.

**Flow:**
1. User opens Trending Battle page
2. JS (v52-memeapi) runs: fetches meme-api.com/gimme/memes/10, dankmemes/10, wholesomememes/10
3. Filter: not NSFW, image url valid (.jpg/.png/.gif/.webp), score >? (uses API ups)
4. Dedupe by reddit_id / postLink against Supabase (`reddit_id` column)
5. Insert new as:
```json
{
  title: reddit title slice 80,
  image_url: url,
  image_uri: url,
  kind: 'trending',
  source: 'reddit',
  reddit_id: id,
  reddit_score: ups,
  elo: 1200,
  wins: 0,
  losses: 0,
  origin: "r/memes • 12k upvotes • via MemeAPI"
}
```
6. Battle pool = only `kind='trending'` + created_at within last 7 days (enforced in UI filter, old trending falls out)
7. Voting: existing logic — winner elo + wins, loser elo - losses, POST to `/rest/v1/battles` with winner_id/loser_id, PATCH memes
8. Leaderboard = Top 20 trending by elo desc, 7-day window
9. Cooldown: 10min localStorage (`v52_last`) to avoid spam, manual trigger `v52_import_now()` in console

**Why meme-api.com?** Free, no key, CORS works, avoids Reddit 403. 9GAG skipped — not free/easy, can add later via Apify.

**Title/text to reflect trending only:**
- H1: TRENDING BATTLE
- Subtitle: LIVE • Auto-sourced from Reddit • Rolling 7-day window
- Description box explains MID → HOT → ELITE → GOAT
- No Mix/HOF tabs

**Ranking tiers (from your image_b27db8.png):**
- GOAT 🏆 — Top 1% — Wins almost every battle — yellow dot glow
- ELITE ⭐ — Top 10% — Very dank — purple dot
- HOT 🔥 — Winning more than losing — orange dot
- MID — Average — yellow dim dot
- ROOKIE — New here (<3 battles) — white dot
- FELL OFF — Losing a lot — gray dot
- Rank #3 = 3rd best out of all. Win = +tier, Lose = -tier (hidden ELO behind scenes)

---

## 4. File History / Recovery Points

- **official-v19-fixed-same-appearance.html** — Original bundle base (stable before V3)
- **V3.0-STABLE-all-fixes.html** — Logo fix + image modal + grid contain + share attempt
- **V3.1-STABLE-logo-share.html** — Removed yellow sides from logo only, PC share modal attempt
- **V3.2-STABLE-clean-share.html** — Clean rebuild from official-v19, fixed nested button bug, share div (not button), contain, yellow glow, like/dislike
- **V4.0-BATTLE-ranking-engine.html** — Added Ranking Explained + Leaderboard (Top 20) fetching Supabase, tier calc
- **V5.0-TRENDING-BATTLE.html** — Trending-only title, auto-import Reddit direct (failed due to CORS 403)
- **V5.1-TRENDING-fix.html** — Minimal fix hiding tabs
- **V5.2-TRENDING-working.html** — **CURRENT STABLE** — uses meme-api.com, tabs hidden, trending-only

Deploy zips mirror each.

---

## 5. How to Deploy

1. Take `V5.2-TRENDING-working-deploy.zip` → unzip → `index.html`
2. Upload to Cloudflare Pages (explained.meme project) → Drag & drop or `wrangler pages deploy`
3. Purge cache
4. Test in incognito: EXPLAINED grid, click meme modal, share button, Trending Battle — should see toast "Pulling trending..." then leaderboard
5. Console: `v52_import_now()` forces import

---

## 6. Supabase Schema (relevant)

Table `memes`:
- id (uuid)
- title (text)
- image_url / image_uri (text) — both kept for compatibility (fixRow in fetch interceptor)
- kind: 'trending' for battle, other values for explained
- source: 'reddit'
- reddit_id: text (for dedupe)
- reddit_score: int
- elo: int (default 1200)
- wins, losses: int
- origin: text
- created_at: timestamp (used for 7-day window)
- avg_rating, ratings_count: for Certified Funny
- ... other fields

Table `battles`:
- winner_id, loser_id, created_at

Edge: fetch interceptor in HTML fixes image_uri ↔ image_url.

---

## 7. Code Injection Points

All custom code injected via `<style id="vXX">` and `<script id="vXX">` at end of `<head>`/`</body>`.

- v32-css/js: logo layout, grid contain, yellow glow, share div, like row, modal fix, hide tags
- v40-battle: leaderboard styles + tier badges, ranking explained HTML, fetch memes
- v50-trending: title overhaul, badges, description
- v52-memeapi: hideTabs(), fetchMemesAPI(), importTrending(), auto-import logic

No build step — all JS runs client-side.

---

## 8. Current Issues / Next Steps

**Fixed:**
- Logo yellow sides
- Image crop/jump
- Share copying broken ?meme= link → now direct image URL + file share
- Reddit CORS 403 → meme-api.com workaround

**Still to consider:**
- Reddit auto-import reliability: meme-api.com is unofficial, may rate-limit. Long-term: Supabase Edge Function cron fetching Reddit with OAuth, or Apify actor
- 7-day window enforcement: currently UI filter only, old trending still in DB (not deleted). Could add cleanup Edge Function: delete trending where created_at < 7 days and wins < threshold
- 9GAG: if easy free API found, add
- Nav tab rename: BATTLE ARENA → TRENDING BATTLE in nav
- Leaderboard live update after vote (currently requires reload)
- Share battle result card: "I made X GOAT"
- Biggest climbers / Fell Off sections

**Roadmap ideas discussed:**
- Tier Leagues (ROOKIE PIT → MID → HOT → ELITE → GOAT)
- Champion Your Meme (track your impact)
- Daily War / weekly reset
- Explain trending winners → promote to EXPLAINED

---

## 9. How to Continue Development

- Always base new version on V5.2 (cleanest stable with trending)
- Keep EXPLAINED untouched — only modify Battle Arena JS
- Test hiding tabs: selector `div.flex.p-1.rounded-full` containing Mix
- For sourcing: if meme-api.com fails, fallback to `https://api.allorigins.win/raw?url=https://www.reddit.com/r/memes/hot.json`
- For manual import: run `v52_import_now()` in console on Battle page

---

## 10. Assets

- image_b27db8.png — Ranking Explained design (GOAT/ELITE/HOT/MID/ROOKIE/FELL OFF)
- image_7e2c41.png — Screenshot of filter tabs to remove (Mix / Hall of Fame / Trending Now)

---

**End of Handoff — V5.2 is current stable, ready for deploy and further iteration on Trending Battle.**
