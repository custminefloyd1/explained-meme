import fs from "node:fs";
import assert from "node:assert/strict";

const root = new URL("../explained meme/", import.meta.url);
const read = (name) => fs.readFileSync(new URL(name, root), "utf8");
const index = read("index.html");
const certified = read("certified-funny.html");
const screensaver = read("screensaver.html");
const contact = read("contact.html");
const generator = read("meme-generator.html");
const radar = read("meme-radar.html");
const standalone = [certified, screensaver, contact];

assert.match(certified, /href="screensaver\.html">SCREENSAVER/);
assert.match(certified, /href="contact\.html">CONTACT/);
assert.match(screensaver, /href="contact\.html">CONTACT/);
for (const page of [...standalone, generator, radar]) assert.match(page, /href="meme-radar\.html"[^>]*>MEME RADAR/);
assert.match(index, /radar\.dataset\.memeRadarNav="true"/);
assert.doesNotMatch(index, /\{id:"LIVE",label:"LIVE"\}/);
assert.match(index, /className:"flex flex-row items-end gap-3 text-left group cursor-pointer max-w-full"/);
assert.match(index, /tracking-\[0\.22em\].*mb-\[10px\] opacity-90/);


for (const page of standalone) {
  assert.match(page, /\.brand-row\{min-height:96px\}\.brand\{align-items:flex-end;gap:12px\}/);
  assert.match(page, /@media\(max-width:767px\)\{\.brand-row\{min-height:80px\}\.brand img\{height:64px\}\}/);
  assert.match(page, /@media\(max-width:639px\)\{\.brand-row\{min-height:72px\}/);
  assert.match(page, />FOREVER FUNNY<\/span>/);
  assert.match(page, /\/\* Header consistency V2/);
  assert.match(page, /\.nav \.active\{margin:4px 0;padding:9px 20px;border-radius:8px\}/);
  assert.match(page, /font-family:"JetBrains Mono",monospace;font-size:10px/);
  assert.match(page, /\.site-head>\.brand-row,\.site-head>\.nav\{width:min\(1216px,calc\(100% - 64px\)\)\}/);
}

console.log("navigation consistency checks passed");
