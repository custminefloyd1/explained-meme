-- Stages the 90 approved Explained records without publishing them.
-- This migration does NOT write to public.memes and grants no visitor access.
-- A candidate remains invisible until an administrator clears an image and
-- deliberately promotes it through a separate reviewed release.

begin;

create table if not exists public.explained_meme_candidates (
  id text primary key,
  title text not null,
  meaning text not null,
  origin text not null,
  example text not null default '',
  tags text[] not null default '{}',
  research_source text not null,
  origin_verified boolean not null default false,
  image_url text,
  image_credit text,
  image_rights_status text not null default 'pending_clearance'
    check (image_rights_status in ('pending_clearance', 'cleared_editorial', 'rejected')),
  publication_status text not null default 'draft'
    check (publication_status in ('draft', 'approved', 'published', 'rejected')),
  allowed_use text not null default 'explained_editorial_only',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  check (publication_status <> 'published' or (
    origin_verified
    and image_rights_status = 'cleared_editorial'
    and image_url is not null
    and btrim(image_url) <> ''
    and image_credit is not null
    and btrim(image_credit) <> ''
  ))
);

alter table public.explained_meme_candidates enable row level security;
revoke all on table public.explained_meme_candidates from anon, authenticated;
grant all on table public.explained_meme_candidates to service_role;

insert into public.explained_meme_candidates
  (id, title, meaning, origin, example, tags, research_source, origin_verified)
values
  ('explained-7', 'This Is Fine', 'A reaction to an obviously worsening situation that someone calmly accepts, ignores or pretends is manageable.', 'Gunshow webcomic by K.C. Green (2013); meme popularised later', 'The deadline is tonight, nothing works, and I have opened another meeting invite. This is fine.', '{"reaction","denial","crisis","webcomic"}'::text[], 'https://knowyourmeme.com/memes/this-is-fine', true)
on conflict (id) do update set
  title = excluded.title,
  meaning = excluded.meaning,
  origin = excluded.origin,
  example = excluded.example,
  tags = excluded.tags,
  research_source = excluded.research_source,
  origin_verified = excluded.origin_verified,
  updated_at = now();

insert into public.explained_meme_candidates
  (id, title, meaning, origin, example, tags, research_source, origin_verified)
values
  ('explained-8', 'Is This a Pigeon?', 'Used when somebody confidently mistakes, mislabels or misunderstands something obvious.', 'The Brave Fighter of Sun Fighbird / Tumblr (2011)', 'Manager sees one quiet afternoon: Is this unlimited capacity?', '{"misidentification","anime","labelling","misunderstanding"}'::text[], 'https://knowyourmeme.com/memes/is-this-a-pigeon', true)
on conflict (id) do update set
  title = excluded.title,
  meaning = excluded.meaning,
  origin = excluded.origin,
  example = excluded.example,
  tags = excluded.tags,
  research_source = excluded.research_source,
  origin_verified = excluded.origin_verified,
  updated_at = now();

insert into public.explained_meme_candidates
  (id, title, meaning, origin, example, tags, research_source, origin_verified)
values
  ('explained-9', 'One Does Not Simply', 'Frames an action as far more difficult, complicated or unrealistic than it first appears.', 'The Lord of the Rings: The Fellowship of the Ring (2001)', 'One does not simply finish a group project without twelve reminder messages.', '{"difficulty","statement","film quote","snowclone"}'::text[], 'https://knowyourmeme.com/memes/one-does-not-simply-walk-into-mordor', true)
on conflict (id) do update set
  title = excluded.title,
  meaning = excluded.meaning,
  origin = excluded.origin,
  example = excluded.example,
  tags = excluded.tags,
  research_source = excluded.research_source,
  origin_verified = excluded.origin_verified,
  updated_at = now();

insert into public.explained_meme_candidates
  (id, title, meaning, origin, example, tags, research_source, origin_verified)
values
  ('explained-10', 'Success Kid', 'Celebrates a small victory, unexpected success or situation that turned out better than expected.', 'Flickr photograph by Laney Griner (2007)', 'Forgot my umbrella. Meeting moved online.', '{"success","reaction","advice animal","victory"}'::text[], 'https://knowyourmeme.com/memes/success-kid-i-hate-sandcastles', true)
on conflict (id) do update set
  title = excluded.title,
  meaning = excluded.meaning,
  origin = excluded.origin,
  example = excluded.example,
  tags = excluded.tags,
  research_source = excluded.research_source,
  origin_verified = excluded.origin_verified,
  updated_at = now();

insert into public.explained_meme_candidates
  (id, title, meaning, origin, example, tags, research_source, origin_verified)
values
  ('explained-11', 'Bad Luck Brian', 'Uses an awkward school portrait with captions describing an ordinary setup followed by extreme misfortune.', 'Reddit (2012)', 'Downloads the backup. Backup file is corrupted.', '{"bad luck","character macro","misfortune","advice animal"}'::text[], 'https://knowyourmeme.com/memes/bad-luck-brian', true)
on conflict (id) do update set
  title = excluded.title,
  meaning = excluded.meaning,
  origin = excluded.origin,
  example = excluded.example,
  tags = excluded.tags,
  research_source = excluded.research_source,
  origin_verified = excluded.origin_verified,
  updated_at = now();

insert into public.explained_meme_candidates
  (id, title, meaning, origin, example, tags, research_source, origin_verified)
values
  ('explained-12', 'Philosoraptor', 'Pairs a thoughtful velociraptor illustration with pseudo-philosophical questions, paradoxes and absurd observations.', 'Lonely Dinosaur T-shirt by Sam Smith / 4chan (2008)', 'If tomatoes are fruit, is ketchup a smoothie?', '{"question","philosophy","advice animal","dinosaur"}'::text[], 'https://knowyourmeme.com/memes/philosoraptor', true)
on conflict (id) do update set
  title = excluded.title,
  meaning = excluded.meaning,
  origin = excluded.origin,
  example = excluded.example,
  tags = excluded.tags,
  research_source = excluded.research_source,
  origin_verified = excluded.origin_verified,
  updated_at = now();

insert into public.explained_meme_candidates
  (id, title, meaning, origin, example, tags, research_source, origin_verified)
values
  ('explained-13', 'Ancient Aliens', 'Mockingly explains an event, mystery or coincidence by attributing it to aliens without credible evidence.', 'History Channel''s Ancient Aliens / 4chan (2010)', 'The printer worked after I turned it off and on. Aliens.', '{"aliens","conspiracy","explanation","television"}'::text[], 'https://knowyourmeme.com/memes/ancient-aliens', true)
on conflict (id) do update set
  title = excluded.title,
  meaning = excluded.meaning,
  origin = excluded.origin,
  example = excluded.example,
  tags = excluded.tags,
  research_source = excluded.research_source,
  origin_verified = excluded.origin_verified,
  updated_at = now();

insert into public.explained_meme_candidates
  (id, title, meaning, origin, example, tags, research_source, origin_verified)
values
  ('explained-14', 'Futurama Fry', 'Expresses uncertainty between two explanations using the structure “Not sure if X, or just Y.”', 'Futurama / image-macro sites (2011)', 'Not sure if productive, or just reorganising the task list again.', '{"uncertainty","reaction","television","internal monologue"}'::text[], 'https://knowyourmeme.com/memes/futurama-fry-not-sure-if', true)
on conflict (id) do update set
  title = excluded.title,
  meaning = excluded.meaning,
  origin = excluded.origin,
  example = excluded.example,
  tags = excluded.tags,
  research_source = excluded.research_source,
  origin_verified = excluded.origin_verified,
  updated_at = now();

insert into public.explained_meme_candidates
  (id, title, meaning, origin, example, tags, research_source, origin_verified)
values
  ('explained-16', 'Surprised Pikachu', 'Reacting with shock to a predictable consequence, especially when the outcome should have been obvious.', 'Pokémon anime / Tumblr (2018)', 'Skips every software update. Laptop breaks. Surprised Pikachu.', '{"reaction","predictable consequence","anime","shock"}'::text[], 'https://knowyourmeme.com/memes/surprised-pikachu', true)
on conflict (id) do update set
  title = excluded.title,
  meaning = excluded.meaning,
  origin = excluded.origin,
  example = excluded.example,
  tags = excluded.tags,
  research_source = excluded.research_source,
  origin_verified = excluded.origin_verified,
  updated_at = now();

insert into public.explained_meme_candidates
  (id, title, meaning, origin, example, tags, research_source, origin_verified)
values
  ('explained-17', 'Mocking SpongeBob', 'Mocks or sarcastically repeats somebody''s statement, usually by alternating uppercase and lowercase letters.', 'SpongeBob SquarePants / Twitter (2017)', 'You should organise your files. YoU sHoUlD oRgAnIsE yOuR fIlEs.', '{"mockery","sarcasm","reaction","SpongeBob"}'::text[], 'https://knowyourmeme.com/memes/mocking-spongebob', true)
