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


### Correct importer deployment verified — 2026-09-15

A Functions-list screenshot verified the final deployment-name state:

- `arena-import-v6` exists with one deployment.
- The incorrectly named `swift-processor` function was deleted by the user.
- The screenshot showed exactly one Edge Function in the project.

This corrects the prior uncertain deployment record. Runtime invocation, JWT-verification configuration, external source access, database inserts, and function logs remain unverified.


### Importer unauthorized-access test passed — 2026-09-15

After disabling legacy JWT verification, the user invoked `arena-import-v6` with an unauthenticated POST request and received HTTP 401 with body `Unauthorized`. The response included a Deno execution ID, confirming the request reached the Edge Function and was rejected by its custom-secret check.

The user then accidentally entered the example JSON response at the shell prompt, producing a local zsh `no matches found` error. That shell error is unrelated to Supabase. An authorized importer invocation has not yet been demonstrated.


### First authorized importer test diagnosed — 2026-09-15

The first authorized POST reached the function and returned `{"inserted":0,"failures":[]}`. A follow-up database query confirmed the table remained at 14 total rows, zero Trending rows, and zero non-null Reddit IDs.

Live MemeAPI response inspection identified the cause: current `postLink` values use the short form `https://redd.it/<reddit_id>`, while the importer accepted only `reddit.com/.../comments/<reddit_id>`. Every otherwise-valid candidate was filtered out without being classified as a source failure.

The importer was patched to accept and parse both allowlisted Reddit URL formats while still rejecting unrelated hosts. The corrected version must be redeployed before retesting.


### Authorized importer runtime test passed — 2026-09-15

After redeploying the short-link parser fix, the user invoked `arena-import-v6` with the configured custom secret. The function returned:

```json
{"inserted":15,"failures":[]}
```

This verifies custom-secret authentication, Edge Function execution, MemeAPI access, candidate filtering, admin database access, and insertion of 15 rows without reported subreddit-source failures. A follow-up database query is still required to confirm those rows have `kind='trending'`, non-null Reddit IDs, current timestamps, valid HTTPS images, and appear in `arena_standings_v7`.


### Imported Battle eligibility verified — 2026-09-15

The user ran the post-import eligibility query. Verified counts:

- Total memes: 29
- `kind='trending'` memes: 15
- Rows with non-null `reddit_id`: 15
- Reddit imports with valid HTTPS images: 15
- Rows returned by current-week `arena_standings_v7(arena_week_v7())`: 15

The complete sourcing-to-standings path is therefore working for the first controlled import. Automatic scheduling is not configured yet. Anonymous Auth, CAPTCHA, real client voting, concurrency, and weekly finalization remain unverified.


### Turnstile Battle integration — 2026-09-15

The user supplied the public Cloudflare Turnstile site key. It was added only to the Daily Meme Battle authentication path in `explained meme/index.html`.

Implementation details:

- Turnstile loads lazily only when a live visitor needs a new anonymous Supabase session.
- Offline preview does not load Turnstile and remains network-free.
- Existing anonymous sessions and refresh-token renewals do not trigger another challenge.
- Uses explicit execution with interaction-only appearance.
- The returned token is sent in Supabase Auth's required `gotrue_meta_security.captcha_token` request field.
- Load, verification, and timeout failures produce visible voting errors.
- The public site key is present in frontend code by design. The Turnstile secret key is not in GitHub and must be entered only in Supabase Auth configuration.

The mocked Battle test was extended to verify the CAPTCHA token in the anonymous signup request. All 41 assertions passed, including offline no-network/no-persistence checks and existing voting behaviour.

Do not enable CAPTCHA until its secret is configured in Supabase. Then enable CAPTCHA and Anonymous Sign-Ins together and perform a live incognito vote test.


### Supabase Auth and CAPTCHA enabled — 2026-09-15

The user confirmed both target-project settings were enabled after the frontend Turnstile integration was committed:

- Authentication → Anonymous Sign-Ins: enabled.
- Authentication → Bot and Abuse Protection: enabled with Cloudflare Turnstile and the private Turnstile secret.

The secret value was not shared in the conversation or repository. Configuration presence is user-reported and has not yet been verified by a live anonymous signup or vote. The next release gate is a Cloudflare preview deployment on an allowlisted Turnstile hostname, followed by an incognito vote test and database confirmation.


### Localhost Turnstile test hostname — 2026-09-15

Cloudflare Pages inspection showed the site is manually deployed and is not connected to its Git repository. All visible deployments were production uploads from `main`; no PR/branch preview exists. Connecting Git at this stage was rejected as unsafe because it could redeploy a repository version that has not been proven identical to the current live bundle.

The user added `localhost` to the existing Cloudflare Turnstile widget's allowed hostnames, while retaining production hostnames. This permits a local HTTP server to test the branch frontend against real Supabase Auth and voting without changing the live website. Remove `localhost` from the widget after testing is complete.


### First live browser vote and follow-up fixes — 2026-09-15

The branch was served from `http://localhost:8000` with localhost allowlisted in Turnstile. The user confirmed that real memes loaded, anonymous Auth/Turnstile voting worked, ten votes completed, and each confirmed vote advanced immediately.

The test exposed two UX problems:

- Share did not work in the tested desktop browser.
- Extra rounds remained visually stuck at 10/10 and eventually exhausted the finite set of unique daily pairs without explaining progress.

Implemented fixes in `explained meme/index.html`:

- Share now tries the native share sheet, falls back to Clipboard API, then falls back to a manual copy prompt.
- Shared live links always point to `https://explained.meme/#battle`, not localhost.
- The daily achievement remains 10/10 while a separate extra-pick count is displayed.
- The round label advances as `EXTRA PICK 1`, `EXTRA PICK 2`, etc.
- The exhausted state reports the completed extra-pick count and explains that no unseen eligible daily matchups remain.

### Legacy browser uploader removal

The user chose the recommended security path instead of preserving the legacy `?admin` uploader. Removed:

- The hidden admin upload markup.
- URL/hash/localStorage admin gating.
- The Ctrl+Shift+A reveal shortcut.
- Direct browser uploads to the Templates storage bucket.
- The associated direct browser insert/retry logic for `public.memes`.

