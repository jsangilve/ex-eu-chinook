defmodule Chinook.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def up do
    create table("user") do
      add :username, :string
      add :email, :string
      add :role, :string

      timestamps()
    end
  end

  def down do
    drop table("user")
  end
end
