-- Fresh daily contender pool for Daily Meme Battle.
-- Prerequisites: arena-v7-retention.sql and arena-v7-daily-leaderboard.sql.
-- Weekly standings remain cumulative; only the playable matchup pool resets daily.
begin;

create or replace function public.arena_daily_pool_v8(
  p_day date default (now() at time zone 'UTC')::date
)
returns table(id text,title text,image_url text,created_at timestamptz,elo integer,wins integer,losses integer,rank bigint)
language sql stable security definer set search_path='' as $$
 select s.*
 from public.arena_standings_v7(public.arena_week_v7()) s
 where s.created_at >= p_day::timestamp at time zone 'UTC'
   and s.created_at < (p_day + 1)::timestamp at time zone 'UTC'
 order by s.rank
 limit 200
$$;

create or replace function public.arena_state_v7(p_since timestamptz default null)
returns jsonb language plpgsql security definer set search_path='' as $$
declare
 w timestamptz:=public.arena_week_v7(); pool jsonb; daily jsonb; prior jsonb;
 n bigint; fresh bigint; count_all bigint; pool_day date:=(now() at time zone 'UTC')::date;
begin
 perform public.arena_finalize_v7();
 select count(*) into count_all from public.arena_daily_pool_v8(pool_day);
 -- Availability fallback: if today's scheduled import failed or produced fewer
 -- than two unique images, use yesterday's batch rather than serving a blank game.
 if count_all < 2 then
   pool_day:=pool_day-1;
   select count(*) into count_all from public.arena_daily_pool_v8(pool_day);
 end if;
 select coalesce(jsonb_agg(to_jsonb(s)),'[]'::jsonb) into pool
 from (select * from public.arena_daily_pool_v8(pool_day) order by rank) s;
 select coalesce(jsonb_agg(to_jsonb(d)),'[]'::jsonb) into daily
 from (select * from public.arena_daily_standings_v7() order by rank) d;
 select count(*) into n from public.arena_daily_pool_v8((now() at time zone 'UTC')::date);
 select count(*) into fresh from public.arena_daily_pool_v8((now() at time zone 'UTC')::date)
 where p_since is not null and created_at>p_since;
 select to_jsonb(a) into prior from public.arena_winners_v7 a where week_start=w-interval '7 days';
 return jsonb_build_object('pool',pool,'pool_day',pool_day,'daily_board',daily,
   'week_start',w,'closes_at',w+interval '7 days','server_now',now(),
   'new_today',n,'new_since',case when p_since is null then null else fresh end,
   'eligible_count',count_all,'previous_winner',prior);
end $$;

create or replace function public.arena_vote_v7(p_winner text,p_loser text,p_request uuid)
returns jsonb language plpgsql security definer set search_path='' as $$
declare
 actor uuid:=auth.uid(); w timestamptz:=public.arena_week_v7(); today date:=(now() at time zone 'UTC')::date;
 pool_day date:=today; winrow record; loserrow record; delta integer; prior_n bigint; agree_n bigint;
 before_rank bigint; after_rank bigint; consensus numeric; response jsonb;
begin
 if actor is null then raise exception 'Authentication required' using errcode='42501';end if;
 if p_request is null or p_winner is null or p_loser is null or p_winner=p_loser then raise exception 'Invalid vote' using errcode='22023';end if;
 perform pg_advisory_xact_lock(hashtextextended(actor::text,0));
 if exists(select 1 from public.arena_votes_v7 where request_id=p_request) then raise exception 'Vote already recorded; refresh daily state' using errcode='23505';end if;
 if (select count(*) from public.arena_votes_v7 where voter_id=actor and created_at>now()-interval '1 minute')>=30 then raise exception 'Rate limit' using errcode='P0001';end if;
 perform pg_advisory_xact_lock(hashtextextended('arena-v7-'||w::text,0));
 if exists(select 1 from public.arena_winners_v7 where week_start=w) then raise exception 'Season closed';end if;
 if (select count(*) from public.arena_daily_pool_v8(today))<2 then pool_day:=today-1;end if;
 if not exists(select 1 from public.arena_daily_pool_v8(pool_day) where id=p_winner)
    or not exists(select 1 from public.arena_daily_pool_v8(pool_day) where id=p_loser) then
   raise exception 'Contender expired' using errcode='22023';
 end if;
 select * into winrow from public.arena_standings_v7(w) where id=p_winner;
 select * into loserrow from public.arena_standings_v7(w) where id=p_loser;
 before_rank:=winrow.rank;
 select count(*),count(*) filter(where winner_id=p_winner) into prior_n,agree_n
 from public.arena_votes_v7 where week_start=w and voter_id<>actor
 and ((winner_id=p_winner and loser_id=p_loser) or (winner_id=p_loser and loser_id=p_winner));
 if prior_n>=5 then consensus:=round(100.0*agree_n/prior_n);end if;
 insert into public.arena_votes_v7(request_id,voter_id,week_start,winner_id,loser_id)
 values(p_request,actor,w,p_winner,p_loser);
 insert into public.arena_entries_v7(week_start,meme_id) values(w,p_winner),(w,p_loser) on conflict do nothing;
 delta:=greatest(1,round(32*(1-1/(1+power(10::numeric,greatest(-4000,least(4000,loserrow.elo-winrow.elo))::numeric/400))))::integer);
 update public.arena_entries_v7 set rating=rating+delta,wins=wins+1 where week_start=w and meme_id=p_winner;
 update public.arena_entries_v7 set rating=rating-delta,losses=losses+1 where week_start=w and meme_id=p_loser;
 select rank into after_rank from public.arena_standings_v7(w) where id=p_winner;
 select jsonb_build_object('rows',jsonb_agg(to_jsonb(s)),'before_rank',before_rank,'after_rank',after_rank,
   'delta',delta,'agreement',consensus,'sample',prior_n,'majority',
   case when prior_n>=5 and agree_n*2<>prior_n then agree_n*2>prior_n else null end)
 into response from (select * from public.arena_standings_v7(w) order by rank limit 200) s;
 return response;
end $$;

revoke all on function public.arena_daily_pool_v8(date) from public,anon,authenticated;
revoke all on function public.arena_state_v7(timestamptz),public.arena_vote_v7(text,text,uuid) from public,anon,authenticated;
grant execute on function public.arena_state_v7(timestamptz) to anon,authenticated;
grant execute on function public.arena_vote_v7(text,text,uuid) to authenticated;
commit;