Normal content reading and the V7 Battle RPC flow remain.

This removal does not by itself close the underlying legacy database/storage permissions. Added read-only `supabase/arena-v7-legacy-write-preflight.sql` to inspect relevant `memes` and `storage.objects` policies, direct client grants, and affected buckets before writing a lockdown migration.

The mocked Battle suite passes all 41 assertions. The test now also fails immediately if the removed admin uploader markers reappear.


### Legacy-write preflight reviewed and lockdown prepared — 2026-09-15

The user returned the CSV from `supabase/arena-v7-legacy-write-preflight.sql`. It confirmed:

- `public.memes` had public INSERT and two public UPDATE policies.
- Both `anon` and `authenticated` held every table privilege on `public.memes`, including INSERT, UPDATE, DELETE and TRUNCATE.
- Storage policy `Allow insert 1psdoj_0` used `WITH CHECK (true)`, allowing a client upload without restricting the bucket.
- Storage policy `Allow upload 1twzac9_0` allowed public uploads to the `Templates` bucket.
- Existing Storage SELECT policies are bucket-scoped. The `memes` and `Templates` buckets are public; `Trending` is private.

Added `supabase/arena-v7-lockdown-legacy-writes.sql`. It has **not** been executed.

The migration:

- Drops the three legacy public write policies on `public.memes`.
- Revokes non-read table privileges on `public.memes` from `anon` and `authenticated`.
- Explicitly preserves SELECT access needed by the existing site.
- Drops both public Storage upload policies.
- Preserves Storage read policies and does not revoke the standard `storage.objects` table grants, because Supabase Storage combines those grants with RLS.
- Includes fail-closed assertions; if any client-facing write policy or direct `memes` write privilege remains, the transaction rolls back.

Compatibility impact is intentional: any remaining legacy browser code that directly updates `memes.elo`, `wins`, `losses`, or other meme fields will stop persisting. Daily Meme Battle V7 is unaffected because it votes through `arena_vote_v7`. The server importer is unaffected because it uses the admin client. Browser uploads to Templates are intentionally disabled because the uploader was removed.

Next action: run the complete lockdown SQL in Supabase SQL Editor, then rerun `supabase/arena-v7-legacy-write-preflight.sql` and return its CSV for verification.


### Legacy public-write lockdown executed — 2026-09-15

The user ran the complete `supabase/arena-v7-lockdown-legacy-writes.sql` migration in the target Supabase project and reported `Success. No rows returned`.

This means Supabase reported no SQL execution error and the migration's fail-closed assertions did not abort the transaction. It is strong evidence that the identified public `memes` write privileges/policies and public Storage write policies were removed, while intended reads were preserved.

This result is not the final independent verification. The next required action is to rerun `supabase/arena-v7-legacy-write-preflight.sql`, export the single result row as CSV, and verify the post-lockdown policy/grant state.


### Post-lockdown security verification passed — 2026-09-15

The user reran `supabase/arena-v7-legacy-write-preflight.sql` after executing the lockdown and returned the CSV generated at `2026-09-15 12:24:33+00`.

Verified final state:

- `public.memes` now has exactly one relevant policy: public SELECT through `public_read_memes_table`.
- `anon` and `authenticated` now have only SELECT on `public.memes`.
- The public INSERT policy and both public UPDATE policies are absent.
- All direct INSERT, UPDATE, DELETE, TRUNCATE, REFERENCES, and TRIGGER privileges on `public.memes` are absent for both client roles.
- Both Storage INSERT policies are absent, including the unscoped `WITH CHECK (true)` policy.
- Only Storage SELECT policies remain for the inspected buckets.
- The standard direct grants on `storage.objects` remain. This is expected in Supabase: RLS controls API access, and no client-facing write policy now authorizes uploads or mutations.
- Bucket configuration is unchanged: `memes` and `Templates` are public, while `Trending` is private.

The identified legacy public-write exposure is closed. Public reads remain available. Daily Meme Battle V7 RPC voting and the admin importer are not dependent on the removed permissions.

Remaining release work is separate: retest the branch in the browser after the share/extra-round fixes, configure automatic importer scheduling, test season finalization, and establish a safe Cloudflare deployment path.


### Daily-ten hard stop and stronger vote feedback — 2026-09-15

The user tested a previously downloaded local ZIP and reported that extra voting repeated the same limited meme pool, daily progress remained at 10/10, sharing still appeared broken, and the vote-confirmation box lacked visibility. EXPLAINED remained correct. The old ZIP did not contain the branch's prior extra-count/share fixes; downloaded files do not update automatically.

Product decision: optional endless extra rounds were removed. Repetition after the daily achievement weakens the finite daily loop and reduces the reason to return. Daily Meme Battle now ends at ten confirmed votes and displays: `Come back tomorrow for fresh matchups.`

The 10/10 result intentionally persists through refresh in the same browser and UTC day. This prevents refreshing from resetting or farming the daily goal.

Frontend changes:

- Removed the `Keep battling` action from the completed result.
- Preserved the result card, share action, backed meme and leaderboard.
- Increased the vote-feedback box size, border contrast, background contrast, weight and shadow.
- Kept the previously implemented native-share, Clipboard API, legacy-copy and manual-prompt fallbacks.
- Did not change database permissions. The verified legacy-write lockdown remains active.

GitHub initially blocked replacement of the large legacy single-file bundle because unrelated dormant direct Supabase write code still exists elsewhere in V5.2. The user explicitly approved replacing the current branch HTML for these scoped Battle changes while requiring the database permissions to remain locked.

Verification:

- Updated the mocked suite with a `daily session stops at ten` assertion.
- All 43 assertions passed against the current GitHub HTML.
- Commits: `eb2caf5e897aa07842bac66143971a4be3af18f5` (frontend) and `589fa76edf0621672b0cd01c104b0f23847bd91f` (test).
- No production deployment was performed.

A valid retest requires downloading a fresh ZIP of `codex/battle-arena-v6`; the user's existing local folder will not receive these commits.


