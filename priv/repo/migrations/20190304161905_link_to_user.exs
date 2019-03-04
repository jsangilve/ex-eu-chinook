defmodule Chinook.Repo.Migrations.LinkToUser do
  @moduledoc """
  Introduces Foreign Keys to app_user on Employee, and Customer tables.
  """
  use Ecto.Migration

  def up do
    alter table("Customer") do
      add :user_id, references("app_user", on_delete: :nilify_all, on_update: :nilify_all)
    end

    alter table("Employee") do
      add :user_id, references("app_user", on_delete: :nilify_all, on_update: :nilify_all)
    end
  end

  def down do
    alter table("Employee") do
      remove :user_id
    end

    alter table("Customer") do
      remove :user_id
    end
  end
end
