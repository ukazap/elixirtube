defmodule Elixirtube.Library.Playlist do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  alias Elixirtube.Library.Media
  alias Elixirtube.Library.Series

  schema "playlists" do
    belongs_to :series, Series
    has_many :media, Media

    field :source, :string
    field :slug, :string
    field :title, :string
    field :locations, {:array, :string}
    field :description, :string
    field :urls, {:array, :string}
    field :thumbnails, :map
    field :published_at, :utc_datetime

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(playlist, attrs) do
    playlist
    |> cast(attrs, [
      :slug,
      :source,
      :title,
      :locations,
      :description,
      :urls,
      :thumbnails,
      :published_at
    ])
    |> validate_required([:slug, :source, :title, :locations, :description, :urls, :published_at])
    |> unique_constraint([:slug])
  end
end