### Reliable share panel, crowd-threshold clarity and logo copy — 2026-09-15

The user retested the current Battle and confirmed the ten-vote stop, persisted progress, meme loading and EXPLAINED section work. Two remaining issues were reported: the share action still appeared non-functional in the tested browser, and the crowd-agreement percentage was not shown. The user also requested the logo tagline change from `FUNNY FOREVER` to `FOREVER FUNNY`.

Implemented:

- Replaced dependence on the native browser share sheet with an always-visible in-page share dialog.
- The dialog contains selectable result text, a Copy action, a WhatsApp link, an Email link and manual Command+C guidance.
- Uses the fixed canonical live URL `https://explained.meme/#battle`.
- Retains honest low-sample behaviour. A percentage is shown only when the backend returns at least five earlier votes by other visitors on that exact pair.
- The low-sample state is now explicit and prominent: `CROWD RESULT LOCKED · This exact matchup needs 5 earlier votes.`
- A real result is shown prominently as `XX% OF EARLIER VOTES AGREED WITH YOU`.
- Changed the header tagline to `FOREVER FUNNY`.

The missing percentage in the test was caused by insufficient exact-pair voting history, not lost data or a display failure. Fabricated percentages were not introduced.

Verification:

- Added a test that completes the daily ten, activates Share, and requires the visible fallback panel and Copy action.
- Updated crowd-feedback expectations for both low-sample and real-consensus cases.
- All 44 mocked assertions pass against the current GitHub HTML.
- Frontend commits: `5caf0d6818f212e0a5be6c22bf0d13ccfc98d62f` and `8c6835a8c961af7150c37beafc822211eb0f95d5`.
- Test commits: `a91873e3ccddeb0d2afe68f0570125629814c82e` and `aa2e85e0dfe4c8a6cb11e0a8f5868079c9cbc27d`.
- No production deployment was performed. A fresh branch ZIP is required for browser retesting.


### Share-copy confirmation and larger header logo — 2026-09-15

The user verified that voting and the new share panel work. Copying succeeded but closed the panel immediately, providing weak confirmation. The user also requested a larger header logo.

Implemented:

- Copying a result no longer closes the share dialog.
- The Copy button changes to `Copied!` after a successful clipboard operation.
- The copied text remains visible for inspection or manual copying.
- Increased the responsive logo heights from 48/56/72 px to 56/68/88 px at mobile/small/desktop breakpoints.
- Added regression guards requiring the persistent share panel and copied-confirmation state.
- All 44 mocked Battle assertions pass.
- Frontend commit: `02f88d4219cbcbe8b03a0e7688dec6858c0514bc`.
- Test commit: `afeabb68faa65b870927c0ae7ea7fca19155a141`.
- No production deployment was performed.


### Header logo sizing regression corrected — 2026-09-15

The attempted logo enlargement used new arbitrary Tailwind classes (`h-[56px]`, `sm:h-[68px]`, and `md:h-[88px]`). This site ships a precompiled CSS bundle, so those new class names had no generated rules. The image therefore fell back to its large natural dimensions and dominated the page.

After explicit user approval for another full single-file replacement, the unreliable classes were removed and replaced with a scoped `.site-logo` rule:

- Mobile: 56px height.
- Small screens: 64px height.
- Desktop: 80px height.
- Width remains automatic and viewport-constrained.

The database permission lockdown was not changed. The explicit CSS was verified in the committed HTML and all 44 mocked Battle assertions pass.

Commit: `0ff52179e8267dde23f6c898244f49a4e0c68447`.

No production deployment was performed. Browser verification requires a fresh branch ZIP.


### Certified Funny security audit and backend migration prepared — 2026-09-15

The Certified Funny tab was audited before deployment. Its current rating handler is not safe or functional after the legacy-write lockdown:

- It updates React state immediately, so the interface claims success before the server confirms anything.
- It sends an unauthenticated direct `PATCH` to `public.memes`.
- It does not await the request or inspect the HTTP response.
- Its empty `catch` suppresses failures.
- Because direct client writes to `public.memes` are now correctly revoked, ratings appear to work but do not persist after reload.
- Concurrent ratings would also lose updates because the browser calculates and overwrites the aggregate.

Added `supabase/certified-funny-v1.sql` as the secure repair backend. It has not yet been executed.

The migration provides:

- Immutable `certified_funny_votes_v1` records with RLS and no direct client access.
- Authenticated anonymous voting through `certified_funny_rate_v1`.
- Rating validation from 1 through 10.
- One rating per identity, meme and UTC day.
- Idempotent request UUID handling.
- Per-identity minute rate limiting.
- Row locking and an atomic server-side average/count update.
- Validation that only `kind='funny'` records can be rated.
- Fail-closed permission assertions.
- No reopening of direct `public.memes` writes.

Commit: `1fedd480d0d181ffa63d325260b3557ce6724ad1`.

Required order: run this SQL in Supabase, confirm success, then replace the Certified Funny frontend handler with authenticated RPC calls and visible saving/success/failure states. Do not deploy the current Certified Funny handler.


### Certified Funny V1 backend migration applied — 2026-09-15

The user ran the complete `supabase/certified-funny-v1.sql` migration in the target Supabase project and reported `Success. No rows returned`.

This means Supabase reported no SQL error and the migration's fail-closed permission assertions did not abort the transaction. The secure rating table and RPC are expected to be installed, with no direct client-table access and no reopening of legacy `public.memes` writes.

This is not yet a completed Certified Funny release. The current frontend still uses the broken legacy direct-PATCH handler and must be replaced with the authenticated `certified_funny_rate_v1` RPC before deployment. Runtime persistence, duplicate-vote handling, error display and concurrent ratings remain to be tested.


### Certified Funny product and monetization clarification — 2026-09-15

User clarified:

- Certified Funny contains a personal archive of funny pictures saved over many years from many sources.
- The desired rating inventory is larger than the Battle: approximately 25 available ratings per day.
- Licensing/provenance of the saved images is unknown.
- The long-term objective is passive income, potentially involving a screensaver product.

Product direction recorded:

