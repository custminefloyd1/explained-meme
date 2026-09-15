-- Certified Funny — remove stale owner-import metadata
--
-- Deletes only metadata rows created by certified-funny-import-existing-storage.sql
-- when their corresponding file no longer exists in the "memes" Storage bucket.
-- Current Storage files, votes, unrelated meme rows, and permissions are untouched.
--
-- Run this whole file once in Supabase SQL Editor, then run
-- certified-funny-import-check.sql again.
-- Expected after cleanup: 50 Storage objects, 50 Funny rows,
-- 50 supported images, 0 missing metadata, 0 malformed rows.

begin;

delete from public.memes m
where m.kind = 'funny'
  and m.source = 'owner_storage_import'
  and not exists (
    select 1
    from storage.objects o
    where o.bucket_id = 'memes'
      and o.name = m.image_uri
  );

-- Fail and roll back if stale owner-import metadata remains.
do $$
begin
  if exists (
    select 1
    from public.memes m
    where m.kind = 'funny'
      and m.source = 'owner_storage_import'
      and not exists (
        select 1
        from storage.objects o
        where o.bucket_id = 'memes'
          and o.name = m.image_uri
      )
  ) then
    raise exception 'Stale Certified Funny metadata remains; rolling back';
  end if;
end
$$;

commit;
