defmodule Chinook.Schemas.Permission do
  use Ecto.Schema

  schema "app_permission" do
    field(:name, :string)

    timestamps()
  end
end