on conflict (id) do update set
  title = excluded.title,
  meaning = excluded.meaning,
  origin = excluded.origin,
  example = excluded.example,
  tags = excluded.tags,
  research_source = excluded.research_source,
  origin_verified = excluded.origin_verified,
  updated_at = now();

insert into public.explained_meme_candidates
  (id, title, meaning, origin, example, tags, research_source, origin_verified)
values
  ('explained-18', 'Boardroom Suggestion', 'Shows a sensible proposal being punished while safer or worse ideas receive approval, usually mocking corporate decision-making.', 'Hejibits webcomic (2012)', 'More meetings. More dashboards. Fix the actual problem — thrown out of the window.', '{"workplace","corporate logic","rejection","webcomic"}'::text[], 'https://knowyourmeme.com/memes/boardroom-suggestion', true)
on conflict (id) do update set
  title = excluded.title,
  meaning = excluded.meaning,
  origin = excluded.origin,
  example = excluded.example,
  tags = excluded.tags,
  research_source = excluded.research_source,
  origin_verified = excluded.origin_verified,
  updated_at = now();

insert into public.explained_meme_candidates
  (id, title, meaning, origin, example, tags, research_source, origin_verified)
values
  ('explained-19', 'Gru''s Plan', 'A multi-panel plan looks sensible until the presenter reaches a step revealing that the plan defeats itself.', 'Despicable Me / Reddit (2018)', 'Automate the report. Spend six hours fixing the automation. Repeat every week. Wait.', '{"plan failure","presentation","realisation","film"}'::text[], 'https://knowyourmeme.com/memes/grus-plan', true)
on conflict (id) do update set
  title = excluded.title,
  meaning = excluded.meaning,
  origin = excluded.origin,
  example = excluded.example,
  tags = excluded.tags,
  research_source = excluded.research_source,
  origin_verified = excluded.origin_verified,
  updated_at = now();

insert into public.explained_meme_candidates
  (id, title, meaning, origin, example, tags, research_source, origin_verified)
values
  ('explained-20', 'I Am Once Again Asking', 'A repeated request, appeal or demand framed as something the speaker has already asked for before.', 'Bernie Sanders campaign video / social media (2020)', 'I am once again asking you to name the final file final-final-v7.', '{"request","politics","repetition","reaction"}'::text[], 'https://time.com/5779804/bernie-sanders-memes/', true)
on conflict (id) do update set
  title = excluded.title,
  meaning = excluded.meaning,
  origin = excluded.origin,
  example = excluded.example,
  tags = excluded.tags,
  research_source = excluded.research_source,
  origin_verified = excluded.origin_verified,
  updated_at = now();

insert into public.explained_meme_candidates
  (id, title, meaning, origin, example, tags, research_source, origin_verified)
values
  ('explained-22', 'Doge', 'Uses a Shiba Inu photograph with fragmented inner-monologue captions such as “such,” “very” and “wow.”', 'Kabosu photograph / Tumblr (2010)', 'Such deadline. Very spreadsheet. Much panic. Wow.', '{"dog","Shiba Inu","inner monologue","image macro"}'::text[], 'https://knowyourmeme.com/memes/doge', true)
on conflict (id) do update set
  title = excluded.title,
  meaning = excluded.meaning,
  origin = excluded.origin,
  example = excluded.example,
  tags = excluded.tags,
  research_source = excluded.research_source,
  origin_verified = excluded.origin_verified,
  updated_at = now();

insert into public.explained_meme_candidates
  (id, title, meaning, origin, example, tags, research_source, origin_verified)
values
  ('explained-23', 'Cheems', 'A Shiba Inu character associated with deliberately misspelled words, especially inserting extra M sounds, and awkward or self-deprecating behaviour.', 'Balltze Instagram photograph / Dogelore (2019)', 'I will finish the documemt tommorrow.', '{"dog","Shiba Inu","misspelling","Dogelore"}'::text[], 'https://knowyourmeme.com/memes/cheems', true)
on conflict (id) do update set
  title = excluded.title,
  meaning = excluded.meaning,
  origin = excluded.origin,
  example = excluded.example,
  tags = excluded.tags,
  research_source = excluded.research_source,
  origin_verified = excluded.origin_verified,
  updated_at = now();

insert into public.explained_meme_candidates
  (id, title, meaning, origin, example, tags, research_source, origin_verified)
values
  ('explained-25', 'UNO Draw 25', 'Presents a simple action versus drawing 25 cards, implying that the person would rather accept an absurd penalty than do the action.', 'Twitter (2020)', 'Reply to the email now or draw 25.', '{"dilemma","refusal","cards","object labelling"}'::text[], 'https://knowyourmeme.com/memes/draw-25', true)
on conflict (id) do update set
  title = excluded.title,
  meaning = excluded.meaning,
  origin = excluded.origin,
  example = excluded.example,
  tags = excluded.tags,
  research_source = excluded.research_source,
  origin_verified = excluded.origin_verified,
  updated_at = now();

insert into public.explained_meme_candidates
  (id, title, meaning, origin, example, tags, research_source, origin_verified)
values
  ('explained-26', 'Running Away Balloon', 'Shows somebody reaching for a goal while another force pulls them away, illustrating a limitation, distraction or obstacle.', 'Superelmer comic / Facebook (2017)', 'Me reaching for eight hours of sleep while one more episode pulls me back.', '{"obstacle","distraction","object labelling","webcomic"}'::text[], 'https://knowyourmeme.com/memes/running-away-balloon', true)
on conflict (id) do update set
  title = excluded.title,
  meaning = excluded.meaning,
  origin = excluded.origin,
  example = excluded.example,
  tags = excluded.tags,
  research_source = excluded.research_source,
  origin_verified = excluded.origin_verified,
  updated_at = now();

insert into public.explained_meme_candidates
  (id, title, meaning, origin, example, tags, research_source, origin_verified)
values
  ('explained-27', 'Always Has Been', 'A discovery is immediately confirmed by someone who already knew the truth, often with a dark or absurd threat.', '4chan / social media (2018)', 'Wait, the meeting could have been an email? Always has been.', '{"revelation","catchphrase","astronauts","exploitable"}'::text[], 'https://knowyourmeme.com/memes/wait-its-all-ohio-always-has-been', true)
on conflict (id) do update set
  title = excluded.title,
  meaning = excluded.meaning,
  origin = excluded.origin,
  example = excluded.example,
  tags = excluded.tags,
  research_source = excluded.research_source,
  origin_verified = excluded.origin_verified,
  updated_at = now();

insert into public.explained_meme_candidates
  (id, title, meaning, origin, example, tags, research_source, origin_verified)
values
  ('explained-29', 'They''re the Same Picture', 'Declares two supposedly different choices, products or ideas effectively identical.', 'The Office / social media (2018)', 'Corporate asks you to compare unnecessary meeting and unnecessary call. They''re the same picture.', '{"comparison","equivalence","television","reaction"}'::text[], 'https://knowyourmeme.com/memes/theyre-the-same-picture', true)
on conflict (id) do update set
  title = excluded.title,
  meaning = excluded.meaning,
  origin = excluded.origin,
  example = excluded.example,
  tags = excluded.tags,
  research_source = excluded.research_source,
  origin_verified = excluded.origin_verified,
  updated_at = now();

insert into public.explained_meme_candidates
  (id, title, meaning, origin, example, tags, research_source, origin_verified)
values
  ('explained-30', 'Left Exit 12 Off Ramp', 'Shows someone abruptly abandoning the sensible route for a tempting or irrational alternative.', 'YouTube / Reddit (2017)', 'Finish the priority task; suddenly reorganise the entire desktop.', '{"choice","distraction","driving","object labelling"}'::text[], 'https://knowyourmeme.com/memes/left-exit-12-off-ramp', true)
on conflict (id) do update set
  title = excluded.title,
  meaning = excluded.meaning,
  origin = excluded.origin,
  example = excluded.example,
  tags = excluded.tags,
  research_source = excluded.research_source,
  origin_verified = excluded.origin_verified,
  updated_at = now();

insert into public.explained_meme_candidates
  (id, title, meaning, origin, example, tags, research_source, origin_verified)
values
  ('explained-31', 'Bike Fall', 'Blames another person or thing for a problem the subject clearly caused themselves.', 'Bâton Roue webcomic by Corentin Penloup / Tumblr-era circulation (2011)', 'Ignore every warning; system fails; blame the software.', '{"self-sabotage","blame","bicycle","comic"}'::text[], 'https://knowyourmeme.com/memes/bike-fall', true)
on conflict (id) do update set
  title = excluded.title,
  meaning = excluded.meaning,
  origin = excluded.origin,
  example = excluded.example,
  tags = excluded.tags,
  research_source = excluded.research_source,
  origin_verified = excluded.origin_verified,
  updated_at = now();

