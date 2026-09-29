create extension if not exists pgcrypto;

create table public.host_profiles (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid unique references auth.users(id) on delete set null,
  name text not null,
  slug text not null unique,
  title text not null default '',
  bio text not null default '',
  timezone text not null default 'Africa/Lagos',
  booking_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.appointment_types (
  id uuid primary key default gen_random_uuid(),
  host_id uuid not null references public.host_profiles(id) on delete cascade,
  name text not null,
  slug text not null,
  description text not null default '',
  duration_minutes integer not null check (duration_minutes between 10 and 480),
  location_type text not null default 'google_meet',
  active boolean not null default true,
  created_at timestamptz not null default now(),
  unique (host_id, slug)
);

create table public.availability_rules (
  id uuid primary key default gen_random_uuid(),
  host_id uuid not null references public.host_profiles(id) on delete cascade,
  weekday smallint not null check (weekday between 0 and 6),
  start_time time not null,
  end_time time not null,
  enabled boolean not null default true,
  check (start_time < end_time),
  unique (host_id, weekday)
);

create table public.date_overrides (
  id uuid primary key default gen_random_uuid(),
  host_id uuid not null references public.host_profiles(id) on delete cascade,
  override_date date not null,
  start_time time,
  end_time time,
  unavailable boolean not null default false,
  check (
    unavailable
    or (start_time is not null and end_time is not null and start_time < end_time)
  ),
  unique (host_id, override_date)
);

create table public.appointments (
  id uuid primary key default gen_random_uuid(),
  host_id uuid not null references public.host_profiles(id) on delete cascade,
  appointment_type_id uuid not null references public.appointment_types(id),
  invitee_name text not null check (char_length(invitee_name) between 1 and 120),
  invitee_email text not null check (invitee_email ~* '^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$'),
  starts_at timestamptz not null,
  ends_at timestamptz not null,
  timezone text not null,
  notes text not null default '',
  status text not null default 'confirmed' check (status in ('confirmed', 'canceled', 'completed')),
  meeting_url text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  check (starts_at < ends_at)
);

create index appointments_host_starts_at_idx on public.appointments(host_id, starts_at);
create index appointments_invitee_email_idx on public.appointments(invitee_email);

alter table public.host_profiles enable row level security;
alter table public.appointment_types enable row level security;
alter table public.availability_rules enable row level security;
alter table public.date_overrides enable row level security;
alter table public.appointments enable row level security;

create policy "Public can view active hosts"
on public.host_profiles for select
using (booking_active or owner_id = auth.uid());

create policy "Owners manage their host profile"
on public.host_profiles for all to authenticated
using (owner_id = auth.uid())
with check (owner_id = auth.uid());

create policy "Public can view active appointment types"
on public.appointment_types for select
using (
  active
  and exists (
    select 1 from public.host_profiles h
    where h.id = host_id and h.booking_active
  )
  or exists (
    select 1 from public.host_profiles h
    where h.id = host_id and h.owner_id = auth.uid()
  )
);

create policy "Owners manage appointment types"
on public.appointment_types for all to authenticated
using (exists (select 1 from public.host_profiles h where h.id = host_id and h.owner_id = auth.uid()))
with check (exists (select 1 from public.host_profiles h where h.id = host_id and h.owner_id = auth.uid()));

create policy "Public can view enabled availability"
on public.availability_rules for select
using (
  enabled
  and exists (
    select 1 from public.host_profiles h
    where h.id = host_id and h.booking_active
  )
  or exists (
    select 1 from public.host_profiles h
    where h.id = host_id and h.owner_id = auth.uid()
  )
);

create policy "Owners manage availability"
on public.availability_rules for all to authenticated
using (exists (select 1 from public.host_profiles h where h.id = host_id and h.owner_id = auth.uid()))
with check (exists (select 1 from public.host_profiles h where h.id = host_id and h.owner_id = auth.uid()));

create policy "Owners manage date overrides"
on public.date_overrides for all to authenticated
using (exists (select 1 from public.host_profiles h where h.id = host_id and h.owner_id = auth.uid()))
with check (exists (select 1 from public.host_profiles h where h.id = host_id and h.owner_id = auth.uid()));

create policy "Owners view appointments"
on public.appointments for select to authenticated
using (exists (select 1 from public.host_profiles h where h.id = host_id and h.owner_id = auth.uid()));

create policy "Owners update appointments"
on public.appointments for update to authenticated
using (exists (select 1 from public.host_profiles h where h.id = host_id and h.owner_id = auth.uid()))
with check (exists (select 1 from public.host_profiles h where h.id = host_id and h.owner_id = auth.uid()));

create or replace function public.book_appointment(
  p_appointment_type uuid,
  p_name text,
  p_email text,
  p_starts_at timestamptz,
  p_timezone text,
  p_notes text default ''
)
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  v_type public.appointment_types%rowtype;
  v_ends_at timestamptz;
  v_id uuid;
begin
  select t.* into v_type
  from public.appointment_types t
  join public.host_profiles h on h.id = t.host_id
  where t.id = p_appointment_type
    and t.active
    and h.booking_active;

  if not found then
    raise exception 'This booking page is unavailable.';
  end if;

  if p_starts_at <= now() then
    raise exception 'Choose a future appointment time.';
  end if;

  if nullif(trim(p_name), '') is null
    or nullif(trim(p_email), '') is null
    or p_email !~* '^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$' then
    raise exception 'Enter valid attendee details.';
  end if;

  v_ends_at := p_starts_at + make_interval(mins => v_type.duration_minutes);

  if exists (
    select 1 from public.appointments a
    where a.host_id = v_type.host_id
      and a.status = 'confirmed'
      and tstzrange(a.starts_at, a.ends_at, '[)') && tstzrange(p_starts_at, v_ends_at, '[)')
  ) then
    raise exception 'That time was just booked. Choose another slot.';
  end if;

  insert into public.appointments (
    host_id, appointment_type_id, invitee_name, invitee_email,
    starts_at, ends_at, timezone, notes
  ) values (
    v_type.host_id, v_type.id, trim(p_name), lower(trim(p_email)),
    p_starts_at, v_ends_at, coalesce(nullif(trim(p_timezone), ''), 'Africa/Lagos'),
    left(coalesce(p_notes, ''), 2000)
  )
  returning id into v_id;

  return v_id;
end;
$$;

revoke all on function public.book_appointment(uuid, text, text, timestamptz, text, text) from public;
grant execute on function public.book_appointment(uuid, text, text, timestamptz, text, text) to anon, authenticated;

grant select on public.host_profiles, public.appointment_types, public.availability_rules to anon, authenticated;
grant select, insert, update, delete on public.host_profiles, public.appointment_types,
  public.availability_rules, public.date_overrides, public.appointments to authenticated;

insert into public.host_profiles (id, name, slug, title, bio, timezone)
values (
  '11111111-1111-4111-8111-111111111111',
  'Alex Morgan',
  'alex-morgan',
  'Independent consultant',
  'Independent product consultant helping teams turn complex ideas into clear, useful products.',
  'Africa/Lagos'
);

insert into public.appointment_types (
  id, host_id, name, slug, description, duration_minutes
) values (
  '22222222-2222-4222-8222-222222222222',
  '11111111-1111-4111-8111-111111111111',
  'Product strategy session',
  'product-strategy',
  'A focused session to clarify product direction and next steps.',
  30
);

insert into public.availability_rules (host_id, weekday, start_time, end_time)
select
  '11111111-1111-4111-8111-111111111111',
  day,
  '09:00'::time,
  case when day = 5 then '15:00'::time else '17:00'::time end
from generate_series(1, 5) as day;
