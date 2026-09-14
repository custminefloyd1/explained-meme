// Deploy as a Supabase Edge Function named arena-import-v6.
// Invoke from a server-side schedule, never from a visitor's browser.
// Required secrets: SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY, ARENA_IMPORT_SECRET.
// Needs the companion reddit_id unique-index migration before first invocation.
Deno.serve(async request => {
  const secret=Deno.env.get("ARENA_IMPORT_SECRET");
  if(!secret||request.headers.get("x-arena-import-secret")!==secret)return new Response("Unauthorized",{status:401});
  if(request.method!=="POST")return new Response("Method not allowed",{status:405});
  const base=Deno.env.get("SUPABASE_URL"),key=Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
  if(!base||!key)return new Response("Missing server configuration",{status:503});
  const headers={apikey:key,Authorization:"Bearer "+key,"Content-Type":"application/json"};
  const candidates=new Map(),failures=[];
  for(const sub of ["memes","dankmemes","wholesomememes"]){
    try{
      const response=await fetch("https://meme-api.com/gimme/"+sub+"/10",{signal:AbortSignal.timeout(10000)});
      if(!response.ok)throw Error("Source status "+response.status);
      const data=await response.json();
      for(const post of data.memes||[]){
        if(post.nsfw||post.spoiler||typeof post.url!=="string"||typeof post.postLink!=="string")continue;
        const image=new URL(post.url),source=new URL(post.postLink);
        const id=source.pathname.match(/\/comments\/([a-z0-9]+)(?:\/|$)/i)?.[1];
        if(!id||!/(^|\.)reddit\.com$/i.test(source.hostname)||image.protocol!=="https:"||!/\.(png|jpe?g|gif|webp)$/i.test(image.pathname))continue;
        if(!["i.redd.it","preview.redd.it","i.imgur.com"].includes(image.hostname))continue;
        candidates.set(id,{title:String(post.title||"Reddit meme").slice(0,160),image_url:post.url,image_uri:post.url,kind:"trending",source:"reddit",reddit_id:id,reddit_score:Number(post.ups)||0,elo:1200,wins:0,losses:0,origin:"r/"+sub+" · via MemeAPI"});
      }
    }catch(error){failures.push(sub+": "+String(error.message))}
  }
  if(!candidates.size)return Response.json({inserted:0,failures},{status:failures.length===3?502:200});
  // Ignore existing Reddit IDs: never reset ratings or refresh an old import date.
  const response=await fetch(base+"/rest/v1/memes?on_conflict=reddit_id",{
    method:"POST",headers:{...headers,Prefer:"resolution=ignore-duplicates,return=representation"},
    body:JSON.stringify([...candidates.values()].sort((a,b)=>b.reddit_score-a.reddit_score).slice(0,15)),
    signal:AbortSignal.timeout(15000)
  });
  if(!response.ok){console.error("Arena import database status",response.status);return Response.json({error:"Database rejected import. Check schema and unique index.",failures},{status:502})}
  const inserted=await response.json();
  return Response.json({inserted:inserted.length,failures});
});
