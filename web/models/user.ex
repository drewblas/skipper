defmodule Skipper.User do
  use Skipper.Web, :model
  use Ecto.Model.Callbacks
  alias Skipper.Repo

  before_insert :set_password_digest

  schema "users" do
    # belongs_to :account, Skipper.Account

    field :email, :string
    field :name, :string
    field :password, :string, virtual: true
    field :password_digest, :string
    field :recovery_key, :string

    timestamps
  end

  @required_fields ~w(email password)
  @optional_fields ~w()

  @doc """
  Creates a changeset based on the `model` and `params`.

  If `params` are nil, an invalid chageset is returned
  with no validation performed.
  """

  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
    |> validate_format(:email, ~r/^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,4}$/)
    # |> validate_length(:username, min: 5)
    # |> validate_length(:username, max: 50)
    |> validate_length(:password, min: 8)
    |> validate_length(:password, max: 100)
    |> validate_unique(:email, on: Repo)
    # |> validate_unique(:username, on: Repo)
  end

  def set_password_digest(changeset) do
    password = Ecto.Changeset.get_field(changeset, :password)
    change(changeset, %{password_digest: crypt_password(password)})
  end

  def crypt_password(password) do
    Comeonin.Bcrypt.hashpwsalt(password)
  end
end
