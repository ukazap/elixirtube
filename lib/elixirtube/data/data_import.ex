defmodule Elixirtube.Data.DataImport do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset
  alias __MODULE__

  @primary_key {:git_commit_sha, :string, autogenerate: false}
  schema "data_imports" do
    timestamps(type: :utc_datetime, updated_at: false)
  end

  @doc false
  def changeset(data_import, attrs) do
    data_import
    |> cast(attrs, [:git_commit_sha])
    |> validate_required([:git_commit_sha])
    |> unique_constraint(:git_commit_sha)
  end

  @doc false
  def new_import_changeset(git_commit_sha) do
    changeset(%DataImport{}, %{git_commit_sha: git_commit_sha})
  end
end
