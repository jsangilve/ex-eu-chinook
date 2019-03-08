defmodule Chinook.Helpers.Invoice do
  import Ecto.Query

  alias Chinook.Repo
  alias Chinook.Schemas.{User, Customer, Employee, Invoice}

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

  @spec all(Keyword.t() | map()) :: [Ecto.Schema.t()]
  def all(params) do
    params
    |> query
    |> Repo.all
  end

  @doc """
  Allows more complex comparisons over "special" parameters as
  `:date` or `:total`, e.g. `:date__gte`, date greater than or
  equal to; `:total_lt`, total less than, etc.
  """
  @spec query_special_params(Ecto.Query.t(), Keyword.t()) :: Ecto.Query.t()
  def query_special_params(query, []), do: query

  def query_special_params(query, params) do
    Enum.reduce(params, query, fn {key, value}, acc ->
      query_field(acc, key, value)
    end)
  end

  @doc """
  Filters invoices based on the fields of the associated
  Customer.
  """
  @spec query_association(Ecto.Query.t(), Keyword.t()) :: Ecto.Query.t()
  def query_association(query, []), do: query

  def query_association(query, params) do
    query = query_join(query, :customer)

    Enum.reduce(params, query, fn
      {:customer_id, value}, acc ->
        from([_q, customer: c] in acc, where: field(c, :id) == ^value)

      {key, value}, acc ->
        # TODO let's improve this to re-use query_field
        from([_q, customer: c] in acc, where: field(c, ^key) == ^value)
        #      {op, f_key} = extract_op(key)
        #      from([_q, customer: c] in acc, where: ^query_op(op, )
    end)
  end

  @doc """
  Filters results according to the passed in user's role.
  """
  @spec check_access(Ecto.Query.t(), Ecto.Schema.t()) :: Ecto.Query.t()
  def check_access(query, nil), do: query

  def check_access(query, %User{role: "admin"}), do: query

  def check_access(query, %User{role: "customer"} = user) do
    # prevent from joining Employee (just for performance reasons)
    do_check_access(query, user)
  end

  def check_access(query, user) do
    query
    |> query_join(:employee)
    |> do_check_access(user)
  end

  #########
  # Helpers

  defp do_query(params) do
    base_params = Keyword.take(params, @base_params)
    special_params = Keyword.take(params, @special_params)
    assoc_params = Keyword.take(params, @assoc_params)

    # adding :user access check
    #    assoc_params =
    #      case Keyword.get(params, :user) do
    #        %User{id: user_id, role: "customer"} ->
    #          [{:user_id, user_id} | assoc_params]
    #
    ##        %User{id: user_id, role: "agent"} ->
    #
    #
    #        _ ->
    #          assoc_params
    #      end

    Invoice
    |> where(^base_params)
    |> query_special_params(special_params)
    |> query_association(assoc_params)
    |> check_access(Keyword.get(params, :user))
  end

  defp query_op(:lt, key, value), do: dynamic([q], field(q, ^key) < ^value)

  defp query_op(:lte, key, value), do: dynamic([q], field(q, ^key) <= ^value)

  defp query_op(:gt, key, value), do: dynamic([q], field(q, ^key) > ^value)

  defp query_op(:gte, key, value), do: dynamic([q], field(q, ^key) >= ^value)

  defp query_op(_, key, value), do: dynamic([q], field(q, ^key) == ^value)

  defp do_check_access(query, %User{id: user_id, role: "supervisor"}) do
    from([i, employee: e, customer: c] in query,
    #      join: e2 in Employee, on: e1.reports_to_id == e.id and
      where: e.user_id == ^user_id or c.reports_to_id == ^user_id
    )
  end

  defp do_check_access(query, %User{id: user_id, role: "agent"}) do
    from([i, employee: e] in query,
      where: e.user_id == ^user_id
    )
  end

  defp do_check_access(query, %User{id: user_id, role: "customer"}) do
    from([i, customer: c] in query,
      where: c.user_id == ^user_id
    )
  end

  defp query_join(query, :customer) do
    from(q in query, join: c in Customer, as: :customer, on: q.customer_id == c.id)
  end

  defp query_join(query, :employee) do
    query =
      if not has_named_binding?(query, :customer) do
        query_join(query, :customer)
      else
        query
      end

    from([q, customer: c] in query, join: e in Employee, as: :employee, on: c.rep_id == e.id)
  end

  defp query_join(query, _), do: query

  defp query_field(query, key, value) do
    # look for the operator as a suffix
    {op, field} = extract_op(key)

    from(query, where: ^query_op(op, field, value))
  end

  defp extract_op(key) do
    # look for the operator as a suffix
    key
    |> to_string()
    |> String.split("__", parts: 2)
    |> case do
      [str_key, str_op] ->
        {String.to_existing_atom(str_op), String.to_existing_atom(str_key)}

      [str_key] ->
        {:eq, String.to_existing_atom(str_key)}
    end
  end
end
