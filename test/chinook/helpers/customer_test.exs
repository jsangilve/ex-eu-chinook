defmodule Chinook.Schemas.CustomerTest do
  @moduledoc """
  These tests rely on exitent database data (NOT A GOOD PRACTICE AT ALL, but enough to
   show that everything works with this approach).
  """
  use ExUnit.Case, async: true

  alias Chinook.Repo
  alias Chinook.Schemas.{Customer, User, Employee}
  alias Chinook.Helpers.Customer, as: CustomerH

  import Ecto.Query

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Repo)

    # create user for existent employees
    Employee
    |> Repo.all()
    |> Enum.each(fn employee ->
      assistants =
        from(e in Employee, where: e.reports_to_id == ^employee.id, select: count())
        |> Repo.all()

      role =
        if assistants > 0 do
          "supervisor"
        else
          "agent"
        end

      create_user(
        role,
        "employee_#{employee.id}",
        "employee_#{employee.id}@example.com",
        %{employee_id: employee.id}
      )
    end)

    # create user for existent customers
    Customer
    |> Repo.all()
    |> Enum.each(fn customer ->
      create_user(
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
      %Employee{user: user} = Repo.get(Employee, 4) |> Repo.preload(:user)

      assert length(CustomerH.all(user)) == 20
    end

    test "A customer can only get itself" do
      %Customer{id: c_id, user: user} = Repo.get(Customer, 1) |> Repo.preload(:user)

      assert [%Customer{id: ^c_id}] = CustomerH.all(user)
    end
  end

  #########
  # HELPERS

  defp gen_user(role, username, email, extra) do
    data =
      %{username: username, role: role, email: email}
      |> Map.merge(extra)

    User.changeset(%User{}, data)
  end

  defp create_user(
         role,
         username \\ "c_test_user",
         email \\ "c_test_email@example.com",
         data \\ %{}
       ) do
    changeset = gen_user(role, username, email, data)

    with {:ok, user} <- Repo.insert(changeset) do
      associate_record(user, data)
    end
  end

  defp associate_record(user, %{employee_id: e_id}) do
    Repo.get(Employee, e_id)
    |> Ecto.Changeset.change(%{user_id: user.id})
    |> Repo.update()
    |> case do
      {:ok, _} -> {:ok, user}
      error -> error
    end
  end

  defp associate_record(user, %{customer_id: c_id}) do
    Repo.get(Customer, c_id)
    |> Ecto.Changeset.change(%{user_id: user.id})
    |> Repo.update()
    |> case do
      {:ok, _} -> {:ok, user}
      error -> error
    end
  end

  defp associate_record(user, _), do: {:ok, user}
end
