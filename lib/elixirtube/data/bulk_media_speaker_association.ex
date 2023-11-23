defmodule Elixirtube.Data.BulkMediaSpeakerAssociation do
  @moduledoc false
  import Ecto.Query, warn: false
  alias Ecto.Multi
  alias Elixirtube.Library.Media
  alias Elixirtube.Library.MediaSpeaker
  alias Elixirtube.Library.Speaker

  @doc false
  @spec run(Multi.t()) :: Multi.t()
  def run(multi) do
    Multi.run(multi, :media_speakers, fn repo, %{media: media_result} ->
      media_and_speaker_slugs =
        media_result
        |> Keyword.get(:upserts, {0, []})
        |> elem(1)
        |> Enum.map(fn %Media{speaker_names: s} = media ->
          {media, Enum.map(s, &Slug.slugify/1)}
        end)

      speaker_slugs =
        media_and_speaker_slugs
        |> Enum.flat_map(fn {_, speaker_slugs} -> speaker_slugs end)
        |> Enum.uniq()

      speaker_id_lookup =
        from(s in Speaker, select: {s.slug, s.id}, where: s.slug in ^speaker_slugs)
        |> repo.all()
        |> Enum.into(%{})

      entries =
        Enum.flat_map(media_and_speaker_slugs, fn {%Media{id: media_id}, speaker_slugs} ->
          Enum.map(
            speaker_slugs,
            &%{
              media_id: media_id,
              speaker_id: Map.get(speaker_id_lookup, &1)
            }
          )
        end)

      result =
        repo.insert_all(MediaSpeaker, entries,
          on_conflict: :nothing,
          conflict_target: [:media_id, :speaker_id]
        )

      {:ok, [upserts: result]}
    end)
  end
end
