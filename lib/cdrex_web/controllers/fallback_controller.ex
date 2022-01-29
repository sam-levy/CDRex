defmodule CDRexWeb.FallbackController do
  use Phoenix.Controller

  import Ecto.Changeset, only: [traverse_errors: 2]

  alias Ecto.Changeset

  alias CDRexWeb.ErrorView

  def call(conn, {:error, :bad_request}) do
    conn
    |> put_status(:bad_request)
    |> render_error("400.json")
  end

  def call(conn, %StrongParams.Error{errors: errors}) do
    conn
    |> put_status(:bad_request)
    |> render_error("400.json", %{keys: format(errors)})
  end

  def call(conn, {:error, :not_found}) do
    conn
    |> put_status(:not_found)
    |> render_error("404.json")
  end

  def call(conn, {:error, error}) do
    conn
    |> put_status(:unprocessable_entity)
    |> render_error("422.json", errors: format(error))
  end

  defp render_error(conn, template, opt \\ %{}) do
    conn
    |> put_view(ErrorView)
    |> render(template, opt)
  end

  defp format(%Changeset{} = changeset), do: handle_errors(changeset)

  defp format({string, _opts}) when is_binary(string), do: string

  defp format(string) when is_binary(string), do: string

  defp format(errs) when is_map(errs) or is_list(errs) do
    Enum.reduce(errs, %{}, &format_reducer/2)
  end

  defp format_reducer({key, value}, errors), do: Map.put(errors, key, format(value))
  defp format_reducer(value, errors), do: add_error_to_list(format(value), errors)

  defp add_error_to_list(value, list) do
    if is_list(list), do: [value | list], else: [value]
  end

  defp handle_errors(changeset) do
    traverse_errors(changeset, fn {msg, opts} ->
      Enum.reduce(opts, msg, fn {key, value}, acc ->
        String.replace(acc, "%{#{key}}", to_string(value))
      end)
    end)
  end
end