- Treat 25 as the available daily deck, not a mandatory completion threshold.
- Use progressive milestones at 5, 10 and 25 ratings to serve both casual and heavy visitors.
- Certified Funny should provide immediate comparison, rating progress, favourites and taste/profile rewards after sufficient data.
- Daily Meme Battle drives repeat visits; Certified Funny gathers evergreen preference data; EXPLAINED drives discovery; a rights-safe screensaver is the potential paid conversion.
- Do not sell or redistribute the existing unknown-rights image archive. Saved/downloaded status does not establish commercial reproduction rights.
- The safest initial paid product is screensaver software with bring-your-own-folder support, plus only original, public-domain or explicitly commercially licensed starter content.
- Validate demand with a waitlist or preorder before building a native screensaver application.
- Advertising is a traffic-scale model, not a credible early primary revenue source.
- Revenue forecasts must be scenario-based until real monthly users, pageviews, geography, return rates and conversion data exist.

The secure Certified Funny backend has been installed, but the frontend RPC integration remains blocked pending explicit user approval for another replacement of the legacy single-file HTML.


### Clean standalone Certified Funny V1 page — 2026-09-15

Repeated attempts to patch the Certified Funny handler inside the 462 KB generated V5.2 bundle were rejected because full-file replacement preserves unrelated legacy write/interceptor and DOM-patching code. The safer architecture was approved: build the secured experience as a clean standalone page before changing navigation.

Added `explained meme/certified-funny.html`.

Implemented:

- Uses only the installed `certified_funny_rate_v1` RPC for ratings.
- Contains no direct `PATCH` or other browser write to `public.memes`.
- Reuses the Battle's `arena-v6-session` anonymous Supabase session.
- Creates a new anonymous session through the existing Turnstile configuration when needed.
- Waits for an authenticated server confirmation before changing the score, progress or current picture.
- Shows visible saving, confirmed, duplicate and failed-rating messages.
- Blocks double submission while a rating is pending.
- Uses a deterministic daily deck of up to 25 funny pictures.
- Persists same-day browser progress.
- Adds 5, 10 and 25 rating milestones; 25 is the full deck, not the only useful completion point.
- Shows a live top-ten community leaderboard.
- Uses text nodes for database titles/counts instead of interpolating them into HTML.
- Uses only database columns already verified in the project.
- Reuses the existing logo asset and visual language with explicit bounded responsive sizing.

Added `tests/certified-funny-v1.test.mjs`. All 14 checks pass.

Commits:

- Page: `b9e2c1f0271ac5f4190b507ddbb3ea989464ebd9`.
- Verified-column correction: `a76070c2490b0f1858ad2f6356d3a66694471ae4`.
- Tests: `65f05bd82dc75dbe3a5b23b0b3c7416dc44ea40e`.

Limitations and next gate:

- The legacy Certified Funny tab inside `index.html` still exists and remains broken after the database lockdown.
- The new page is not yet linked from that legacy navigation because doing so still requires a separately reviewed integration change.
- No production deployment occurred.
- Runtime rating persistence against Supabase has not yet been browser-tested.
- Test locally at `http://localhost:8000/certified-funny.html`, confirm a rating changes the server value, then refresh and confirm the value persists before integrating navigation.


### Certified Funny empty inventory and header correction — 2026-09-15

The first browser test of the standalone page showed no available pictures and the `FOREVER FUNNY` tagline below the logo.

Diagnosis:

- The legacy tab's six funny pictures were embedded demo fallbacks, not proof of six real `kind='funny'` database rows.
- The new page intentionally uses only real database inventory, so the archive must be imported before rating can work.
- The standalone brand anchor did not use a horizontal layout, placing the tagline below the block-level logo.

Implemented:

- Header brand now uses an explicit flex row, keeping `FOREVER FUNNY` beside the logo with responsive spacing.
- An empty database now shows `0 / 0`, changes the header status, and explicitly reports: `No funny pictures have been imported yet. Owner upload required.`
- Added read-only `supabase/certified-funny-import-preflight.sql` to inspect the real Funny row count, `memes` Storage bucket object count, complete `public.memes` column/default/nullability definitions, recent Storage metadata and relevant constraints before creating an owner-only bulk-import migration.
- No public upload permission was restored.
- All 16 standalone Certified Funny regression checks pass.

Commits:

- Header and empty state: `8199d7235b8cca5688dacd70c476368726e38a6b`.
- Import preflight: `d51ece1007e3261dafde7720b20de4f6a9eb05d1`.
- Test changes: `eda7048218534a74440346ecb4444306f58a184d` and formatting correction `5148a8cd265f31fa1671690a50fb8eb2826f46b4`.

Next action: run the read-only import preflight in Supabase and return its CSV. After reviewing it, create a narrow owner workflow: bulk upload files through the Supabase dashboard to the existing `memes` bucket, then run a reviewed SQL importer that creates only missing `kind='funny'` metadata rows.


### Certified Funny import preflight reviewed — 2026-09-15

The returned preflight CSV, generated at `2026-09-15 16:23:13+00`, confirmed:

- Zero real `public.memes` rows with `kind='funny'`.
- Eighteen existing objects in the owner-controlled `memes` Storage bucket.
- All 18 reported objects are JPEG images.
- `public.memes.id` is required text with no default.
- All other fields needed for the import are nullable or have defaults.
- `avg_rating` is double precision with default 0; `ratings_count`, ELO, wins and losses also have safe defaults.
- The only primary key is `id`; no unique image-path constraint exists.

This proves the legacy tab's six pictures were embedded demo fallbacks. The owner does not need to re-upload the existing 18 files; they need metadata rows.

Added `supabase/certified-funny-import-existing-storage.sql`:

- Creates stable IDs as `funny-` plus MD5 of the Storage object name.
- Creates only `kind='funny'` metadata for supported images in the `memes` bucket.
- Stores the object name in `image_uri`.
- Marks the source as `owner_storage_import`.
- Does not upload, rename, overwrite or delete Storage objects.
- Uses `ON CONFLICT DO NOTHING`, so rerunning it does not duplicate rows.
- Includes a malformed-row assertion that rolls back on failure.

