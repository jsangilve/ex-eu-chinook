defmodule Chinook.Schemas.User do
  use Ecto.Schema

  import Ecto.Changeset

  schema "app_user" do
    field :username, :string
    field :email, :string
    field :role, :string

    timestamps()
  end

  def changeset(user, params) do

    valid = [:username, :email, :role]

    user
    |> cast(params, valid)
    |> validate_required(valid)
  end
end
