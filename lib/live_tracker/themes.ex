defmodule LiveTracker.Themes do
  @moduledoc """
  Themes for LiveTracker.
  """

  @type name :: String.t()
  @type slug :: String.t()
  @type t :: %{name: name, slug: slug}

  @spec list_themes :: [t, ...]
  def list_themes do
    [
      %{name: "Elixir", slug: "elixir"},
      %{name: "Ojuice", slug: "ojuice"},
      %{name: "FastBlue", slug: "fastblue"}
    ]
  end

  @spec get_theme(slug) :: t | nil
  def get_theme(slug) do
    list_themes()
    |> Enum.find(&(&1.slug == slug))
  end
end
