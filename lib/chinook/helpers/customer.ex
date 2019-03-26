defmodule Chinook.Helpers.Customer do
  alias Chinook.Repo

  alias Chinook.Schemas.{User, Customer, Employee}

  import Ecto.Query

  @doc """
  Lists customer accessible to the user.
  """
  @spec all(Ecto.Schema.t()) :: [Ecto.Schema.t()]

  def all(user) do
    cond do
      User.group_member?(user, :admin) -> do_all(:admin, user)
      User.group_member?(user, :supervisor) -> do_all(:supervisor, user)
      User.group_member?(user, :agent) -> do_all(:agent, user)
      true -> do_all(:customer, user)
    end
  end

  #########
  # Helpers

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
