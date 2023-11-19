defmodule Elixirtube.Repo.Migrations.CreateSeries do
  use Ecto.Migration

  def change do
    create table(:series) do
      add :slug, :string
      add :title, :string
      add :description, :text
      add :urls, {:array, :string}

      timestamps(type: :utc_datetime)
    end

    create unique_index(:series, [:slug])
  end
end
