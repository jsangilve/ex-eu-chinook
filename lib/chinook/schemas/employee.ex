defmodule Chinook.Schemas.Employee do
  use Ecto.Schema

  alias Chinook.Schemas.User

  @primary_key {:id, :integer, autogenerate: false, source: :EmployeeId}
  schema "Employee" do
    field(:first_name, :string, source: :FirstName)
    field(:last_name, :string, source: :LastName)
    field(:title, :string, source: :Title)

    belongs_to(:reports_to, __MODULE__, foreign_key: :reports_to_id, source: :ReportsTo)
    belongs_to(:user, User, foreign_key: :user_id)
  end
end