insert into public.explained_meme_candidates
  (id, title, meaning, origin, example, tags, research_source, origin_verified)
values
  ('explained-32', 'Clown Makeup', 'Shows a person progressing through increasingly foolish decisions until they have fully made a clown of themselves.', 'Facebook (May 2019) / Twitter spread (June 2019)', 'Say yes to one meeting; accept six more; wonder why no work gets done.', '{"escalation","self-delusion","clown","progression"}'::text[], 'https://knowyourmeme.com/memes/clown-makeup', true)
on conflict (id) do update set
  title = excluded.title,
  meaning = excluded.meaning,
  origin = excluded.origin,
  example = excluded.example,
  tags = excluded.tags,
  research_source = excluded.research_source,
  origin_verified = excluded.origin_verified,
  updated_at = now();

insert into public.explained_meme_candidates
  (id, title, meaning, origin, example, tags, research_source, origin_verified)
values
  ('explained-33', 'Epic Handshake', 'Highlights common ground, a shared trait or agreement between two otherwise different groups.', 'Predator footage / YouTube (2007)', 'Morning people and night owls: both hate 8 a.m. meetings.', '{"agreement","comparison","handshake","film"}'::text[], 'https://knowyourmeme.com/memes/epic-handshake', true)
on conflict (id) do update set
  title = excluded.title,
  meaning = excluded.meaning,
  origin = excluded.origin,
  example = excluded.example,
  tags = excluded.tags,
  research_source = excluded.research_source,
  origin_verified = excluded.origin_verified,
  updated_at = now();

insert into public.explained_meme_candidates
  (id, title, meaning, origin, example, tags, research_source, origin_verified)
values
  ('explained-34', 'Sweating Jordan Peele', 'Expresses extreme pressure, nervousness or panic when facing a difficult choice or discovery.', 'Key & Peele / reaction GIFs (2013)', 'When the client says, ‘Can you share your screen?’', '{"pressure","nervousness","reaction","comedy"}'::text[], 'https://knowyourmeme.com/memes/sweating-jordan-peele', true)
on conflict (id) do update set
  title = excluded.title,
  meaning = excluded.meaning,
  origin = excluded.origin,
  example = excluded.example,
  tags = excluded.tags,
  research_source = excluded.research_source,
  origin_verified = excluded.origin_verified,
  updated_at = now();

insert into public.explained_meme_candidates
  (id, title, meaning, origin, example, tags, research_source, origin_verified)
values
  ('explained-35', 'Vince McMahon Reaction', 'Escalates through several stages of excitement, approval or amazement.', 'YouTube / WWE footage (2013)', 'No meeting; email cancelled; deadline extended; Friday off.', '{"escalation","excitement","reaction","wrestling"}'::text[], 'https://knowyourmeme.com/memes/vince-mcmahon-reaction', true)
on conflict (id) do update set
  title = excluded.title,
  meaning = excluded.meaning,
  origin = excluded.origin,
  example = excluded.example,
  tags = excluded.tags,
  research_source = excluded.research_source,
  origin_verified = excluded.origin_verified,
  updated_at = now();

insert into public.explained_meme_candidates
  (id, title, meaning, origin, example, tags, research_source, origin_verified)
values
  ('explained-36', 'Roll Safe', 'Presents flawed reasoning as though it were a clever solution.', 'The Hood Documentary / Twitter (2016)', 'You cannot miss a deadline if you never set one.', '{"bad logic","cleverness","reaction","television"}'::text[], 'https://knowyourmeme.com/memes/roll-safe', true)
on conflict (id) do update set
  title = excluded.title,
  meaning = excluded.meaning,
  origin = excluded.origin,
  example = excluded.example,
  tags = excluded.tags,
  research_source = excluded.research_source,
  origin_verified = excluded.origin_verified,
  updated_at = now();

insert into public.explained_meme_candidates
  (id, title, meaning, origin, example, tags, research_source, origin_verified)
values
  ('explained-37', 'Arthur Fist', 'Represents controlled anger, frustration or the effort to remain calm.', 'Arthur / Twitter (2016)', 'When someone replies all to say ‘thanks.’', '{"anger","frustration","reaction","cartoon"}'::text[], 'https://knowyourmeme.com/memes/arthurs-fist', true)
on conflict (id) do update set
  title = excluded.title,
  meaning = excluded.meaning,
  origin = excluded.origin,
  example = excluded.example,
  tags = excluded.tags,
  research_source = excluded.research_source,
  origin_verified = excluded.origin_verified,
  updated_at = now();

insert into public.explained_meme_candidates
  (id, title, meaning, origin, example, tags, research_source, origin_verified)
values
  ('explained-38', 'Confused Nick Young', 'Reacts to a baffling, contradictory or nonsensical statement.', 'Through the Lens / YouTube (2014)', 'The project is urgent, but nobody has approved it.', '{"confusion","disbelief","reaction","interview"}'::text[], 'https://knowyourmeme.com/memes/confused-nick-young', true)
on conflict (id) do update set
  title = excluded.title,
  meaning = excluded.meaning,
  origin = excluded.origin,
  example = excluded.example,
  tags = excluded.tags,
  research_source = excluded.research_source,
  origin_verified = excluded.origin_verified,
  updated_at = now();

insert into public.explained_meme_candidates
  (id, title, meaning, origin, example, tags, research_source, origin_verified)
values
  ('explained-39', 'Blinking White Guy', 'Shows disbelief or surprise after hearing something absurd or unexpected.', 'NeoGAF / Giant Bomb footage (2015)', 'You want the report today, but the data arrives tomorrow?', '{"disbelief","surprise","reaction","GIF"}'::text[], 'https://knowyourmeme.com/memes/blinking-white-guy', true)
on conflict (id) do update set
  title = excluded.title,
  meaning = excluded.meaning,
  origin = excluded.origin,
  example = excluded.example,
  tags = excluded.tags,
  research_source = excluded.research_source,
  origin_verified = excluded.origin_verified,
  updated_at = now();

insert into public.explained_meme_candidates
  (id, title, meaning, origin, example, tags, research_source, origin_verified)
values
  ('explained-40', 'Michael Scott No God Please No', 'Expresses intense rejection, dread or horror at something happening again.', 'The Office, “Frame Toby” (2008)', 'Another mandatory team-building workshop? No, God, please no.', '{"rejection","dread","reaction","television"}'::text[], 'https://knowyourmeme.com/memes/michael-scott-no-god-please-no', true)
on conflict (id) do update set
  title = excluded.title,
  meaning = excluded.meaning,
  origin = excluded.origin,
  example = excluded.example,
  tags = excluded.tags,
  research_source = excluded.research_source,
  origin_verified = excluded.origin_verified,
  updated_at = now();

insert into public.explained_meme_candidates
  (id, title, meaning, origin, example, tags, research_source, origin_verified)
values
  ('explained-41', 'Oprah You Get a Car', 'Shows something being distributed freely or indiscriminately to everyone.', 'The Oprah Winfrey Show footage / YouTube (2008)', 'You get a meeting, you get a meeting, everybody gets a meeting.', '{"distribution","giveaway","reaction","television"}'::text[], 'https://knowyourmeme.com/memes/oprah-you-get-a-car', true)
on conflict (id) do update set
  title = excluded.title,
  meaning = excluded.meaning,
  origin = excluded.origin,
  example = excluded.example,
  tags = excluded.tags,
  research_source = excluded.research_source,
  origin_verified = excluded.origin_verified,
  updated_at = now();

insert into public.explained_meme_candidates
  (id, title, meaning, origin, example, tags, research_source, origin_verified)
values
  ('explained-42', 'Leonardo DiCaprio Cheers', 'Signals recognition, approval, congratulations or a knowing toast.', 'The Great Gatsby (2013)', 'The spreadsheet balances on the first attempt. Cheers.', '{"approval","toast","reaction","film"}'::text[], 'https://knowyourmeme.com/memes/leonardo-dicaprio-cheers', true)
on conflict (id) do update set
  title = excluded.title,
  meaning = excluded.meaning,
  origin = excluded.origin,
  example = excluded.example,
  tags = excluded.tags,
  research_source = excluded.research_source,
  origin_verified = excluded.origin_verified,
  updated_at = now();

insert into public.explained_meme_candidates
  (id, title, meaning, origin, example, tags, research_source, origin_verified)
values
  ('explained-43', 'Leonardo DiCaprio Laughing', 'Shows delighted, mocking or disbelieving laughter at another person''s claim.', 'Django Unchained footage / Tumblr (2017)', '‘It will only be a five-minute meeting.’', '{"laughter","mockery","reaction","film"}'::text[], 'https://knowyourmeme.com/memes/leonardo-dicaprio-laughing', true)
