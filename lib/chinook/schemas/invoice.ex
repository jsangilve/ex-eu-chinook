defmodule Chinook.Schemas.Invoice do
  @moduledoc """
  Represents a Chinook database Invoice. Not all database
  fields has been mapped by this module.
  """
  use Ecto.Schema

  alias Chinook.Schemas.Customer

  @primary_key {:id, :integer, autogenerate: false, source: :InvoiceId}
  schema "Invoice" do
    field(:date, :utc_datetime, source: :InvoiceDate)
    field(:total, :decimal, source: :Total)
    field(:address, :string, source: :BillingAddress)
    field(:city, :string, source: :BillingCity)
    field(:state, :string, source: :BillingState)
    field(:country, :string, source: :BillingCountry)

    belongs_to(:customer, Customer, source: :CustomerId, foreign_key: :customer_id)
  end
end
