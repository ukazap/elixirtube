defmodule Elixirtube.Library.Series do
  use Ecto.Schema
  import Ecto.Changeset

  alias Elixirtube.Library.Playlist

  schema "series" do
    has_many :playlists, Playlist

    field :slug, :string
    field :title, :string
    field :description, :string
    field :urls, {:array, :string}

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(series, attrs) do
    series
    |> cast(attrs, [:slug, :title, :description, :urls])
    |> validate_required([:slug, :title, :description, :urls])
    |> unique_constraint([:slug])
  end
end
