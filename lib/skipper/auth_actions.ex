defmodule Skipper.AuthActions do
  alias Skipper.UserQueries
  alias Skipper.User

  def register(params) do
    changeset = User.changeset(%User{}, params)
    if changeset.valid? do
      user = Skipper.Repo.insert(changeset)
      {:ok, user}
    else
      {:error, changeset}
    end
  end

  @doc """
    Verifies if the provided `password` is the same as the `password` for the user
    associated with the given `email`.
  """
  def verify_password(email, password) do
    case UserQueries.find_by_email(email) do
      %User{password_digest: password_digest} = user ->
        if Comeonin.Bcrypt.checkpw(password, password_digest) do
          {:ok, user}
        else
          {:error, "Incorrect user or password"}
        end
      _ -> {:error, "Incorrect user or password"}
    end
  end

  @doc """
    Sends an e-mail to the user with a link to recover the password.
  """
  def recover_password(email) do
    UserQueries.find_by_email(email)
    |> UserQueries.add_recovery_key(generate_random_key)
    |> send_password_recovery_email
  end

  @doc """
    Triggers an error when `password` and `password_confirm` mismatch.
  """
  def reset_password(_, password, password_confirm) when password != password_confirm do
    {:error, "passwords must match"}
  end

  @doc """
    Triggers an error when `recovery_hash` is invalid.
  """
  def reset_password(recovery_hash, _, _)
    when is_nil(recovery_hash)
    or recovery_hash == "" do
    {:error, "invalid recovery hash"}
  end

  @doc """
    Resets the password for the user with the given `recovery_hash`.
  """
  def reset_password(recovery_hash, password, password_confirm, repo \\ Addict.Repository, password_interactor \\ Addict.PasswordInteractor)  when password == password_confirm do
    hash = password_interactor.generate_hash(password)
    repo.find_by_recovery_hash(recovery_hash)
    |> reset_user_password(hash, repo)
  end

  #
  # Private functions
  #

  defp reset_user_password(nil,_,_) do
    {:error, "invalid recovery hash"}
  end

  defp reset_user_password({:error, message},_,_) do
    {:error, message}
  end

  defp reset_user_password(user, hash, repo) do
    repo.change_password(user, hash)
  end

  defp validate_params(nil) do
    throw "Unable to create user, invalid hash: nil"
  end

  defp validate_params(user_params) do
    case is_nil(user_params["email"])
         or is_nil(user_params["password"])
         or is_nil(user_params["username"]) do
           false -> user_params
           true -> throw "Unable to create user, invalid hash. Required params: email, password, username"
         end
  end

  defp create_username(hash, user_params, repo) do
    user_params = Map.delete(user_params, "password")
    |> Map.put("hash", hash)
    repo.create(user_params)
  end

  defp send_password_recovery_email({:ok, nil}, _) do
    {:error, "Unable to send recovery e-mail"}
  end

  defp send_password_recovery_email({:ok, user}, mailer) do
    result = mailer.send_password_recovery_email(user)
    IO.puts "sent recovery email"
    case result do
      {:ok, _} -> {:ok, user}
      {:error, message} -> {:error, message}
    end
  end

  defp send_password_recovery_email({:error, _}, _) do
    {:error, "Unable to send recovery e-mail"}
  end

  defp send_welcome_email({:ok, user}, mailer) do
    result = mailer.send_welcome_email(user)
    case result do
      {:ok, _} -> {:ok, user}
      {:error, message} -> {:error, message}
    end
  end

  defp send_welcome_email({:error, message}, _) do
    {:error, message}
  end

  defp generate_random_key do
    Comeonin.Pbkdf2.hashpwsalt "1"
  end

  def send_welcome_email(user) do
    Skipper.Mailer.send_email_to_user "#{user.username} <#{user.email}>",
      "Registration <welcome@yourawesomeapp.com>",
      "Welcome to yourawesomeapp!",
      "Body"
  end

  def send_password_recovery_email(user) do
    Skipper.Mailer.send_email_to_user "#{user.username} <#{user.email}>",
      "Password Recovery <no-reply@yourawesomeapp.com>",
      "You requested a password recovery link",
      "Body"
  end
end
