defmodule Skipper.UserQueries do
  import Ecto.Query
  alias Skipper.User
  alias Skipper.Repo

  def find_by_email(email) do
    query = from user in User,
    where: user.email == ^email,
    select: user
    Repo.one(query)
  end

  def find_by_recovery_key(key) do
    query = from user in User, where: user.recovery_key == ^key
    Repo.one query
  end

  def add_recovery_key(nil, _) do
    {:error, "Invalid user"}
  end

  @doc """
  Adds a recovery key to the user.
  """
  def add_recovery_key(user, key) do
    user = %{user | recovery_key: key}

    {:ok, Repo.update(user)}
  end

  @doc """
  Changes the password_digest for the target user.
  """
  def change_password(user, password_digest) do
    user = %{ user | recovery_key: nil, password_digest: password_digest}

    {:ok, Repo.update(user)}
  end
end