Added read-only `supabase/certified-funny-import-check.sql` to verify Storage count, Funny row count, supported images missing metadata and malformed imports.

Commits: `099a9159ef9c5a35d2ae99458b086a52ac9de98b` and `27bc786048b6b1ced7513664b25a32e206f42f24`.

Neither SQL file has been executed. Next: run the importer, then the verification query and return its single result row.


### Certified Funny clean Storage upload — 2026-09-15

The user chose to discard the previous 18-file test inventory and start with a clean Funny archive. They reported uploading 50 selected images to the existing `memes` Storage bucket.

This is user-reported and not yet independently verified. No metadata importer has been reported executed after this upload.

Next required actions:

1. Run `supabase/certified-funny-import-existing-storage.sql`.
2. Run the read-only `supabase/certified-funny-import-check.sql`.
3. Verify 50 Storage objects, 50 supported images, 50 `kind='funny'` rows, zero supported images missing metadata and zero malformed import rows.
4. Only then retest `certified-funny.html` ratings and refresh persistence.


### Certified Funny import verification found stale metadata — 2026-09-15

The user ran `supabase/certified-funny-import-existing-storage.sql` after uploading the new 50-picture inventory, then returned the output of `supabase/certified-funny-import-check.sql`.

Verified result at `2026-09-15 16:48:52+00`:

- Storage objects: 50.
- Supported Storage images: 50.
- Funny metadata rows: 100.
- Supported images missing metadata: 0.
- Malformed imported rows: 0.

Conclusion: all 50 current uploads were imported correctly, but 50 metadata rows from the deleted prior Storage inventory still remain. The page is not yet a clean 50-picture inventory.

Added `supabase/certified-funny-remove-stale-metadata.sql`. It deletes only `kind='funny'`, `source='owner_storage_import'` metadata whose exact `image_uri` no longer exists in the `memes` Storage bucket. It does not delete current files, votes, unrelated rows or change any grants/RLS policies. The transaction fails closed if stale owner-import metadata remains.

Cleanup commit: `f8e2f77c19fe49affd2212f9b3eeb4d0ff08eaea`.

Next:

1. Run `supabase/certified-funny-remove-stale-metadata.sql`.
2. Run `supabase/certified-funny-import-check.sql` again.
3. Require counts of 50 / 50 / 50 / 0 / 0 before browser rating tests.


### Certified Funny orphan source identified and cleanup corrected — 2026-09-15

A source-group diagnostic established the exact composition of the 100 Funny rows:

- 50 valid rows use `source='owner_storage_import'`, with 50 unique `image_uri` and `image_url` values.
- 50 unusable orphan rows have `source IS NULL`, zero `image_uri` values and zero `image_url` values.

The first cleanup correctly removed nothing because it deliberately targeted only stale `owner_storage_import` rows. Its earlier assumption that the extra records were stale owner imports was disproven.

Updated `supabase/certified-funny-remove-stale-metadata.sql` to delete only the two verified broken patterns: stale owner imports without a matching Storage object, and `kind='funny'` rows whose source, image URI and image URL are all null. Valid current uploads, votes, unrelated rows, grants and RLS policies remain untouched. The script retains a fail-closed post-delete assertion.

Correction commit: `a9b03c86f60d2612997e6ae634dd1960e4f17c89`.

Next: rerun the updated cleanup file, then rerun `supabase/certified-funny-import-check.sql`. Expected counts remain 50 / 50 / 50 / 0 / 0.


### Certified Funny clean inventory verified — 2026-09-15

The user ran the corrected cleanup and returned the final `certified-funny-import-check.sql` result generated at `2026-09-15 16:57:08+00`.

Verified counts:

- Storage objects: 50.
- Funny metadata rows: 50.
- Supported Storage images: 50.
- Supported images missing metadata: 0.
- Malformed imported rows: 0.

The previous 50 unusable null-source/null-image orphan rows are gone. The current 50-image owner inventory and its metadata are aligned. No database permissions were opened or changed by this cleanup.

Next release gate: browser-test `http://localhost:8000/certified-funny.html`; verify all images load, one 1–10 rating receives server confirmation, the aggregate changes, refresh preserves the server result, and a second same-day rating on the same picture is rejected.


### Certified Funny rapid-rating failure corrected — 2026-09-15

Live local testing succeeded through 20 confirmed ratings, then picture 21 returned the generic `Rating was not saved. Please retry.` state. Inspection proved this matched the backend's per-identity ceiling of 20 ratings in one minute, not a frozen interface. The limit contradicted the intended rapid 25-picture daily deck.

Changes:

- Raised the authenticated RPC abuse ceiling from 20 to 40 ratings per rolling minute, allowing the full 25-picture deck at a fast pace while retaining one rating per identity/meme/UTC day.
- Kept immutable vote storage, authentication, idempotency, validation, direct-write revocation and RLS unchanged.
- Frontend now recognizes PostgreSQL code `54000` and instructs the visitor to wait one minute before retrying the same picture.
- Added a regression assertion for the actionable rate-limit message.
- Verified the committed frontend contains the error mapping, the migration contains the 40/minute ceiling and the previous 20/minute condition is absent.

Commits:

- Frontend: `1df64eae11aa3ad36c78acce1b566253deb50553`.
- Backend migration: `e5e2b27a18297370943f2d9f00322690710d3b4c`.
- Test: `e82533ac01829c2827869607b90b085336fdfe57`.

Deployment requirement: rerun the updated `supabase/certified-funny-v1.sql` in Supabase so the already-installed RPC receives the new ceiling, and use a fresh branch download for the updated frontend message.


### Certified Funny Turnstile interaction repaired — 2026-09-15

Fresh local testing displayed Cloudflare's interactive `Verify you are human` checkbox, but the visitor could not click it. The root cause was an inline `pointer-events:none` rule on the full Turnstile host. The challenge rendered correctly but its own parent discarded pointer input.

The host now uses `pointer-events:auto`; it remains `display:none` outside authentication, so it cannot intercept normal page interaction. Added a regression assertion requiring the interactive rule and forbidding the blocking rule.

