defmodule Elixirtube.Repo.Migrations.CreatePlaylists do
  use Ecto.Migration

  def change do
    create table(:playlists) do
      add :slug, :string
      add :source, :string
      add :title, :string
      add :location, :string
      add :description, :text
      add :urls, {:array, :string}
      add :thumbnails, :map
      add :published_at, :utc_datetime
      add :series_id, references(:series, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end

    create unique_index(:playlists, [:slug])
    create unique_index(:playlists, [:source])
    create index(:playlists, [:series_id])
  end
end
