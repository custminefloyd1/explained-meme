# HANDOFF — explained.meme — Daily Meme Battle V7

**Date:** 2026-09-15  
**Repository:** `custminefloyd1/explained-meme`  
**Base branch:** `main`  
**Working branch:** `codex/battle-arena-v6`  
**Draft pull request:** https://github.com/custminefloyd1/explained-meme/pull/1  
**Live site:** unchanged; nothing in this work has been deployed  
**Current product name:** **DAILY MEME BATTLE**

---

## 1. Purpose

explained.meme has an evergreen EXPLAINED experience and a voting experience for current memes. The goal of this work was to rebuild only the Battle Arena so visitors have a reason to vote, return, follow the competition and share a result.

The final product direction is:

> Ten quick meme choices per day. Every confirmed choice immediately loads the next matchup, shows honest crowd/rank feedback, and helps crown a weekly winner.

All other website pages must remain visually and functionally unchanged from V5.2.

---

## 2. Files originally reviewed

The repository uses different names from the locally uploaded copies:

- Uploaded `index(1).html` → repository `explained meme/index.html`
- Uploaded `V5-2-TRENDING-Working(1).html` → repository `V5-2-TRENDING-Working.html`
- Resolved original handoff → `HANDOFF-Explained-Meme-V5-2.md`

The clean index was 450,447 characters / 644 lines. V5.2 was 475,101 characters / 1,130 lines. V5.2 was largely the clean React bundle plus injected CSS/JavaScript patches.

---

## 3. Original V5.2 audit

The first review found that V5.2 looked like a Trending Battle but did not implement its central promises correctly.

### Critical findings

- The React battle state still defaulted to `MIX`. V5.2 hid the Mix/Hall of Fame/Trending controls but never changed the underlying state to Trending.
- The seven-day window was not enforced in the battle pool.
- `created_at` was used to order the database fetch but was discarded from mapped meme objects and never used for eligibility.
- The injected leaderboard fetched the top 100 memes without filtering by `kind='trending'` or date, while calling itself a weekly trending leaderboard.
- There was no weekly season, cutoff, reset, archived winner or finalization mechanism.
- The so-called ELO update was always `+12/-12`, regardless of opponent strength.
- Votes used separate client-side PATCH requests and could overwrite concurrent results.
- Visitors’ browsers triggered imports. A localStorage cooldown was per browser, not global.
- The obsolete direct-Reddit importer and newer MemeAPI importer both remained active.
- External database/Reddit content was interpolated into `innerHTML`, creating stored-XSS exposure.
- Errors were mostly swallowed, so a vote could look successful locally without persistence.
- The injected leaderboard did not update after votes and was hidden on mobile.
- Random pairing had weak repeat/exposure controls.
- “This week’s GOAT” and “rolling seven days” were marketing claims rather than implemented behaviour.

### Product conclusion

The two-card choice mechanic was strong, but endless random clicking offered little return value. Fresh Reddit content alone was not defensible because Reddit already provides more content. The retention loop needed entertainment, visible influence, a finite daily goal, a personal stake, weekly closure and a reason to check back.

---

## 4. Product decisions made

### Naming

The navigation tab and page title were unified as **DAILY MEME BATTLE**.

Why:

- “Battle Arena” does not explain that the content is memes.
- “Trending Battle” can sound like a fight about trending topics.
- “Daily Meme Battle” communicates the content and return cadence.

### Core retention loop

The requested MVP became:

1. Click a meme.
2. Save one confirmed vote.
3. Immediately load another matchup—no “Next battle” confirmation.
4. Briefly show how earlier visitors voted.
5. Show whether the vote moved the selected meme’s rank.
6. Complete ten daily picks.
7. Back one meme and track it on a return visit.
8. See how many memes are new today / since the last visit.
9. Return for the Sunday-night weekly result.
10. Share a daily result.

### Honesty rules

