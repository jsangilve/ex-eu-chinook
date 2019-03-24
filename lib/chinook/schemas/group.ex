defmodule Chinook.Schemas.Group do
  use Ecto.Schema

  alias Chinook.Schemas.User
  alias Chinook.Schemas.Permission

  @timestamps_opts [type: :naive_datetime_usec]
  schema "app_group" do
    field(:name, :string)

    many_to_many(:users, User, join_through: "app_user_group", on_replace: :delete)

    many_to_many(:permissions, Permission,
      join_through: "app_group_permission",
      on_replace: :delete
    )

    timestamps()
  end
end
