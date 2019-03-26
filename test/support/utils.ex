defmodule Chinook.TestUtils do
  @moduledoc """
  Common functions to be used across test cases.
  """

  alias Chinook.Repo
  alias Chinook.Schemas.{Customer, Employee, User, Group, Permission}

  import Ecto.Query

  @group_names ["admin", "supervisor", "agent", "customer"]
  @admin_perms ["FullCustomers", "FullInvoices"]
  @supervisor_perms [
    "FullSupervisedCustomers",
    "FullAssignedCustomers",
    "FullSupervisedInvoices",
    "FullAssignedInvoices"
  ]
  @agent_perms ["FullAssignedCustomers", "FullAssignedInvoices"]

  @permission_names [
    "FullCustomers",
    "ReadSupervisedCustomers",
    "FullSupervisedCustomers",
    "ReadAssignedCustomers",
    "FullAssignedCustomers",
    "FullInvoices",
    "ReadSupervisedInvoices",
    "FullSupervisedInvoices",
    "ReadAssignedInvoices",
    "FullAssignedInvoices"
  ]

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

  def create_groups do
    dt = NaiveDateTime.utc_now()

    groups =
      @group_names
      |> Enum.map(
        &[
          name: &1,
          inserted_at: dt,
          updated_at: dt
        ]
      )

    Repo.insert_all(Group, groups)
  end

  def create_permissions do
    dt = NaiveDateTime.utc_now()

    permissions =
      @permission_names
      |> Enum.map(
        &[
          name: &1,
          inserted_at: dt,
          updated_at: dt
        ]
      )

    Repo.insert_all(Permission, permissions)
  end

  def put_user_group(user, group) do
    %User{groups: groups} = user = Repo.preload(user, :groups)

    user
    |> Ecto.Changeset.change()
    |> Ecto.Changeset.put_assoc(:groups, [group | groups])
    |> Repo.update()
  end

  def put_group_permission(group, permission) do
    %Group{permissions: perms} = group = Repo.preload(group, :permissions)

    group
    |> Ecto.Changeset.change()
    |> Ecto.Changeset.put_assoc(:permissions, [permission | perms])
    |> Repo.update()
  end

  def create_admin_perms do
    associate_group_perms("admin", @admin_perms)
  end

  def create_supervisor_perms do
    associate_group_perms("supervisor", @supervisor_perms)
  end

  def create_agent_perms do
    associate_group_perms("agent", @agent_perms)
  end

  def setup_groups_perms do
    create_groups()
    create_permissions()

    with :ok <- create_admin_perms(),
         :ok <- create_supervisor_perms(),
         :ok <- create_agent_perms() do
      :ok
    end
  end

  #########
  # Helpers

  defp associate_group_perms(group_name, perm_names) do
    group = Repo.get_by(Group, name: group_name)

    from(p in Permission, where: p.name in ^perm_names)
    |> Repo.all()
    |> Enum.each(&put_group_permission(group, &1))
  end

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