- Never fabricate crowd percentages in production.
- “68% agreed” means earlier votes from other visitors on that exact pair.
- Show agreement only after at least five earlier votes.
- Exclude low-sample pairs and ties from the daily agreement result.
- A low-traffic week can finish with “insufficient votes” instead of a fake winner.
- “New” means database import time, not the original Reddit publication time.
- Offline demo percentages and rankings must be visibly labelled simulated.

---

## 5. Frontend implementation

**File:** `explained meme/index.html`

The old Battle Arena render branch was replaced with an isolated React component, `ArenaV6`. The component is V7-compatible despite the historical function name.

### Implemented UI and behaviour

- Responsive two-card matchup.
- Meme images use `object-fit: contain`; meme content is not cropped.
- Click/tap the image or vote button to vote.
- Left/right keyboard voting.
- Skip matchup control.
- Expand control using a native dialog.
- Immediate advancement only after the live vote is confirmed.
- Double-click guard.
- Fixed, non-blocking feedback overlay lasting about 5.5 seconds.
- Crowd agreement, sample size and rank movement in feedback.
- Daily ten progress and UTC reset countdown.
- Optional extra rounds after the daily ten.
- End-of-session result card.
- Backed-meme tracking.
- Backed-meme movement compared with the previous browser visit in the same week.
- Monday–Sunday weekly countdown.
- Current top-ten leaderboard visible on desktop and mobile.
- Previous weekly winner or explicit insufficient-votes result.
- New-today and new-since-last-visit counts.
- Shareable daily result.
- `#battle` deep link opens Daily Meme Battle.
- Loading, empty, exhausted, broken-image, failed-vote and expired-season states.
- All Battle-specific styles are scoped with `.arena-v6` / `.av-*` classes.
- Obsolete V4/V5 Battle injection, polling and browser importer code was removed from the new branch build.
- The previous parent keyboard voting listener was disabled to prevent double submission.

### Browser-local state

Stored locally:

- Daily voting journal: `arena-v7-journal`
- Backed meme snapshot: `arena-v7-backed`
- Last arena visit: `arena-v7-visited`
- Anonymous Supabase session: historical key `arena-v6-session`

Consequences:

- Progress and backed memes do not sync across devices.
- Clearing browser storage removes them.
- A successful server vote with a lost response may leave local progress behind. Retrying does not count the server vote twice.

### Preserving the rest of the site

An initial implementation mistakenly used the clean index as the baseline. That was corrected: the final branch was rebuilt from V5.2.

The navigation label and Battle integration are intentional changes. Other pages retain the V5.2 code. V5.2 itself skips its EXPLAINED database fetch when opened through `file://`, so local EXPLAINED content can differ from production even when its code is unchanged.

The user explicitly approved replacement of the draft branch’s full single-file HTML after being informed that V5.2 contains unrelated legacy admin-upload controls and direct Supabase/storage write paths. Those legacy paths were preserved and still require a separate security audit.

---

## 6. Offline preview

Opening `explained meme/index.html` directly from the downloaded branch ZIP activates preview mode.

### Preview behaviour

- Six embedded, original sample memes.
- No Supabase dependency.
- No network requests by the arena.
- No persistent votes, scores, daily progress or backed meme.
- Simulated rankings and crowd percentages.
- Prominent `PREVIEW · SIMULATED RESULTS` disclosure.
- Instant next matchup.
- Daily-ten completion and result card can be tested.
- Reloading resets the demo.

### Preview steps

1. Download:
   https://github.com/custminefloyd1/explained-meme/archive/refs/heads/codex/battle-arena-v6.zip
2. Extract the ZIP.
3. Open `explained meme/index.html` in Chrome or Firefox.
4. Select **DAILY MEME BATTLE**.

The live website is not changed by this preview.

---

## 7. V7 database design

**Active migration for this build:** `supabase/arena-v7-retention.sql`

Do **not** use `supabase/arena-v6-voting.sql` as the active voting backend for this frontend. It remains only as history from the earlier iteration.

### Tables

#### `arena_entries_v7`

Isolated rating state per weekly season:

