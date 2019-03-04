defmodule Chinook.Helpers.Customer do
  alias Chinook.Repo

  alias Chinook.Schemas.{User, Customer, Employee}

  import Ecto.Query

  @doc """
  Lists customer accessible to the user
  """
  @spec all(Ecto.Schema.t()) :: [Ecto.Schema.t()]
  def all(%User{role: "supervisor", id: usr_id}) do
    # obtains only customers whose representative
    # DIRECTLY report to the given supervisor user.
    # TODO can we do this on only one query
    %Employee{id: emp_id} = Repo.get_by(Employee, user_id: usr_id)

    Customer
    |> join(:inner, [c], e in Employee, on: c.rep_id == e.id)
    |> where([c, e], e.reports_to_id == ^emp_id or c.rep_id == ^emp_id)
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
