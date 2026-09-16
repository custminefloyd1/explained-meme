import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";
import test from "node:test";

const index = await readFile(new URL("../explained meme/index.html", import.meta.url), "utf8");

test("Explained page omits inventory and SEO counters", () => {
  assert.doesNotMatch(index, /entries • SEO-ready/);
  assert.doesNotMatch(index, /n\.length," memes • ",l\.length," funnys • ",o\.length," trending"/);
});

test("Daily Meme Battle clearly describes the live viral format", () => {
  assert.match(index, /TODAY’S VIRAL MEMES\. YOUR VOTE\./);
  assert.match(index, /New contenders arrive every day/);
  assert.match(index, /Weekly viral leaderboard/);
  assert.doesNotMatch(index, /monthly leaderboard|yearly leaderboard/i);
});

test("Ibiza Final Boss content update is complete and permission-neutral", async () => {
  const sql = await readFile(new URL("../supabase/ibiza-final-boss-content.sql", import.meta.url), "utf8");
  assert.match(sql, /meaning\s*=/i);
  assert.match(sql, /origin\s*=/i);
  assert.match(sql, /example\s*=/i);
  assert.match(sql, /where id = '1789328384070-ibiza_final_boss\.jpg'/);
  assert.doesNotMatch(sql, /^\s*(grant|create\s+policy|alter\s+table)\b/imu);
});