- `week_start`
- `meme_id`
- `rating`
- `wins`
- `losses`

The new competition does not modify legacy `memes.elo/wins/losses`.

#### `arena_votes_v7`

Immutable vote log:

- Idempotency `request_id`
- Authenticated anonymous `voter_id`
- Weekly season
- Winner and loser
- UTC vote day
- Timestamp

A unique index prevents the same identity from voting on the same unordered pair more than once per UTC day.

#### `arena_winners_v7`

Archived season result:

- Week start and close
- Winner identity/title/image/rating
- Vote count
- Status: `winner` or `insufficient_votes`
- Finalization timestamp

Completed seasons are treated as immutable.

### Functions

#### `arena_week_v7()`

Returns the current Monday 00:00 UTC season start.

#### `arena_standings_v7(week)`

Returns the eligible weekly pool and deterministic rank.

Eligibility:

- `kind='trending'`
- Imported during the selected week
- Not future-dated
- HTTPS image URL

#### `arena_state_v7(since)`

Returns:

- Current top-200 pool
- Week start and close
- Server time
- New today
- New since the supplied prior visit
- Full eligible count
- Previous week’s archived result

#### `arena_vote_v7(winner, loser, request_id)`

Performs an atomic vote:

- Requires authenticated identity.
- Rejects invalid or expired contenders.
- Uses an idempotency request UUID.
- Serializes per visitor and per season.
- Applies a per-identity minute limit.
- Inserts the vote once.
- Updates opponent-adjusted rating with K=32.
- Calculates before/after rank inside the transaction.
- Calculates pair-specific agreement from earlier votes by other visitors.
- Returns refreshed standings data and feedback values.

#### `arena_finalize_v7()`

Finalizes closed seasons:

- Runs once per season.
- Winner requires at least three appearances.
- Entire season requires at least five votes.
- Ranking: rating, wins, stable meme ID.
- Stores an explicit insufficient-votes result when thresholds are not met.

Weekly finalization can run through reviewed pg_cron configuration at Monday 00:00 UTC. Without cron, the next `arena_state_v7` request after close finalizes the previous week.

### Security model

- V7 tables have RLS enabled.
- Direct anon/authenticated table access is revoked.
- Anonymous clients may call the state function.
- Authenticated anonymous visitors may call the vote function.
- Security-definer functions set an empty search path.
- Anonymous identities can still be recreated; this is not bot-proof.
- CAPTCHA/Auth rate limits and abuse monitoring remain necessary.
- Existing legacy table/storage policies were not changed.

---

## 8. Reddit/MemeAPI importing

Files:

- `supabase/arena-v6-import.sql`
- `supabase/functions/arena-import-v6/index.ts`

These were created to replace visitor-triggered imports with a server-side import path.

### Importer behaviour

- Protected by `ARENA_IMPORT_SECRET`.
- Uses server-only `SUPABASE_SERVICE_ROLE_KEY`.
- Pulls from `memes`, `dankmemes`, and `wholesomememes`.
- Rejects NSFW/spoiler/invalid records.
- Restricts accepted image hosts/protocols/extensions.
- Extracts a Reddit ID and deduplicates through a unique index.
- Never resets ratings or refreshes the import date of an existing Reddit post.
- Can be scheduled server-side, for example hourly.
- Must never expose importer/service-role secrets in HTML.

### Important sourcing limitation

MemeAPI sampling is not evidence that an item is comprehensively “trending.” Current weekly eligibility is based on database import time. A future version should use a reliable Reddit OAuth/server pipeline with source post time, engagement thresholds, moderation and image mirroring.

---

## 9. Verification completed

**Test file:** `tests/arena-v6.test.mjs`

Thirty-six mocked assertions pass, covering:

- Immediate advancement.
- No Next confirmation control.
- Double-submit protection.
- No direct client score PATCH.
- Confirmed-vote persistence.
- Failed votes not counted locally.
- Visible failure state.
- Low-sample agreement honesty.
- Numeric agreement display.
- Daily completion.
- Demo/live result labelling.
- Offline zero-network behaviour.
- Offline zero-persistence behaviour.

