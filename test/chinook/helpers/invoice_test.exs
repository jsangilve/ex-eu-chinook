defmodule Chinook.Schemas.InvoiceTest do
  use ExUnit.Case, async: true

  alias Chinook.Repo

  alias Chinook.Schemas.{Customer, User, Employee, Invoice}
  alias Chinook.Helpers.Invoice, as: InvoiceH
  alias Chinook.Helpers.Customer, as: CustomerH
  alias Chinook.TestUtils

  import Ecto.Query

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Repo)

    # create user for existent employees
    Employee
    |> Repo.all()
    |> Enum.each(fn employee ->
      assistants =
        from(e in Employee, where: e.reports_to_id == ^employee.id)
        |> Repo.aggregate(:count, :id)

      role =
        if assistants > 0 do
          "supervisor"
        else
          "agent"
        end

      TestUtils.create_user(
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
      TestUtils.create_user(
        "customer",
        "customer_#{customer.id}",
        "customer_#{customer.id}@example.com",
        %{customer_id: customer.id}
      )
    end)
  end

  describe "query/1" do
    test "only list invoices that belong to the customer with id 3" do
      invoices = InvoiceH.all(customer_id: 3)

      assert length(invoices) == 7, "get 7 invoices without checking access"
      assert Enum.all?(invoices, fn %Invoice{customer_id: c_id} -> c_id == 3 end)

      # same result when user is passed in
      %Customer{user: user} = Repo.get(Customer, 3) |> Repo.preload(:user)

      invoices = InvoiceH.all(customer_id: 3, user: user)

      assert length(invoices) == 7
      assert Enum.all?(invoices, fn %Invoice{customer_id: c_id} -> c_id == 3 end)
    end

    test "access check prevent customers from getting invoices from another customer" do
      %Customer{user: user} = Repo.get(Customer, 3) |> Repo.preload(:user)

      assert [] = InvoiceH.all(customer_id: 4, user: user)
    end

    test "only list invoices that belong to customers assisted by agent 3" do
      %Employee{user: user} = Repo.get(Employee, 3) |> Repo.preload(:user)

      customer_ids = CustomerH.all(user) |> Enum.map(&Map.get(&1, :id))

      invoices = InvoiceH.all(user: user)

      assert Enum.all?(invoices, fn %Invoice{customer_id: c_id} -> c_id in customer_ids end)
    end

    test "cannot list invoices that belong to another agent's customer" do
      %Employee{user: user1} = Repo.get(Employee, 3) |> Repo.preload(:user)
      %Employee{user: user2} = Repo.get(Employee, 4) |> Repo.preload(:user)

      %Customer{id: user1_cust_id} = CustomerH.all(user1) |> Enum.random()
      %Customer{id: user2_cust_id} = CustomerH.all(user2) |> Enum.random()

      assert [] = InvoiceH.all(customer_id: user2_cust_id, user: user1)
      assert [] = InvoiceH.all(customer_id: user1_cust_id, user: user2)
    end

    test "supervisor can list all invoices" do
      %Employee{user: user} = Repo.get(Employee, 2) |> Repo.preload(:user)

      invoices = InvoiceH.all(user: user)
      all_invoices = Repo.all(Invoice)
      assert length(invoices) == length(all_invoices)
    end
  end
end
