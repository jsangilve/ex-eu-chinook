defmodule Chinook.Repo.Migrations.CreateGroups do
  use Ecto.Migration

  def up do
    create table("app_group") do
      add :name, :string, null: false

      timestamps()
    end

    create table("app_user_group") do
      add :user_id, references("app_user"), null: false
      add :group_id, references("app_group"), null: false
    end
  end

  def down do
    drop table("app_user_group")
    drop table("app_group")
  end
end