Additional checks completed during development:

- All inline scripts parse.
- Battle component parses independently.
- Original non-Battle content reconstructs exactly after reversing intentional Battle integration/navigation changes.
- The current repository contains all requested retention features and the V7 migration.

Run:

```bash
node tests/arena-v6.test.mjs
```

### Not verified yet

- Real browser rendering/interaction.
- Real Supabase SQL execution.
- Actual RLS/Auth behaviour.
- Concurrent database transactions.
- Cron finalization.
- Live importer.
- Cloudflare deployment.
- Production analytics or retention impact.

Automated mocked tests are useful but not proof that the production system works.

---

## 10. Repository state

Current draft PR:

- https://github.com/custminefloyd1/explained-meme/pull/1
- Title: `Daily Meme Battle: instant voting and weekly retention loop`
- Status: open draft
- Merge status was reported mergeable before this handoff was added.
- Nothing has been merged or deployed.

Important files on `codex/battle-arena-v6`:

- `explained meme/index.html` — V5.2-based site plus new Daily Meme Battle
- `BATTLE-ARENA-V6.md` — concise setup and limitations
- `HANDOFF-Daily-Meme-Battle-V7.md` — this complete handoff
- `supabase/arena-v7-retention.sql` — active V7 competition backend
- `supabase/arena-v6-voting.sql` — superseded historical voting migration
- `supabase/arena-v6-import.sql` — importer schema prerequisite
- `supabase/functions/arena-import-v6/index.ts` — optional server importer
- `tests/arena-v6.test.mjs` — automated component checks
- `V5-2-TRENDING-Working.html` — untouched historical V5.2 reference

---

## 11. Exact next steps

Do not merge or deploy yet.

### Phase A — visual acceptance

1. Download the current branch ZIP.
2. Review Daily Meme Battle at desktop and mobile widths.
3. Test selecting, instant advancement, feedback, skip, expand, backing, daily completion, extra rounds and sharing.
4. Record layout/copy problems with screenshots.
5. Fix visual issues before database work.

### Phase B — staging backend

1. Create/use a staging Supabase project or database branch.
2. Confirm the real `public.memes` column types match the migration assumptions.
3. Apply `arena-v7-retention.sql`.
4. Enable anonymous authentication.
5. Configure Auth rate limits/CAPTCHA.
6. Verify function grants and blocked direct table access.
7. Seed at least two current-week trending memes.
8. Test success, duplicate, retry, reversed pair, invalid ID, expired week and concurrent vote cases.
9. Seed at least five earlier pair votes and verify agreement math.
10. Test weekly finalization with both sufficient and insufficient traffic.

### Phase C — sourcing

1. Confirm whether a reliable server importer already exists.
2. If not, review and deploy the included Edge Function.
3. Configure secrets server-side.
4. Schedule imports.
5. Add monitoring for source/API/database failures.
6. Add moderation/reporting before meaningful public traffic.

### Phase D — production release

1. Re-run the automated test.
2. Complete browser QA against staging.
3. Review the separate security risk in legacy admin/direct-write code.
4. Update the handoff with final configuration.
5. Mark the PR ready only after release gates pass.
6. Merge.
7. Deploy through the existing Cloudflare Pages workflow.
8. Test in incognito on desktop and mobile.
9. Monitor failed loads, failed votes, broken images and importer health.

---

## 12. Metrics required after launch

The objective is repeat visits, so measure behaviour rather than guessing.

Minimum events:

- Battle page viewed
- First vote completed
- Each confirmed vote
- Daily ten completed
- Matchup skipped
- Meme backed/unbacked
- Backed meme viewed on return
- Result shared
- New-since-last-visit displayed
- Weekly result viewed
- Load/auth/vote/image errors

Primary product metrics:

