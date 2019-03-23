defmodule Chinook.Schemas.User do
  use Ecto.Schema

  import Ecto.Changeset

  alias Chinook.Schemas.Group
  alias Chinook.Schemas.Permission

  # this could also be used to define an enum with `ecto_enum`,
  # but let's keep our list of deps as small as possible.
  # An Ecto.Type could also be defined.
  @valid_roles ["admin", "supervisor", "agent", "customer"]

  @spec valid_role?(atom() | binary()) :: boolean
  def valid_role?(role) do
    role in @valid_roles
  end

  schema "app_user" do
    field(:username, :string)
    field(:email, :string)
    field(:role, :string)

    many_to_many(:groups, Group, join_through: "app_user_group")
    many_to_many(:permisions, Permission, join_through: "app_user_permission")

    timestamps()
  end

  def changeset(user, params) do
    valid = [:username, :email, :role]

    user
    |> cast(params, valid)
    |> validate_required(valid)
    |> validate_change(:role, &validate/2)
  end

  #########
  # Helpers

  defp validate(:role, value) do
    if not valid_role?(value) do
      roles = Enum.join(@valid_roles, ", ")

      [role: "Invalid role #{value}. Valid values: #{roles}"]
    else
      []
    end
  end

  defp validate(_, _), do: []
end
