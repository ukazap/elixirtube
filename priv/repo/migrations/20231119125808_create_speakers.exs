defmodule Elixirtube.Repo.Migrations.CreateSpeakers do
  use Ecto.Migration

  def change do
    create table(:speakers) do
      add :slug, :string
      add :name, :string
      add :bio, :text
      add :urls, {:array, :string}

      timestamps(type: :utc_datetime)
    end

    create unique_index(:speakers, [:slug])
  end
end
