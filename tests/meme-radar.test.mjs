import test from "node:test";
import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";

const html = await readFile(new URL("../explained meme/meme-radar.html", import.meta.url), "utf8");
const data = JSON.parse(await readFile(new URL("../data/meme-radar.json", import.meta.url), "utf8"));
const escaped = (value) => value.replaceAll("&", "&amp;").replaceAll("'", "&#39;").replaceAll('"', "&quot;").replaceAll("<", "&lt;").replaceAll(">", "&gt;");

test("Radar exposes verified editorial signals without invented scores", () => {
  assert.equal(data.signals.length, 5);
  for (const signal of data.signals) {
    assert.ok(signal.source.startsWith("https://"));
    assert.ok(html.includes(escaped(signal.title)));
  }
  assert.match(html, /No invented trend scores/);
  assert.doesNotMatch(html, /Trend score/);
});

test("Radar live feed is read-only and sends visitors to the battle", () => {
  assert.match(html, /kind=eq\.trending/);
  assert.match(html, /reddit_score/);
  assert.doesNotMatch(html, /method:\s*["'](?:POST|PATCH|DELETE)/);
  assert.match(html, /index\.html#battle/);
});
