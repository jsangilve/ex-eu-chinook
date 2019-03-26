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
    # replacing role by groups and permissions
    field(:role, :string)

    many_to_many(:groups, Group, join_through: "app_user_group", on_replace: :delete)

    many_to_many(:permisions, Permission, join_through: "app_user_permission", on_replace: :delete)

    # virtual field to put group and user permissions
    field(:all_permissions, {:array, :string}, virtual: true, default: [])

    timestamps()
  end

  def changeset(user, params) do
    valid = [:username, :email]

    user
    |> cast(params, valid)
    |> validate_required(valid)
    |> validate_change(:role, &validate/2)
  end

  @spec group_member?(Ecto.Changeset.t(), atom()) :: boolean()
  def group_member?(user, :admin), do: has_group?(user, "admin")
  def group_member?(user, :supervisor), do: has_group?(user, "supervisor")
  def group_member?(user, :agent), do: has_group?(user, "agent")
  def group_member?(user, :customer), do: has_group?(user, "customer")
  def group_member?(_, _), do: false

  #########
  # Helpers

  defp has_group?(%__MODULE__{groups: groups}, group_name) when is_list(groups) do
    Enum.any?(groups, &(&1.name == group_name))
  end

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
