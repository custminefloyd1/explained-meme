-- Contact V1 — private delivery metadata and abuse controls
-- Run once in Supabase SQL Editor before deploying contact-v1.
-- Message bodies, names and email addresses are NOT stored here.

begin;

create table if not exists public.contact_deliveries_v1 (
  request_id uuid primary key,
  sender_id uuid not null,
  status text not null check (status in ('pending','sent','failed')),
  provider_message_id text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists contact_deliveries_v1_sender_created_idx
  on public.contact_deliveries_v1 (sender_id, created_at desc);

alter table public.contact_deliveries_v1 enable row level security;
revoke all on table public.contact_deliveries_v1 from public, anon, authenticated;

do $$
begin
  if has_table_privilege('anon', 'public.contact_deliveries_v1', 'SELECT,INSERT,UPDATE,DELETE')
     or has_table_privilege('authenticated', 'public.contact_deliveries_v1', 'SELECT,INSERT,UPDATE,DELETE') then
    raise exception 'Direct contact-delivery access exists; rolling back';
  end if;
end
$$;

commit;
