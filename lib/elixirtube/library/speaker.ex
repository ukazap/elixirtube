defmodule Elixirtube.Library.Speaker do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  alias Elixirtube.Library.MediaSpeaker
  alias Elixirtube.Library.Speaker

  schema "speakers" do
    many_to_many :media, Speaker, join_through: MediaSpeaker

    field :name, :string
    field :slug, :string
    field :bio, :string
    field :urls, {:array, :string}

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(speaker, attrs) do
    speaker
    |> cast(attrs, [:slug, :name, :bio, :urls])
    |> validate_required([:slug, :name])
  end
end