Verified on the committed branch:

- Turnstile host contains `pointer-events:auto`.
- No `pointer-events:none` remains in the standalone page.
- Regression guard is present.

Commits:

- Frontend: `7338df83e4cb200928f51b4cccc820a7e4368c06`.
- Test: `09f4d9393c5bc3e2e4bd68aac7a00ee187ba6423`.

No database schema, data, grants or RLS policies changed. Local retesting requires a fresh branch file/ZIP; refreshing an older extracted copy does not retrieve GitHub updates.


### Certified Funny uploaded filenames hidden — 2026-09-15

The user confirmed the previously blocked Turnstile prompt disappeared after refresh. This is expected after successful anonymous authentication because the Supabase session is cached locally; a challenge should not appear for every rating.

Uploaded filenames were visible as picture titles and leaderboard labels. These are storage implementation details, often ugly or revealing, and add no product value.

Changed the standalone page so every public label is a neutral deterministic `Funny #N`; raw database/upload filenames are no longer displayed in the current rating card or leaderboard. Image URLs and database identifiers remain functional internally. Added a regression assertion that forbids the previous title-based display logic.

Commits:

- Frontend: `e637457e3a432d50a93b7f2995779d0b8beec635`.
- Test: `c2e57bc303f11265eae33954e7435c90669f0461`.

No database or permission change was made. A fresh branch file/ZIP is required to see this frontend update locally.


### Certified Funny leaderboard full-image preview — 2026-09-15

The leaderboard's thumbnails were not actionable, preventing visitors from inspecting the pictures ranked as most funny. Every leaderboard row is now a semantic button that can be activated by mouse, touch or keyboard.

Selecting a row opens a native modal preview with:

- The full image using contained aspect-ratio rendering.
- Neutral `Funny #N` label and leaderboard rank.
- Community average and confirmed vote count.
- Close button, Escape support from the native dialog and backdrop-click closing.

Raw upload filenames remain hidden. Added regression guards for the full preview and keyboard-accessible row controls. The committed inline script parses successfully.

Commits:

- Frontend: `263a438764afee8788602e1b117e2034b98d0fcf`.
- Test: `bccaccba39701ab8f90edeef42d2c86f3efbff36`.

No database, authentication, rating or permission logic changed.


### Main navigation connected to secure Certified Funny page — 2026-09-15

After visual acceptance of the standalone Certified Funny experience, the main site's `CERTIFIED FUNNY?` navigation control was connected to `certified-funny.html`.

Scope:

- Only the `CERTIFIED_FUNNY` navigation action redirects to the standalone page.
- EXPLAINED, Daily Meme Battle, Screensaver, Live and Contact navigation behaviour remains unchanged.
- The old embedded Certified Funny render branch remains dormant in the monolith; removing it is deferred because it is unnecessary for routing and would expand regression risk.
- Added a regression guard requiring the secure standalone destination.
- Verified the redirect occurs exactly once.
- Verified every inline script in both `index.html` and `certified-funny.html` parses successfully.

Commits:

- Main navigation: `961144cc27c9c26cedac8b395a20b75745ad26da`.
- Regression guard: `e56d4e0e2662ac880ddc373f863aad31f18ce3f7`.

No database, authentication, rating, RLS or grant changes were made. Next gate: test navigation in a fresh local branch download, then run a complete pre-deployment smoke test across all public sections.


### Standalone free Screensaver V1 built; main navigation integration awaiting approval — 2026-09-15

The old embedded Screensaver tab mixed a usable browser slideshow button with owner-upload instructions and imaginary paid products that had no checkout or deliverable. That presentation was removed from the new standalone design.

Added `explained meme/screensaver.html` as a read-only public browser screensaver:

- Source filters: All, Explained, Trending and Funny.
- One dominant Start Screensaver action.
- Native browser fullscreen with safe fallback.
- Shuffle, top-rated and newest ordering.
- 8-, 15- and 30-second intervals.
- Pause, previous, next, close and keyboard controls.
- Optional Screen Wake Lock where supported.
- Automatic broken-image skipping.
- Picture count, honest new-since-last-visit state and top community score.
- Contextual paths from a slide to Daily Meme Battle, Certified Funny or Explained.
- No product cards, prices, owner-upload instructions or public write operations.
- Raw upload filenames are not displayed.
- First visit shows no fabricated freshness count.

Added `tests/screensaver-v1.test.mjs` with static regression checks. The committed inline script parses successfully and the verified page contains no POST, PATCH or DELETE requests.

Commits:

- Initial standalone viewer: `55d3e9cd3aed71609351ed7347a42c52d424b26a`.
- Honest freshness state: `011533ed7b9bbd8c0f067622112c31d516dd140d`.
- Screensaver test: `507351da9892353e39f86c818c7b94e36d2b9515`.

The attempted one-line redirect from the generated `index.html` was rejected because replacing that 462 KB file also resubmits unrelated dormant legacy direct POST/PATCH and fetch-interceptor code. No workaround was used. A prematurely added navigation assertion was removed in commit `a02f2511a3621449293549e6a9824e3151c328c9`, so the repository does not falsely claim integration.

Current state: the standalone page is ready at `screensaver.html`, but the main site's Screensaver button still opens the old embedded tab. Exact user authorization is required before replacing the current branch HTML solely to add the redirect, with the existing database permission lockdown remaining mandatory.


### Screensaver main navigation integration approved and completed — 2026-09-15

The user explicitly approved replacing the current branch HTML solely to connect Screensaver to `screensaver.html`, despite the dormant legacy write code, while requiring database permissions to remain locked.

Completed:

- The main site's `SCREENSAVER` navigation action now redirects to the standalone free viewer.
- The redirect occurs exactly once.
- The navigation regression assertion was restored.
- Every inline script in the main bundle and standalone Screensaver parses successfully.
- The standalone Screensaver contains no POST, PATCH or DELETE requests.
- No database schema, data, authentication, grants, RLS or Storage policies changed.

Commits:

- Main navigation: `c8164d31e55257d559d8426a5fafd80afe838e0c`.
- Regression guard: `29eae1c6167d8d3b1d5230364735ad2689d8eb46`.