on conflict (id) do update set
  title = excluded.title,
  meaning = excluded.meaning,
  origin = excluded.origin,
  example = excluded.example,
  tags = excluded.tags,
  research_source = excluded.research_source,
  origin_verified = excluded.origin_verified,
  updated_at = now();

insert into public.explained_meme_candidates
  (id, title, meaning, origin, example, tags, research_source, origin_verified)
values
  ('explained-44', 'Sad Pablo Escobar', 'Represents lonely waiting, boredom or having nothing to do.', 'Narcos season 2 footage / social media (2016)', 'Waiting for someone to approve the final draft.', '{"waiting","loneliness","boredom","television"}'::text[], 'https://knowyourmeme.com/memes/pablo-escobar-waiting', true)
on conflict (id) do update set
  title = excluded.title,
  meaning = excluded.meaning,
  origin = excluded.origin,
  example = excluded.example,
  tags = excluded.tags,
  research_source = excluded.research_source,
  origin_verified = excluded.origin_verified,
  updated_at = now();

insert into public.explained_meme_candidates
  (id, title, meaning, origin, example, tags, research_source, origin_verified)
values
  ('explained-45', 'Waiting Skeleton', 'Exaggerates how long someone has been waiting for an event, reply or result.', 'Meme Generator “Waiting for OP” image macro (2010)', 'Me waiting for the ‘quick’ software update to finish.', '{"waiting","delay","skeleton","reaction"}'::text[], 'https://knowyourmeme.com/memes/waiting-for-op', true)
on conflict (id) do update set
  title = excluded.title,
  meaning = excluded.meaning,
  origin = excluded.origin,
  example = excluded.example,
  tags = excluded.tags,
  research_source = excluded.research_source,
  origin_verified = excluded.origin_verified,
  updated_at = now();

insert into public.explained_meme_candidates
  (id, title, meaning, origin, example, tags, research_source, origin_verified)
values
  ('explained-46', 'Confused Travolta', 'Shows someone looking around in confusion because something or somebody is missing.', 'Pulp Fiction footage / Imgur (2015)', 'Opening the shared folder after someone says the file is definitely there.', '{"confusion","searching","reaction","film"}'::text[], 'https://knowyourmeme.com/memes/confused-travolta', true)
on conflict (id) do update set
  title = excluded.title,
  meaning = excluded.meaning,
  origin = excluded.origin,
  example = excluded.example,
  tags = excluded.tags,
  research_source = excluded.research_source,
  origin_verified = excluded.origin_verified,
  updated_at = now();

insert into public.explained_meme_candidates
  (id, title, meaning, origin, example, tags, research_source, origin_verified)
values
  ('explained-47', 'Spider-Man Pointing', 'Compares two nearly identical people or groups accusing or recognising each other.', 'Spider-Man animated series / Sharenator (2011)', 'Marketing blaming Sales; Sales blaming Marketing.', '{"comparison","duplication","accusation","cartoon"}'::text[], 'https://knowyourmeme.com/memes/spider-man-pointing-at-spider-man', true)
on conflict (id) do update set
  title = excluded.title,
  meaning = excluded.meaning,
  origin = excluded.origin,
  example = excluded.example,
  tags = excluded.tags,
  research_source = excluded.research_source,
  origin_verified = excluded.origin_verified,
  updated_at = now();

insert into public.explained_meme_candidates
  (id, title, meaning, origin, example, tags, research_source, origin_verified)
values
  ('explained-48', 'Batman Slapping Robin', 'A blunt interruption or correction delivered before the other person can finish speaking.', 'World’s Finest Comics #153 (1965) / image-macro circulation (late 2000s)', 'Robin: Let’s add another feature— Batman: Ship the current version.', '{"dialogue","interruption","correction","comic"}'::text[], 'https://knowyourmeme.com/memes/batman-slapping-robin', true)
on conflict (id) do update set
  title = excluded.title,
  meaning = excluded.meaning,
  origin = excluded.origin,
  example = excluded.example,
  tags = excluded.tags,
  research_source = excluded.research_source,
  origin_verified = excluded.origin_verified,
  updated_at = now();

insert into public.explained_meme_candidates
  (id, title, meaning, origin, example, tags, research_source, origin_verified)
values
  ('explained-49', 'Trollface', 'Signals deliberate trolling, provocation or satisfaction after causing annoyance.', 'DeviantArt (2008)', 'Changes the group-chat name and waits for the notifications.', '{"trolling","character","reaction","rage comic"}'::text[], 'https://knowyourmeme.com/memes/trollface', true)
on conflict (id) do update set
  title = excluded.title,
  meaning = excluded.meaning,
  origin = excluded.origin,
  example = excluded.example,
  tags = excluded.tags,
  research_source = excluded.research_source,
  origin_verified = excluded.origin_verified,
  updated_at = now();

insert into public.explained_meme_candidates
  (id, title, meaning, origin, example, tags, research_source, origin_verified)
values
  ('explained-50', 'Grumpy Cat', 'Expresses persistent displeasure, pessimism or rejection.', 'Reddit (2012)', 'Team celebration scheduled for 8 a.m. No.', '{"cat","displeasure","reaction","character"}'::text[], 'https://knowyourmeme.com/memes/grumpy-cat', true)
on conflict (id) do update set
  title = excluded.title,
  meaning = excluded.meaning,
  origin = excluded.origin,
  example = excluded.example,
  tags = excluded.tags,
  research_source = excluded.research_source,
  origin_verified = excluded.origin_verified,
  updated_at = now();

insert into public.explained_meme_candidates
  (id, title, meaning, origin, example, tags, research_source, origin_verified)
values
  ('explained-51', 'Nyan Cat', 'A flying pixel cat with a rainbow trail, used as a playful symbol of early internet absurdity.', 'LOL-COMICS (2011)', 'The report is late, but at least the loading animation is cheerful.', '{"cat","pixel art","rainbow","internet classic"}'::text[], 'https://knowyourmeme.com/memes/nyan-cat-pop-tart-cat', true)
on conflict (id) do update set
  title = excluded.title,
  meaning = excluded.meaning,
  origin = excluded.origin,
  example = excluded.example,
  tags = excluded.tags,
  research_source = excluded.research_source,
  origin_verified = excluded.origin_verified,
  updated_at = now();

insert into public.explained_meme_candidates
  (id, title, meaning, origin, example, tags, research_source, origin_verified)
values
  ('explained-52', 'Keyboard Cat', 'A cat playing a keyboard, often used as a humorous outro after failure or embarrassment.', 'YouTube (2009)', 'Presentation crashes on the final slide. Play him off, Keyboard Cat.', '{"cat","failure","outro","video"}'::text[], 'https://knowyourmeme.com/memes/keyboard-cat', true)
on conflict (id) do update set
  title = excluded.title,
  meaning = excluded.meaning,
  origin = excluded.origin,
  example = excluded.example,
  tags = excluded.tags,
  research_source = excluded.research_source,
  origin_verified = excluded.origin_verified,
  updated_at = now();

insert into public.explained_meme_candidates
  (id, title, meaning, origin, example, tags, research_source, origin_verified)
values
  ('explained-53', 'Dramatic Chipmunk', 'A sudden dramatic turn toward the camera that exaggerates a reveal or accusation.', 'YouTube (2007)', 'Someone mentions the missing budget line. Dramatic turn.', '{"dramatic reveal","reaction","animal","video"}'::text[], 'https://knowyourmeme.com/memes/dramatic-chipmunk', true)
on conflict (id) do update set
  title = excluded.title,
  meaning = excluded.meaning,
  origin = excluded.origin,
  example = excluded.example,
  tags = excluded.tags,
  research_source = excluded.research_source,
  origin_verified = excluded.origin_verified,
  updated_at = now();

insert into public.explained_meme_candidates
  (id, title, meaning, origin, example, tags, research_source, origin_verified)
values
  ('explained-54', 'Ermahgerd', 'Represents overwhelming nerdy excitement using deliberately distorted pronunciation.', 'Reddit (2012)', 'Ermahgerd, the meeting was cancelled!', '{"excitement","character macro","books","pronunciation"}'::text[], 'https://knowyourmeme.com/memes/ermahgerd', true)
on conflict (id) do update set
  title = excluded.title,
  meaning = excluded.meaning,
  origin = excluded.origin,
  example = excluded.example,
  tags = excluded.tags,
  research_source = excluded.research_source,
  origin_verified = excluded.origin_verified,
  updated_at = now();

insert into public.explained_meme_candidates
  (id, title, meaning, origin, example, tags, research_source, origin_verified)
values
  ('explained-55', 'Overly Attached Girlfriend', 'Portrays obsessive, possessive or uncomfortably intense attention.', 'YouTube (2012)', 'You said you were busy, so I checked all twelve status indicators.', '{"obsession","character macro","relationship","video"}'::text[], 'https://knowyourmeme.com/memes/overly-attached-girlfriend', true)