- View → first-vote conversion
- Votes per session
- Daily-ten completion rate
- D1 and D7 return rate
- Weekly-result return rate
- Percentage of visitors backing a meme
- Share rate and share-return conversion
- Repeat-pair rate
- Exposure distribution between memes
- Vote persistence failure rate
- Broken/report rate by source

Do not add streaks or points until this core loop demonstrates real repeat value.

---

## 13. Deferred ideas

Useful later, not part of the current MVP:

- Synced accounts and cross-device progress.
- Friend challenges / compare-results links.
- Real humour profiles based on enough data.
- Streaks after repeat value is proven.
- Personalised matchup recommendations.
- Biggest climbers / fell-off sections.
- Promote weekly winners into EXPLAINED.
- Image mirroring instead of relying on external Reddit URLs.
- Proper source-post timestamps and engagement thresholds.
- Moderator queue and user reporting.
- Live/realtime leaderboard subscriptions.
- Recovery endpoint for a vote saved server-side but missing from local progress.

---

## 14. Blunt status

The frontend is a credible review build and the offline demo is usable. The retention concepts are implemented in code. The V7 backend is designed but completely untested against the real Supabase database. Real crowd percentages, rankings, freshness counts and weekly winners are **not live** until the migration, Auth configuration, sourcing and staging tests are completed.

Merging the PR now would produce a polished interface whose production voting backend is unavailable. Do not do that.


---

## 15. Backend execution log — 2026-09-15

### User authorization

The user approved proceeding with backend work and requested that the handoff be updated after every backend change.

### Access check

A supported Supabase connector is not installed/available in this ChatGPT workspace. Only the public client configuration embedded in the existing HTML is visible. No database-owner connection, Supabase dashboard session, CLI access token, service-role secret, staging project or migration runner is available.

Therefore the following actions were **not** performed:

- No SQL was executed.
- No production or staging database schema was changed.
- Anonymous authentication was not enabled.
- RLS/grants were not changed or tested.
- No Edge Function was deployed.
- No server secrets were configured.
- No importer or pg_cron schedule was created.
- No real votes or meme rows were written.

Trying to use the public browser key for database administration would be insecure and insufficient.

### Safe work completed

Added `supabase/arena-v7-preflight.sql`.

This is a read-only inspection script that checks:

- Required `public.memes` columns and exact types.
- Current-week eligible trending counts.
- Missing IDs, titles and image URLs.
- Duplicate Reddit IDs.
- Primary/unique constraints.
- RLS state and policies.
- Direct anon/authenticated table privileges.
- Existing V7 object collisions.
- pg_cron availability.
- Separate Auth/CAPTCHA settings that must be checked in the dashboard.

The preflight creates, updates and deletes nothing.

### Required user action / continuation point

1. Open the correct Supabase project.
2. Go to **SQL Editor** and create a new query.
3. Open `supabase/arena-v7-preflight.sql` from the draft branch.
4. Paste and run it.
5. Export or screenshot **every result grid**. Do not send passwords, access tokens, service-role keys or other secrets.
6. Separately report whether Anonymous Sign-Ins and CAPTCHA are enabled.
7. Return the results in this conversation.

Do **not** run `arena-v7-retention.sql` yet. Its assumptions must be compared with the real preflight output first.

### Next agent task after results arrive

- Compare actual column types and policies with the V7 migration.
- Patch unsafe/incompatible assumptions.
- Update this handoff.
- Produce an exact, staged migration checklist.
- Apply/test through a supported authorized Supabase connection if one becomes available; otherwise guide the user through each reviewed SQL operation and verify returned results before continuing.


### Preflight usability update — 2026-09-15

The first multi-query preflight was run in Supabase. The supplied screenshot displayed only the final result grid, because the SQL Editor surfaced the last SELECT. That result confirmed:

- `pg_cron` default version: `1.6.4`
- Installed version: `NULL`
- Status: `AVAILABLE_NOT_INSTALLED`

This does **not** mean pg_cron should be installed yet. Scheduling is deferred until the schema and voting functions pass staging tests.

