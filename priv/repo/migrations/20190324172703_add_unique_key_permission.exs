defmodule Chinook.Repo.Migrations.AddUniqueKeyPermission do
  use Ecto.Migration

  def up do
    create unique_index("app_permission", [:name], name: "app_permission_name_unique")
  end

  def down do
    drop index("app_permission", [:name], name: "app_permission_name_unique")
  end
end
