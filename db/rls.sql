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

create policy delete_reservation
  on reservations
  for update
  using (
    deleted_at is null
  )
  with check (
    deleted_at is not null
  );
