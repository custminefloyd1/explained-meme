import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";
import test from "node:test";

const sql = await readFile(new URL("../supabase/arena-v7-daily-leaderboard.sql", import.meta.url), "utf8");
const html = await readFile(new URL("../explained meme/index.html", import.meta.url), "utf8");

test("daily leaderboard is computed server-side from today's votes", () => {
  assert.match(sql, /arena_daily_standings_v7/);
  assert.match(sql, /where v\.vote_day=p_day/);
  assert.match(sql, /r\.appearances>=3/);
  assert.match(sql, /daily_board/);
});

test("daily leaderboard preserves locked table permissions", () => {
  assert.match(sql, /revoke all on function public\.arena_daily_standings_v7\(date\) from public,anon,authenticated/);
  assert.doesNotMatch(sql, /grant\s+(select|insert|update|delete)\s+on/i);
  assert.doesNotMatch(sql, /create\s+policy/i);
});

test("battle UI exposes daily and weekly boards without claiming monthly or yearly", () => {
  assert.match(html, /Show today's leaderboard/);
  assert.match(html, /Show this week's leaderboard/);
  assert.match(html, /Weighted score balances win rate with vote volume/);
  assert.doesNotMatch(html, /monthly leaderboard|yearly leaderboard/i);
});