The old embedded Screensaver render branch remains dormant inside the legacy bundle; the public navigation no longer reaches it.


### Screensaver fullscreen ratio and speed controls corrected — 2026-09-15

Local testing found that fullscreen images appeared stretched. The viewer previously assigned both `width:100%` and `height:100%` before applying `object-fit:contain`. Although contain should normally preserve ratio, intrinsic image sizing is more robust across fullscreen browser implementations.

Changed fullscreen images to `width:auto; height:auto; max-width:100vw; max-height:100vh; object-fit:contain`. The image now scales within the viewport without forcing both axes.

Replaced the previous 8/15/30-second timing choices with exactly:

- 3 seconds.
- 5 seconds.
- 10 seconds (default).
- 30 seconds.

Regression checks require intrinsic fullscreen sizing, forbid the previous forced dimensions and require the exact new timing set. The committed script parses successfully.

Commits:

- Screensaver: `183926bd3c4eb1a142be20ed42e41520a85bfeca`.
- Tests: `13ecfb3cfe45e020d757c3b54ac1e30ac05b307c`.

No main navigation, database or permission logic changed.


### Contact V1 honest delivery system prepared — 2026-09-15

The legacy embedded Contact form was diagnosed as non-functional and dishonest:

- It used Netlify form attributes while the site is hosted on Cloudflare Pages.
- It POSTed URL-encoded data to `/`, where no contact processor exists.
- It never checked `response.ok`.
- Its exception path still set the success state and displayed `Message sent! (preview mode)`.
- Therefore the UI could claim delivery when no email was sent.

Prepared a standalone replacement, not yet connected to main navigation:

- `explained meme/contact.html`: secure form with real pending/error/success states; success appears only after the Edge Function returns `accepted:true`.
- `supabase/functions/contact-v1/index.ts`: authenticated Supabase Edge Function that validates the user's live anonymous token and sends through Resend.
- `supabase/contact-v1.sql`: private RLS-enabled delivery metadata table with all client access revoked.
- `tests/contact-v1.test.mjs`: regression guards for honest confirmation, authentication, secret isolation, validation, rate limiting, idempotency and locked metadata.
- `CONTACT-V1-SETUP.md`: exact owner setup and inbox-test steps.

Security and reliability properties:

- Resend API key and destination/sender addresses exist only as Edge Function secrets.
- Resend idempotency key prevents duplicate delivery when a request is retried.
- Limits are three accepted/pending messages per 15 minutes and ten per 24 hours per authenticated anonymous identity.
- Honeypot, client/server length validation and restricted subject values are included.
- CORS is limited to production, localhost and this project's Pages preview pattern.
- Only request ID, anonymous sender ID, status, provider message ID and timestamps are stored; visitor name, email and message body are not stored in the site database.
- No direct client database writes are permitted.
- The committed standalone page script parses successfully and static security checks pass.

Commits:

- SQL metadata migration: `a7a8781f87552542b31daaf4315f11d21c1c1e0c`.
- Edge Function: `93739cfdc2452c57512edc3d59325110ecd27a56`.
- Contact page: `2745101643ddc7c88113ffefe7e931641c41cc1a`.
- Regression tests: `e76dfece9e3f70629e3e91abd45df7ec77b83222`.
- Setup guide: `6b99a6f938eb4a5418c00a4311e887a2712bbc83`.

External setup remains mandatory: verify `explained.meme` in Resend, create the sending API key, add `RESEND_API_KEY`, `CONTACT_TO_EMAIL` and `CONTACT_FROM_EMAIL` as Supabase secrets, run the SQL, deploy `contact-v1`, and prove delivery in Resend Logs and the real inbox. Main navigation must remain on the legacy page until that test passes.


### Contact V1 private delivery table applied — 2026-09-15

The user ran the complete `supabase/contact-v1.sql` migration in the target Supabase project and reported `Success. No rows returned`.

Supabase therefore reported no SQL error and the migration's fail-closed privilege assertion did not abort. The private `contact_deliveries_v1` metadata table and sender/time index are expected to be installed with RLS enabled and all direct public/anon/authenticated table access revoked.

This does not prove email delivery. Remaining gates are deploying `contact-v1`, disabling the legacy gateway JWT toggle because the function performs live `auth.getUser` validation itself, testing `contact.html`, verifying the send in Resend Logs and receiving the message in the configured inbox.


### Contact V1 Edge Function deployed — 2026-09-15

The user reported completing both deployment steps:

- Supabase Edge Function deployed with the exact name `contact-v1`.
- `Verify JWT with legacy secret` set to OFF.

This is the intended configuration. Disabling the legacy gateway verifier avoids incompatibility with current project tokens; it does not bypass authentication because `contact-v1` extracts the bearer token and validates it live through the project Auth service using `admin.auth.getUser(token)`. Invalid or missing identities receive HTTP 401.

User also previously confirmed that `RESEND_API_KEY`, `CONTACT_TO_EMAIL` and `CONTACT_FROM_EMAIL` are present as encrypted Supabase Edge Function secrets and that the Resend domain is verified.

Still unverified: actual browser submission, Resend acceptance/log entry, inbox arrival, reply-to behaviour and rate-limit behaviour. Main Contact navigation remains on the legacy page until the first three delivery checks pass.


### Contact V1 endpoint deployment visually verified — 2026-09-15

A Supabase Functions-list screenshot now verifies that an Edge Function with the exact endpoint slug `contact-v1` exists and has one deployment. The earlier user report that deployment was complete was inaccurate: the first three attempts created random slugs `bright-function`, `smart-function` and `smooth-responder`, which could not satisfy the frontend's fixed `/functions/v1/contact-v1` request.

The three accidental endpoints remain deployed and must be deleted after the correct endpoint passes the inbox test. They are not referenced by the website and unnecessarily expand the exposed function surface.

Still required before navigation integration:

- Confirm `contact-v1` has `Verify JWT with legacy secret` set to OFF.
- Retry `contact.html`.
- Confirm accepted status in the page.
- Confirm the message in Resend Logs and the destination inbox.
- Delete only `bright-function`, `smart-function` and `smooth-responder`; preserve `arena-import-v6` and `contact-v1`.