on conflict (id) do update set
  title = excluded.title,
  meaning = excluded.meaning,
  origin = excluded.origin,
  example = excluded.example,
  tags = excluded.tags,
  research_source = excluded.research_source,
  origin_verified = excluded.origin_verified,
  updated_at = now();

insert into public.explained_meme_candidates
  (id, title, meaning, origin, example, tags, research_source, origin_verified)
values
  ('explained-56', 'Scumbag Steve', 'Labels inconsiderate, selfish or socially obnoxious behaviour.', 'Reddit (2011)', 'Borrows your charger; returns only the cable.', '{"selfishness","character macro","advice animal","behaviour"}'::text[], 'https://knowyourmeme.com/memes/scumbag-steve', true)
on conflict (id) do update set
  title = excluded.title,
  meaning = excluded.meaning,
  origin = excluded.origin,
  example = excluded.example,
  tags = excluded.tags,
  research_source = excluded.research_source,
  origin_verified = excluded.origin_verified,
  updated_at = now();

insert into public.explained_meme_candidates
  (id, title, meaning, origin, example, tags, research_source, origin_verified)
values
  ('explained-57', 'Condescending Wonka', 'Pairs a patronising reaction with sarcastic disbelief about somebody''s claim.', 'Quickmeme (2010)', 'You finished one task early? Please, tell me more about productivity.', '{"sarcasm","condescension","reaction","film"}'::text[], 'https://knowyourmeme.com/memes/condescending-wonka-creepy-wonka', true)
on conflict (id) do update set
  title = excluded.title,
  meaning = excluded.meaning,
  origin = excluded.origin,
  example = excluded.example,
  tags = excluded.tags,
  research_source = excluded.research_source,
  origin_verified = excluded.origin_verified,
  updated_at = now();

insert into public.explained_meme_candidates
  (id, title, meaning, origin, example, tags, research_source, origin_verified)
values
  ('explained-58', 'The Most Interesting Man in the World', 'Uses the structure ‘I don''t always X, but when I do, Y’ for an exaggerated personal rule.', 'Dos Equis television commercial (2007)', 'I don''t always join meetings, but when I do, they could have been emails.', '{"statement","advertising","character macro","catchphrase"}'::text[], 'https://knowyourmeme.com/memes/the-most-interesting-man-in-the-world', true)
on conflict (id) do update set
  title = excluded.title,
  meaning = excluded.meaning,
  origin = excluded.origin,
  example = excluded.example,
  tags = excluded.tags,
  research_source = excluded.research_source,
  origin_verified = excluded.origin_verified,
  updated_at = now();

insert into public.explained_meme_candidates
  (id, title, meaning, origin, example, tags, research_source, origin_verified)
values
  ('explained-59', 'First World Problems', 'Mocks minor inconveniences experienced from a position of comfort or privilege.', 'Unknown / image-macro culture (2011)', 'The Wi-Fi reaches the sofa but not the garden chair.', '{"minor problem","privilege","character macro","complaint"}'::text[], 'https://knowyourmeme.com/memes/first-world-problems', true)
on conflict (id) do update set
  title = excluded.title,
  meaning = excluded.meaning,
  origin = excluded.origin,
  example = excluded.example,
  tags = excluded.tags,
  research_source = excluded.research_source,
  origin_verified = excluded.origin_verified,
  updated_at = now();

insert into public.explained_meme_candidates
  (id, title, meaning, origin, example, tags, research_source, origin_verified)
values
  ('explained-60', 'Salt Bae', 'Shows someone adding a final touch with excessive flair or theatrical confidence.', 'Twitter (2017)', 'Adds one emoji to the quarterly report. Salt Bae.', '{"flair","finishing touch","reaction","video"}'::text[], 'https://knowyourmeme.com/memes/salt-bae', true)
on conflict (id) do update set
  title = excluded.title,
  meaning = excluded.meaning,
  origin = excluded.origin,
  example = excluded.example,
  tags = excluded.tags,
  research_source = excluded.research_source,
  origin_verified = excluded.origin_verified,
  updated_at = now();

insert into public.explained_meme_candidates
  (id, title, meaning, origin, example, tags, research_source, origin_verified)
values
  ('explained-61', 'Kermit Sipping Tea', 'Makes a pointed observation while pretending it is none of the speaker''s business.', 'Lipton “Be More Tea” advertisement / Instagram (2014)', 'Somebody deleted the backup, but that''s none of my business.', '{"commentary","gossip","reaction","advertising"}'::text[], 'https://knowyourmeme.com/memes/kermit-sipping-tea', true)
on conflict (id) do update set
  title = excluded.title,
  meaning = excluded.meaning,
  origin = excluded.origin,
  example = excluded.example,
  tags = excluded.tags,
  research_source = excluded.research_source,
  origin_verified = excluded.origin_verified,
  updated_at = now();

insert into public.explained_meme_candidates
  (id, title, meaning, origin, example, tags, research_source, origin_verified)
values
  ('explained-62', 'Evil Kermit', 'Shows an internal struggle where a bad inner voice encourages temptation or irresponsible behaviour.', 'Twitter (2016)', 'Me: save the document. Evil me: close it and trust autosave.', '{"temptation","inner conflict","dialogue","film"}'::text[], 'https://knowyourmeme.com/memes/evil-kermit', true)
on conflict (id) do update set
  title = excluded.title,
  meaning = excluded.meaning,
  origin = excluded.origin,
  example = excluded.example,
  tags = excluded.tags,
  research_source = excluded.research_source,
  origin_verified = excluded.origin_verified,
  updated_at = now();

insert into public.explained_meme_candidates
  (id, title, meaning, origin, example, tags, research_source, origin_verified)
values
  ('explained-63', 'Sad Keanu', 'Represents loneliness, sadness or quietly eating alone.', 'Reddit (2010)', 'When everyone is working from home except you.', '{"sadness","loneliness","reaction","celebrity"}'::text[], 'https://knowyourmeme.com/memes/sad-keanu', true)
on conflict (id) do update set
  title = excluded.title,
  meaning = excluded.meaning,
  origin = excluded.origin,
  example = excluded.example,
  tags = excluded.tags,
  research_source = excluded.research_source,
  origin_verified = excluded.origin_verified,
  updated_at = now();

insert into public.explained_meme_candidates
  (id, title, meaning, origin, example, tags, research_source, origin_verified)
values
  ('explained-64', 'Side-Eyeing Chloe', 'A suspicious or uncomfortable side-eye used when something sounds strange or unconvincing.', 'YouTube footage / Tumblr (2013)', 'Manager: this reorganisation will simplify everything. Chloe side-eye.', '{"suspicion","awkwardness","reaction","video"}'::text[], 'https://knowyourmeme.com/memes/side-eyeing-chloe', true)
on conflict (id) do update set
  title = excluded.title,
  meaning = excluded.meaning,
  origin = excluded.origin,
  example = excluded.example,
  tags = excluded.tags,
  research_source = excluded.research_source,
  origin_verified = excluded.origin_verified,
  updated_at = now();

insert into public.explained_meme_candidates
  (id, title, meaning, origin, example, tags, research_source, origin_verified)
values
  ('explained-65', 'Kombucha Girl', 'Shows a rapid shift between dislike and tentative approval while evaluating something.', 'TikTok video by Brittany Broski (August 2019)', 'A four-day workweek? At first unsure… actually, yes.', '{"evaluation","reaction","TikTok","mixed feelings"}'::text[], 'https://knowyourmeme.com/memes/kombucha-girl', true)
on conflict (id) do update set
  title = excluded.title,
  meaning = excluded.meaning,
  origin = excluded.origin,
  example = excluded.example,
  tags = excluded.tags,
  research_source = excluded.research_source,
  origin_verified = excluded.origin_verified,
  updated_at = now();

insert into public.explained_meme_candidates
  (id, title, meaning, origin, example, tags, research_source, origin_verified)
values
  ('explained-66', 'Confused Math Lady', 'Visualises intense confusion or mental calculation in response to something difficult to understand.', 'Senhora do Destino footage / UKMix (2013)', 'Trying to understand how five small tasks became forty hours of work.', '{"confusion","calculation","reaction","television"}'::text[], 'https://knowyourmeme.com/memes/confused-math-lady', true)
on conflict (id) do update set
  title = excluded.title,
  meaning = excluded.meaning,
  origin = excluded.origin,
  example = excluded.example,
  tags = excluded.tags,
  research_source = excluded.research_source,
  origin_verified = excluded.origin_verified,
  updated_at = now();

insert into public.explained_meme_candidates
  (id, title, meaning, origin, example, tags, research_source, origin_verified)
