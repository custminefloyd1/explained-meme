-- Add a server-calculated daily leaderboard to Daily Meme Battle v7.
-- Run once after arena-v7-retention.sql. Existing table permissions stay locked.
begin;

create index if not exists arena_v7_vote_day
on public.arena_votes_v7(vote_day,winner_id,loser_id);

create or replace function public.arena_daily_standings_v7(
  p_day date default (now() at time zone 'UTC')::date
)
returns table(
  id text,title text,image_url text,wins bigint,losses bigint,
  appearances bigint,win_rate integer,score integer,rank bigint
)
language sql stable security definer set search_path='' as $$
 with results as (
   select candidate as meme_id,
          count(*) filter(where winner_id=candidate) as wins,
          count(*) filter(where loser_id=candidate) as losses,
          count(*) as appearances
   from public.arena_votes_v7 v
   cross join lateral (values(v.winner_id),(v.loser_id)) x(candidate)
   where v.vote_day=p_day
   group by candidate
 ), scored as (
   select r.*,
     round(100.0*r.wins/nullif(r.appearances,0))::integer as win_rate,
     round(100 * (
       ((r.wins::numeric/r.appearances) + 1.642/(2*r.appearances)
        - 1.2816*sqrt(((r.wins::numeric/r.appearances)*(1-r.wins::numeric/r.appearances)+1.642/(4*r.appearances))/r.appearances))
       /(1+1.642/r.appearances)
     ))::integer as score
   from results r where r.appearances>=3
 )
 select m.id::text,m.title,coalesce(m.image_url,m.image_uri),s.wins,s.losses,s.appearances,
        s.win_rate,s.score,
        row_number() over(order by s.score desc,s.appearances desc,s.wins desc,s.meme_id)
 from scored s join public.memes m on m.id::text=s.meme_id
 where coalesce(m.image_url,m.image_uri) like 'https://%'
 order by score desc,appearances desc,wins desc,m.id::text
 limit 10
$$;

create or replace function public.arena_state_v7(p_since timestamptz default null)
returns jsonb language plpgsql security definer set search_path='' as $$
declare w timestamptz:=public.arena_week_v7(); pool jsonb; daily jsonb; prior jsonb; n bigint; fresh bigint; count_all bigint;
begin
 perform public.arena_finalize_v7();
 select coalesce(jsonb_agg(to_jsonb(s)),'[]'::jsonb) into pool
 from (select * from public.arena_standings_v7(w) order by rank limit 200) s;
 select coalesce(jsonb_agg(to_jsonb(d)),'[]'::jsonb) into daily
 from (select * from public.arena_daily_standings_v7() order by rank) d;
 select count(*),count(*) filter(where created_at >= date_trunc('day',now() at time zone 'UTC') at time zone 'UTC'),
 count(*) filter(where p_since is not null and created_at>p_since)
 into count_all,n,fresh from public.arena_standings_v7(w);
 select to_jsonb(a) into prior from public.arena_winners_v7 a where week_start=w-interval '7 days';
 return jsonb_build_object('pool',pool,'daily_board',daily,'week_start',w,'closes_at',w+interval '7 days',
 'server_now',now(),'new_today',n,'new_since',case when p_since is null then null else fresh end,
 'eligible_count',count_all,'previous_winner',prior);
end $$;

-- Keep tables private. Only the existing state RPC exposes the bounded top ten.
revoke all on function public.arena_daily_standings_v7(date) from public,anon,authenticated;
revoke all on function public.arena_state_v7(timestamptz) from public,anon,authenticated;
grant execute on function public.arena_state_v7(timestamptz) to anon,authenticated;

commit;
