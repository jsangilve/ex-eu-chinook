defmodule Chinook.Helpers.Customer do
  alias Chinook.Repo

  alias Chinook.Schemas.{User, Customer, Employee}

  import Ecto.Query

  @doc """
  Lists customer accessible to the user
  """
  @spec all(Ecto.Schema.t()) :: [Ecto.Schema.t()]
  def all(%User{role: "supervisor", id: usr_id}) do
    # lists customers whose agent DIRECTLY report to the given
    # supervisor user or has this user as agent.
    Employee
    |> join(:inner, [e1], e2 in Employee, on: e2.reports_to_id == e1.id)
    |> join(:inner, [e1, e2], c in Customer, on: c.rep_id == e2.id or c.rep_id == e1.id)
    |> where([e], e.user_id == ^usr_id)
    |> Repo.all()
  end

  def all(%User{role: "agent", id: usr_id}) do
    Customer
    |> join(:inner, [c], e in Employee, on: c.rep_id == e.id and e.user_id == ^usr_id)
    |> Repo.all()
  end

  def all(%User{role: "customer", id: usr_id}) do
    Customer
    |> where([c], c.user_id == ^usr_id)
    |> Repo.all()
  end

  def all(_user) do
    Repo.all(Customer)
  end
end
