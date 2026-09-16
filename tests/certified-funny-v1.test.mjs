import {readFileSync} from "node:fs";
const html=readFileSync(new URL("../explained meme/certified-funny.html",import.meta.url),"utf8");
const checks=[
 ["secure RPC is used",html.includes("/rest/v1/rpc/certified_funny_rate_v1")],
 ["legacy direct PATCH is absent",!html.includes('method:"PATCH"')&&!html.includes("method:'PATCH'")],
 ["server response is checked",html.includes("if(!r.ok)")&&html.includes("Rating was not saved. Please retry.")],
 ["success follows awaited RPC",html.includes("const saved=await r.json()")&&html.includes("Rating confirmed")],
 ["Turnstile token is sent",html.includes("gotrue_meta_security:{captcha_token:await captcha()}")],
 ["Turnstile challenge is clickable",html.includes("turnstileHost")&&html.includes("pointer-events:auto")&&!html.includes("pointer-events:none")],
 ["anonymous session is reused",html.includes('localStorage.getItem("arena-v6-session")')],
 ["double submit guard exists",html.includes("if(state.busy||!current())return")],
 ["rate-limit failure is actionable",html.includes("You’re rating very quickly. Wait one minute, then retry this picture.")],
 ["daily limit is 25",html.includes("LIMIT=25")],
 ["5 10 25 milestones exist",html.includes("5 QUICK")&&html.includes("10 SOLID")&&html.includes("25 CLEARED")],
 ["daily progress persists",html.includes('certified-funny-v1-progress')],
 ["external values use textContent",html.includes("strong.textContent=safeTitle")&&!html.includes("row.innerHTML")],
 ["verified columns only",html.includes("select=id,kind,title,image_url,image_uri,avg_rating,ratings_count")&&!html.includes("select=id,kind,title,image_url,image_uri,storage_path")],
 ["responsive logo is bounded",html.includes(".brand img{display:block;height:80px")&&html.includes("@media(max-width:520px)")],
 ["tagline stays beside logo",html.includes(".brand{display:flex;align-items:center")&&html.includes(".tagline{margin-top:0;white-space:nowrap")],
 ["empty inventory is honest",html.includes("No funny pictures have been imported yet. Owner upload required.")&&html.includes('$("progressText").textContent="0 / 0"')],
 ["canonical page title exists",html.includes("<title>Certified Funny? — Explained Meme</title>")],
 ["uploaded filenames stay private",html.includes('function safeTitle(m,i){return "Funny #"+(i+1)}')&&!html.includes("const t=String(m.title")],
 ["leaderboard pictures open full preview",html.includes('id="leaderDialog"')&&html.includes("function openLeader(m,i,rank)")&&html.includes('row.addEventListener("click"')],
 ["leaderboard rows are keyboard accessible",html.includes('const row=document.createElement("button")')&&html.includes('row.type="button"')&&html.includes('row.setAttribute("aria-label"')]
];
for(const [name,pass] of checks){console.log((pass?"PASS ":"FAIL ")+name);if(!pass)process.exitCode=1}
