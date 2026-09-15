-- Certified Funny — post-import verification
-- Read-only. Run after certified-funny-import-existing-storage.sql.
select
  now() as checked_at,
  (select count(*) from storage.objects where bucket_id = 'memes') as storage_objects,
  (select count(*) from public.memes where lower(coalesce(kind, '')) = 'funny') as funny_rows,
  (
    select count(*)
    from storage.objects o
    where o.bucket_id = 'memes'
      and (
        lower(coalesce(o.metadata->>'mimetype', '')) in ('image/jpeg','image/png','image/gif','image/webp')
        or lower(o.name) ~ '\.(jpe?g|png|gif|webp)$'
      )
  ) as supported_storage_images,
  (
    select count(*)
    from storage.objects o
    where o.bucket_id = 'memes'
      and (
        lower(coalesce(o.metadata->>'mimetype', '')) in ('image/jpeg','image/png','image/gif','image/webp')
        or lower(o.name) ~ '\.(jpe?g|png|gif|webp)$'
      )
      and not exists (
        select 1
        from public.memes m
        where m.id = 'funny-' || md5(o.name)
          and m.kind = 'funny'
          and m.image_uri = o.name
      )
  ) as supported_images_missing_metadata,
  (
    select count(*)
    from public.memes
    where source = 'owner_storage_import'
      and (image_uri is null or btrim(image_uri) = '')
  ) as malformed_import_rows;
