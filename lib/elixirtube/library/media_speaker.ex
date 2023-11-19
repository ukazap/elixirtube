defmodule Elixirtube.Library.MediaSpeaker do
  use Ecto.Schema
  import Ecto.Changeset

  alias Elixirtube.Library.Media
  alias Elixirtube.Library.Speaker

  @primary_key false
  schema "media_speakers" do
    belongs_to :media, Media
    belongs_to :speaker, Speaker
  end

  @doc false
  def changeset(media_speaker, attrs) do
    media_speaker
    |> cast(attrs, [:media_id, :speaker_id])
    |> validate_required([:media_id, :speaker_id])
    |> unique_constraint([:media_id, :speaker_id])
  end
end
