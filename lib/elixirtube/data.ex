defmodule Elixirtube.Data do
  @moduledoc """
  The Data context.
  """

  import Ecto.Query, warn: false

  alias Ecto.Multi
  alias Elixirtube.Data.BulkMediaSpeakerAssociation
  alias Elixirtube.Data.BulkUpdate
  alias Elixirtube.Data.DataImport
  alias Elixirtube.Data.GitRepo
  alias Elixirtube.Library.Media
  alias Elixirtube.Library.Playlist
  alias Elixirtube.Library.Series
  alias Elixirtube.Library.Speaker
  alias Elixirtube.Repo

  @type import_opts :: [{:dry_run, boolean()}]

  @doc """
  Returns the list of Data Imports.

  ## Examples

      iex> list_data_imports()
      [%DataImport{}, ...]

  """
  def list_data_imports do
    Repo.all(DataImport)
  end

  @doc """
  Gets last Data Import.

  Returns `nil` if the Data import does not exist.

  ## Examples

      iex> get_last_data_import()
      %DataImport{}

  """
  def get_last_data_import() do
    query_last_data_import()
    |> Repo.one()
  end

  @doc """
    Imports data from Elixirtube remote Git repository.

    ## Options

    * `:dry_run` - set to `true` to prevent committing the import into the database; optional, defaults to `false` if not set.

    ## Examples

      iex> run_data_import()
      {:ok,
      %{
        last_import: nil,
        new_import: %Elixirtube.Data.DataImport{
          __meta__: #Ecto.Schema.Metadata<:loaded, "data_imports">,
          git_commit_sha: "eca9c98a59240b07b7f55a362106856811c23c20",
          inserted_at: ~U[2023-11-24 03:51:32Z]
        },
        changes: [
          speakers: [upserts: 289],
          series: [upserts: 1],
          playlists: [upserts: 9],
          media: [upserts: 381],
          media_speakers: [upserts: 417]
        ]
      }}

      iex> run_data_import()
      {:noop,
      %{
        last_import: %Elixirtube.Data.DataImport{
          __meta__: #Ecto.Schema.Metadata<:loaded, "data_imports">,
          git_commit_sha: "eca9c98a59240b07b7f55a362106856811c23c20",
          inserted_at: ~U[2023-11-24 03:51:32Z]
        },
        changes: []
      }}
  """
  @spec run_data_import(import_opts()) :: {:ok, map()} | {:noop, map} | {:error, any()}
  def run_data_import(opts \\ [dry_run: false]) do
    multi =
      Multi.new()
      |> Multi.one(:last_import, query_last_data_import())
      |> Multi.run(:data_changes, fn _, %{last_import: last_import} ->
        case GitRepo.fetch_changes!(_since = git_rev(last_import)) do
          {_latest_rev, nil} -> {:error, nil}
          {_latest_rev, %{}} = value -> {:ok, value}
        end
      end)
      |> Multi.insert(:new_import, fn %{data_changes: {latest_rev, _changes}} ->
        DataImport.new_import_changeset(latest_rev)
      end)
      |> BulkUpdate.run(:speakers, Speaker)
      |> BulkUpdate.run(:series, Series)
      |> BulkUpdate.run(:playlists, Playlist,
        parent: {Series, "series_slug"},
        insert_all: [conflict_target: [:source]]
      )
      |> BulkUpdate.run(:media, Media,
        parent: {Playlist, "playlist_slug"},
        insert_all: [
          conflict_target: [:source],
          # for use in BulkMediaSpeakerAssociation
          returning: [:id, :speaker_names]
        ]
      )
      |> BulkMediaSpeakerAssociation.run()

    multi =
      case Keyword.get(opts, :dry_run) do
        true -> Multi.run(multi, :dry_run?, fn _, _ -> {:error, true} end)
        _ -> multi
      end

    case Repo.transaction(multi) do
      {:error, :data_changes, nil, result} ->
        {:noop, present_result(result)}

      {:error, :dry_run?, true, result} ->
        {:dry_run, present_result(result)}

      {:ok, result} ->
        {:ok, present_result(result)}
    end
  end

  defp query_last_data_import do
    from(d in DataImport, order_by: [desc: d.inserted_at], limit: 1)
  end

  defp git_rev(%DataImport{git_commit_sha: rev}), do: rev
  defp git_rev(_), do: nil

  defp present_result(result) do
    result
    |> Map.delete(:data_changes)
    |> report_changes(:speakers)
    |> report_changes(:series)
    |> report_changes(:playlists)
    |> report_changes(:media)
    |> report_changes(:media_speakers)
  end

  defp report_changes(result, key) do
    counts =
      result
      |> Map.get(key, [])
      |> Enum.map(fn {op, {count, _}} -> {op, count} end)
      |> Enum.filter(fn {_, count} -> count > 0 end)

    changes =
      result
      |> Map.get(:changes, [])
      |> then(
        &case counts do
          [] -> &1
          _ -> &1 ++ [{key, counts}]
        end
      )

    result
    |> Map.delete(key)
    |> Map.put(:changes, changes)
  end
end
