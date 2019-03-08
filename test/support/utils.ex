defmodule Chinook.TestUtils do
  @moduledoc """
  Common functions to be used across test cases.
  """

  alias Chinook.Repo
  alias Chinook.Schemas.{Customer, Employee, User}

  def gen_user(role, username, email, extra) do
    data =
      %{username: username, role: role, email: email}
      |> Map.merge(extra)

    User.changeset(%User{}, data)
  end

  def create_user(
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

  #########
  # Helpers

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
