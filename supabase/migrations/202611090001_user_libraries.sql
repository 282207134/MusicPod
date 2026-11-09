-- Run this entire file in Supabase SQL Editor. Only a signed-in owner can
-- read or write their library. Public/publishable keys alone grant no access.
begin;
create table if not exists public.user_libraries (
  user_id uuid primary key references auth.users(id) on delete cascade,
  data jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now(),
  constraint library_object check (jsonb_typeof(data) = 'object'),
  constraint library_size check (octet_length(data::text) <= 2097152)
);
alter table public.user_libraries enable row level security;
revoke all on table public.user_libraries from anon;
revoke all on table public.user_libraries from authenticated;
grant select, insert, update on table public.user_libraries to authenticated;
drop policy if exists "Read own library" on public.user_libraries;
create policy "Read own library" on public.user_libraries for select
  to authenticated using ((select auth.uid()) = user_id);
drop policy if exists "Create own library" on public.user_libraries;
create policy "Create own library" on public.user_libraries for insert
  to authenticated with check ((select auth.uid()) = user_id);
drop policy if exists "Update own library" on public.user_libraries;
create policy "Update own library" on public.user_libraries for update
  to authenticated using ((select auth.uid()) = user_id)
  with check ((select auth.uid()) = user_id);
commit;
