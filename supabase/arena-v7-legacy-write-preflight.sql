-- Read-only preflight for legacy browser-write lockdown.
-- Run before arena-v7-lockdown-legacy-writes.sql and return the single CSV row.
with
target_policies as (
  select schemaname,tablename,policyname,roles,cmd,qual,with_check
  from pg_policies
  where (schemaname='public' and tablename='memes')
     or (schemaname='storage' and tablename='objects')
),
target_grants as (
  select table_schema,table_name,grantee,privilege_type,is_grantable
  from information_schema.role_table_grants
  where ((table_schema='public' and table_name='memes')
      or (table_schema='storage' and table_name='objects'))
    and grantee in ('anon','authenticated')
),
bucket_status as (
  select id,name,public
  from storage.buckets
  where id in ('Templates','Trending','memes') or name in ('Templates','Trending','memes')
)
select
  now() as inspected_at,
  (
    select coalesce(jsonb_agg(to_jsonb(p) order by schemaname,tablename,policyname),'[]'::jsonb)
    from target_policies p
  ) as relevant_policies,
  (
    select coalesce(jsonb_agg(to_jsonb(g) order by table_schema,table_name,grantee,privilege_type),'[]'::jsonb)
    from target_grants g
  ) as relevant_direct_grants,
  (
    select coalesce(jsonb_agg(to_jsonb(b) order by name),'[]'::jsonb)
    from bucket_status b
  ) as relevant_buckets;
