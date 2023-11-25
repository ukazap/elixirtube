defmodule Elixirtube.Data.DataChange do
  @moduledoc "Data structure representing a change in `/priv/data` directory."
  defstruct ~w[path op schema attrs]a

  @type t :: %__MODULE__{
          path: [String.t()],
          op: :update | :delete,
          schema: atom(),
          attrs: map()
        }

  alias __MODULE__
  alias Elixirtube.Library.Media
  alias Elixirtube.Library.Playlist
  alias Elixirtube.Library.Series
  alias Elixirtube.Library.Speaker

  @doc "Load DataChange from YAML file inside Git repository"
  @spec load(Git.Repository.t(), Path.t()) :: t()
  def load(%Git.Repository{path: repo_path}, path) do
    [repo_path, "priv", "data", path]
    |> Path.join()
    |> YamlElixir.read_from_file()
    |> case do
      {:ok, %{} = map} ->
        {map, Path.split(path)}

      {:error, %YamlElixir.FileNotFoundError{}} ->
        Path.split(path)
    end
    |> to_data_change()
  end

  @doc "Convert DataChange to map via Ecto changeset based on schema"
  @spec to_entry(t(), map) :: map()
  def to_entry(%DataChange{schema: schema, attrs: attrs}, parent_id_lookup \\ %{}) do
    now = DateTime.utc_now(:second)

    schema
    |> struct!([])
    |> schema.changeset(attrs)
    |> Map.get(:changes)
    |> Map.merge(%{inserted_at: now, updated_at: now})
    |> put_parent_id(schema, attrs, parent_id_lookup)
  end

  defp put_parent_id(entry, Playlist, %{"series_slug" => slug}, id_lookup) do
    Map.put(entry, :series_id, Map.get(id_lookup, slug))
  end

  defp put_parent_id(entry, Media, %{"playlist_slug" => slug}, id_lookup) do
    Map.put(entry, :playlist_id, Map.get(id_lookup, slug))
  end

  defp put_parent_id(entry, _, _, _), do: entry

  # Update operations

  defp to_data_change({%{"speaker" => attrs}, ["speakers", filename] = path}) do
    slug = Path.basename(filename, ".yml")
    attrs = Map.put(attrs, "slug", slug)
    %DataChange{path: path, op: :update, schema: Speaker, attrs: attrs}
  end

  defp to_data_change({%{"series" => attrs}, ["series", slug, "series.yml"] = path}) do
    attrs = Map.put(attrs, "slug", slug)
    %DataChange{path: path, op: :update, schema: Series, attrs: attrs}
  end

  defp to_data_change(
         {%{"playlist" => attrs}, ["series", series_slug, slug, "playlist.yml"] = path}
       ) do
    attrs = Map.merge(attrs, %{"slug" => slug, "series_slug" => series_slug})
    %DataChange{path: path, op: :update, schema: Playlist, attrs: attrs}
  end

  defp to_data_change(
         {%{"video" => attrs}, ["series", _, playlist_slug, "media", filename] = path}
       ) do
    [position, slug] = filename |> Path.basename(".yml") |> String.split("_")
    slug = "#{playlist_slug}-#{slug}"

    attrs =
      Map.merge(attrs, %{
        "slug" => slug,
        "playlist_slug" => playlist_slug,
        "media_type" => :video,
        "position_in_playlist" => position
      })

    %DataChange{path: path, op: :update, schema: Media, attrs: attrs}
  end

  # Delete operations

  defp to_data_change(["speakers", filename] = path) do
    %DataChange{
      path: path,
      op: :delete,
      schema: Speaker,
      attrs: %{"slug" => Path.basename(filename, ".yml")}
    }
  end

  defp to_data_change(["series", slug, "series.yml"] = path) do
    %DataChange{path: path, op: :delete, schema: Series, attrs: %{"slug" => slug}}
  end

  defp to_data_change(["series", _, slug, "playlist.yml"] = path) do
    %DataChange{path: path, op: :delete, schema: Playlist, attrs: %{"slug" => slug}}
  end

  defp to_data_change(["series", _, playlist_slug, "media", filename] = path) do
    [_, slug] = filename |> Path.basename(".yml") |> String.split("_")
    slug = "#{playlist_slug}-#{slug}"
    %DataChange{path: path, op: :delete, schema: Media, attrs: %{"slug" => slug}}
  end
end
