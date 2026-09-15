-- Daily Meme Battle V7 — READ-ONLY PREFLIGHT
-- Safe purpose: inspect the real Supabase schema before applying arena-v7-retention.sql.
-- This script creates, changes and deletes NOTHING.
-- Run the complete script in Supabase SQL Editor and save/export every result grid.

-- 1. Required memes columns and exact types.
select
  c.column_name,
  c.data_type,
  c.udt_name,
  c.is_nullable,
  c.column_default
from information_schema.columns c
where c.table_schema='public'
  and c.table_name='memes'
  and c.column_name in (
    'id','title','image_url','image_uri','kind','created_at',
    'reddit_id','reddit_score','source','elo','wins','losses'
  )
order by c.ordinal_position;

-- 2. PASS/FAIL summary for columns required by the V7 migration.
with required(column_name) as (
  values ('id'),('title'),('kind'),('created_at')
),
present as (
  select column_name
  from information_schema.columns
  where table_schema='public' and table_name='memes'
)
select
  r.column_name,
  case when p.column_name is null then 'MISSING' else 'PRESENT' end as status
from required r
left join present p using(column_name)
union all
select
  'image_url OR image_uri',
  case when exists(
    select 1 from present where column_name in('image_url','image_uri')
  ) then 'PRESENT' else 'MISSING' end
order by column_name;

-- 3. Current data health. Uses JSON field access so missing optional columns do not abort.
select
  count(*) as total_rows,
  count(*) filter(where to_jsonb(m)->>'kind'='trending') as trending_rows,
  count(*) filter(
    where to_jsonb(m)->>'kind'='trending'
      and nullif(to_jsonb(m)->>'created_at','')::timestamptz
        >= date_trunc('week',now() at time zone 'UTC') at time zone 'UTC'
      and nullif(to_jsonb(m)->>'created_at','')::timestamptz <= now()
  ) as current_week_trending,
  count(*) filter(where nullif(to_jsonb(m)->>'id','') is null) as null_ids,
  count(*) filter(where nullif(btrim(to_jsonb(m)->>'title'),'') is null) as missing_titles,
  count(*) filter(
    where to_jsonb(m)->>'kind'='trending'
      and coalesce(nullif(btrim(to_jsonb(m)->>'image_url'),''),
                   nullif(btrim(to_jsonb(m)->>'image_uri'),'')) is null
  ) as trending_without_image,
  count(*) filter(
    where to_jsonb(m)->>'kind'='trending'
      and coalesce(to_jsonb(m)->>'image_url',to_jsonb(m)->>'image_uri','') not like 'https://%'
  ) as trending_without_https_image,
  min(nullif(to_jsonb(m)->>'created_at','')::timestamptz)
    filter(where to_jsonb(m)->>'kind'='trending') as oldest_trending,
  max(nullif(to_jsonb(m)->>'created_at','')::timestamptz)
    filter(where to_jsonb(m)->>'kind'='trending') as newest_trending
from public.memes m;

-- 4. Duplicate Reddit identifiers. Safe even when reddit_id is absent.
select
  to_jsonb(m)->>'reddit_id' as reddit_id,
  count(*) as duplicate_count
from public.memes m
where nullif(to_jsonb(m)->>'reddit_id','') is not null
group by to_jsonb(m)->>'reddit_id'
having count(*)>1
order by duplicate_count desc,reddit_id
limit 100;

-- 5. Primary key/unique constraints on memes.
select
  c.conname as constraint_name,
  c.contype as constraint_type,
  pg_get_constraintdef(c.oid) as definition
from pg_constraint c
where c.conrelid='public.memes'::regclass
  and c.contype in('p','u')
order by c.contype,c.conname;

-- 6. Row-level security state.
select
  n.nspname as schema_name,
  c.relname as table_name,
  c.relrowsecurity as rls_enabled,
  c.relforcerowsecurity as rls_forced
from pg_class c
join pg_namespace n on n.oid=c.relnamespace
where n.nspname='public' and c.relname='memes';

-- 7. Existing policies on memes. Expressions may reveal policy logic, not row data.
select
  policyname,
  permissive,
  roles,
  cmd,
  qual,
  with_check
from pg_policies
where schemaname='public' and tablename='memes'
order by policyname;

-- 8. Existing direct privileges. Direct UPDATE for anon/authenticated is a legacy risk.
select
  grantee,
  privilege_type,
  is_grantable
from information_schema.role_table_grants
where table_schema='public'
  and table_name='memes'
  and grantee in('anon','authenticated')
order by grantee,privilege_type;

-- 9. Collision check: V7 objects should normally be absent before first migration.
select
  to_regclass('public.arena_entries_v7') as arena_entries_v7,
  to_regclass('public.arena_votes_v7') as arena_votes_v7,
  to_regclass('public.arena_winners_v7') as arena_winners_v7,
  to_regprocedure('public.arena_state_v7(timestamp with time zone)') as arena_state_v7,
  to_regprocedure('public.arena_vote_v7(text,text,uuid)') as arena_vote_v7,
  to_regprocedure('public.arena_finalize_v7()') as arena_finalize_v7;

-- 10. Optional scheduling support. "available" does not mean enabled/configured.
select
  name,
  default_version,
  installed_version,
  case when installed_version is null then 'AVAILABLE_NOT_INSTALLED' else 'INSTALLED' end as status
from pg_available_extensions
where name='pg_cron';

-- 11. Authentication configuration cannot be safely established by this SQL preflight.
-- In the Supabase dashboard, separately report:
-- Authentication > Providers > Anonymous Sign-Ins: enabled/disabled
-- Authentication > Rate Limits: current anonymous/sign-up limits
-- Authentication > Bot and Abuse Protection: CAPTCHA enabled/disabled
