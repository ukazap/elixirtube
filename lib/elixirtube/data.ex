defmodule Elixirtube.Data do
  @moduledoc """
  The Data context.
  """

  import Ecto.Query, warn: false

  alias Elixirtube.Data.DataImport
  alias Elixirtube.Data.GitRepo
  alias Elixirtube.Data.RawData
  alias Elixirtube.Library.Media
  alias Elixirtube.Library.MediaSpeaker
  alias Elixirtube.Library.Playlist
  alias Elixirtube.Library.Series
  alias Elixirtube.Library.Speaker
  alias Elixirtube.Repo

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
    from(d in DataImport, order_by: [desc: d.inserted_at], limit: 1)
    |> Repo.one()
  end

  @doc "Imports data from Elixirtube remote Git repository."
  @spec import_data!() :: map() | :noop
  def import_data! do
    with data_import <- get_last_data_import(),
         since_commit_sha <- current_commit_sha(data_import),
         {latest_commit_sha, [_ | _] = changes} <- GitRepo.fetch_changes!(since_commit_sha),
         changes <- Enum.group_by(changes, fn %RawData{schema: s} -> s end) do
      import_transaction(latest_commit_sha, changes)
    else
      {sha, []} when is_binary(sha) -> :noop
    end
  end

  defp current_commit_sha(%DataImport{git_commit_sha: sha}), do: sha
  defp current_commit_sha(_), do: nil

  @schemas [Speaker, Series, Playlist, Media, MediaSpeaker]
  defp import_transaction(commit_sha, changes) do
    Repo.transaction(fn ->
      # Insert data import
      data_import = insert_data_import!(commit_sha)

      # Upsert data
      Enum.reduce(@schemas, %{DataImport => data_import}, fn schema, acc ->
        raw_data_list = Map.get(changes, schema, [])
        {entries, acc} = construct_entries(schema, raw_data_list, acc)

        opts = [
          on_conflict: {:replace_all_except, [:id, :inserted_at]},
          conflict_target: conflict_target(schema),
          returning: returning(schema)
        ]

        schema
        |> Repo.insert_all(entries, opts)
        |> case do
          {count, returned} when is_integer(count) ->
            accumulate_result(acc, schema, {count, returned})

          error ->
            Repo.rollback(error)
        end
      end)
    end)
  end

  defp insert_data_import!(commit_sha) do
    %DataImport{}
    |> DataImport.changeset(%{git_commit_sha: commit_sha})
    |> Repo.insert!()
  end

  defp construct_entries(Speaker, raw_data_list, acc) do
    {Enum.map(raw_data_list, &RawData.to_entry/1), acc}
  end

  defp construct_entries(Series, raw_data_list, acc) do
    {Enum.map(raw_data_list, &RawData.to_entry/1), acc}
  end

  defp construct_entries(Playlist, raw_data_list, acc) do
    parent_slug_to_id = create_parent_slug_to_id_lookup(raw_data_list, Series)

    entries =
      Enum.map(raw_data_list, fn %{parent: {_, parent_slug}} = raw_data ->
        raw_data
        |> RawData.to_entry()
        |> Map.put(:series_id, Map.get(parent_slug_to_id, parent_slug))
      end)

    {entries, acc}
  end

  defp construct_entries(Media, raw_data_list, acc) do
    parent_slug_to_id = create_parent_slug_to_id_lookup(raw_data_list, Playlist)

    entries =
      Enum.map(raw_data_list, fn %{parent: {_, parent_slug}} = raw_data ->
        raw_data
        |> RawData.to_entry()
        |> Map.put(:playlist_id, Map.get(parent_slug_to_id, parent_slug))
      end)

    {entries, acc}
  end

  defp construct_entries(
         MediaSpeaker,
         _raw_data_list,
         %{Media => {_, media_list}} = acc
       ) do
    media_and_speaker_slugs =
      Enum.map(media_list, fn %Media{speaker_names: speaker_names} = media ->
        {media, Enum.map(speaker_names, &Slug.slugify/1)}
      end)

    speaker_slugs =
      media_and_speaker_slugs
      |> Enum.flat_map(fn {_, speaker_slugs} -> speaker_slugs end)
      |> Enum.uniq()

    speaker_slug_to_id =
      from(s in Speaker, select: {s.slug, s.id}, where: s.slug in ^speaker_slugs)
      |> Repo.all()
      |> Enum.into(%{})

    entries =
      media_and_speaker_slugs
      |> Enum.flat_map(fn {%Media{id: media_id}, speaker_slugs} ->
        Enum.map(speaker_slugs, fn speaker_slug ->
          %{
            media_id: media_id,
            speaker_id: Map.get(speaker_slug_to_id, speaker_slug)
          }
        end)
      end)

    {entries, acc}
  end

  defp create_parent_slug_to_id_lookup(raw_data_list, schema) do
    parent_slugs =
      raw_data_list
      |> Stream.map(fn %{parent: {^schema, slug}} -> slug end)
      |> Stream.filter(&is_binary/1)
      |> Enum.uniq()

    from(s in schema, select: {s.slug, s.id}, where: s.slug in ^parent_slugs)
    |> Repo.all()
    |> Enum.into(%{})
  end

  defp conflict_target(Speaker), do: [:slug]
  defp conflict_target(Series), do: [:slug]
  defp conflict_target(Playlist), do: [:source]
  defp conflict_target(Media), do: [:source]
  defp conflict_target(MediaSpeaker), do: [:media_id, :speaker_id]

  defp returning(Media), do: [:id, :speaker_names]
  defp returning(_), do: false

  def accumulate_result(acc, Media, {_, _} = result) do
    Map.put(acc, Media, result)
  end

  def accumulate_result(%{Media => {media_count, _}} = acc, MediaSpeaker, {count, _}) do
    Map.merge(acc, %{
      MediaSpeaker => count,
      Media => media_count
    })
  end

  def accumulate_result(acc, schema, {count, _}) do
    Map.put(acc, schema, count)
  end
end
