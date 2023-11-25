defmodule Elixirtube.Repo.Migrations.AddPositionToMedia do
  use Ecto.Migration

  def change do
    alter table(:media) do
      add :position_in_playlist, :integer
    end
  end
end
