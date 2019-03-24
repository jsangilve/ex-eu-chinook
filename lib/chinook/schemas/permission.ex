defmodule Chinook.Schemas.Permission do
  use Ecto.Schema

  @timestamps_opts [type: :naive_datetime_usec]
  schema "app_permission" do
    field(:name, :string)

    timestamps()
  end
end
