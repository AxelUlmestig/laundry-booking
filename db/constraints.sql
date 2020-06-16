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
        and deleted_at is null
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
