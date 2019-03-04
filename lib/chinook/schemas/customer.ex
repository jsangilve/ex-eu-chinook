defmodule Chinook.Schemas.Customer do
  use Ecto.Schema

  alias Chinook.Schemas.{Employee, User}

  @primary_key {:id, :integer, autogenerate: false, source: :CustomerId}
  schema "Customer" do
    field(:first_name, :string, source: :FirstName)
    field(:last_name, :string, source: :LastName)

    belongs_to(:representative, Employee, source: :SupportRepId, foreign_key: :rep_id)
    belongs_to(:user, User, foreign_key: :user_id)
  end
end
