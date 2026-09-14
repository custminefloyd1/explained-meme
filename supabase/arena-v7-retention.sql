-- Daily Meme Battle v7. Review/apply in staging; no other page/table policies change.
-- Requires existing public.memes(id,title,image_url,image_uri,kind,created_at).
-- Enable Supabase anonymous authentication; configure CAPTCHA/rate limits.
begin;
create table if not exists public.arena_entries_v7(
 week_start timestamptz not null, meme_id text not null, rating integer not null default 1200,
 wins integer not null default 0, losses integer not null default 0,
 primary key(week_start,meme_id)
);
create table if not exists public.arena_votes_v7(
 request_id uuid primary key, voter_id uuid not null references auth.users(id),
 week_start timestamptz not null, created_at timestamptz not null default now(),
 winner_id text not null, loser_id text not null, check(winner_id<>loser_id),
 vote_day date not null default (now() at time zone 'UTC')::date
);
create unique index if not exists arena_v7_pair_once on public.arena_votes_v7
(voter_id,vote_day,least(winner_id,loser_id),greatest(winner_id,loser_id));
create index if not exists arena_v7_vote_rate on public.arena_votes_v7(voter_id,created_at);
create index if not exists arena_v7_vote_pair on public.arena_votes_v7(week_start,winner_id,loser_id);
create table if not exists public.arena_winners_v7(
 week_start timestamptz primary key, closes_at timestamptz not null,
 meme_id text, title text, image_url text, rating integer, votes bigint not null,
 status text not null check(status in('winner','insufficient_votes')), finalized_at timestamptz not null default now()
);
alter table public.arena_entries_v7 enable row level security;
alter table public.arena_votes_v7 enable row level security;
alter table public.arena_winners_v7 enable row level security;
revoke all on public.arena_entries_v7,public.arena_votes_v7,public.arena_winners_v7 from anon,authenticated;

create or replace function public.arena_week_v7()
returns timestamptz language sql stable set search_path='' as $$
 select date_trunc('week',now() at time zone 'UTC') at time zone 'UTC'
$$;

-- No client-supplied winner. Closed seasons are immutable, including no-winner results.
create or replace function public.arena_finalize_v7()
returns void language plpgsql security definer set search_path='' as $$
declare season timestamptz; winner record; n bigint;
begin
 for season in select week_start from (select distinct week_start from public.arena_entries_v7
   where week_start<public.arena_week_v7() union select public.arena_week_v7()-interval '7 days') weeks order by week_start loop
   perform pg_advisory_xact_lock(hashtextextended('arena-v7-'||season::text,0));
   if exists(select 1 from public.arena_winners_v7 where week_start=season) then continue; end if;
   select count(*) into n from public.arena_votes_v7 where week_start=season;
   select e.meme_id,m.title,coalesce(m.image_url,m.image_uri) as image_url,e.rating into winner
   from public.arena_entries_v7 e join public.memes m on m.id::text=e.meme_id
   where e.week_start=season and e.wins+e.losses>=3
   order by e.rating desc,e.wins desc,e.meme_id limit 1;
   insert into public.arena_winners_v7(week_start,closes_at,meme_id,title,image_url,rating,votes,status)
   values(season,season+interval '7 days',
     case when n>=5 then winner.meme_id end,case when n>=5 then winner.title end,
     case when n>=5 then winner.image_url end,case when n>=5 then winner.rating end,n,
     case when n>=5 and winner.meme_id is not null then 'winner' else 'insufficient_votes' end);
 end loop;
end $$;

create or replace function public.arena_standings_v7(p_week timestamptz)
returns table(id text,title text,image_url text,created_at timestamptz,elo integer,wins integer,losses integer,rank bigint)
language sql stable security definer set search_path='' as $$
 select m.id::text,m.title,coalesce(m.image_url,m.image_uri),m.created_at,
   coalesce(e.rating,1200),coalesce(e.wins,0),coalesce(e.losses,0),
   row_number() over(order by coalesce(e.rating,1200) desc,coalesce(e.wins,0) desc,m.id::text)
 from public.memes m left join public.arena_entries_v7 e on e.meme_id=m.id::text and e.week_start=p_week
 where m.kind='trending' and m.created_at>=p_week and m.created_at< p_week+interval '7 days'
   and m.created_at<=now() and coalesce(m.image_url,m.image_uri) like 'https://%'