values
  ('explained-67', 'Crying Jordan', 'Places Michael Jordan''s crying face onto people or things experiencing defeat or disappointment.', 'Hall of Fame speech (2009)', 'My weekend plans after seeing Monday''s deadline.', '{"defeat","disappointment","reaction","sports"}'::text[], 'https://knowyourmeme.com/memes/crying-michael-jordan', true)
on conflict (id) do update set
  title = excluded.title,
  meaning = excluded.meaning,
  origin = excluded.origin,
  example = excluded.example,
  tags = excluded.tags,
  research_source = excluded.research_source,
  origin_verified = excluded.origin_verified,
  updated_at = now();

insert into public.explained_meme_candidates
  (id, title, meaning, origin, example, tags, research_source, origin_verified)
values
  ('explained-68', 'Ight Imma Head Out', 'Signals an immediate decision to leave after hearing or seeing something undesirable.', 'Twitter (2019)', 'The meeting has no agenda? Ight, imma head out.', '{"exit","reaction","cartoon","departure"}'::text[], 'https://knowyourmeme.com/memes/ight-imma-head-out', true)
on conflict (id) do update set
  title = excluded.title,
  meaning = excluded.meaning,
  origin = excluded.origin,
  example = excluded.example,
  tags = excluded.tags,
  research_source = excluded.research_source,
  origin_verified = excluded.origin_verified,
  updated_at = now();

insert into public.explained_meme_candidates
  (id, title, meaning, origin, example, tags, research_source, origin_verified)
values
  ('explained-69', 'Patrick Wallet', 'A dialogue where clear logic repeatedly fails to persuade someone who refuses the obvious conclusion.', 'SpongeBob SquarePants footage / Imgur (2013)', 'You asked for the report. This is the report. So you received it? No.', '{"dialogue","failed reasoning","frustration","cartoon"}'::text[], 'https://knowyourmeme.com/memes/patrick-stars-wallet', true)
on conflict (id) do update set
  title = excluded.title,
  meaning = excluded.meaning,
  origin = excluded.origin,
  example = excluded.example,
  tags = excluded.tags,
  research_source = excluded.research_source,
  origin_verified = excluded.origin_verified,
  updated_at = now();

insert into public.explained_meme_candidates
  (id, title, meaning, origin, example, tags, research_source, origin_verified)
values
  ('explained-70', 'Caveman SpongeBob', 'Represents primitive panic, sudden threat detection or an instinctive overreaction.', 'SpongeBob SquarePants footage / 4chan (2015)', 'Hearing the email notification after logging off.', '{"panic","primitive reaction","cartoon","threat"}'::text[], 'https://knowyourmeme.com/memes/spongegar-primitive-sponge-caveman-spongebob', true)
on conflict (id) do update set
  title = excluded.title,
  meaning = excluded.meaning,
  origin = excluded.origin,
  example = excluded.example,
  tags = excluded.tags,
  research_source = excluded.research_source,
  origin_verified = excluded.origin_verified,
  updated_at = now();

insert into public.explained_meme_candidates
  (id, title, meaning, origin, example, tags, research_source, origin_verified)
values
  ('explained-71', 'Mr. Krabs Blur', 'Shows disorientation, panic or sensory overload in a chaotic situation.', 'SpongeBob SquarePants footage / Twitter (2016)', 'When three people ask questions while your screen is sharing.', '{"disorientation","panic","reaction","cartoon"}'::text[], 'https://knowyourmeme.com/memes/confused-mr-krabs', true)
on conflict (id) do update set
  title = excluded.title,
  meaning = excluded.meaning,
  origin = excluded.origin,
  example = excluded.example,
  tags = excluded.tags,
  research_source = excluded.research_source,
  origin_verified = excluded.origin_verified,
  updated_at = now();

insert into public.explained_meme_candidates
  (id, title, meaning, origin, example, tags, research_source, origin_verified)
values
  ('explained-72', 'SpongeBob Imagination Rainbow', 'Adds an ironic or enthusiastic label to something being imagined or exaggerated.', 'SpongeBob SquarePants, “Idiot Box” (2002) / image-macro culture', 'Imagine… documentation that is actually current.', '{"imagination","irony","statement","cartoon"}'::text[], 'https://knowyourmeme.com/memes/spongebob-imagination', true)
on conflict (id) do update set
  title = excluded.title,
  meaning = excluded.meaning,
  origin = excluded.origin,
  example = excluded.example,
  tags = excluded.tags,
  research_source = excluded.research_source,
  origin_verified = excluded.origin_verified,
  updated_at = now();

insert into public.explained_meme_candidates
  (id, title, meaning, origin, example, tags, research_source, origin_verified)
values
  ('explained-73', 'Anakin and Padmé Four-Panel', 'Starts with an optimistic assumption and ends with uneasy silence when reassurance never comes.', 'Star Wars footage / Twitter (2021)', 'You tested the backup, right? You tested it, right?', '{"dialogue","expectation","silence","film"}'::text[], 'https://knowyourmeme.com/memes/for-the-better-right', true)
on conflict (id) do update set
  title = excluded.title,
  meaning = excluded.meaning,
  origin = excluded.origin,
  example = excluded.example,
  tags = excluded.tags,
  research_source = excluded.research_source,
  origin_verified = excluded.origin_verified,
  updated_at = now();

insert into public.explained_meme_candidates
  (id, title, meaning, origin, example, tags, research_source, origin_verified)
values
  ('explained-74', 'It''s Over Anakin, I Have the High Ground', 'Claims a decisive advantage, often followed by overconfidence or a failed challenge.', 'Star Wars: Episode III – Revenge of the Sith (2005)', 'I have the approved version. You underestimate my duplicate files.', '{"advantage","dialogue","film","overconfidence"}'::text[], 'https://knowyourmeme.com/memes/its-over-anakin-i-have-the-high-ground', true)
on conflict (id) do update set
  title = excluded.title,
  meaning = excluded.meaning,
  origin = excluded.origin,
  example = excluded.example,
  tags = excluded.tags,
  research_source = excluded.research_source,
  origin_verified = excluded.origin_verified,
  updated_at = now();

insert into public.explained_meme_candidates
  (id, title, meaning, origin, example, tags, research_source, origin_verified)
values
  ('explained-75', 'Thanos: What Did It Cost?', 'Pairs an achievement with the painful sacrifice required to obtain it.', 'Avengers: Infinity War (2018)', 'Inbox zero. What did it cost? The entire afternoon.', '{"sacrifice","dialogue","success","film"}'::text[], 'https://knowyourmeme.com/memes/what-did-it-cost-everything', true)
on conflict (id) do update set
  title = excluded.title,
  meaning = excluded.meaning,
  origin = excluded.origin,
  example = excluded.example,
  tags = excluded.tags,
  research_source = excluded.research_source,
  origin_verified = excluded.origin_verified,
  updated_at = now();

insert into public.explained_meme_candidates
  (id, title, meaning, origin, example, tags, research_source, origin_verified)
values
  ('explained-76', 'Captain America Elevator', 'Represents rising tension, recognising danger or calmly preparing for a confrontation.', 'Marvel film footage / Instagram (2019)', 'When the meeting title says ‘quick alignment’ and Legal joins.', '{"tension","recognition","reaction","film"}'::text[], 'https://knowyourmeme.com/memes/captain-america-elevator-fight', true)
on conflict (id) do update set
  title = excluded.title,
  meaning = excluded.meaning,
  origin = excluded.origin,
  example = excluded.example,
  tags = excluded.tags,
  research_source = excluded.research_source,
  origin_verified = excluded.origin_verified,
  updated_at = now();

insert into public.explained_meme_candidates
  (id, title, meaning, origin, example, tags, research_source, origin_verified)
values
  ('explained-77', 'Ralph Wiggum: I''m in Danger', 'Calmly acknowledges that a situation is obviously becoming dangerous or disastrous.', 'Family Guy/The Simpsons crossover “The Simpsons Guy” (2014)', 'Deploying on Friday afternoon: I''m in danger.', '{"danger","reaction","cartoon","understatement"}'::text[], 'https://knowyourmeme.com/memes/ralph-in-danger-im-in-danger', true)
on conflict (id) do update set
  title = excluded.title,
  meaning = excluded.meaning,
  origin = excluded.origin,
  example = excluded.example,
  tags = excluded.tags,
  research_source = excluded.research_source,
  origin_verified = excluded.origin_verified,
  updated_at = now();

insert into public.explained_meme_candidates
  (id, title, meaning, origin, example, tags, research_source, origin_verified)
values
  ('explained-78', 'Homer Disappearing into Bushes', 'Shows an embarrassed retreat or quietly withdrawing from an awkward situation.', 'The Simpsons / GIF culture (2010)', 'Volunteers an idea; realises it means more work; disappears.', '{"exit","embarrassment","reaction","cartoon"}'::text[], 'https://knowyourmeme.com/memes/homer-simpson-backs-into-bushes', true)
