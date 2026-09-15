-- Certified Funny owner-import preflight
-- Read-only: creates, updates and deletes nothing.
-- Run the whole file in Supabase SQL Editor, then download the single result row as CSV.

select
  now() as inspected_at,
  (select count(*) from public.memes where lower(coalesce(kind, '')) = 'funny') as funny_rows,
  (select count(*) from storage.objects where bucket_id = 'memes') as memes_bucket_objects,
  (
    select coalesce(jsonb_agg(
      jsonb_build_object(
        'column_name', column_name,
        'data_type', data_type,
        'udt_name', udt_name,
        'is_nullable', is_nullable,
        'column_default', column_default
      )
      order by ordinal_position
    ), '[]'::jsonb)
    from information_schema.columns
    where table_schema = 'public'
      and table_name = 'memes'
  ) as memes_columns,
  (
    select coalesce(jsonb_agg(
      jsonb_build_object(
        'name', name,
        'created_at', created_at,
        'metadata', metadata
      )
      order by created_at desc
    ), '[]'::jsonb)
    from (
      select name, created_at, metadata
      from storage.objects
      where bucket_id = 'memes'
      order by created_at desc
      limit 20
    ) recent
  ) as recent_memes_bucket_objects,
  (
    select coalesce(jsonb_agg(
      jsonb_build_object(
        'constraint_name', tc.constraint_name,
        'constraint_type', tc.constraint_type,
        'columns', cols.columns
      )
      order by tc.constraint_name
    ), '[]'::jsonb)
    from information_schema.table_constraints tc
    left join lateral (
      select jsonb_agg(kcu.column_name order by kcu.ordinal_position) as columns
      from information_schema.key_column_usage kcu
      where kcu.constraint_schema = tc.constraint_schema
        and kcu.constraint_name = tc.constraint_name
        and kcu.table_name = tc.table_name
    ) cols on true
    where tc.table_schema = 'public'
      and tc.table_name = 'memes'
      and tc.constraint_type in ('PRIMARY KEY', 'UNIQUE', 'CHECK')
  ) as memes_constraints;
