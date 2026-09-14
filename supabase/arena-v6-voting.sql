-- Battle Arena v6: apply in Supabase SQL editor after reviewing existing policies.
-- Requires public.memes with id, kind, created_at, elo, wins, losses.
-- Enable anonymous sign-ins in Authentication settings. Never expose service_role.
-- This migration does NOT alter policies used by other website pages.
begin;
create table if not exists public.arena_votes_v6 (
  id bigint generated always as identity primary key,
  voter_id uuid not null references auth.users(id) on delete cascade,
  winner_id text not null,
  loser_id text not null,
  vote_day date not null default (now() at time zone 'UTC')::date,
  created_at timestamptz not null default now(),
  check (winner_id <> loser_id)
);
create unique index if not exists arena_votes_v6_once_per_pair
on public.arena_votes_v6 (voter_id, vote_day, least(winner_id,loser_id), greatest(winner_id,loser_id));
create index if not exists arena_votes_v6_rate_limit
on public.arena_votes_v6 (voter_id, created_at);
alter table public.arena_votes_v6 enable row level security;
revoke all on public.arena_votes_v6 from anon, authenticated;
create or replace function public.arena_vote_v6(p_winner text, p_loser text)
returns jsonb
language plpgsql security definer set search_path = ''
as $$
declare
  actor uuid := auth.uid();
  w public.memes%rowtype;
  l public.memes%rowtype;
  delta integer;
  answer jsonb;
begin
  if actor is null then raise exception 'Authentication required' using errcode='42501'; end if;
  if p_winner is null or p_loser is null or p_winner=p_loser then
    raise exception 'Two different contenders required' using errcode='22023';
  end if;
  -- Serialize each visitor before checking limits, then lock memes in fixed order.
  perform pg_advisory_xact_lock(hashtextextended(actor::text,0));
  if (select count(*) from public.arena_votes_v6 where voter_id=actor and created_at>now()-interval '1 minute')>=20 then
    raise exception 'Too many votes; wait a minute' using errcode='P0001';
  end if;
  perform id from public.memes where id::text in (p_winner,p_loser) order by id::text for update;
  select * into w from public.memes where id::text=p_winner;
  select * into l from public.memes where id::text=p_loser;
  if w.id is null or l.id is null or w.kind is distinct from 'trending' or l.kind is distinct from 'trending'
    or w.created_at is null or l.created_at is null
    or w.created_at<now()-interval '7 days' or l.created_at<now()-interval '7 days'
    or w.created_at>now() or l.created_at>now() then
    raise exception 'Contenders are no longer eligible' using errcode='22023';
  end if;
  insert into public.arena_votes_v6(voter_id,winner_id,loser_id) values(actor,p_winner,p_loser);
  delta := greatest(1,round(32*(1-1/(1+power(10::numeric,
    greatest(-4000,least(4000,coalesce(l.elo,1200)-coalesce(w.elo,1200)))::numeric/400))))::integer);
  update public.memes set elo=coalesce(elo,1200)+delta,wins=coalesce(wins,0)+1 where id::text=p_winner;
  update public.memes set elo=coalesce(elo,1200)-delta,losses=coalesce(losses,0)+1 where id::text=p_loser;
  select jsonb_agg(jsonb_build_object('id',id::text,'elo',elo,'wins',wins,'losses',losses))
    into answer from public.memes where id::text in (p_winner,p_loser);
  return answer;
end;
$$;
revoke all on function public.arena_vote_v6(text,text) from public,anon;
grant execute on function public.arena_vote_v6(text,text) to authenticated;
commit;

-- Release requirement: audit existing public.memes policies. If anon/authenticated
-- clients may PATCH elo/wins/losses directly, they can bypass this function.
-- Do not revoke shared website privileges blindly: migrate those old write paths
-- deliberately before claiming tamper-resistant global rankings.
-- Anonymous identities can be recreated; configure Auth rate limits/CAPTCHA and
-- stronger identity checks if abuse appears. This is not bot-proof.
