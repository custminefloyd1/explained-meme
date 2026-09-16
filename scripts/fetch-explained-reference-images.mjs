import { readFile, writeFile } from "node:fs/promises";

const manifest = JSON.parse(await readFile(new URL("../data/explained-memes-approved.json", import.meta.url), "utf8"));
const pilot = new Set(["explained-7", "explained-8", "explained-9", "explained-10", "explained-11", "explained-12", "explained-13", "explained-14", "explained-16", "explained-17"]);
const entries = manifest.entries.filter((entry) => !pilot.has(entry.id));
const results = [];

function decode(value) {
  return value.replaceAll("&amp;", "&").replaceAll("&#039;", "'").replaceAll("&quot;", '"');
}

async function inspect(entry) {
  try {
    const response = await fetch(entry.research_source, {
      headers: { "user-agent": "Mozilla/5.0 ExplainedMemeEditorialResearch/1.0" },
      signal: AbortSignal.timeout(12_000),
    });
    const html = await response.text();
    const match = html.match(/<meta[^>]+property=["']og:image["'][^>]+content=["']([^"']+)/i)
      ?? html.match(/<meta[^>]+content=["']([^"']+)["'][^>]+property=["']og:image["']/i)
      ?? html.match(/<meta[^>]+name=["']twitter:image(?::src)?["'][^>]+content=["']([^"']+)/i);
    return { id: entry.id, title: entry.title, page_url: entry.research_source, image_url: match ? decode(match[1]) : null, http_status: response.status };
  } catch (error) {
    return { id: entry.id, title: entry.title, page_url: entry.research_source, image_url: null, error: String(error) };
  }
}

for (let i = 0; i < entries.length; i += 5) {
  results.push(...await Promise.all(entries.slice(i, i + 5).map(inspect)));
}

await writeFile(new URL("../tmp-explained-image-sources.json", import.meta.url), JSON.stringify(results, null, 2) + "\n");
console.log(JSON.stringify({ total: results.length, found: results.filter((item) => item.image_url).length, missing: results.filter((item) => !item.image_url).map((item) => item.title) }, null, 2));
