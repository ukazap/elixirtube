defmodule Elixirtube.Repo.Migrations.ChangePlaylistLocationToLocations do
  use Ecto.Migration

  def change do
    alter table(:playlists) do
      remove :location, :string
      add :locations, {:array, :string}
    end
  end
end
