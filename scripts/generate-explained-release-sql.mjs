import { readFile, writeFile } from "node:fs/promises";

const manifest = JSON.parse(await readFile(new URL("../data/explained-memes-approved.json", import.meta.url), "utf8"));
const sources = JSON.parse(await readFile(new URL("../data/explained-image-sources.json", import.meta.url), "utf8"));
const pilot = new Set(["explained-7", "explained-8", "explained-9", "explained-10", "explained-11", "explained-12", "explained-13", "explained-14", "explained-16", "explained-17"]);
const assets = new Map(sources.entries.map((entry) => [entry.id, entry]));
const entries = manifest.entries.filter((entry) => !pilot.has(entry.id));
const quote = (value) => `'${String(value).replaceAll("'", "''")}'`;
const rows = entries.map((entry) => {
  const asset = assets.get(entry.id);
  if (!asset) throw new Error(`Missing asset record for ${entry.id}`);
  const tags = [...new Set(["explained", "editorial-reference", ...entry.tags])].map(quote).join(",");
  const source = `explained_editorial_reference:${entry.research_source}`;
  return `  (${[
    quote(entry.id), quote(entry.title), quote(asset.public_url), quote(asset.public_url), quote("meme"),
    `array[${tags}]`, quote(source), quote(entry.meaning), quote(entry.origin), quote(entry.example), "now()",
  ].join(", ")})`;
});
const ids = entries.map((entry) => quote(entry.id));

const sql = `-- Publishes the remaining 80 reviewed Explained entries as editorial references.
-- Both image columns are populated because the database sync trigger treats image_uri as authoritative.
-- The source prefix keeps these third-party editorial references out of Screensaver.
-- This script does not grant or modify database permissions.

begin;

insert into public.memes
  (id, title, image_url, image_uri, kind, tags, source, meaning, origin, example, created_at)
values
${rows.join(",\n")}
on conflict (id) do update set
  title = excluded.title,
  image_url = excluded.image_url,
  image_uri = excluded.image_uri,
  kind = excluded.kind,
  tags = excluded.tags,
  source = excluded.source,
  meaning = excluded.meaning,
  origin = excluded.origin,
  example = excluded.example;

do $$
begin
  if (select count(*) from public.memes where id in (
    ${ids.join(",")}
  ) and image_url is not null and image_uri is not null) <> 80 then
    raise exception 'Explained remaining release incomplete; rolling back';
  end if;
end
$$;

commit;
`;

await writeFile(new URL("../supabase/explained-memes-remaining-release.sql", import.meta.url), sql);
console.log(`Generated release SQL for ${entries.length} entries.`);