on conflict (id) do update set
  title = excluded.title,
  meaning = excluded.meaning,
  origin = excluded.origin,
  example = excluded.example,
  tags = excluded.tags,
  research_source = excluded.research_source,
  origin_verified = excluded.origin_verified,
  updated_at = now();

insert into public.explained_meme_candidates
  (id, title, meaning, origin, example, tags, research_source, origin_verified)
values
  ('explained-79', 'Principal Skinner: Pathetic', 'A dismissive judgement aimed at a weak attempt or unimpressive result.', 'The Simpsons footage / Tumblr (2016)', 'The password is still ‘password1’? Pathetic.', '{"dismissal","judgement","reaction","cartoon"}'::text[], 'https://knowyourmeme.com/memes/principal-skinners-pathetic', true)
on conflict (id) do update set
  title = excluded.title,
  meaning = excluded.meaning,
  origin = excluded.origin,
  example = excluded.example,
  tags = excluded.tags,
  research_source = excluded.research_source,
  origin_verified = excluded.origin_verified,
  updated_at = now();

insert into public.explained_meme_candidates
  (id, title, meaning, origin, example, tags, research_source, origin_verified)
values
  ('explained-80', 'Lisa Simpson Presentation', 'Uses a presentation screen to state an opinion, argument or uncomfortable truth.', 'The Simpsons footage / Reddit (2018)', 'More meetings do not fix unclear decisions.', '{"opinion","presentation","statement","cartoon"}'::text[], 'https://knowyourmeme.com/memes/lisa-simpsons-presentation', true)
on conflict (id) do update set
  title = excluded.title,
  meaning = excluded.meaning,
  origin = excluded.origin,
  example = excluded.example,
  tags = excluded.tags,
  research_source = excluded.research_source,
  origin_verified = excluded.origin_verified,
  updated_at = now();

insert into public.explained_meme_candidates
  (id, title, meaning, origin, example, tags, research_source, origin_verified)
values
  ('explained-81', 'Grandpa Simpson Walks In and Out', 'Shows immediately reversing course and leaving after seeing an undesirable situation.', 'The Simpsons, “Bart After Dark” (1996) / looping GIF culture', 'Joins call; hears ‘icebreaker’; turns around.', '{"exit","reversal","reaction","cartoon"}'::text[], 'https://knowyourmeme.com/memes/grandpa-simpson-walks-in-and-out', true)
on conflict (id) do update set
  title = excluded.title,
  meaning = excluded.meaning,
  origin = excluded.origin,
  example = excluded.example,
  tags = excluded.tags,
  research_source = excluded.research_source,
  origin_verified = excluded.origin_verified,
  updated_at = now();

insert into public.explained_meme_candidates
  (id, title, meaning, origin, example, tags, research_source, origin_verified)
values
  ('explained-82', 'Who Killed Hannibal?', 'Shows someone causing a problem and then blaming an unrelated person or group for it.', 'The Eric Andre Show footage (2013) / viral image-macro spread (2018)', 'Removes the deadline, project runs late: Who could have caused this?', '{"self-sabotage","blame","television","dialogue"}'::text[], 'https://knowyourmeme.com/memes/who-killed-hannibal', true)
on conflict (id) do update set
  title = excluded.title,
  meaning = excluded.meaning,
  origin = excluded.origin,
  example = excluded.example,
  tags = excluded.tags,
  research_source = excluded.research_source,
  origin_verified = excluded.origin_verified,
  updated_at = now();

insert into public.explained_meme_candidates
  (id, title, meaning, origin, example, tags, research_source, origin_verified)
values
  ('explained-83', 'I Guess I''ll Die', 'A resigned response to a small inconvenience presented as though no alternative exists.', 'Stock photograph of Mike Baldwin / reaction-image circulation (2016)', 'The coffee machine is empty. I guess I''ll die.', '{"resignation","reaction","webcomic","inconvenience"}'::text[], 'https://knowyourmeme.com/memes/i-guess-ill-die', true)
on conflict (id) do update set
  title = excluded.title,
  meaning = excluded.meaning,
  origin = excluded.origin,
  example = excluded.example,
  tags = excluded.tags,
  research_source = excluded.research_source,
  origin_verified = excluded.origin_verified,
  updated_at = now();

insert into public.explained_meme_candidates
  (id, title, meaning, origin, example, tags, research_source, origin_verified)
values
  ('explained-84', 'Tuxedo Winnie the Pooh', 'Compares an ordinary expression or choice with a supposedly refined, formal alternative.', 'Winnie the Pooh and Tigger Too (1974) / 4chan and Reddit spread (2019)', 'Problem. Issue. Strategic opportunity.', '{"comparison","refined","wording","cartoon"}'::text[], 'https://knowyourmeme.com/memes/tuxedo-winnie-the-pooh', true)
on conflict (id) do update set
  title = excluded.title,
  meaning = excluded.meaning,
  origin = excluded.origin,
  example = excluded.example,
  tags = excluded.tags,
  research_source = excluded.research_source,
  origin_verified = excluded.origin_verified,
  updated_at = now();

insert into public.explained_meme_candidates
  (id, title, meaning, origin, example, tags, research_source, origin_verified)
values
  ('explained-85', 'Bell Curve / IQ Distribution', 'Shows two extremes reaching the same simple conclusion while the middle overcomplicates it.', '4chan “midwit” format (2017); Wojak bell-curve variant popularised later', 'Beginner: save the file. Expert: save the file. Middle: build a twelve-step sync workflow.', '{"comparison","intelligence","bell curve","overthinking"}'::text[], 'https://knowyourmeme.com/memes/iq-bell-curve-midwit', true)
on conflict (id) do update set
  title = excluded.title,
  meaning = excluded.meaning,
  origin = excluded.origin,
  example = excluded.example,
  tags = excluded.tags,
  research_source = excluded.research_source,
  origin_verified = excluded.origin_verified,
  updated_at = now();

insert into public.explained_meme_candidates
  (id, title, meaning, origin, example, tags, research_source, origin_verified)
values
  ('explained-86', 'Hard to Swallow Pills', 'Labels an uncomfortable fact as medicine that is difficult but necessary to accept.', 'WikiHow stock illustrations (2017) / Reddit spread (2018)', 'Busy is not the same as productive.', '{"uncomfortable truth","opinion","pill","webcomic"}'::text[], 'https://knowyourmeme.com/memes/hard-to-swallow-pills', true)
on conflict (id) do update set
  title = excluded.title,
  meaning = excluded.meaning,
  origin = excluded.origin,
  example = excluded.example,
  tags = excluded.tags,
  research_source = excluded.research_source,
  origin_verified = excluded.origin_verified,
  updated_at = now();

insert into public.explained_meme_candidates
  (id, title, meaning, origin, example, tags, research_source, origin_verified)
values
  ('explained-87', 'Nobody:', 'Frames an action as completely unprompted by showing that nobody asked for it.', 'Twitter “Literally Nobody” format (2018)', 'Nobody: Absolutely nobody: Printer: low cyan, cannot print black.', '{"unprompted behaviour","text format","silence","reaction"}'::text[], 'https://knowyourmeme.com/memes/nobody', true)
on conflict (id) do update set
  title = excluded.title,
  meaning = excluded.meaning,
  origin = excluded.origin,
  example = excluded.example,
  tags = excluded.tags,
  research_source = excluded.research_source,
  origin_verified = excluded.origin_verified,
  updated_at = now();

insert into public.explained_meme_candidates
  (id, title, meaning, origin, example, tags, research_source, origin_verified)
values
  ('explained-88', 'Panik Kalm Panik', 'Moves from panic to relief and back to panic when new information changes the situation.', 'Meme Man format / Reddit (February 2020)', 'Deadline today. Panik. Extension granted. Kalm. Extension is ten minutes. Panik.', '{"escalation","panic","relief","Meme Man"}'::text[], 'https://knowyourmeme.com/memes/panik-kalm-panik', true)
on conflict (id) do update set
  title = excluded.title,
  meaning = excluded.meaning,
  origin = excluded.origin,
  example = excluded.example,
  tags = excluded.tags,
  research_source = excluded.research_source,
  origin_verified = excluded.origin_verified,
  updated_at = now();

insert into public.explained_meme_candidates
  (id, title, meaning, origin, example, tags, research_source, origin_verified)
values
  ('explained-89', 'Stonks', 'Ironic approval of a foolish financial or strategic decision presented as profit or success.', 'Special Meme Fresh / Facebook (June 2017)', 'Spend €20 to avoid a €5 delivery fee. Stonks.', '{"ironic success","finance","Meme Man","reaction"}'::text[], 'https://knowyourmeme.com/memes/stonks', true)
