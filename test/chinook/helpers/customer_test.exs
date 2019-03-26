defmodule Chinook.Schemas.CustomerTest do
  @moduledoc """
  These tests rely on exitent database data (NOT A GOOD PRACTICE AT ALL, 
  but enough to show that everything works with this approach).
  """
  use ExUnit.Case, async: true

  alias Chinook.Repo
  alias Chinook.Schemas.{Customer, User, Employee, Group, Permission}
  alias Chinook.Helpers.Customer, as: CustomerH
  alias Chinook.TestUtils

  import Ecto.Query

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Repo)

    TestUtils.setup_groups_perms()

    # create user for existent employees
    Employee
    |> Repo.all()
    |> Enum.each(fn employee ->
      assistants =
        from(e in Employee, where: e.reports_to_id == ^employee.id)
        |> Repo.aggregate(:count, :id)

      # let's change this test to add permissions instead of a role
      with {:ok, user} <-
             TestUtils.create_user(
               nil,
               "emp_#{employee.id}",
               "emp_#{employee.id}@example.com",
               %{employee_id: employee.id}
             ) do
        group =
          if assistants > 0 do
            Repo.get_by(Group, name: "supervisor")
          else
            Repo.get_by(Group, name: "agent")
          end

        TestUtils.put_user_group(user, group)
      end
    end)

    # create user for existent customers
    Customer
    |> Repo.all()
    |> Enum.each(fn customer ->
      TestUtils.create_user(
        "customer",
        "customer_#{customer.id}",
        "customer_#{customer.id}@example.com",
        %{customer_id: customer.id}
      )
    end)
  end

  describe "get_customers/1" do
    test "A supervisor can list the customer of all its agents" do
      # supervisor / employee_id 2
      %Employee{user: emp2} = Repo.get(Employee, 2) |> Repo.preload(:user)
      # supervisor / employee_id 6
      %Employee{user: emp6} = Repo.get(Employee, 6) |> Repo.preload(:user)

      assert length(CustomerH.all(emp2)) == 59
      assert length(CustomerH.all(emp6)) == 0
    end

    test "An agent can only get associated customers" do
      # let's user employee 2
      %Employee{user: user} = e = Repo.get(Employee, 4) |> Repo.preload(:user)
      assert length(CustomerH.all(user)) == 20
    end

    test "A customer can only get itself" do
      %Customer{id: c_id, user: user} = Repo.get(Customer, 1) |> Repo.preload(:user)

      assert [%Customer{id: ^c_id}] = CustomerH.all(user)
    end
  end
end
