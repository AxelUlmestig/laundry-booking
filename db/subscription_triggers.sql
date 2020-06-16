create function notify_reservation_updated()
  returns trigger as $$
  begin
    perform pg_notify(
       'postgraphile:reservation_updated',
       '{}'
     );
    return new;
  end;
  $$ language 'plpgsql';

create trigger trigger_reservation_updated_on_insert
  after insert
  on reservations
  execute procedure notify_reservation_updated();

create trigger trigger_reservation_updated_on_update
  after update
  on reservations
  execute procedure notify_reservation_updated();
