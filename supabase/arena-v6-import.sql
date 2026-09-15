-- Optional server importer prerequisite. Review against the real database.
-- A duplicate reddit_id causes index creation to fail rather than deleting data.
begin;
alter table public.memes add column if not exists reddit_id text;
alter table public.memes add column if not exists reddit_score integer default 0;
alter table public.memes add column if not exists source text;
create unique index if not exists arena_memes_reddit_id_unique on public.memes(reddit_id);
commit;