The words `enabled/disabled` visible near the bottom of the editor were part of SQL comments, not actual Authentication settings. Anonymous Sign-Ins and CAPTCHA therefore remain unverified.

To make collection practical for a non-technical operator, added:

- `supabase/arena-v7-preflight-single-result.sql`

It returns every database preflight category in one result row. The user should run the whole file, use **Results → Download CSV**, and attach the CSV. This replaces the earlier instruction to capture every grid separately. The original multi-result preflight remains as a readable diagnostic reference.


### Single-result preflight review — 2026-09-15

The user explicitly approved recording these Supabase findings in this private repository handoff.

The returned CSV from `arena-v7-preflight-single-result.sql` confirmed:

- `public.memes` contains 14 rows and zero `kind='trending'` rows. The live Battle currently has no eligible memes.
- Required Battle fields exist: `id`, `kind`, `title`, `created_at`, `image_url`, and `image_uri`.
- IDs are non-null and protected by the primary key.
- `created_at` is `timestamp without time zone`, not `timestamptz`. The V7 migration must explicitly normalize this legacy timestamp as UTC before execution.
- Importer prerequisite fields `reddit_id`, `reddit_score`, and `source` are absent. Apply and review `arena-v6-import.sql` before deploying the included importer.
- RLS is enabled on `memes`, but legacy permissive public INSERT/UPDATE policies and broad direct privileges for `anon` and `authenticated` exist. These are a serious security risk and require a compatibility-aware review because older site features may depend on them.
- No V7 tables or functions exist, so there are no current V7 migration-name collisions.
- `pg_cron` version 1.6.4 is available but not installed.
- Supabase Dashboard verification: Anonymous Sign-Ins are disabled.
- Supabase Dashboard verification: Bot and Abuse Protection/CAPTCHA is disabled.

Do not enable Anonymous Sign-Ins yet. Do not enable CAPTCHA without first adding a compatible CAPTCHA token flow to the frontend. Do not run `arena-v7-retention.sql` until the timestamp compatibility patch and security review are complete.


### Backend compatibility patch — 2026-09-15

Completed repository-only preparation; no Supabase SQL was executed.

- Patched `supabase/arena-v7-retention.sql` to treat the inspected legacy `memes.created_at` `timestamp without time zone` values explicitly as UTC before weekly comparisons and API output.
- Reviewed `supabase/arena-v6-import.sql` against the preflight schema. It adds only the missing `reddit_id`, `reddit_score`, and `source` columns plus a unique Reddit-ID index. It does not rewrite or delete existing meme rows. Index creation deliberately fails if future/pre-existing non-null duplicates exist.
- Added read-only `supabase/arena-v7-post-migration-check.sql`. It verifies importer columns, V7 tables, RLS, function presence, RPC grants, and absence of direct client grants on V7 tables in one result row. It intentionally does not call `arena_state_v7`, because that RPC can finalize a closed season and is therefore not read-only.
- Attempted to run the existing mocked frontend suite against files fetched from GitHub. The transient runner could not ingest the large single-file HTML reliably, so this attempt was inconclusive rather than a pass. The SQL-only change does not alter frontend code, but the suite must still be rerun from a normal repository checkout before release.

Current safe execution order remains: importer prerequisite, V7 migration, post-migration check, controlled seed/import test, then Auth/CAPTCHA integration. Do not merge or deploy yet.


### Importer prerequisite applied — 2026-09-15

The user ran `supabase/arena-v6-import.sql` in the target Supabase project and reported: `Success. No rows returned`.

This is the expected SQL Editor result for the successful transactional DDL. It indicates no execution error was reported; it does not independently prove every object exists. Presence of `reddit_id`, `reddit_score`, `source`, and the unique Reddit-ID index will be verified by the post-migration check after the V7 migration.

No importer function was deployed, no memes were imported, and Auth/CAPTCHA remain disabled.


### V7 voting migration applied — 2026-09-15

The user ran the patched `supabase/arena-v7-retention.sql` from branch `codex/battle-arena-v6` in the target Supabase project and reported: `Success. No rows returned`.

