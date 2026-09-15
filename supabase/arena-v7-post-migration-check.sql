-- Daily Meme Battle V7 post-migration verification.
-- Run only after arena-v6-import.sql and arena-v7-retention.sql.
-- Read-only: this query does not call arena_state_v7 because that function may finalize a season.
with
expected_tables(name) as (
 values ('arena_entries_v7'),('arena_votes_v7'),('arena_winners_v7')
),
expected_functions(signature) as (
 values
 ('arena_week_v7()'),
 ('arena_finalize_v7()'),
 ('arena_standings_v7(timestamp with time zone)'),
 ('arena_state_v7(timestamp with time zone)'),
 ('arena_vote_v7(text,text,uuid)')
),
import_columns(name) as (
 values ('reddit_id'),('reddit_score'),('source')
),
table_status as (
 select e.name,
        to_regclass('public.'||e.name) is not null as present,
        coalesce(c.relrowsecurity,false) as rls_enabled
 from expected_tables e
 left join pg_class c on c.oid=to_regclass('public.'||e.name)
),
function_status as (
 select signature,
        to_regprocedure('public.'||signature) is not null as present
 from expected_functions
),
direct_v7_grants as (
 select grantee,table_name,privilege_type
 from information_schema.role_table_grants
 where table_schema='public'
   and table_name in (select name from expected_tables)
   and grantee in ('anon','authenticated')
),
rpc_grants as (
 select grantee,routine_name,privilege_type
 from information_schema.routine_privileges
 where specific_schema='public'
   and routine_name in (
     'arena_week_v7','arena_finalize_v7','arena_standings_v7',
     'arena_state_v7','arena_vote_v7'
   )
   and grantee in ('PUBLIC','anon','authenticated')
),
import_status as (
 select i.name,
        exists(
          select 1 from information_schema.columns c
          where c.table_schema='public' and c.table_name='memes' and c.column_name=i.name
        ) as present
 from import_columns i
)
select
 now() as inspected_at,
 not exists(select 1 from table_status where not present) as all_v7_tables_present,
 not exists(select 1 from table_status where not rls_enabled) as all_v7_tables_have_rls,
 not exists(select 1 from direct_v7_grants) as no_direct_client_v7_table_grants,
 not exists(select 1 from function_status where not present) as all_v7_functions_present,
 not exists(select 1 from import_status where not present) as importer_columns_present,
 (
   select coalesce(jsonb_agg(to_jsonb(t) order by name),'[]'::jsonb)
   from table_status t
 ) as v7_table_details,
 (
   select coalesce(jsonb_agg(to_jsonb(f) order by signature),'[]'::jsonb)
   from function_status f
 ) as v7_function_details,
 (
   select coalesce(jsonb_agg(to_jsonb(i) order by name),'[]'::jsonb)
   from import_status i
 ) as importer_column_details,
 (
   select coalesce(jsonb_agg(to_jsonb(g) order by grantee,table_name,privilege_type),'[]'::jsonb)
   from direct_v7_grants g
 ) as unexpected_direct_v7_grants,
 (
   select coalesce(jsonb_agg(to_jsonb(r) order by routine_name,grantee),'[]'::jsonb)
   from rpc_grants r
 ) as rpc_grant_details;
