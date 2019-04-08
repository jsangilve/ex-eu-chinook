defmodule Chinook.Helpers.Customer do
  @moduledoc """
  Helper functions to query the Customer's schema checking
  access through the database's Row-Level Security.
  """
  alias Chinook.Repo

  alias Chinook.Schemas.{User, Customer}

  require Chinook.Schemas.User

  @config_current_user "chinook.app_user"
  @config_parameters ["chinook.app_user"]

  @doc """
  Lists customer accessible to the user.

  Creates a transaction that set's the current role and
  the @config_current.user before getting the list of Customers.
  """
  @spec all(Ecto.Schema.t()) :: [Ecto.Schema.t()]

  def all(%User{id: user_id, role: role}) do
    with {:ok, result} =
           Repo.transaction(fn ->
             set_local_role(role)
             set_local_parameter(@config_current_user, user_id)
             Repo.all(Customer)
           end) do
      result
    end
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
  def set_local_role(value) when User.is_valid_role(value) do
    sql = "SET LOCAL ROLE #{value}"
    Repo.query!(sql)
  end

  def set_local_role(role) do
    raise ArgumentError, "Invalid role #{role}"
  end

  # reset to database's session role
  def reset_role do
    Repo.query!("RESET ROLE")
  end
end
