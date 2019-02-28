defmodule Chinook.Schemas.Album do
  use Ecto.Schema

  alias Chinook.Schemas.Artist

  @primary_key {:id, :integer, autogenerate: false, source: :AlbumId}
  schema "Album" do
    field(:title, :string, source: :Title)
    belongs_to(:artist, Artist, source: :ArtistId)
  end
end
