# Daily Meme Battle — retention build

## Preview

Download the `codex/battle-arena-v6` branch ZIP, open `explained meme/index.html`, and select **DAILY MEME BATTLE**.

The local file contains six embedded demo memes. Picks advance instantly. After ten picks, a demo result card appears. Demo rankings and percentages are explicitly labelled simulated; the preview makes no network requests and saves nothing.

## Implemented experience

- Immediate next matchup after a confirmed vote—no confirmation button.
- Brief, non-blocking feedback showing crowd agreement and rank movement.
- Agreement uses earlier votes from other visitors on that exact matchup. Fewer than five earlier votes shows “not enough votes,” never a fabricated percentage.
- Ten daily picks with UTC reset and optional extra rounds.
- End card showing agreement with the earlier majority across comparable matchups.
- Back one meme and see movement on the next visit.
- Monday–Sunday UTC competition, countdown, isolated weekly ratings and archived winner.
- “New today” and “new since your last visit” use server data.
- A quiet week records “insufficient votes” instead of inventing a champion.
- Mobile leaderboard and shareable daily result.

## Required backend setup — not applied

Use `supabase/arena-v7-retention.sql` for this build. Do **not** apply the older `arena-v6-voting.sql` as the active voting backend.

1. Review the real `public.memes` schema in a staging Supabase project.
2. Apply `arena-v7-retention.sql`.
3. Enable Supabase anonymous authentication and configure Auth rate limits/CAPTCHA.
4. Confirm anonymous visitors can call `arena_state_v7`, authenticated anonymous visitors can call `arena_vote_v7`, and neither can directly read or write the private v7 tables.
5. Test duplicate requests, repeated pairs, invalid/expired contenders, concurrent votes, low-sample agreement, rank ordering and weekly finalization.
6. Keep an existing server-side Reddit importer if one exists. Otherwise review `arena-v6-import.sql`, deploy `functions/arena-import-v6/index.ts`, and schedule it server-side. Never expose service-role or importer secrets in the HTML.
7. For exact Monday publication, enable and review the optional pg_cron call documented at the end of the migration. Otherwise the first state request after close finalizes the prior week.
8. Browser-test desktop and mobile before deployment.

## Statistic definitions

- “68% agreed” means 68% of earlier votes from other visitors on this exact pair chose the same meme.
- It is shown only with at least five earlier votes.
- Daily agreement excludes tied matchups and pairs below the sample threshold.
- Rank movement is computed inside the same database transaction as the vote.
- The winner needs at least three appearances; the whole season needs at least five votes.
- Ties break by wins and then stable meme ID.
- “New” means database import time, not the original Reddit posting time.

## Verification

Thirty-six mocked assertions pass, covering instant advancement, double-click protection, successful and failed votes, low-sample honesty, numeric agreement, daily completion and offline zero-network/zero-persistence behaviour. All inline scripts parse. Non-Battle code remains unchanged from the previously approved branch build.

Run the repository test with:

```bash
node tests/arena-v6.test.mjs
```

Still outstanding: real browser rendering, SQL execution, Supabase configuration, scheduled importing and production deployment.

## Known limits

- Anonymous identities can be recreated; rate limiting is not bot-proof.
- Local daily progress and the backed meme do not sync across browsers or devices.
- A successful vote whose response is lost can be stored server-side while local progress remains behind; retrying will not double-count it.
- The leaderboard loads up to 200 contenders and refreshes after the visitor’s own vote, not continuously.
- MemeAPI sampling is not proof of virality.
- Moderation/reporting and a real recommendation engine are not included.
- V5.2’s pre-existing admin upload and direct Supabase-write code remains, as explicitly approved, and still needs a separate security audit.
- V5.2’s EXPLAINED page skips its database fetch under `file://`, so its local content can differ from production.
