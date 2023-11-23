defmodule Elixirtube.Repo.Migrations.CascadeDeleteMediaSpeakers do
  use Ecto.Migration

  def change do
    alter table(:media_speakers) do
      modify :media_id, references(:media, on_delete: :delete_all),
        from: references(:media, on_delete: :nothing)

      modify :speaker_id, references(:speakers, on_delete: :delete_all),
        from: references(:speakers, on_delete: :nothing)
    end
  end
end
