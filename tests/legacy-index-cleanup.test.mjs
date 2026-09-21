import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";
import test from "node:test";

const html = await readFile(new URL("../explained meme/index.html", import.meta.url), "utf8");

test("legacy index does not intercept fetch globally", () => {
  assert.doesNotMatch(html, /window\.fetch\s*=/);
  assert.doesNotMatch(html, /origFetch/);
  assert.doesNotMatch(html, /fetch interceptor installed/);
});

test("legacy hidden components cannot write scores or battles directly", () => {
  assert.doesNotMatch(html, /rest\/v1\/memes\?id=eq/);
  assert.doesNotMatch(html, /rest\/v1\/battles/);
  assert.doesNotMatch(html, /method:\s*["']PATCH["']/);
});

test("active pages still use their intended secure and read-only routes", () => {
  assert.match(html, /rest\/v1\/rpc\/arena_vote_v7/);
  assert.match(html, /rest\/v1\/rpc\/arena_state_v7/);
  assert.match(html, /rest\/v1\/memes\?select=\*&order=created_at\.desc&limit=300/);
  assert.match(html, /window\.location\.href="certified-funny\.html"/);
});
