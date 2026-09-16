import assert from "node:assert/strict";
import { access, readFile } from "node:fs/promises";
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

test("the editorial pilot ships exactly ten local reference images", async () => {
  const ids = [7, 8, 9, 10, 11, 12, 13, 14, 16, 17];
  const names = [
    "this-is-fine", "is-this-a-pigeon", "one-does-not-simply", "success-kid",
    "bad-luck-brian", "philosoraptor", "ancient-aliens", "futurama-fry",
    "surprised-pikachu", "mocking-spongebob"
  ];
  await Promise.all(ids.map((id, i) => access(new URL(`../explained meme/assets/explained-${id}-${names[i]}.jpg`, import.meta.url))));
});

test("the remaining release ships 80 traced local reference images", async () => {
  const sources = JSON.parse(await readFile(new URL("../data/explained-image-sources.json", import.meta.url), "utf8"));
  assert.equal(sources.entries.length, 80);
  assert.equal(new Set(sources.entries.map((entry) => entry.id)).size, 80);
  await Promise.all(sources.entries.map((entry) =>
    access(new URL(`../explained meme/${entry.image_path}`, import.meta.url))
  ));
  for (const entry of sources.entries) {
    assert.match(entry.image_source, /^https:\/\//, entry.id);
    assert.match(entry.research_source, /^https:\/\//, entry.id);
  }
});

test("release SQL populates both trigger-synchronised image columns", async () => {
  for (const file of ["explained-memes-pilot-release.sql", "explained-memes-remaining-release.sql"]) {
    const sql = await readFile(new URL(`../supabase/${file}`, import.meta.url), "utf8");
    assert.match(sql, /\(id, title, image_url, image_uri,/);
    assert.match(sql, /image_url = excluded\.image_url,/);
    assert.match(sql, /image_uri = excluded\.image_uri,/);
    assert.doesNotMatch(sql, /^\s*(grant|create\s+policy|alter\s+table)\b/imu);
  }
});

test("Screensaver includes Explained editorial-reference images", async () => {
  const html = await readFile(new URL("../explained meme/screensaver.html", import.meta.url), "utf8");
  assert.match(html, /select=id,kind,image_url,image_uri,source,/);
  assert.doesNotMatch(html, /startsWith\("explained_editorial_reference:"\)/);
});


test("title sanitizer keeps legitimate long Explained titles", async () => {
  const html = await readFile(new URL("../explained meme/index.html", import.meta.url), "utf8");
  const sanitizerSource = html.match(/function Sn\(e\)\{.*?return!1\}/s)?.[0];

  assert.ok(sanitizerSource, "title sanitizer must remain present in the bundle");
  assert.doesNotMatch(sanitizerSource, /e\.length>24/);

  const isUploadedFilename = Function(`${sanitizerSource}; return Sn`)();
  assert.equal(isUploadedFilename("Pedro Pascal Laughing/Crying"), false);
  assert.equal(isUploadedFilename("The Most Interesting Man in the World"), false);
  assert.equal(isUploadedFilename("IMG_0837 (44).JPG"), true);
  assert.equal(isUploadedFilename("413b467b-9a2c-4e1f-b8d2-7f9a3c2e1a8d"), true);
  assert.equal(isUploadedFilename("uploads/meme-title"), true);
  assert.equal(isUploadedFilename("uploads\\meme-title"), true);
});
