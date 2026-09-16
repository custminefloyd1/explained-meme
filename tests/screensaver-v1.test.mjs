import {readFileSync} from "node:fs";
const html=readFileSync(new URL("../explained meme/screensaver.html",import.meta.url),"utf8");
const checks=[
 ["four source filters",["all","explained","trending","funny"].every(x=>html.includes('data-mode="'+x+'"'))],
 ["large start control",html.includes('id="start"')&&html.includes("START SCREENSAVER")],
 ["fullscreen viewer",html.includes("requestFullscreen()")&&html.includes("fullscreenchange")],
 ["fullscreen ratio stays intrinsic",html.includes(".stage img{display:block;width:auto;height:auto;max-width:100vw;max-height:100vh;object-fit:contain")&&!html.includes(".stage img{display:block;width:100%;height:100%")],
 ["slideshow controls",html.includes('id="prev"')&&html.includes('id="next"')&&html.includes('id="pause"')],
 ["speed choices",html.includes('value="3000"')&&html.includes('value="5000"')&&html.includes('value="10000" selected')&&html.includes('value="30000"')&&!html.includes('value="8000"')&&!html.includes('value="15000"')],
 ["ordering choices",html.includes('value="shuffle"')&&html.includes('value="top"')&&html.includes('value="new"')],
 ["keyboard controls",html.includes('e.key==="ArrowLeft"')&&html.includes('e.key==="ArrowRight"')&&html.includes('e.key===" "')],
 ["wake lock is optional",html.includes('"wakeLock" in navigator')],
 ["broken images are skipped",html.includes('$("slide").addEventListener("error"')],
 ["return freshness is honest",html.includes('newItems===null?"—":newItems')&&html.includes("new since your last visit")],
 ["viewer has no promotional action button",!html.includes('id="actionLink"')&&!html.includes("actionFor(m)")],
 ["all Explained images are eligible",!html.includes('startsWith("explained_editorial_reference:")')],
 ["no fake products",!html.includes("PRODUCTS")&&!html.includes("Wallpaper Pack")&&!html.includes("$4.99")],
 ["no public uploads",!html.includes("Owner uploads")&&!html.includes("Public uploads")],
 ["no raw filenames displayed",!html.includes("m.title")],
 ["read-only database use",!html.includes('method:"POST"')&&!html.includes('method:"PATCH"')&&!html.includes('method:"DELETE"')]
];
for(const [name,pass] of checks){console.log((pass?"PASS ":"FAIL ")+name);if(!pass)process.exitCode=1}
for(const m of html.matchAll(/<script\b[^>]*>([\s\S]*?)<\/script>/g))new Function(m[1]);
