defmodule Chinook.Schemas.Group do
  use Ecto.Schema

  alias Chinook.Schemas.User
  alias Chinook.Schemas.Permission

  schema "app_group" do
    field(:name, :string)

    many_to_many(:users, User, join_through: "app_user_group")
    many_to_many(:permissions, Permission, join_through: "app_group_permission")

    timestamps()
  end

end
