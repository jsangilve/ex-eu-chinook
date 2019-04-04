defmodule Chinook.Repo.Migrations.CustomerPolicies do
  use Ecto.Migration

  def up do
    # unlimited Admin access to Customer table
    execute ~s<CREATE POLICY admin_customer ON "Customer" TO chinook_admin USING (true)>

    # limit Supervisor access to Customer table
    execute ~s<CREATE POLICY supervisor_customer ON "Customer" TO chinook_supervisor
      USING (
        "SupportRepId" IN (
          SELECT e2."EmployeeId"
          FROM "Employee" e1 
          JOIN "Employee" e2 ON 
            e2."ReportsTo" = e1."EmployeeId" OR e2.user_id = current_setting('chinook.app_user')::integer
          WHERE e1.user_id = current_setting('chinook.app_user')::integer
        )
      )>

    # limit agent access to Customer table
    execute ~s<CREATE POLICY agent_customer ON "Customer" TO chinook_agent 
      USING ("SupportRepId" = (SELECT "EmployeeId" FROM "Employee" e WHERE e.user_id = current_setting('chinook.app_user')::integer))>

    # limit customer access to Customer table
    execute ~s<CREATE POLICY customer_itself on "Customer" to chinook_customer
    USING (user_id = current_setting('chinook.app_user')::integer)>
  end

  def down do
    execute ~s<DROP POLICY admin_customer on "Customer">
    execute ~s<DROP POLICY supervisor_customer on "Customer">
    execute ~s<DROP POLICY agent_customer on "Customer">
    execute ~s<DROP POLICY customer_itself on "Customer">
  end
end
