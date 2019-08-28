defmodule LiveTracker.Sessions.Session do
  @moduledoc """
  Schema for managing user sessions.
  """
  use Ecto.Schema

  import Ecto.Changeset

  alias Ecto.UUID

  @type t :: %__MODULE__{
          id: String.t(),
          username: String.t() | nil,
          theme: String.t(),
          current_song_id: String.t() | nil
        }

  @valid_themes ~w(elixir ojuice fastblue)

  embedded_schema do
    field(:username, :string)
    field(:theme, :string, default: "elixir")
    field(:current_song_id, :string)
  end

  @spec new :: t()
  def new do
    %__MODULE__{
      id: UUID.generate()
    }
  end

  def changeset(session, params \\ %{}) do
    session
    |> cast(params, ~w(username theme)a)
    |> validate_required([:username])
    |> validate_format(:username, ~r/[A-Za-z0-9]+/)
    |> validate_length(:username, max: 14)
    |> validate_inclusion(:theme, @valid_themes)
  end
end
