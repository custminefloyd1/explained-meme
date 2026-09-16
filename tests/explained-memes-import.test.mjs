import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";
import test from "node:test";

const manifestUrl = new URL("../data/explained-memes-approved.json", import.meta.url);
const manifest = JSON.parse(await readFile(manifestUrl, "utf8"));

test("approved Explained manifest contains exactly 90 unique records", () => {
  assert.equal(manifest.entries.length, 90);
  assert.equal(new Set(manifest.entries.map((entry) => entry.id)).size, 90);
});

test("every origin is verified but every image remains blocked", () => {
  for (const entry of manifest.entries) {
    assert.equal(entry.origin_status, "VERIFIED", entry.id);
    assert.equal(entry.image_status, "pending_clearance", entry.id);
    assert.equal(entry.image_url, null, entry.id);
    assert.match(entry.site_use, /EXPLAINED PAGE ONLY/i, entry.id);
    assert.match(entry.prohibited, /screensaver/i, entry.id);
    assert.match(entry.prohibited, /merchandise/i, entry.id);
  }
});

test("records include the fields required by the Explained page", () => {
  for (const entry of manifest.entries) {
    for (const field of ["id", "title", "meaning", "origin", "example", "research_source"]) {
      assert.equal(typeof entry[field], "string", `${entry.id}: ${field}`);
      assert.ok(entry[field].trim(), `${entry.id}: ${field}`);
    }
    assert.ok(Array.isArray(entry.tags) && entry.tags.length > 0, entry.id);
  }
});
