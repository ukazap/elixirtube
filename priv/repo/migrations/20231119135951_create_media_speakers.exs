defmodule Elixirtube.Repo.Migrations.CreateMediaSpeakers do
  use Ecto.Migration

  def change do
    create table(:media_speakers) do
      add :media_id, references(:media, on_delete: :nothing)
      add :speaker_id, references(:speakers, on_delete: :nothing)
    end

    create unique_index(:media_speakers, [:media_id, :speaker_id])
    create index(:media_speakers, [:media_id])
    create index(:media_speakers, [:speaker_id])
  end
end
