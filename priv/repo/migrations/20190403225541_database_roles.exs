defmodule Chinook.Repo.Migrations.DatabaseRoles do
  use Ecto.Migration

  def up do
    execute "CREATE ROLE chinook_admin"
    execute "CREATE ROLE chinook_supervisor"
    execute "CREATE ROLE chinook_agent"
    execute "CREATE ROLE chinook_customer"

    # access to roles
    execute "GRANT chinook_admin TO chinook_app"
    execute "GRANT chinook_supervisor TO chinook_app"
    execute "GRANT chinook_agent TO chinook_app"
    execute "GRANT chinook_customer TO chinook_app"

    # chinook_admin
    execute "GRANT ALL PRIVILEGES ON app_user TO chinook_admin"
    execute "GRANT ALL PRIVILEGES ON \"Customer\" TO chinook_admin"
    execute "GRANT ALL PRIVILEGES ON \"Employee\" TO chinook_admin" 

    # chinook_supevisor
    execute "GRANT ALL PRIVILEGES ON app_user TO chinook_supervisor"
    execute "GRANT ALL PRIVILEGES ON \"Customer\" TO chinook_supervisor"
    execute "GRANT ALL PRIVILEGES ON \"Employee\" TO chinook_supervisor" 

    # chinook_agent
    execute "GRANT ALL PRIVILEGES ON app_user TO chinook_agent"
    execute "GRANT ALL PRIVILEGES ON \"Employee\" TO chinook_agent"
    execute "GRANT ALL PRIVILEGES ON \"Customer\" TO chinook_agent"

    # chinook_customer
    execute "GRANT ALL PRIVILEGES ON app_user TO chinook_customer"
    execute "GRANT ALL PRIVILEGES ON \"Customer\" TO chinook_customer"
  end

  def down do
    execute "DROP OWNED BY chinook_admin"
    execute "DROP OWNED BY chinook_supervisor"
    execute "DROP OWNED BY chinook_agent"
    execute "DROP OWNED BY chinook_customer"

    execute "DROP ROLE chinook_admin"
    execute "DROP ROLE chinook_supervisor"
    execute "DROP ROLE chinook_agent"
    execute "DROP ROLE chinook_customer"
  end
end
