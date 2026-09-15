-- Certified Funny — remove stale and unusable metadata
--
-- Verified against the 2026-09-15 source breakdown:
--   50 valid rows: source = owner_storage_import, with image paths
--   50 unusable rows: source/image_uri/image_url are all NULL
--
-- Deletes only:
-- 1. Owner-import metadata whose Storage file no longer exists.
-- 2. Unusable Funny rows with no source and no image reference.
--
-- Current Storage files, valid owner imports, votes, unrelated meme rows,
-- grants and RLS policies are untouched.
--
-- Run this whole file once in Supabase SQL Editor, then run
-- certified-funny-import-check.sql again.
-- Expected after cleanup: 50 Storage objects, 50 Funny rows,
-- 50 supported images, 0 missing metadata, 0 malformed rows.

begin;

delete from public.memes m
where m.kind = 'funny'
  and (
    (
      m.source = 'owner_storage_import'
      and not exists (
        select 1
        from storage.objects o
        where o.bucket_id = 'memes'
          and o.name = m.image_uri
      )
    )
    or (
      m.source is null
      and m.image_uri is null
      and m.image_url is null
    )
  );

-- Fail and roll back if either verified broken-row pattern remains.
do $$
begin
  if exists (
    select 1
    from public.memes m
    where m.kind = 'funny'
      and (
        (
          m.source = 'owner_storage_import'
          and not exists (
            select 1
            from storage.objects o
            where o.bucket_id = 'memes'
              and o.name = m.image_uri
          )
        )
        or (
          m.source is null
          and m.image_uri is null
          and m.image_url is null
        )
      )
  ) then
    raise exception 'Broken Certified Funny metadata remains; rolling back';
  end if;
end
$$;

commit;
