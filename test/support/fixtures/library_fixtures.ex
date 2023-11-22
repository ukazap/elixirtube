defmodule Elixirtube.LibraryFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Elixirtube.Library` context.
  """

  @doc """
  Generate a series.
  """
  def series_fixture(attrs \\ %{}) do
    {:ok, series} =
      attrs
      |> Enum.into(%{
        description: "some description",
        slug: "some slug",
        title: "some title",
        urls: ["option1", "option2"]
      })
      |> Elixirtube.Library.create_series()

    series
  end

  @doc """
  Generate a speaker.
  """
  def speaker_fixture(attrs \\ %{}) do
    {:ok, speaker} =
      attrs
      |> Enum.into(%{
        bio: "some bio",
        name: "some name",
        slug: "some slug",
        urls: ["option1", "option2"]
      })
      |> Elixirtube.Library.create_speaker()

    speaker
  end

  @doc """
  Generate a playlist.
  """
  def playlist_fixture(attrs \\ %{}) do
    {:ok, playlist} =
      attrs
      |> Enum.into(%{
        description: "some description",
        locations: ["some location"],
        published_at: ~U[2023-11-18 13:06:00Z],
        slug: "some slug",
        source: "some source",
        thumbnails: %{},
        title: "some title",
        urls: ["option1", "option2"]
      })
      |> Elixirtube.Library.create_playlist()

    playlist
  end

  @doc """
  Generate a media.
  """
  def media_fixture(attrs \\ %{}) do
    {:ok, media} =
      attrs
      |> Enum.into(%{
        description: "some description",
        media_type: :video,
        published_at: ~U[2023-11-18 13:38:00Z],
        raw_title: "some raw_title",
        slug: "some slug",
        source: "some source",
        speaker_names: ["option1", "option2"],
        thumbnails: %{},
        title: "some title",
        urls: ["option1", "option2"]
      })
      |> Elixirtube.Library.create_media()

    media
  end
end
