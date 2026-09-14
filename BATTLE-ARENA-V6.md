# Battle Arena v6 — review build

## Scope
Only `explained meme/index.html` changes existing site code:
- Replace the Battle Arena render branch with isolated `ArenaV6`.
- Disable its obsolete parent keyboard-voting handler.
- Allow `#battle` links to open the arena.
- Add CSS exclusively under arena-specific classes.
All other existing HTML/JavaScript bytes reconstruct exactly to the base file.
V5.2 and old versions are untouched.

## Included
- Responsive two-card voting, contained images, expand dialog with native modal focus handling.
- Daily ten (UTC) with browser-persisted progress; extra rounds remain available.
- Imported-in-last-seven-days eligibility; no fabricated old-content fallbacks.
- Rating leaderboard available on mobile; refreshed after own confirmed votes.
- Back one meme and find it on return; arena sharing uses #battle.
- Local pairing history and exposure-aware pairing selection.
- Loading, empty, exhausted, image-error and backend-error states.
- A guarded atomic voting RPC with opponent-adjusted ratings.
- An optional server-side Reddit/MemeAPI importer; no visitor-triggered imports.

## Release steps — NOT executed by this PR
1. Review the actual Supabase schema and RLS policies. These were not available for inspection.
2. Apply `supabase/arena-v6-voting.sql` in a staging database.
3. Enable anonymous sign-ins in Supabase Authentication. Configure abuse controls and rate limits.
4. Audit direct UPDATE access on memes. Existing clients may still be able to overwrite elo/wins/losses.
   This migration intentionally does not revoke permissions used by other pages.
   Do not advertise tamper-resistant rankings until that separate policy audit is complete.
5. If no existing server importer is running, review/apply `supabase/arena-v6-import.sql`,
   deploy `supabase/functions/arena-import-v6/index.ts`, and schedule POST requests on the server
   (suggested cadence: hourly) with the x-arena-import-secret header.
   Set ARENA_IMPORT_SECRET as a server secret; use the platform-configured SUPABASE_URL and
   SUPABASE_SERVICE_ROLE_KEY. Never put either secret in the HTML.
   The function uses its own secret check; configure gateway authentication consistently.
   The unique index deliberately fails if existing Reddit IDs are duplicated: resolve those
   records manually, without dropping votes or resetting scores.
6. Run `node tests/arena-v6.test.mjs`.
7. Browser-test at 390px, 768px, and 1440px: cards, expand/Escape/focus, successful vote,
   failed vote, double-clicks, skip, UTC rollover, daily completion, backed pick and shared #battle link.
8. Test SQL with two concurrent votes and reversed duplicate pair submissions in staging.
9. Deploy the reviewed HTML using the existing Cloudflare Pages workflow. No hosting changes are included.

## Honest limits
- Voting intentionally refuses to count locally if auth/RPC is missing; it is not live until setup.
- Seven days means time added to this database, not Reddit post age. MemeAPI's random sample
  does not establish virality; sorting sample upvotes is not a comprehensive trending algorithm.
- No weekly seasons, archived champions, analytics instrumentation or report/moderation backend yet.
- Daily progress/backed pick is browser-local, not synced across devices. Storage clearing loses it.
- Anonymous identities can be recreated. The RPC rate limit is per identity, not bot-proof.
- Leaderboard is the fetched eligible top 200, not realtime across visitors; own votes update it.
- The server importer relies on MemeAPI and external images, with no image hosting/mirroring.
- Existing legacy scores are not reset. Proper ELO updates begin after this migration.
- The legacy site remains a bundled single HTML; this PR does not rebuild other pages.

## Verification performed
- All five resulting inline scripts parse.
- Ten mocked component checks pass: eligible pool, double-click guard, no direct PATCH,
  failed votes not counted, visible failure, confirmed votes counted and visible feedback.
- Byte reconstruction check confirms unrelated original content is preserved.
- No real database writes, SQL execution, scheduled imports, browser rendering or deployment
  were performed in this environment. Browser and staging checks remain release gates.
