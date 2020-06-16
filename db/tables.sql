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
