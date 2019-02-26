defmodule Chinook.Schemas.Artist do
  use Ecto.Schema

  alias Chinook.Schemas.Album

  @primary_key {:id, :integer, autogenerate: false, source: :ArtistId}
  schema "Artist" do
    field(:name, :string, source: :Name)

    has_many(:albums, Album, foreign_key: :ArtistId)
  end
end
