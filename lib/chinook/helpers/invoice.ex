defmodule Chinook.Helpers.Invoice do
  import Ecto.Query

  alias Chinook.Schemas.User

  @base_params [:id, :address, :city, :state, :country]
  @special_params [:date, :total]
  @assoc_params [:customer_id]

  @doc """
  Queries invoices given a map or keyword list of parameters.
  """
  @spec query(Keyword.t() | map()) :: Ecto.Query.t()
  def query(params \\ %{})

  def query(params) when is_list(params) do
    params
    |> Enum.uniq_by(fn {k, _} -> k end)
    |> do_query
  end

  @spec query(map()) :: Ecto.Query.t()
  def query(params) when is_map(params) do
    params
    |> Map.to_list()
    |> do_query
  end

  @doc false
  def do_query(params) do
    base_params = Keyword.take(params, @base_params)
    special_params = Keyword.take(params, @special_params)
    assoc_params = Keyword.take(params, @assoc_params)

    # adding :user access check
    assoc_params =
      case Keyword.get(params, :user) do
        %User{id: user_id, role: "customer"} ->
          [{:user_id, user_id} | assoc_params]

#        %User{id: user_id, role: "agent"} ->


        _ ->
          assoc_params
      end

    Invoice
    |> where(^base_params)
    |> query_special_params(special_params)
    |> query_association(assoc_params)
  end

  @doc """
  Allows more complex comparison over "special" parameters as `:date` or `:total`,
  e.g. `:date__gte`, date greater than or equal to; `:total_lt`, total less than, etc.
  """
  @spec query_special_params(Ecto.Query.t(), Keyword.t()) :: Ecto.Query.t()
  def query_special_params(query, []), do: query

  def query_special_params(query, params) do
    Enum.reduce(params, query, fn {key, value}, acc ->
      query_field(acc, key, value)
    end)
  end

  @doc false
  def query_field(query, key, value) do
    # look for the operator as a suffix
    split_key = key |> to_string() |> String.split("__", parts: 2)

    {field, op} =
      case split_key do
        [str_key, str_op] ->
          {String.to_existing_atom(str_key), String.to_existing_atom(str_op)}

        [str_key] ->
          {String.to_existing_atom(str_key), :eq}
      end

    from(query, where: ^query_op(op, field, value))
  end

  @doc """
  Filters invoices based on the fields of the associated schema
  Customer.
  """
  @spec query_association(Ecto.Query.t(), Keyword.t()) :: Ecto.Query.t()
  def query_association(query, []), do: query

  def query_association(query, params) do
    join_query = from(q in query, join: c in Customer, as: :customer, on: q.customer_id == c.id)

    Enum.reduce(params, join_query, fn {key, value}, acc ->
      # TODO let's improve this to re-use query_field
      from([_q, customer: c] in acc, where: field(c, ^key) == ^value)
    end)
  end

  #########
  # Helpers

  defp query_op(:lt, key, value) do
    dynamic([q], field(q, ^key) < ^value)
  end

  defp query_op(:lte, key, value) do
    dynamic([q], field(q, ^key) <= ^value)
  end

  defp query_op(:gt, key, value) do
    dynamic([q], field(q, ^key) > ^value)
  end

  defp query_op(:gte, key, value) do
    dynamic([q], field(q, ^key) >= ^value)
  end

  defp query_op(_, key, value) do
    dynamic([q], field(q, ^key) == ^value)
  end
end
