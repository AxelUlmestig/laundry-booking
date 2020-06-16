#!/bin/sh

NUKE_DB=$(cat <<-SQL
  drop schema public cascade;
  create schema public;
  grant all on schema public to current_user;
  grant all on schema public to public;
SQL
)

psql postgres://postgres@localhost:5433/postgres -c "$NUKE_DB"

psql postgres://postgres@localhost:5433/postgres \
  -f db/tables.sql \
  -f db/constraints.sql \
  -f db/subscription_triggers.sql \
  -f db/roles.sql \
  -f db/grants.sql \
  -f db/rls.sql

SEED_DB=$(cat <<-SQL
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
      ('B1202', 'alice@mail.com'),
      ('D1202', 'bob@mail.com');
SQL
)

psql postgres://postgres@localhost:5433/postgres -c "$SEED_DB"
