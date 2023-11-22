defmodule Elixirtube.Repo.Migrations.CreateDataImports do
  use Ecto.Migration

  def change do
    create table(:data_imports, primary_key: false) do
      add :git_commit_sha, :string, null: false, primary_key: true

      timestamps(type: :utc_datetime, updated_at: false)
    end

    create unique_index(:data_imports, [:git_commit_sha])
  end
end