### Contact V1 browser submission accepted — 2026-09-15

The user confirmed `contact-v1` has `Verify JWT with legacy secret` OFF and completed a local browser submission through `contact.html`. The page displayed `Message accepted.` after several seconds.

This verifies:

- The browser could authenticate or reuse an anonymous Supabase session.
- CORS allowed the localhost request.
- The exact `/functions/v1/contact-v1` endpoint responded.
- The function returned HTTP success with `accepted:true`.
- The frontend did not show its success state before that response.

The delay can include Auth, network and Edge Function cold-start time. No performance conclusion should be drawn from one local submission.

Not yet independently confirmed: Resend log status, destination inbox arrival and Reply-To behaviour. Do not connect main navigation or call delivery complete until those checks pass.


### Contact V1 end-to-end email delivery verified — 2026-09-15

The user completed the end-to-end Contact V1 test and confirmed:

- The standalone page received `accepted:true` and displayed `Message accepted.`.
- Resend logged `POST /emails` with HTTP 200.
- The email arrived in the configured destination inbox.
- Using Reply addressed the visitor email entered in the form.
- The Resend API key is restricted to sending access.
- `contact-v1` has the legacy JWT gateway toggle OFF and performs its own live token validation.

This verifies the complete delivery path: browser → anonymous Supabase Auth → `contact-v1` → Resend → owner inbox, including Reply-To behaviour. Contact V1 is functionally ready for navigation integration.

Remaining cleanup/release steps:

- Delete only the accidental `bright-function`, `smart-function` and `smooth-responder` endpoints.
- Preserve `arena-import-v6` and `contact-v1`.
- Obtain explicit authorization to replace the generated branch HTML solely to redirect CONTACT to `contact.html`, because the large legacy bundle contains dormant direct-write code.
- Retest navigation from the main page after a fresh branch download.


### Main Contact navigation connected to verified Contact V1 — 2026-09-15

The user explicitly approved replacing the current branch HTML solely to connect Contact to `contact.html`, despite the dormant legacy write code, while requiring database permissions to remain locked.

Completed:

- The main site's `CONTACT` navigation action now redirects to the end-to-end verified standalone Contact V1 page.
- The redirect occurs exactly once.
- Added a regression guard requiring the verified standalone destination.
- Every inline script in the main bundle and `contact.html` parses successfully.
- The standalone form still requires HTTP success plus `accepted:true` and contains no Netlify fake-success path.
- No database schema, data, authentication configuration, grants, RLS or Storage policies changed.

Commits:

- Main navigation: `50b9a4abc4cb10c94d7dcd9cb1da6cad550c2529`.
- Regression guard: `4ce807ba7a75f9728a56fa7a02094001a51b4bff`.

The legacy embedded Contact branch remains dormant inside the monolith and is no longer reachable through public navigation. The accidental Supabase functions `bright-function`, `smart-function` and `smooth-responder` still require owner-confirmed deletion if not already removed.


### Production release merge — 2026-09-15

The user explicitly authorized deployment. Pull request #1 was marked ready and squash-merged into `main`.

Release source:

- Reviewed branch head: `6fa1d6679017d62fbf44d7b804e2ef08f9d38e2d`.
- Resulting main commit: `05df0c0c2929beb416adf49afe2201b97c280638`.
- Branch comparison immediately before merge: 133 commits ahead, 0 behind.
- Merge result: successful.

The Cloudflare Pages production upload has not yet been triggered from this workspace because the Cloudflare connection is not active. The production site must not be described as deployed until Cloudflare confirms a successful deployment and the live-domain smoke test passes.

Database permissions were not changed during the merge and remain locked. The accidental Supabase functions `bright-function`, `smart-function` and `smooth-responder` should be deleted if they still exist; preserve `arena-import-v6` and `contact-v1`.


### Cross-page navigation and header consistency fix — 2026-09-15

User testing after the release merge found three routing defects and inconsistent standalone header geometry.

Corrected on branch `codex/navigation-consistency-v1`:

- Certified Funny now links directly to `screensaver.html` and `contact.html` instead of incorrectly returning to the Explained view.
- Screensaver now links directly to `contact.html`.
- Removed the unfinished `LIVE` item from the main navigation. Its dormant legacy render code was left unreachable to minimize regression risk.
- Standardized the standalone logo at 80px desktop, 64px tablet and 56px mobile.
- Standardized brand-row height, horizontal logo/tagline alignment, 12px gap and tagline baseline across Certified Funny, Screensaver and Contact.
- Added `tests/navigation-consistency.test.mjs` to prevent route, LIVE-tab and header regressions.
- Fourteen targeted route/header/script checks passed against the committed branch.

Commits:

- Certified Funny: `5374dcb2074bc7e7d8bb5cb4d2af3a7897788f79`.
- Screensaver: `fcc9d0148729cefbc762d03e09d0a96ab6809e6a`.
- Contact: `35c571f7262bad1b3621f468768b165b1c37917d`.
- Main navigation: `5c8a2fd26eeb6c65f401a1138ebda2b0e487bdef`.
- Regression test: `e521ac147bae7749827db522861770703e26fb89`.

No Supabase schema, data, authentication setting, Edge Function, grant, RLS policy or Storage policy changed. Database permissions remain locked. This branch is not deployed until visual acceptance and a separate merge/deployment action.


### Navigation consistency fix merged for deployment — 2026-09-15

After local test-folder confusion, the user authorized deploying and checking the fix on the hosted site. Pull request #2 was marked ready and squash-merged into `main`.

- Reviewed branch head: `05b277d7f856cc225e83b1248899f20eff17f1c2`.
- Resulting main commit: `8861f8b32d22500566fd60a6b6a4102a280395e1`.
- Scope: cross-page links, removal of the public LIVE tab, standalone header/logo/tagline consistency and regression coverage.
- No Supabase schema, data, authentication, functions, grants, RLS or Storage permissions changed.

Cloudflare deployment and live-domain smoke testing remain external confirmation gates.
