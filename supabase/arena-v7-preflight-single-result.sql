-- Daily Meme Battle V7 — SINGLE-RESULT READ-ONLY PREFLIGHT
-- Creates, changes and deletes NOTHING.
-- Run the whole script once. Then use Results > Download CSV and attach that CSV here.
with
column_report as (
  select coalesce(jsonb_agg(jsonb_build_object(
    'column',c.column_name,
    'data_type',c.data_type,
    'udt_name',c.udt_name,
    'nullable',c.is_nullable,
    'default',c.column_default
  ) order by c.ordinal_position),'[]'::jsonb) as value
  from information_schema.columns c
  where c.table_schema='public' and c.table_name='memes'
    and c.column_name in(
      'id','title','image_url','image_uri','kind','created_at',
      'reddit_id','reddit_score','source','elo','wins','losses'
    )
),
required_report as (
  select jsonb_object_agg(required_name,status order by required_name) as value
  from (
    select r.required_name,
      case
        when r.required_name='image_url OR image_uri' and exists(
          select 1 from information_schema.columns
          where table_schema='public' and table_name='memes'
            and column_name in('image_url','image_uri')
        ) then 'PRESENT'
        when r.required_name<>'image_url OR image_uri' and exists(
          select 1 from information_schema.columns
          where table_schema='public' and table_name='memes'
            and column_name=r.required_name
        ) then 'PRESENT'
        else 'MISSING'
      end as status
    from (values
      ('id'),('title'),('kind'),('created_at'),('image_url OR image_uri')
    ) r(required_name)
  ) x
),
data_report as (
  select jsonb_build_object(
    'total_rows',count(*),
    'trending_rows',count(*) filter(where to_jsonb(m)->>'kind'='trending'),
    'current_week_trending',count(*) filter(
      where to_jsonb(m)->>'kind'='trending'
        and nullif(to_jsonb(m)->>'created_at','')::timestamptz
          >= date_trunc('week',now() at time zone 'UTC') at time zone 'UTC'
        and nullif(to_jsonb(m)->>'created_at','')::timestamptz<=now()
    ),
    'null_ids',count(*) filter(where nullif(to_jsonb(m)->>'id','') is null),
    'missing_titles',count(*) filter(where nullif(btrim(to_jsonb(m)->>'title'),'') is null),
    'trending_without_image',count(*) filter(
      where to_jsonb(m)->>'kind'='trending'
        and coalesce(nullif(btrim(to_jsonb(m)->>'image_url'),''),
                     nullif(btrim(to_jsonb(m)->>'image_uri'),'')) is null
    ),
    'trending_without_https_image',count(*) filter(
      where to_jsonb(m)->>'kind'='trending'
        and coalesce(to_jsonb(m)->>'image_url',to_jsonb(m)->>'image_uri','') not like 'https://%'
    ),
    'oldest_trending',min(nullif(to_jsonb(m)->>'created_at','')::timestamptz)
      filter(where to_jsonb(m)->>'kind'='trending'),
    'newest_trending',max(nullif(to_jsonb(m)->>'created_at','')::timestamptz)
      filter(where to_jsonb(m)->>'kind'='trending')
  ) as value
  from public.memes m
),
duplicate_report as (
  select coalesce(jsonb_agg(jsonb_build_object(
    'reddit_id',reddit_id,'count',duplicate_count
  ) order by duplicate_count desc,reddit_id),'[]'::jsonb) as value
  from (
    select to_jsonb(m)->>'reddit_id' as reddit_id,count(*) as duplicate_count
    from public.memes m
    where nullif(to_jsonb(m)->>'reddit_id','') is not null
    group by to_jsonb(m)->>'reddit_id'
    having count(*)>1
    limit 100
  ) d
),
constraint_report as (
  select coalesce(jsonb_agg(jsonb_build_object(
    'name',c.conname,'type',c.contype,'definition',pg_get_constraintdef(c.oid)
  ) order by c.contype,c.conname),'[]'::jsonb) as value
  from pg_constraint c
  where c.conrelid='public.memes'::regclass and c.contype in('p','u')
),
rls_report as (
  select coalesce(jsonb_agg(jsonb_build_object(
    'table',c.relname,'enabled',c.relrowsecurity,'forced',c.relforcerowsecurity
  )),'[]'::jsonb) as value
  from pg_class c join pg_namespace n on n.oid=c.relnamespace
  where n.nspname='public' and c.relname='memes'
),
policy_report as (
  select coalesce(jsonb_agg(jsonb_build_object(
    'name',policyname,'permissive',permissive,'roles',roles,
    'command',cmd,'using',qual,'check',with_check
  ) order by policyname),'[]'::jsonb) as value
  from pg_policies
  where schemaname='public' and tablename='memes'
),
privilege_report as (
  select coalesce(jsonb_agg(jsonb_build_object(
    'role',grantee,'privilege',privilege_type,'grantable',is_grantable
  ) order by grantee,privilege_type),'[]'::jsonb) as value
  from information_schema.role_table_grants
  where table_schema='public' and table_name='memes'
    and grantee in('anon','authenticated')
),
collision_report as (
  select jsonb_build_object(
    'arena_entries_v7',to_regclass('public.arena_entries_v7'),
    'arena_votes_v7',to_regclass('public.arena_votes_v7'),
    'arena_winners_v7',to_regclass('public.arena_winners_v7'),
    'arena_state_v7',to_regprocedure('public.arena_state_v7(timestamp with time zone)'),
    'arena_vote_v7',to_regprocedure('public.arena_vote_v7(text,text,uuid)'),
    'arena_finalize_v7',to_regprocedure('public.arena_finalize_v7()')
  ) as value
),
cron_report as (
  select coalesce(jsonb_agg(jsonb_build_object(
    'name',name,'default_version',default_version,
    'installed_version',installed_version,
    'status',case when installed_version is null
      then 'AVAILABLE_NOT_INSTALLED' else 'INSTALLED' end
  )),'[]'::jsonb) as value
  from pg_available_extensions where name='pg_cron'
)
select
  now() as inspected_at,
  current_database() as database_name,
  (select value from required_report) as required_columns,
  (select value from column_report) as column_details,
  (select value from data_report) as data_health,
  (select value from duplicate_report) as duplicate_reddit_ids,
  (select value from constraint_report) as unique_constraints,
  (select value from rls_report) as rls_state,
  (select value from policy_report) as policies,
  (select value from privilege_report) as direct_privileges,
  (select value from collision_report) as existing_v7_objects,
  (select value from cron_report) as pg_cron;
