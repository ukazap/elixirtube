defmodule Elixirtube.Repo.Migrations.ChangeMediaUniqueConstraints do
  use Ecto.Migration

  def change do
    drop unique_index(:media, [:playlist_id, :slug])
    create unique_index(:media, [:slug])
  end
end
