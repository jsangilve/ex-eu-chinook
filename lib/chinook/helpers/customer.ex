defmodule Chinook.Helpers.Customer do
  @moduledoc """
  Helper functions to query the Customer's schema checking
  access through the database's Row-Level Security.
  """
  alias Chinook.Repo

  alias Chinook.Schemas.{User, Customer, Employee}

  import Ecto.Query

  @config_current_user "chinook.app_user"
  @config_parameters ["chinook.app_user"]
  @valid_roles ["admin", "supervisor", "agent", "customer"]


  @doc """
  Lists customer accessible to the user.

  It wraps within a tra
  It creates a transaction to use the current user's
  role along with
  to the current user;
  """
  @spec all(Ecto.Schema.t()) :: [Ecto.Schema.t()]

  def all(%User{id: user_id}) do
    Repo.transaction(fn ->
      set_local_parameter(@config_current_user, user_id)
      Repo.all(Customer)
    end)
  end

  #########
  # Helpers

  # set database config parameter for the current transaction
  defp set_local_parameter(param, value) when param in @config_parameters do
    sql = "SET LOCAL #{param} to #{value}"
    Repo.query!(sql)
  end

  defp set_local_parameter(param, _) do
    raise ArgumentError, "Invalid config parameter #{param}"
  end

  # reset database config parameter for the current transaction
  def reset_local_parameter(param) when param in @config_parameters do
    sql = "SET LOCAL #{param} to DEFAULT;"
    Repo.query!(sql)
  end

  def set_local_parameter(param) do
    raise ArgumentError, "Invalid config parameter #{param}"
  end

  # set database role for transaction
  def set_local_role(role) when role in @valid_roles  do
    sql = "SET LOCAL ROLE #{role}"
    Repo.query!(sql)
  end

  def set_local_role(role) do
    raise ArgumentError, "Invalid role #{role}"
  end

  # reset to database's session role
  def reset_role do
    Repo.query!("RESET ROLE")
  end

  @spec do_query_all(integer(), Ecto.Query.t()) :: Ecto
  defp do_query_all(user_id, query) do
    Repo.transaction(fn ->
      set_local_parameter(@config_current_user, user_id)
      Repo.all(query)
    end)
  end

  defp do_all(:admin, _) do
    Repo.all(Customer)
  end

  defp do_all(:supervisor, %User{id: usr_id}) do
    # lists customers whose agent DIRECTLY report to the given
    # supervisor user or has this user as agent.
    Employee
    |> join(:inner, [e1], e2 in Employee, on: e2.reports_to_id == e1.id and e1.user_id == ^usr_id)
    |> join(:inner, [e1, e2], c in Customer, on: c.rep_id == e2.id or c.rep_id == e1.id)
    |> Repo.all()
  end

  defp do_all(:agent, %User{id: usr_id}) do
    Customer
    |> join(:inner, [c], e in Employee, on: c.rep_id == e.id and e.user_id == ^usr_id)
    |> Repo.all()
  end

  defp do_all(:customer, %User{id: usr_id}) do
    Customer
    |> where([c], c.user_id == ^usr_id)
    |> Repo.all()
  end
end
