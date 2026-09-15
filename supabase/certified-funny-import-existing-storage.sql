-- Certified Funny — import existing owner-uploaded Storage images
-- Reviewed against certified-funny-import-preflight output from 2026-09-15.
--
-- Creates one public.memes metadata row for each supported image already in
-- the owner-controlled Storage bucket named "memes".
-- Does not upload, rename, overwrite, or delete Storage objects.
-- Idempotent: stable IDs plus ON CONFLICT make reruns safe.
--
-- Run this whole file once in Supabase SQL Editor.
-- Expected result: Success. No rows returned.

begin;

insert into public.memes (
  id,
  title,
  image_uri,
  kind,
  tags,
  is_user_submitted,
  created_at,
  source
)
select
  'funny-' || md5(o.name) as id,
  o.name as title,
  o.name as image_uri,
  'funny' as kind,
  array['funny']::text[] as tags,
  false as is_user_submitted,
  (o.created_at at time zone 'UTC') as created_at,
  'owner_storage_import' as source
from storage.objects o
where o.bucket_id = 'memes'
  and (
    lower(coalesce(o.metadata->>'mimetype', '')) in (
      'image/jpeg',
      'image/png',
      'image/gif',
      'image/webp'
    )
    or lower(o.name) ~ '\.(jpe?g|png|gif|webp)$'
  )
on conflict (id) do nothing;

-- Fail and roll back if an imported row is malformed.
do $$
begin
  if exists (
    select 1
    from public.memes
    where source = 'owner_storage_import'
      and (
        kind <> 'funny'
        or id is null
        or image_uri is null
        or btrim(image_uri) = ''
      )
  ) then
    raise exception 'Malformed Certified Funny metadata row; rolling back';
  end if;
end
$$;

commit;
