defmodule Skipper.AuthController do
  use Skipper.Web, :controller
  alias Skipper.User

  plug Skipper.Plugs.CheckAuthentication
  plug :redirect_if_authenticated when action in [:register, :register_form, :login, :login_form]
  plug :scrub_params, "user" when action in [:create, :update]
  plug :action

  def index(conn, _params) do
    users = Repo.all(User)
    render conn, "index.html", users: users
  end

  def login_form(conn, _params) do
    render conn, "login_form.html"
  end

  def login(conn, %{"login_info" => %{"email" => email, "password" => password}}) do
    case Skipper.AuthActions.check_email_and_password(email, password) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "You have logged in!")
        |> put_session(:user_id, user.id)
        |> redirect(to: default_path(conn))
      :error ->
        conn
        |> put_flash(:info, "No such login or password")
        |> redirect(to: auth_path(conn, :login_form))
    end
  end

  def sign_out(conn, _params) do
    conn
    |> put_flash(:info, "You have logged out!")
    |> delete_session(:user_id)
    |> redirect(to: default_path(conn))
  end

  def register_form(conn, _params) do
    render(conn, "register_form.html", changeset: User.changeset(%User{}))
  end

  def register(conn, %{"user" => user_params}) do
    case Skipper.AuthActions.register(user_params) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "You have signed up and logged in!")
        |> put_session(:user_id, user.id)
        |> redirect(to: page_path(conn, :index))
      {:error, changeset} ->
        conn
        |> render("register_form.html", changeset: changeset)
    end
  end

  @doc """
   Entry point for asking for a new password.
   Params need to be populated with `email`
  """
  def recover_password(conn, params) do
    email = params["email"]

    case Skipper.AuthActions.recover_password(email) do
      {:ok, _} ->
        conn
        |> put_flash(:info, "Password recovery email sent!")
        |> render("recover_password.html")
      {:error, changeset} ->
        conn
        |> render("recover_password.html", changeset: changeset)
    end
  end

  @doc """
   Entry point for setting a user's password given the reset token.
   Params needed to be populated with `token`, `password` and `password_confirm`
  """
  def reset_password(conn, params) do
    token = params["token"]
    password = params["password"]
    password_confirm = params["password_confirm"]

    {conn, message} = @manager.reset_password(token, password, password_confirm)
    |> SessionInteractor.password_reset(conn)
    json conn, message
  end

  # Private functions

  defp redirect_if_authenticated(conn, _opts) do
    if conn.assigns[:current_user] do
      conn
      |> put_flash(:info, "You have already logged in!")
      |> redirect(to: default_path(conn))
    end
    conn
  end

  defp default_path(conn) do
    page_path(conn, :index)
  end
end