$$;

create or replace function public.arena_state_v7(p_since timestamptz default null)
returns jsonb language plpgsql security definer set search_path='' as $$
declare w timestamptz:=public.arena_week_v7(); pool jsonb; prior jsonb; n bigint; fresh bigint; count_all bigint;
begin
 perform public.arena_finalize_v7();
 select coalesce(jsonb_agg(to_jsonb(s)),'[]'::jsonb) into pool
 from (select * from public.arena_standings_v7(w) order by rank limit 200) s;
 select count(*),count(*) filter(where created_at >= date_trunc('day',now() at time zone 'UTC') at time zone 'UTC'),
 count(*) filter(where p_since is not null and created_at>p_since)
 into count_all,n,fresh from public.arena_standings_v7(w);
 select to_jsonb(a) into prior from public.arena_winners_v7 a where week_start=w-interval '7 days';
 return jsonb_build_object('pool',pool,'week_start',w,'closes_at',w+interval '7 days',
 'server_now',now(),'new_today',n,'new_since',case when p_since is null then null else fresh end,
 'eligible_count',count_all,'previous_winner',prior);
end $$;

create or replace function public.arena_vote_v7(p_winner text,p_loser text,p_request uuid)
returns jsonb language plpgsql security definer set search_path='' as $$
declare actor uuid:=auth.uid(); w timestamptz:=public.arena_week_v7();
 winrow record; loserrow record; delta integer; prior_n bigint; agree_n bigint;
 before_rank bigint; after_rank bigint; consensus numeric; response jsonb;
begin
 if actor is null then raise exception 'Authentication required' using errcode='42501';end if;
 if p_request is null or p_winner is null or p_loser is null or p_winner=p_loser then
 raise exception 'Invalid vote' using errcode='22023';end if;
 perform pg_advisory_xact_lock(hashtextextended(actor::text,0));
 -- Do not double-count a retry. Client can refresh after an ambiguous network outcome.
 if exists(select 1 from public.arena_votes_v7 where request_id=p_request) then
 raise exception 'Vote already recorded; refresh daily state' using errcode='23505';end if;
 if (select count(*) from public.arena_votes_v7 where voter_id=actor and created_at>now()-interval '1 minute')>=30 then
 raise exception 'Rate limit' using errcode='P0001';end if;
 -- Serialize season ratings/rank calculation and finalization to avoid lost updates.
 perform pg_advisory_xact_lock(hashtextextended('arena-v7-'||w::text,0));
 if exists(select 1 from public.arena_winners_v7 where week_start=w) then raise exception 'Season closed';end if;
 select * into winrow from public.arena_standings_v7(w) where id=p_winner;
 select * into loserrow from public.arena_standings_v7(w) where id=p_loser;
 if winrow.id is null or loserrow.id is null then raise exception 'Contender expired' using errcode='22023';end if;
 before_rank:=winrow.rank;
 -- Prior votes on this exact pair by OTHER visitors only; never label this a population survey.
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
revoke all on function public.arena_finalize_v7(),public.arena_standings_v7(timestamptz) from public,anon,authenticated;
revoke all on function public.arena_state_v7(timestamptz),public.arena_vote_v7(text,text,uuid) from public,anon,authenticated;
grant execute on function public.arena_state_v7(timestamptz) to anon,authenticated;
grant execute on function public.arena_vote_v7(text,text,uuid) to authenticated;
commit;
-- Optional: enable pg_cron in Supabase, then schedule as database owner:
-- select cron.schedule('arena-v7-weekly-close','0 0 * * 1','select public.arena_finalize_v7()');
-- Otherwise completed seasons finalize on the next arena-state request.
-- Weeks close Sunday 23:59:59 UTC (Monday 00:00 UTC). Winner needs >=3 appearances,
-- and the whole season >=5 votes. Low-traffic seasons honestly have no winner.
-- This protects NEW arena tables. Existing legacy policies still need review.