This is the expected SQL Editor result for transactional DDL and means no execution error was reported. It does not by itself verify object presence, RLS, grants, or RPC availability. The next required action is to run `supabase/arena-v7-post-migration-check.sql` and review its single result row.

Anonymous Sign-Ins and Bot and Abuse Protection/CAPTCHA remain disabled. No importer function has been deployed and the database still had zero eligible Trending memes at the last data check.


### Post-migration verification passed — 2026-09-15

The user ran `supabase/arena-v7-post-migration-check.sql` and returned the CSV generated at `2026-09-15 10:13:08+00`.

Verified results:

- All V7 tables exist: `arena_entries_v7`, `arena_votes_v7`, and `arena_winners_v7`.
- RLS is enabled on all three V7 tables.
- No direct `anon` or `authenticated` grants exist on the V7 tables.
- All five V7 functions exist.
- Importer columns `reddit_id`, `reddit_score`, and `source` exist.
- No unexpected direct V7 table grants were returned.
- RPC grants match the design: `arena_state_v7` is executable by `anon` and `authenticated`; `arena_vote_v7` is executable only by `authenticated`; `arena_week_v7` is public. The privileged finalizer and standings functions are not exposed to client roles.

Database schema installation and static permission verification therefore passed. Runtime voting, anonymous Auth, CAPTCHA, importer deployment, real Trending data, concurrency, and season finalization are still unverified.


### Importer payload compatibility fix — 2026-09-15

Before deploying the Edge Function, its insert payload was compared with the verified production `memes` schema. Two blockers were found and corrected in `supabase/functions/arena-import-v6/index.ts`:

- The importer did not supply `memes.id`, which is non-null and has no reported default. New rows now receive a stable ID in the form `reddit-<reddit_id>`.
- The importer supplied an `origin` property, but the verified table has no `origin` column. That unsupported property was removed.

Without these corrections, the PostgREST insert would have been rejected. The Edge Function is still not deployed and has not been invoked against MemeAPI or the database.


### Current Edge Functions editor compatibility — 2026-09-15

The user supplied a screenshot of the current Supabase browser editor. Its active entry point is `index.ts` and its runtime uses the current `@supabase/server` `withSupabase` handler format. The user had added a separate `arena-import-v6.ts` file while `index.ts` still contained the Hello World template; that extra file would not execute.

The repository importer was updated to the current runtime format:

- `index.ts` is the intended entry point.
- Uses `withSupabase({ auth: "none" })`.
- Requires JWT verification to be disabled at deployment.
- Performs its own request authentication using the high-entropy `ARENA_IMPORT_SECRET` and `x-arena-import-secret` header.
- Uses the runtime-provided `ctx.supabaseAdmin` client, so project URL and database secret-key environment variables do not need to be manually copied into function secrets.
- Uses an idempotent `reddit_id` upsert with duplicate ignoring.

The function has still not been deployed or invoked.


### Importer deployed and secret configured — 2026-09-15

The user confirmed both of the following in the target Supabase project:

- Edge Function deployed with the exact name `arena-import-v6`.
- Custom function secret `ARENA_IMPORT_SECRET` created and saved.

The secret value was not shared in the conversation or repository. Deployment has not yet been proven by an authorized invocation, function logs, or inserted Trending rows. The next gate is one controlled POST request with the `x-arena-import-secret` header, followed by a database count check.


### Importer deployment-name correction — 2026-09-15

A subsequent Supabase Functions screenshot contradicted the earlier verbal confirmation. The deployed function is actually named `swift-processor`, not `arena-import-v6`. It showed two deployments under that incorrect name.

Therefore the importer is **not yet deployed under its required stable name**. Do not configure scheduling against `swift-processor`. Keep it temporarily until a correctly named `arena-import-v6` deployment has been created and tested; delete the incorrect function only afterward. The project-level `ARENA_IMPORT_SECRET` was reported configured but has not yet been runtime-tested.
