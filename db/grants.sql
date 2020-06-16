grant usage, select on all sequences in schema public to postgraphile;

grant select on users to postgraphile;
grant select on laundry_rooms to postgraphile;
grant select on time_slots to postgraphile;
grant select on reservations to postgraphile;

grant insert (reservation_date, laundry_room_id, time_slot_id, user_id) on reservations to postgraphile;
grant update (deleted_at) on reservations to postgraphile;
