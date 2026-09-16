-- Publishes the first 10 reviewed Explained entries as editorial references.
-- Images are deliberately excluded from Screensaver by their source prefix.
-- This script does not grant or modify database permissions.

begin;

insert into public.memes
  (id, title, image_url, kind, tags, source, meaning, origin, example, created_at)
values
  ('explained-7', 'This Is Fine', 'https://explained.meme/assets/explained-7-this-is-fine.jpg', 'meme', array['explained','editorial-reference'], 'explained_editorial_reference:https://kcgreendotcom.com/', 'A reaction to an obviously worsening situation that someone calmly accepts, ignores or pretends is manageable.', 'Gunshow webcomic by K.C. Green (2013); meme popularised later', 'The deadline is tonight, nothing works, and I have opened another meeting invite. This is fine.', now()),
  ('explained-8', 'Is This a Pigeon?', 'https://explained.meme/assets/explained-8-is-this-a-pigeon.jpg', 'meme', array['explained','editorial-reference'], 'explained_editorial_reference:https://knowyourmeme.com/memes/is-this-a-pigeon', 'Used when somebody confidently mistakes, mislabels or misunderstands something obvious.', 'The Brave Fighter of Sun Fighbird / Tumblr (2011)', 'Manager sees one quiet afternoon: Is this unlimited capacity?', now()),
  ('explained-9', 'One Does Not Simply', 'https://explained.meme/assets/explained-9-one-does-not-simply.jpg', 'meme', array['explained','editorial-reference'], 'explained_editorial_reference:https://knowyourmeme.com/memes/one-does-not-simply-walk-into-mordor', 'Frames an action as far more difficult, complicated or unrealistic than it first appears.', 'The Lord of the Rings: The Fellowship of the Ring (2001)', 'One does not simply finish a group project without twelve reminder messages.', now()),
  ('explained-10', 'Success Kid', 'https://explained.meme/assets/explained-10-success-kid.jpg', 'meme', array['explained','editorial-reference'], 'explained_editorial_reference:https://knowyourmeme.com/memes/success-kid-i-hate-sandcastles', 'Celebrates a small victory, unexpected success or situation that turned out better than expected.', 'Flickr photograph by Laney Griner (2007)', 'Forgot my umbrella. Meeting moved online.', now()),
  ('explained-11', 'Bad Luck Brian', 'https://explained.meme/assets/explained-11-bad-luck-brian.jpg', 'meme', array['explained','editorial-reference'], 'explained_editorial_reference:https://www.badluckbrian.com/', 'Uses an awkward school portrait with captions describing an ordinary setup followed by extreme misfortune.', 'Reddit (2012)', 'Downloads the backup. Backup file is corrupted.', now()),
  ('explained-12', 'Philosoraptor', 'https://explained.meme/assets/explained-12-philosoraptor.jpg', 'meme', array['explained','editorial-reference'], 'explained_editorial_reference:https://knowyourmeme.com/memes/philosoraptor', 'Pairs a thoughtful velociraptor illustration with pseudo-philosophical questions, paradoxes and absurd observations.', 'Lonely Dinosaur T-shirt by Sam Smith / 4chan (2008)', 'If tomatoes are fruit, is ketchup a smoothie?', now()),
  ('explained-13', 'Ancient Aliens', 'https://explained.meme/assets/explained-13-ancient-aliens.jpg', 'meme', array['explained','editorial-reference'], 'explained_editorial_reference:https://knowyourmeme.com/memes/ancient-aliens', 'Mockingly explains an event, mystery or coincidence by attributing it to aliens without credible evidence.', 'History Channel''s Ancient Aliens / 4chan (2010)', 'The printer worked after I turned it off and on. Aliens.', now()),
  ('explained-14', 'Futurama Fry', 'https://explained.meme/assets/explained-14-futurama-fry.jpg', 'meme', array['explained','editorial-reference'], 'explained_editorial_reference:https://knowyourmeme.com/memes/futurama-fry-not-sure-if', 'Expresses uncertainty between two explanations using the structure “Not sure if X, or just Y.”', 'Futurama / image-macro sites (2011)', 'Not sure if productive, or just reorganising the task list again.', now()),
  ('explained-16', 'Surprised Pikachu', 'https://explained.meme/assets/explained-16-surprised-pikachu.jpg', 'meme', array['explained','editorial-reference'], 'explained_editorial_reference:https://knowyourmeme.com/memes/surprised-pikachu', 'Reacting with shock to a predictable consequence, especially when the outcome should have been obvious.', 'Pokémon anime / Tumblr (2018)', 'Skips every software update. Laptop breaks. Surprised Pikachu.', now()),
  ('explained-17', 'Mocking SpongeBob', 'https://explained.meme/assets/explained-17-mocking-spongebob.jpg', 'meme', array['explained','editorial-reference'], 'explained_editorial_reference:https://knowyourmeme.com/memes/mocking-spongebob', 'Mocks or sarcastically repeats somebody''s statement, usually by alternating uppercase and lowercase letters.', 'SpongeBob SquarePants / Twitter (2017)', 'You should organise your files. YoU sHoUlD oRgAnIsE yOuR fIlEs.', now())
on conflict (id) do update set
  title = excluded.title,
  image_url = excluded.image_url,
  kind = excluded.kind,
  tags = excluded.tags,
  source = excluded.source,
  meaning = excluded.meaning,
  origin = excluded.origin,
  example = excluded.example;

do $$
begin
  if (select count(*) from public.memes where id in (
    'explained-7','explained-8','explained-9','explained-10','explained-11',
    'explained-12','explained-13','explained-14','explained-16','explained-17'
  )) <> 10 then
    raise exception 'Explained pilot release incomplete; rolling back';
  end if;
end
$$;

commit;