on conflict (id) do update set
  title = excluded.title,
  meaning = excluded.meaning,
  origin = excluded.origin,
  example = excluded.example,
  tags = excluded.tags,
  research_source = excluded.research_source,
  origin_verified = excluded.origin_verified,
  updated_at = now();

insert into public.explained_meme_candidates
  (id, title, meaning, origin, example, tags, research_source, origin_verified)
values
  ('explained-90', 'American Chopper Argument', 'Turns a disagreement into an escalating multi-panel shouting match.', 'American Chopper footage (2009); viral Twitter format (2018)', 'We need fewer meetings. Let''s schedule a meeting to discuss it.', '{"argument","dialogue","television","escalation"}'::text[], 'https://knowyourmeme.com/memes/american-chopper-argument', true)
on conflict (id) do update set
  title = excluded.title,
  meaning = excluded.meaning,
  origin = excluded.origin,
  example = excluded.example,
  tags = excluded.tags,
  research_source = excluded.research_source,
  origin_verified = excluded.origin_verified,
  updated_at = now();

insert into public.explained_meme_candidates
  (id, title, meaning, origin, example, tags, research_source, origin_verified)
values
  ('explained-91', 'Gigachad', 'Represents an exaggerated ideal of confidence, strength or unapologetic self-assurance.', 'Sleek’N’Tears photography by Krista Sudmalis / 4chan (2017)', 'Reads the instructions before starting. Gigachad.', '{"confidence","character","physique","reaction"}'::text[], 'https://knowyourmeme.com/memes/gigachad', true)
on conflict (id) do update set
  title = excluded.title,
  meaning = excluded.meaning,
  origin = excluded.origin,
  example = excluded.example,
  tags = excluded.tags,
  research_source = excluded.research_source,
  origin_verified = excluded.origin_verified,
  updated_at = now();

insert into public.explained_meme_candidates
  (id, title, meaning, origin, example, tags, research_source, origin_verified)
values
  ('explained-92', 'Virgin vs. Chad', 'Contrasts an insecure or overcomplicated character with a confident, exaggerated counterpart.', '4chan /r9k/ (2017)', 'Virgin twelve-tab workflow vs. Chad single checklist.', '{"comparison","character","confidence","drawing"}'::text[], 'https://knowyourmeme.com/memes/virgin-vs-chad', true)
on conflict (id) do update set
  title = excluded.title,
  meaning = excluded.meaning,
  origin = excluded.origin,
  example = excluded.example,
  tags = excluded.tags,
  research_source = excluded.research_source,
  origin_verified = excluded.origin_verified,
  updated_at = now();

insert into public.explained_meme_candidates
  (id, title, meaning, origin, example, tags, research_source, origin_verified)
values
  ('explained-93', 'Wojak', 'A simple drawn character used to express melancholy, frustration, nostalgia and many other emotions.', 'Polish imageboard Vichan (2009) / Krautchan (2010)', 'Says ‘no worries’ after receiving the fourth revision request.', '{"character","reaction","drawing","emotion"}'::text[], 'https://knowyourmeme.com/memes/wojak-feels-guy', true)
on conflict (id) do update set
  title = excluded.title,
  meaning = excluded.meaning,
  origin = excluded.origin,
  example = excluded.example,
  tags = excluded.tags,
  research_source = excluded.research_source,
  origin_verified = excluded.origin_verified,
  updated_at = now();

insert into public.explained_meme_candidates
  (id, title, meaning, origin, example, tags, research_source, origin_verified)
values
  ('explained-94', 'NPC Wojak', 'Portrays somebody as conformist, repetitive or following a script without independent thought.', '4chan (2016); mainstream political spread (2018)', 'Every consultant slide: leverage synergies, unlock value, transform.', '{"conformity","scripted behaviour","character","drawing"}'::text[], 'https://knowyourmeme.com/memes/npc-wojak', true)
on conflict (id) do update set
  title = excluded.title,
  meaning = excluded.meaning,
  origin = excluded.origin,
  example = excluded.example,
  tags = excluded.tags,
  research_source = excluded.research_source,
  origin_verified = excluded.origin_verified,
  updated_at = now();

insert into public.explained_meme_candidates
  (id, title, meaning, origin, example, tags, research_source, origin_verified)
values
  ('explained-95', 'Soyjak Pointing', 'Shows exaggerated excitement or recognition, often mockingly aimed at shallow enthusiasm.', 'John Oberg photograph / Twitter (February 2020); Soyjak adaptation later in 2020', 'Look! The app changed the button colour!', '{"excitement","pointing","character","reaction"}'::text[], 'https://knowyourmeme.com/memes/two-soyjaks-pointing', true)
on conflict (id) do update set
  title = excluded.title,
  meaning = excluded.meaning,
  origin = excluded.origin,
  example = excluded.example,
  tags = excluded.tags,
  research_source = excluded.research_source,
  origin_verified = excluded.origin_verified,
  updated_at = now();

insert into public.explained_meme_candidates
  (id, title, meaning, origin, example, tags, research_source, origin_verified)
values
  ('explained-96', 'Pepe the Frog', 'A highly adaptable cartoon frog used for reactions ranging from sadness to smugness; later contexts can carry political baggage.', 'Boy’s Club comic by Matt Furie / Myspace (2005)', 'Feels good when the meeting ends early.', '{"frog","reaction","character","context risk"}'::text[], 'https://knowyourmeme.com/memes/pepe-the-frog', true)
on conflict (id) do update set
  title = excluded.title,
  meaning = excluded.meaning,
  origin = excluded.origin,
  example = excluded.example,
  tags = excluded.tags,
  research_source = excluded.research_source,
  origin_verified = excluded.origin_verified,
  updated_at = now();

insert into public.explained_meme_candidates
  (id, title, meaning, origin, example, tags, research_source, origin_verified)
values
  ('explained-97', 'Elmo Fire', 'Represents gleeful chaos, destruction or extreme excitement as flames rise behind Elmo.', 'Elmo cake image on CakeWrecks (2012) / fire edit on Tumblr (2014)', 'Production is down, but the dashboard is green. Elmo fire.', '{"chaos","fire","reaction","television"}'::text[], 'https://knowyourmeme.com/memes/elmo-rise', true)
on conflict (id) do update set
  title = excluded.title,
  meaning = excluded.meaning,
  origin = excluded.origin,
  example = excluded.example,
  tags = excluded.tags,
  research_source = excluded.research_source,
  origin_verified = excluded.origin_verified,
  updated_at = now();

insert into public.explained_meme_candidates
  (id, title, meaning, origin, example, tags, research_source, origin_verified)
values
  ('explained-98', 'Pedro Pascal Laughing/Crying', 'Shows something that is simultaneously hilarious and emotionally painful.', 'Cape Cod Theatre Project virtual benefit reading (2020); viral edits (2021)', 'The bug is caused by the fix for the previous bug.', '{"mixed emotion","laughter","crying","film"}'::text[], 'https://knowyourmeme.com/memes/pedro-pascal-laughing-then-crying', true)
on conflict (id) do update set
  title = excluded.title,
  meaning = excluded.meaning,
  origin = excluded.origin,
  example = excluded.example,
  tags = excluded.tags,
  research_source = excluded.research_source,
  origin_verified = excluded.origin_verified,
  updated_at = now();

insert into public.explained_meme_candidates
  (id, title, meaning, origin, example, tags, research_source, origin_verified)
values
  ('explained-99', 'Kevin James Smirking', 'Expresses awkward self-consciousness, mild guilt or being caught in an uncomfortable moment.', 'The King of Queens promotional photograph (1998) / X (2023)', 'When they ask who changed the shared spreadsheet.', '{"awkwardness","smirk","reaction","television"}'::text[], 'https://knowyourmeme.com/memes/kevin-james-smirking', true)
on conflict (id) do update set
  title = excluded.title,
  meaning = excluded.meaning,
  origin = excluded.origin,
  example = excluded.example,
  tags = excluded.tags,
  research_source = excluded.research_source,
  origin_verified = excluded.origin_verified,
  updated_at = now();

insert into public.explained_meme_candidates
  (id, title, meaning, origin, example, tags, research_source, origin_verified)
values
  ('explained-100', 'Chill Guy', 'Represents remaining relaxed, detached or unbothered despite pressure or conflict.', 'Artwork by Phillip Banks / Twitter (October 2023); viral on TikTok (2024)', 'Deadline moved forward, but he''s just a chill guy.', '{"calm","indifference","character","drawing"}'::text[], 'https://knowyourmeme.com/memes/chill-guy', true)
on conflict (id) do update set
  title = excluded.title,
  meaning = excluded.meaning,
  origin = excluded.origin,
  example = excluded.example,
  tags = excluded.tags,
  research_source = excluded.research_source,
  origin_verified = excluded.origin_verified,
  updated_at = now();

commit;
