defmodule Elixirtube.Repo.Migrations.CreateMedia do
  use Ecto.Migration

  def change do
    create table(:media) do
      add :media_type, :string
      add :slug, :string
      add :source, :string
      add :title, :string
      add :raw_title, :string
      add :description, :text
      add :speaker_names, {:array, :string}
      add :urls, {:array, :string}
      add :thumbnails, :map
      add :published_at, :utc_datetime
      add :playlist_id, references(:playlists, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end

    create unique_index(:media, [:source])
    create unique_index(:media, [:playlist_id, :slug])
    create index(:media, [:playlist_id])
  end
end
