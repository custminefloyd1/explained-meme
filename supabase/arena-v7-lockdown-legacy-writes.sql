-- Daily Meme Battle V7 — legacy public-write lockdown
-- Reviewed against arena-v7-legacy-write-preflight.sql output from 2026-09-15.
--
-- Purpose:
--   * Keep public reads of meme records and public image buckets working.
--   * Remove legacy browser writes to public.memes.
--   * Remove public Storage upload policies, including one dangerously unscoped policy.
--   * Leave V7 RPC voting and the server-side importer working.
--
-- The V7 vote RPC writes only to isolated arena_*_v7 tables through a
-- SECURITY DEFINER function. The Reddit importer uses ctx.supabaseAdmin.
--
-- Run this whole file once in the Supabase SQL Editor.
-- Expected result: "Success. No rows returned."

begin;

-- Legacy browser writes to public.memes are no longer used.
drop policy if exists "Allow public insert" on public.memes;
drop policy if exists "Allow public update" on public.memes;
drop policy if exists "public_update_memes_table" on public.memes;

-- Keep SELECT for the existing read-only parts of the site.
revoke insert, update, delete, truncate, references, trigger
  on table public.memes
  from anon, authenticated;
grant select on table public.memes to anon, authenticated;

-- The removed ?admin uploader was the only known browser upload flow.
-- "Allow insert 1psdoj_0" was especially unsafe: WITH CHECK (true) allowed
-- uploads to any bucket reachable through the Storage API.
drop policy if exists "Allow insert 1psdoj_0" on storage.objects;
drop policy if exists "Allow upload 1twzac9_0" on storage.objects;

-- Do not revoke storage.objects table grants here. Supabase Storage uses those
-- standard grants together with RLS. With no INSERT policy, client uploads are
-- denied, while the existing bucket-scoped SELECT policies/public buckets stay
-- readable.

-- Fail and roll back if a direct client can still mutate public.memes.
do $$
begin
  if has_table_privilege('anon', 'public.memes', 'INSERT')
     or has_table_privilege('anon', 'public.memes', 'UPDATE')
     or has_table_privilege('anon', 'public.memes', 'DELETE')
     or has_table_privilege('anon', 'public.memes', 'TRUNCATE')
     or has_table_privilege('authenticated', 'public.memes', 'INSERT')
     or has_table_privilege('authenticated', 'public.memes', 'UPDATE')
     or has_table_privilege('authenticated', 'public.memes', 'DELETE')
     or has_table_privilege('authenticated', 'public.memes', 'TRUNCATE') then
    raise exception 'Legacy public.memes write privileges still exist; rolling back';
  end if;

  if exists (
    select 1
    from pg_policies
    where schemaname = 'public'
      and tablename = 'memes'
      and cmd in ('INSERT', 'UPDATE', 'DELETE', 'ALL')
      and ('public' = any(roles) or 'anon' = any(roles) or 'authenticated' = any(roles))
  ) then
    raise exception 'Legacy public.memes write policy still exists; rolling back';
  end if;

  if exists (
    select 1
    from pg_policies
    where schemaname = 'storage'
      and tablename = 'objects'
      and cmd in ('INSERT', 'UPDATE', 'DELETE', 'ALL')
      and ('public' = any(roles) or 'anon' = any(roles) or 'authenticated' = any(roles))
  ) then
    raise exception 'Public Storage write policy still exists; rolling back';
  end if;
end
$$;

commit;
