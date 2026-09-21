import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";
import test from "node:test";

const sql = await readFile(new URL("../supabase/arena-v8-daily-pool.sql", import.meta.url), "utf8");
const importer = await readFile(new URL("../supabase/functions/arena-import-v6/index.ts", import.meta.url), "utf8");

test("playable pool contains one UTC import day while weekly standings remain available", () => {
  assert.match(sql, /arena_daily_pool_v8/);
  assert.match(sql, /s\.created_at >= p_day::timestamp at time zone 'UTC'/);
  assert.match(sql, /s\.created_at < \(p_day \+ 1\)::timestamp at time zone 'UTC'/);
  assert.match(sql, /arena_standings_v7\(w\)/);
});

test("state and voting share the same one-day availability fallback", () => {
  assert.match(sql, /if count_all < 2 then/);
  assert.match(sql, /if \(select count\(\*\) from public\.arena_daily_pool_v8\(today\)\)<2 then pool_day:=today-1/);
  assert.match(sql, /Contender expired/);
});

test("daily importer requests a larger sample and removes existing Reddit IDs before selecting 15", () => {
  assert.match(importer, /sub \+ "\/25"/);
  assert.match(importer, /\.in\("reddit_id", candidateIds\)/);
  assert.match(importer, /filter\(\(row\) => !existingIds\.has/);
  assert.match(importer, /slice\(0, 15\)/);
});
