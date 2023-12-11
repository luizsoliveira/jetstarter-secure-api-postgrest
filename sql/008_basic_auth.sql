-- SQL statements based on PostgREST documentation
-- available at: https://postgrest.org/en/stable/how-tos/sql-user-management.html#sql-user-management

-- We put things inside the basic_auth schema to hide
-- them from public view. Certain public procs/views will
-- refer to helpers and tables inside.

create schema if not exists basic_auth;

-- We would like the role to be a foreign key to actual database roles.
-- However PostgreSQL does not support these constraints against the pg_roles table. We’ll use a trigger to manually enforce it.

create or replace function
basic_auth.check_role_exists() returns trigger as $$
begin
  if not exists (select 1 from pg_roles as r where r.rolname = new.role) then
    raise foreign_key_violation using message =
      'unknown database role: ' || new.role;
    return null;
  end if;
  return new;
end
$$ language plpgsql;

drop trigger if exists ensure_user_role_exists on secure.users;
create constraint trigger ensure_user_role_exists
  after insert or update on secure.users
  for each row
  execute procedure basic_auth.check_role_exists();


-- Next we’ll use the pgcrypto extension and a trigger to keep passwords safe in the users table.

create extension if not exists pgcrypto;

create or replace function
basic_auth.encrypt_pass() returns trigger as $$
begin
  if tg_op = 'INSERT' or new.pass <> old.pass then
    new.pass = crypt(new.pass, gen_salt('bf'));
  end if;
  return new;
end
$$ language plpgsql;

drop trigger if exists encrypt_pass on secure.users;
create trigger encrypt_pass
  before insert or update on secure.users
  for each row
  execute procedure basic_auth.encrypt_pass();

  -- With the table in place we can make a helper to check a password against the encrypted column.
  -- It returns the database role for a user if the email and password are correct.

  create or replace function
basic_auth.user_role(email text, pass text) returns name
  language plpgsql
  as $$
begin
  return (
  select role from secure.users su
   where su.email = user_role.email
     and su.pass = crypt(user_role.pass, su.pass)
  );
end;
$$;

-- Creating roles

create role authenticator noinherit;
grant api_anon_user to authenticator;