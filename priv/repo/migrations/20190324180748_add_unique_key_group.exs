defmodule Chinook.Repo.Migrations.AddUniqueKeyGroup do
  use Ecto.Migration

  def up do
    create unique_index("app_group", [:name], name: "app_group_name_unique")
  end

  def down do
    drop index("app_group", [:name], name: "app_group_name_unique")
  end
end
