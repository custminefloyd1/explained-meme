-- Certified Funny V1 — secure, atomic rating backend
-- Run once in the Supabase SQL Editor after arena-v7-retention.sql.
-- Expected SQL Editor result: Success. No rows returned.

begin;

create table if not exists public.certified_funny_votes_v1 (
  id bigint generated always as identity primary key,
  request_id uuid not null unique,
  voter_id uuid not null,
  meme_id text not null,
  rating smallint not null check (rating between 1 and 10),
  vote_day date not null default (timezone('utc', now()))::date,
  created_at timestamptz not null default now(),
  unique (voter_id, meme_id, vote_day)
);

alter table public.certified_funny_votes_v1 enable row level security;

revoke all on table public.certified_funny_votes_v1 from anon, authenticated;
revoke all on sequence public.certified_funny_votes_v1_id_seq from anon, authenticated;

create or replace function public.certified_funny_rate_v1(
  p_meme text,
  p_rating integer,
  p_request uuid
)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_user uuid := auth.uid();
  v_row public.memes%rowtype;
  v_existing public.certified_funny_votes_v1%rowtype;
begin
  if v_user is null then
    raise exception 'Authentication required' using errcode = '42501';
  end if;

  if p_meme is null or p_request is null or p_rating not between 1 and 10 then
    raise exception 'Invalid rating request' using errcode = '22023';
  end if;

  -- Serialize this visitor's rating for this meme.
  perform pg_advisory_xact_lock(hashtextextended(v_user::text || ':' || p_meme, 0));

  select *
    into v_existing
  from public.certified_funny_votes_v1
  where request_id = p_request;

  if found then
    if v_existing.voter_id <> v_user
       or v_existing.meme_id <> p_meme
       or v_existing.rating <> p_rating then
      raise exception 'Request ID conflict' using errcode = '22023';
    end if;

    select * into v_row from public.memes where id::text = p_meme;
    return jsonb_build_object(
      'meme_id', p_meme,
      'avg_rating', coalesce(v_row.avg_rating, 0),
      'ratings_count', coalesce(v_row.ratings_count, 0),
      'duplicate', true
    );
  end if;

  if exists (
    select 1
    from public.certified_funny_votes_v1
    where voter_id = v_user
      and meme_id = p_meme
      and vote_day = (timezone('utc', now()))::date
  ) then
    raise exception 'Already rated today' using errcode = '23505';
  end if;

  -- Basic per-identity abuse ceiling.
  if (
    select count(*)
    from public.certified_funny_votes_v1
    where voter_id = v_user
      and created_at >= now() - interval '1 minute'
  ) >= 20 then
    raise exception 'Rate limit exceeded' using errcode = '54000';
  end if;

  select *
    into v_row
  from public.memes
  where id::text = p_meme
    and lower(coalesce(kind, '')) = 'funny'
  for update;

  if not found then
    raise exception 'Funny meme not found' using errcode = '22023';
  end if;

  insert into public.certified_funny_votes_v1
    (request_id, voter_id, meme_id, rating)
  values
    (p_request, v_user, p_meme, p_rating);

  update public.memes
  set
    avg_rating = round(
      (
        coalesce(avg_rating, 0)::numeric * coalesce(ratings_count, 0)
        + p_rating
      ) / (coalesce(ratings_count, 0) + 1),
      1
    ),
    ratings_count = coalesce(ratings_count, 0) + 1
  where id::text = p_meme
  returning * into v_row;

  return jsonb_build_object(
    'meme_id', p_meme,
    'avg_rating', v_row.avg_rating,
    'ratings_count', v_row.ratings_count,
    'duplicate', false
  );
end
$$;

revoke all on function public.certified_funny_rate_v1(text, integer, uuid) from public, anon;
grant execute on function public.certified_funny_rate_v1(text, integer, uuid) to authenticated;

-- Fail closed if client roles gained direct access.
do $$
begin
  if has_table_privilege('anon', 'public.certified_funny_votes_v1', 'SELECT,INSERT,UPDATE,DELETE')
     or has_table_privilege('authenticated', 'public.certified_funny_votes_v1', 'SELECT,INSERT,UPDATE,DELETE') then
    raise exception 'Direct Certified Funny vote-table access exists; rolling back';
  end if;

  if has_function_privilege('anon', 'public.certified_funny_rate_v1(text,integer,uuid)', 'EXECUTE') then
    raise exception 'Anonymous unauthenticated RPC access exists; rolling back';
  end if;

  if not has_function_privilege('authenticated', 'public.certified_funny_rate_v1(text,integer,uuid)', 'EXECUTE') then
    raise exception 'Authenticated RPC access missing; rolling back';
  end if;
end
$$;

commit;
