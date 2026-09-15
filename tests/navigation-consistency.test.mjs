import fs from "node:fs";
import assert from "node:assert/strict";

const root = new URL("../explained meme/", import.meta.url);
const read = (name) => fs.readFileSync(new URL(name, root), "utf8");
const index = read("index.html");
const certified = read("certified-funny.html");
const screensaver = read("screensaver.html");
const contact = read("contact.html");
const standalone = [certified, screensaver, contact];

assert.match(certified, /href="screensaver\.html">SCREENSAVER/);
assert.match(certified, /href="contact\.html">CONTACT/);
assert.match(screensaver, /href="contact\.html">CONTACT/);
assert.doesNotMatch(index, /\{id:"LIVE",label:"LIVE"\}/);

for (const page of standalone) {
  assert.match(page, /\.brand-row\{min-height:96px\}\.brand\{align-items:flex-end;gap:12px\}/);
  assert.match(page, /@media\(max-width:767px\)\{\.brand-row\{min-height:80px\}\.brand img\{height:64px\}\}/);
  assert.match(page, /@media\(max-width:639px\)\{\.brand-row\{min-height:72px\}/);
  assert.match(page, />FOREVER FUNNY<\/span>/);
}

console.log("navigation consistency checks passed");
