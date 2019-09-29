defmodule LiveTracker.Sessions do
  @moduledoc """
  Context for handling managing sessions.
  """

  alias LiveTracker.Sessions.{Session, SessionStore}

  @spec create_session(Ecto.Changeset.t(), map) ::
          {:ok, Session.t()} | {:error, Ecto.Changeset.t()}
  def create_session(changeset, attrs \\ %{}) do
    with result <- change_session(changeset, attrs),
         %{valid?: true} <- result,
         session <- Map.merge(result.data, result.changes) do
      SessionStore.insert(session)
    else
      %{valid?: false} = changeset -> {:error, changeset}
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking session changes.
  ## Examples
      iex> change_session(session)
      %Ecto.Changeset{source: %Session{}}
  """
  def change_session(session, attrs \\ %{}) do
    Session.changeset(session, attrs)
  end

  @doc """
  Returns true if a session is completely setup.
  """
  def valid_session?(session) do
    case change_session(session) do
      %{valid?: true} -> true
      _ -> false
    end
  end

  @doc """
  Generates a random username for a users session.
  """
  @spec generate_username(String.t() | nil) :: {:ok, String.t()}
  def generate_username(previous_username) do
    prefixes = ~w(Zero Chip Beet)
    suffixes = ~w(Overid3 Phreak Digit41)

    username = Enum.random(prefixes) <> Enum.random(suffixes)

    if username == previous_username do
      generate_username(previous_username)
    else
      {:ok, username}
    end
  end
end
