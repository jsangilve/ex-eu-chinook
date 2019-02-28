defmodule Chinook.Schemas.Customer do
  use Ecto.Schema

  alias Chinook.Schemas.Employee

  @primary_key {:id, :integer, autogenerate: false, source: :CustomerId}
  schema "Customer" do
    field(:first_name, :string, source: :FirstName)
    field(:last_name, :string, source: :LastName)

    belongs_to(:representative, Employee, foreign_key: :SupportRepId)
  end
end
