import { mkdir, readFile, rm, writeFile } from "node:fs/promises";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";

const root = dirname(dirname(fileURLToPath(import.meta.url)));
const site = join(root, "explained meme");
const manifest = JSON.parse(await readFile(join(root, "data/explained-memes-approved.json"), "utf8"));

const slugify = (value) => value
  .normalize("NFKD")
  .replace(/[\u0300-\u036f]/g, "")
  .toLowerCase()
  .replace(/[^a-z0-9]+/g, "-")
  .replace(/^-|-$/g, "");

const escapeHtml = (value = "") => String(value)
  .replaceAll("&", "&amp;")
  .replaceAll("<", "&lt;")
  .replaceAll(">", "&gt;")
  .replaceAll('"', "&quot;")
  .replaceAll("'", "&#39;");

const extraEntries = [{
  id: "1789328384070-ibiza_final_boss.jpg",
  title: "Ibiza Final Boss",
  meaning: "A nickname for Jack Kay, whose extremely confident Ibiza club look is framed as the ultimate, overpowered nightclub character — the person you meet at the final level of an Ibiza night out.",
  origin: "A viral video filmed at Zero Six West in Ibiza in August 2025 showed Newcastle tourist Jack Kay dancing in dark sunglasses, a black vest, a gold chain and a distinctive bowl haircut.",
  example: "When you reach the last club of the night and the Ibiza Final Boss is waiting at the bar.",
  tags: ["viral", "Ibiza", "reaction"],
  image_url: "https://locumfwdacdrqgxputou.supabase.co/storage/v1/object/public/memes/1789328384070-ibiza_final_boss.jpg",
}];

const entries = [...manifest.entries, ...extraEntries].map((entry) => ({
  ...entry,
  slug: slugify(entry.title),
  image_url: entry.image_url || `https://explained.meme/assets/${entry.id}-${slugify(entry.title)}.jpg`,
}));

const page = (entry) => {
  const title = `${entry.title} Meme Explained: Meaning, Origin & Example`;
  const description = `${entry.title} meme meaning, origin and an example of how to use it. ${entry.meaning}`.slice(0, 158);
  const canonical = `https://explained.meme/memes/${entry.slug}/`;
  const jsonLd = JSON.stringify({
    "@context": "https://schema.org",
    "@type": "Article",
    headline: title,
    description,
    image: [entry.image_url],
    mainEntityOfPage: canonical,
    author: { "@type": "Organization", name: "Explained.meme", url: "https://explained.meme/" },
    publisher: { "@type": "Organization", name: "Explained.meme", url: "https://explained.meme/" },
  }).replaceAll("<", "\\u003c");
  return `<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width,initial-scale=1">
  <title>${escapeHtml(title)}</title>
  <meta name="description" content="${escapeHtml(description)}">
  <link rel="canonical" href="${canonical}">
  <meta property="og:type" content="article">
  <meta property="og:site_name" content="Explained.meme">
  <meta property="og:title" content="${escapeHtml(title)}">
  <meta property="og:description" content="${escapeHtml(description)}">
  <meta property="og:url" content="${canonical}">
  <meta property="og:image" content="${escapeHtml(entry.image_url)}">
  <meta name="twitter:card" content="summary_large_image">
  <link rel="icon" href="../../favicon.png">
  <script type="application/ld+json">${jsonLd}</script>
  <style>
    :root{color-scheme:dark;--lime:#d4ff00;--muted:#a1a1aa;--line:#27272a}*{box-sizing:border-box}body{margin:0;background:#09090b;color:#fafafa;font-family:Inter,ui-sans-serif,system-ui,-apple-system,BlinkMacSystemFont,"Segoe UI",sans-serif}a{color:inherit}.wrap{width:min(1080px,calc(100% - 32px));margin:auto}.top{border-bottom:1px solid #18181b}.top .wrap{display:flex;align-items:center;justify-content:space-between;gap:20px;padding:12px 0}.brand{display:block;text-decoration:none;flex:0 0 auto}.brand img{display:block;width:auto;height:64px;max-width:min(280px,calc(100vw - 32px));object-fit:contain}nav{display:flex;gap:18px;font:700 11px ui-monospace,monospace;letter-spacing:.08em}nav a{text-decoration:none;color:#a1a1aa}nav a:hover{color:var(--lime)}main{padding:38px 0 64px}.crumbs{font:11px ui-monospace,monospace;color:#71717a;margin-bottom:24px}.crumbs a:hover{color:var(--lime)}.hero{display:grid;grid-template-columns:minmax(0,1.05fr) minmax(300px,.95fr);gap:34px;align-items:start}.image{background:#000;border:1px solid var(--line);border-radius:18px;overflow:hidden}.image img{display:block;width:100%;max-height:650px;object-fit:contain}.eyebrow,.label{font:700 10px ui-monospace,monospace;letter-spacing:.16em;color:var(--lime)}h1{font-size:clamp(38px,6vw,68px);letter-spacing:-.055em;line-height:.94;margin:10px 0 22px}.summary{font-size:18px;line-height:1.55;color:#d4d4d8}.actions{display:flex;flex-wrap:wrap;gap:10px;margin-top:24px}.button{display:inline-flex;padding:12px 16px;border-radius:999px;background:var(--lime);color:#09090b;text-decoration:none;font:800 11px ui-monospace,monospace;letter-spacing:.06em}.button.secondary{background:#18181b;color:#fafafa;border:1px solid var(--line)}.details{display:grid;grid-template-columns:1fr 1fr;gap:16px;margin-top:34px}.card{background:#111;border:1px solid var(--line);border-radius:16px;padding:22px}.card.meaning{grid-column:1/-1}.card p{color:#d4d4d8;line-height:1.65;margin:9px 0 0}footer{border-top:1px solid #18181b;padding:26px 0;color:#71717a;font:11px ui-monospace,monospace}@media(max-width:760px){.hero{grid-template-columns:1fr}.details{grid-template-columns:1fr}.card.meaning{grid-column:auto}.top .wrap{align-items:flex-start;flex-direction:column}nav{overflow:auto;width:100%}.brand img{height:56px}}
  </style>
</head>
<body>
  <header class="top"><div class="wrap"><a class="brand" href="../../"><img src="../../explained_meme_logo_transparent.png" alt="Explained Meme"></a><nav aria-label="Main navigation"><a href="../../">EXPLAINED</a><a href="../../meme-generator.html">MEME GENERATOR</a><a href="../">ALL MEMES</a></nav></div></header>
  <main class="wrap">
    <div class="crumbs"><a href="../../">HOME</a> / <a href="../">MEMES</a> / ${escapeHtml(entry.title).toUpperCase()}</div>
    <article>
      <div class="hero">
        <figure class="image"><img src="${escapeHtml(entry.image_url)}" alt="${escapeHtml(entry.title)} meme" width="900" height="675"></figure>
        <div><div class="eyebrow">MEME EXPLAINED</div><h1>${escapeHtml(entry.title)}</h1><p class="summary">${escapeHtml(entry.meaning)}</p><div class="actions"><a class="button" href="../../meme-generator.html?image=${encodeURIComponent(entry.image_url)}&amp;title=${encodeURIComponent(entry.title)}">USE IN GENERATOR</a>${entry.research_source ? `<a class="button secondary" href="${escapeHtml(entry.research_source)}" rel="nofollow noopener">RESEARCH SOURCE</a>` : ""}</div></div>
      </div>
      <div class="details"><section class="card meaning"><div class="label">WHAT IT MEANS</div><p>${escapeHtml(entry.meaning)}</p></section><section class="card"><div class="label">ORIGIN</div><p>${escapeHtml(entry.origin)}</p></section><section class="card"><div class="label">EXAMPLE</div><p>${escapeHtml(entry.example)}</p></section></div>
    </article>
  </main>
  <footer><div class="wrap">explained meme (2026)</div></footer>
</body>
</html>`;
};

