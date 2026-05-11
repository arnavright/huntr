create table if not exists public.waitlist (
  email text primary key,
  signed_up_at timestamptz not null default now(),
  constraint waitlist_email_normalized
    check (email = lower(btrim(email))),
  constraint waitlist_email_length
    check (char_length(email) between 3 and 320),
  constraint waitlist_email_format
    check (email ~ '^[a-z0-9._%+\-]+@[a-z0-9.\-]+\.[a-z]{2,}$')
);

do $$
begin
  if not exists (
    select 1
    from pg_constraint
    where conname = 'waitlist_email_normalized'
      and conrelid = 'public.waitlist'::regclass
  ) then
    alter table public.waitlist
      add constraint waitlist_email_normalized
      check (email = lower(btrim(email)));
  end if;

  if not exists (
    select 1
    from pg_constraint
    where conname = 'waitlist_email_length'
      and conrelid = 'public.waitlist'::regclass
  ) then
    alter table public.waitlist
      add constraint waitlist_email_length
      check (char_length(email) between 3 and 320);
  end if;

  if not exists (
    select 1
    from pg_constraint
    where conname = 'waitlist_email_format'
      and conrelid = 'public.waitlist'::regclass
  ) then
    alter table public.waitlist
      add constraint waitlist_email_format
      check (email ~ '^[a-z0-9._%+\-]+@[a-z0-9.\-]+\.[a-z]{2,}$');
  end if;
end $$;

alter table public.waitlist enable row level security;
alter table public.waitlist force row level security;

revoke all on table public.waitlist from anon, authenticated;
grant usage on schema public to anon;
grant insert (email) on table public.waitlist to anon;

drop policy if exists "allow anonymous waitlist inserts" on public.waitlist;

create policy "allow anonymous waitlist inserts"
on public.waitlist
for insert
to anon
with check (
  email is not null
  and email = lower(btrim(email))
  and char_length(email) between 3 and 320
  and email ~ '^[a-z0-9._%+\-]+@[a-z0-9.\-]+\.[a-z]{2,}$'
);
