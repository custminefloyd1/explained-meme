import { mkdir, readFile, rm, writeFile } from "node:fs/promises";
import { execFile } from "node:child_process";
import { promisify } from "node:util";
import path from "node:path";
import { fileURLToPath } from "node:url";

const exec = promisify(execFile);
const root = new URL("../", import.meta.url);
const manifest = JSON.parse(await readFile(new URL("../data/explained-memes-approved.json", import.meta.url), "utf8"));
const discovered = JSON.parse(await readFile(new URL("../tmp-explained-image-sources.json", import.meta.url), "utf8"));
const pilot = new Set(["explained-7", "explained-8", "explained-9", "explained-10", "explained-11", "explained-12", "explained-13", "explained-14", "explained-16", "explained-17"]);
const overrides = {
  "explained-20": "https://i.imgflip.com/3oevdk.jpg",
  "explained-22": "https://api.memegen.link/images/doge.jpg",
  "explained-31": "https://i.imgflip.com/1b42wl.jpg",
  "explained-32": "https://i.imgflip.com/38el31.jpg",
  "explained-40": "https://api.memegen.link/images/michael-scott.jpg",
  "explained-42": "https://i.imgflip.com/39t1o.jpg",
  "explained-45": "https://i.imgflip.com/2fm6x.jpg",
  "explained-48": "https://i.imgflip.com/9ehk.jpg",
  "explained-52": "https://i.kym-cdn.com/photos/images/facebook/000/192/097/-2.jpg",
  "explained-61": "https://s3.amazonaws.com/arc-wordpress-client-uploads/lanacionpy/wp-content/uploads/2017/07/20051032/Rana-rene%CC%81-.jpg-.jpg",
  "explained-72": "https://i.imgflip.com/3i7p.jpg",
  "explained-74": "https://media.makeameme.org/created/its-over-anakin-b94ae695b3.jpg",
  "explained-81": "https://i.kym-cdn.com/photos/images/newsfeed/001/963/111/2da.jpg",
  "explained-82": "https://i.imgflip.com/28s2gu.jpg",
  "explained-83": "https://i.imgflip.com/1vrgwx.jpg",
  "explained-88": "https://i.imgflip.com/3qqcim.png",
  "explained-99": "https://hips.hearstapps.com/hmg-prod/images/promotional-portrait-of-american-actor-and-comedian-kevin-news-photo-1695761653.jpg?crop=1xw%3A0.45488xh%3B0",
  "explained-100": "https://upload.wikimedia.org/wikipedia/en/c/c7/Chill_guy_original_artwork.jpg",
};

const found = new Map(discovered.map((item) => [item.id, item.image_url]));
const entries = manifest.entries.filter((entry) => !pilot.has(entry.id));
const assetDir = fileURLToPath(new URL("../explained meme/assets/", import.meta.url));
const tempDir = fileURLToPath(new URL("../.tmp-explained-images/", import.meta.url));
await mkdir(assetDir, { recursive: true });
await rm(tempDir, { recursive: true, force: true });
await mkdir(tempDir, { recursive: true });

const slugify = (value) => value.toLowerCase().normalize("NFKD").replace(/[^a-z0-9]+/g, "-").replace(/^-|-$/g, "");
const records = [];

for (const [index, entry] of entries.entries()) {
  const sourceImage = overrides[entry.id] ?? found.get(entry.id);
  if (!sourceImage) throw new Error(`No image source for ${entry.id} ${entry.title}`);
  const filename = `${entry.id}-${slugify(entry.title)}.jpg`;
  const raw = path.join(tempDir, `${entry.id}.source`);
  const output = path.join(assetDir, filename);
  const response = await fetch(sourceImage, {
    headers: { "user-agent": "Mozilla/5.0 ExplainedMemeEditorialResearch/1.0" },
    signal: AbortSignal.timeout(30_000),
  });
  if (!response.ok) throw new Error(`${entry.id}: image fetch returned ${response.status}`);
  await writeFile(raw, Buffer.from(await response.arrayBuffer()));
  await exec("convert", [
    `${raw}[0]`, "-auto-orient", "-strip", "-colorspace", "sRGB",
    "-resize", "1200x900>", "-sampling-factor", "4:2:0", "-quality", "82", output,
  ]);
  const { stdout } = await exec("identify", ["-format", "%wx%h", output]);
  records.push({
    id: entry.id,
    title: entry.title,
    filename,
    image_path: `assets/${filename}`,
    public_url: `https://explained.meme/assets/${filename}`,
    image_source: sourceImage,
    research_source: entry.research_source,
    dimensions: stdout,
  });
  console.log(`${index + 1}/${entries.length} ${entry.id} ${stdout}`);
}

await writeFile(new URL("../data/explained-image-sources.json", import.meta.url), JSON.stringify({ generated_at: new Date().toISOString(), entries: records }, null, 2) + "\n");
await rm(tempDir, { recursive: true, force: true });
console.log(`Built ${records.length} assets.`);
