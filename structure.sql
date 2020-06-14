-- reset db

drop schema public cascade;
create schema public;
grant all on schema public to current_user;
grant all on schema public to public;

-- define roles

do
$do$
  begin
    if not exists (
      select
      from   pg_catalog.pg_roles
      where  rolname = 'postgraphile') then

      create role postgraphile login password 'xyz';
    end if;
  end
$do$;

-- define tables

create table users (
  id                serial  primary key,
  apartment_number  text    unique not null,
  email             text    unique not null
);

create table laundry_rooms (
  id    serial  primary key,
  name  text    unique not null
);

create table time_slots (
  id          serial  primary key,
  start_time  time without time zone not null,
  end_time    time without time zone not null
);

create table reservations (
  id                serial              primary key,
  laundry_room_id   int                 not null references laundry_rooms (id),
  time_slot_id      int                 not null references time_slots (id),
  user_id           int                 not null references users (id),
  reservation_date  date                not null,
  reserved_at       timestamp           not null default now(),
  deleted_at        timestamp
);

-- disallow double booking

create unique index unique_reservations_per_timeslot
  on reservations (
    laundry_room_id,
    time_slot_id,
    reservation_date
  )
  where deleted_at is null;

-- only allow one present/future reservation per user

create function disallow_multiple_reservations()
  returns trigger as $$
  begin
    if (
      select count(*) > 1
      from
        reservations
      inner join time_slots
        on time_slots.id = reservations.time_slot_id
      where
        user_id = new.user_id
        and (reservation_date + end_time) > now()
    ) then
      raise exception 'One user cannot make multiple reservations';
    end if;
    return new;
  end;
  $$ language 'plpgsql';

create trigger disallow_multiple_reservations
  after insert
  on reservations
  for each row
  execute procedure disallow_multiple_reservations();

-- grant appropriate access to postgraphile user

grant usage, select on all sequences in schema public to postgraphile;

grant select on users to postgraphile;
grant select on laundry_rooms to postgraphile;
grant select on time_slots to postgraphile;
grant select on reservations to postgraphile;

grant insert (reservation_date, laundry_room_id, time_slot_id, user_id) on reservations to postgraphile;
grant update (deleted_at) on reservations to postgraphile;

-- RLS
-- TODO: add limitations related to accounts

-- alter table users enable row level security;

alter table reservations enable row level security;

create policy select_reservation
  on reservations
  for select
  using (
    true
  );

create policy insert_reservation
  on reservations
  for insert
  with check (
    true
  );

-- changing deleted_at from null to not null is the only allowed mutation

create policy delete_reservation
  on reservations
  for update
  using (
    deleted_at is null
  )
  with check (
    deleted_at is not null
  );

-- trigger to enforce that deleted_at is accurate

create function set_deleted_at()
  returns trigger as $$
  begin
    new.deleted_at = now();
    return new;
  end;
  $$ language 'plpgsql';

create trigger set_deleted_at
  before update
  on reservations
  for each row
  execute procedure set_deleted_at();

-- insert values

insert into laundry_rooms (name)
  values
    ('Tvättstuga 1'),
    ('Tvättstuga 2');

insert into time_slots (start_time, end_time)
  values
    ('08:00', '12:00'),
    ('12:00', '16:00'),
    ('16:00', '20:00');

insert into users (apartment_number, email)
  values
    ('B1202', 'axel.ulmestig@gmail.com'),
    ('D1202', 'ost@fisk.com');
