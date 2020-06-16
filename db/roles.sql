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
