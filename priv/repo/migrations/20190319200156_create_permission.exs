defmodule Chinook.Repo.Migrations.CreatePermission do
  use Ecto.Migration

  def up do
    create table("app_permission") do
      add :name, :string, null: false

      timestamps()
    end

    create table("app_user_permission") do
      add :user_id, references("app_user"), null: false
      add :permission_id, references("app_permission"), null: false
    end

    create table("app_group_permission") do
      add :group_id, references("app_group"), null: false
      add :permission_id, references("app_permission"), null: false
    end
  end

  def down do
    drop table("app_user_permission")
    drop table("app_group_permission")
    drop table("app_permission")
  end
end
