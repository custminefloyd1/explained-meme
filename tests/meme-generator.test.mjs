import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";
import test from "node:test";

const html=await readFile(new URL("../explained meme/meme-generator.html",import.meta.url),"utf8");
const index=await readFile(new URL("../explained meme/index.html",import.meta.url),"utf8");
const pages=await Promise.all(["certified-funny.html","screensaver.html","contact.html"].map(name=>readFile(new URL("../explained meme/"+name,import.meta.url),"utf8")));

test("generator is browser-only and exports PNG",()=>{
 assert.match(html,/canvas\.toBlob/);
 assert.match(html,/accept="image\/png,image\/jpeg,image\/webp,image\/gif"/);
 assert.match(html,/file\.size>10\*1024\*1024/);
 assert.match(html,/download="explained-meme-/);
 assert.doesNotMatch(html,/method:\s*["'](?:POST|PATCH|PUT|DELETE)["']/i);
 assert.doesNotMatch(html,/storage\/v1\/object\/[^"']+\{method/i);
});

test("generator offers explained templates and editable text",()=>{
 assert.match(html,/kind=eq\.meme/);
 assert.match(html,/select=id,title,image_url,image_uri&kind=eq\.meme/);
 assert.doesNotMatch(html,/select=[^"']*(?:storage_path|file_name)/);
 assert.match(html,/id="topText"/);
 assert.match(html,/id="bottomText"/);
 assert.match(html,/id="fontSize"/);
 assert.match(html,/id="position"/);
});

test("standalone navigation links to generator",()=>{
 for(const page of pages)assert.match(page,/href="meme-generator\.html">MEME GENERATOR/);
 assert.match(index,/dataset\.memeGeneratorNav="true"/);
 assert.match(index,/link\.href="meme-generator\.html"/);
});

test("explained detail connects its selected image to the generator",()=>{
 assert.match(index,/dataset\.useTemplate="true"/);
 assert.match(index,/meme-generator\.html\?image=/);
 assert.match(index,/encodeURIComponent\(image\.currentSrc\|\|image\.src\)/);
});