const pagesDir = join(site, "memes");
await rm(pagesDir, { recursive: true, force: true });
await mkdir(pagesDir, { recursive: true });
for (const entry of entries) {
  const directory = join(pagesDir, entry.slug);
  await mkdir(directory, { recursive: true });
  await writeFile(join(directory, "index.html"), page(entry));
}

const listItems = entries.map((entry) => `<li><a href="${entry.slug}/">${escapeHtml(entry.title)}</a><span>${escapeHtml(entry.meaning)}</span></li>`).join("\n");
await writeFile(join(pagesDir, "index.html"), `<!doctype html><html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>Meme Meanings, Origins & Examples | Explained.meme</title><meta name="description" content="Browse meme meanings, origins and practical examples. Learn what popular memes mean and how people use them."><link rel="canonical" href="https://explained.meme/memes/"><link rel="icon" href="../favicon.png"><style>body{margin:0;background:#09090b;color:#fafafa;font-family:Inter,system-ui,sans-serif}main,header div{width:min(980px,calc(100% - 32px));margin:auto}header{border-bottom:1px solid #27272a;padding:20px 0}header a{color:#d4ff00;font-weight:900;text-decoration:none}main{padding:45px 0}h1{font-size:clamp(40px,7vw,72px);letter-spacing:-.055em;margin:0}p{color:#a1a1aa;font-size:17px}ul{list-style:none;padding:0;display:grid;grid-template-columns:repeat(2,1fr);gap:12px;margin-top:35px}li{background:#111;border:1px solid #27272a;border-radius:14px;padding:18px}li a{display:block;color:#fafafa;font-size:18px;font-weight:800;text-decoration:none}li a:hover{color:#d4ff00}li span{display:block;color:#a1a1aa;font-size:13px;line-height:1.5;margin-top:7px}@media(max-width:700px){ul{grid-template-columns:1fr}}</style></head><body><header><div><a href="../">explained.meme</a></div></header><main><h1>Meme explanations</h1><p>Meanings, origins and examples for ${entries.length} popular memes.</p><ul>${listItems}</ul></main></body></html>`);

const urls = ["https://explained.meme/", "https://explained.meme/memes/", "https://explained.meme/meme-generator.html", ...entries.map((entry) => `https://explained.meme/memes/${entry.slug}/`)];
await writeFile(join(site, "sitemap.xml"), `<?xml version="1.0" encoding="UTF-8"?>\n<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">\n${urls.map((url) => `  <url><loc>${url}</loc></url>`).join("\n")}\n</urlset>\n`);
await writeFile(join(site, "robots.txt"), "User-agent: *\nAllow: /\nSitemap: https://explained.meme/sitemap.xml\n");
await writeFile(join(site, "seo-meme-links.js"), `window.EXPLAINED_MEME_SLUGS=${JSON.stringify(Object.fromEntries(entries.map((entry) => [entry.title.toLowerCase(), entry.slug])))};\n`);
console.log(`Generated ${entries.length} meme pages.`);
