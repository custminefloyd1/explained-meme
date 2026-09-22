import test from "node:test";
import assert from "node:assert/strict";
import { readFile, stat } from "node:fs/promises";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";

const root = dirname(dirname(fileURLToPath(import.meta.url)));
const site = join(root, "explained meme");
const manifest = JSON.parse(await readFile(join(root, "data/explained-memes-approved.json"), "utf8"));

test("every approved meme has a generated, indexable detail page", async () => {
  for (const entry of manifest.entries) {
    const slug = entry.title.normalize("NFKD").replace(/[\u0300-\u036f]/g, "").toLowerCase().replace(/[^a-z0-9]+/g, "-").replace(/^-|-$/g, "");
    const html = await readFile(join(site, "memes", slug, "index.html"), "utf8");
    const escapedTitle = entry.title.replaceAll("&", "&amp;").replaceAll("'", "&#39;");
    assert.ok(html.includes(`<h1>${escapedTitle}</h1>`));
    assert.match(html, /<link rel="canonical"/);
    assert.match(html, /application\/ld\+json/);
    assert.match(html, /WHAT IT MEANS/);
    assert.match(html, /ORIGIN/);
    assert.match(html, /EXAMPLE/);
  }
});

test("SEO discovery files expose meme pages", async () => {
  const sitemap = await readFile(join(site, "sitemap.xml"), "utf8");
  const robots = await readFile(join(site, "robots.txt"), "utf8");
  const index = await readFile(join(site, "memes", "index.html"), "utf8");
  assert.match(sitemap, /\/memes\/this-is-fine\//);
  assert.match(sitemap, /\/memes\/ibiza-final-boss\//);
  assert.match(robots, /Sitemap: https:\/\/explained\.meme\/sitemap\.xml/);
  assert.match(index, /href="this-is-fine\/"/);
  await stat(join(site, "memes", "ibiza-final-boss", "index.html"));
});

test("homepage routes meme cards to full explanations without transfer noise", async () => {
  const homepage = await readFile(join(site, "index.html"), "utf8");
  assert.doesNotMatch(homepage, /Warning: truncated output/);
  assert.match(homepage, /window\.location\.assign\("memes\/"\+slug\+"\/"\)/);
  assert.match(homepage, /link\.textContent="USE IN GENERATOR"/);
});

test("detail pages name the generator action clearly", async () => {
  const html = await readFile(join(site, "memes", "this-is-fine", "index.html"), "utf8");
  assert.match(html, />USE IN GENERATOR<\/a>/);
  assert.doesNotMatch(html, />USE THIS TEMPLATE<\/a>/);
});

test("detail pages use the site logo and omit related suggestions", async () => {
  const html = await readFile(join(site, "memes", "always-has-been", "index.html"), "utf8");
  assert.match(html, /src="\.\.\/\.\.\/explained_meme_logo_transparent\.png"/);
  assert.doesNotMatch(html, /Related meme explanations/);
  assert.doesNotMatch(html, /class="related"/);
});
