defmodule CDRexWeb.ErrorView do
  use CDRexWeb, :view

  def render("422.json", %{errors: errors}) do
    %{
      "message" => "Unprocessable entity",
      "errors" => errors
    }
  end

  def render("400.json", %{keys: keys}) do
    %{
      "message" => "Bad request",
      "errors" => keys
    }
  end

  def render("400.json", _assign) do
    %{
      "message" => "Bad request",
      "errors" => "missing parameters"
    }
  end

  def render("404.json", _assign) do
    %{
      "message" => "Not found"
    }
  end

  def render("500.json", _assign) do
    %{
      "message" => "Internal Server Error"
    }
  end
end
