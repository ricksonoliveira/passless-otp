defmodule Passless.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :phone_number, :string, null: false
      add :inserted_at, :utc_datetime, null: false, default: fragment("NOW()")
      add :updated_at, :utc_datetime, null: false, default: fragment("NOW()")
    end

    create unique_index(:users, [:phone_number], name: :users_phone_number_index)
  end
end
