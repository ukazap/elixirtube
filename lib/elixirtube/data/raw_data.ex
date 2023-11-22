defmodule Elixirtube.Data.RawData do
  defstruct [:schema, :attrs, :parent]

  @type t :: %__MODULE__{
          schema: atom(),
          attrs: map(),
          parent: {atom, String.t()}
        }

  alias __MODULE__
  alias Elixirtube.Library.Media
  alias Elixirtube.Library.Playlist
  alias Elixirtube.Library.Series
  alias Elixirtube.Library.Speaker

  @spec load!(Git.Repository.t(), Path.t()) :: t()
  def load!(%Git.Repository{path: repo_path}, path) do
    repo_path
    |> Path.join(path)
    |> YamlElixir.read_from_file!()
    |> case do
      %{"speaker" => attrs} ->
        slug = Path.basename(path, ".yml")
        %RawData{schema: Speaker, attrs: Map.put(attrs, "slug", slug)}

      %{"series" => attrs} ->
        ["priv", "data", "series", slug, _] = Path.split(path)
        %RawData{schema: Series, attrs: Map.put(attrs, "slug", slug)}

      %{"playlist" => attrs} ->
        ["priv", "data", "series", parent_slug, slug, _] = Path.split(path)

        %RawData{
          schema: Playlist,
          attrs: Map.put(attrs, "slug", slug),
          parent: {Series, parent_slug}
        }

      %{"video" => attrs} ->
        ["priv", "data", "series", _, parent_slug, "media", filename] = Path.split(path)

        [_, slug] =
          filename
          |> Path.basename(".yml")
          |> String.split("_")

        attrs = Map.merge(attrs, %{"slug" => slug, "media_type" => :video})

        %RawData{
          schema: Media,
          attrs: attrs,
          parent: {Playlist, parent_slug}
        }
    end
  end

  @spec to_entry(t()) :: map()
  def to_entry(%RawData{schema: schema, attrs: attrs}) do
    now = DateTime.utc_now(:second)

    schema
    |> struct!([])
    |> schema.changeset(attrs)
    |> Map.get(:changes)
    |> Map.merge(%{inserted_at: now, updated_at: now})
  end
end
