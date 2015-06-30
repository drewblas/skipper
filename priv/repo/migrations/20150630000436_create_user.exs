defmodule Skipper.Repo.Migrations.CreateUser do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :account_id,      :integer

      add :email,           :string, size: 200
      add :name,            :string, size: 200
      add :password_digest, :string, size: 130
      add :recovery_key,    :string, size: 130

      timestamps
    end
    create index(:users, [:account_id])
    create index(:users, [:email], unique: true)

  end
end
