defmodule Elixirtube.Library.Media do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  alias Elixirtube.Library.MediaSpeaker
  alias Elixirtube.Library.Playlist
  alias Elixirtube.Library.Speaker

  schema "media" do
    belongs_to :playlist, Playlist
    many_to_many :speakers, Speaker, join_through: MediaSpeaker

    field :source, :string
    field :media_type, Ecto.Enum, values: [:video, :audio]
    field :slug, :string
    field :position_in_playlist, :integer
    field :title, :string
    field :raw_title, :string
    field :description, :string
    # denormalized speaker names for fast retrieval
    field :speaker_names, {:array, :string}
    field :urls, {:array, :string}
    field :thumbnails, :map
    field :published_at, :utc_datetime

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(media, attrs) do
    media
    |> cast(attrs, [
      :media_type,
      :slug,
      :position_in_playlist,
      :source,
      :title,
      :raw_title,
      :description,
      :speaker_names,
      :urls,
      :thumbnails,
      :published_at
    ])
    |> validate_required([
      :media_type,
      :slug,
      :position_in_playlist,
      :source,
      :title,
      :raw_title,
      :description,
      :speaker_names,
      :urls,
      :published_at
    ])
    |> unique_constraint([:slug])
  end
end
