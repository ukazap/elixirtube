defmodule Elixirtube.LibraryTest do
  use Elixirtube.DataCase

  alias Elixirtube.Library

  describe "series" do
    alias Elixirtube.Library.Series

    import Elixirtube.LibraryFixtures

    @invalid_attrs %{description: nil, title: nil, slug: nil, urls: nil}

    test "list_series/0 returns all series" do
      series = series_fixture()
      assert Library.list_series() == [series]
    end

    test "get_series!/1 returns the series with given id" do
      series = series_fixture()
      assert Library.get_series!(series.id) == series
    end

    test "create_series/1 with valid data creates a series" do
      valid_attrs = %{description: "some description", title: "some title", slug: "some slug", urls: ["option1", "option2"]}

      assert {:ok, %Series{} = series} = Library.create_series(valid_attrs)
      assert series.description == "some description"
      assert series.title == "some title"
      assert series.slug == "some slug"
      assert series.urls == ["option1", "option2"]
    end

    test "create_series/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Library.create_series(@invalid_attrs)
    end

    test "update_series/2 with valid data updates the series" do
      series = series_fixture()
      update_attrs = %{description: "some updated description", title: "some updated title", slug: "some updated slug", urls: ["option1"]}

      assert {:ok, %Series{} = series} = Library.update_series(series, update_attrs)
      assert series.description == "some updated description"
      assert series.title == "some updated title"
      assert series.slug == "some updated slug"
      assert series.urls == ["option1"]
    end

    test "update_series/2 with invalid data returns error changeset" do
      series = series_fixture()
      assert {:error, %Ecto.Changeset{}} = Library.update_series(series, @invalid_attrs)
      assert series == Library.get_series!(series.id)
    end

    test "delete_series/1 deletes the series" do
      series = series_fixture()
      assert {:ok, %Series{}} = Library.delete_series(series)
      assert_raise Ecto.NoResultsError, fn -> Library.get_series!(series.id) end
    end

    test "change_series/1 returns a series changeset" do
      series = series_fixture()
      assert %Ecto.Changeset{} = Library.change_series(series)
    end
  end

  describe "speakers" do
    alias Elixirtube.Library.Speaker

    import Elixirtube.LibraryFixtures

    @invalid_attrs %{name: nil, slug: nil, bio: nil, urls: nil}

    test "list_speakers/0 returns all speakers" do
      speaker = speaker_fixture()
      assert Library.list_speakers() == [speaker]
    end

    test "get_speaker!/1 returns the speaker with given id" do
      speaker = speaker_fixture()
      assert Library.get_speaker!(speaker.id) == speaker
    end

    test "create_speaker/1 with valid data creates a speaker" do
      valid_attrs = %{name: "some name", slug: "some slug", bio: "some bio", urls: ["option1", "option2"]}

      assert {:ok, %Speaker{} = speaker} = Library.create_speaker(valid_attrs)
      assert speaker.name == "some name"
      assert speaker.slug == "some slug"
      assert speaker.bio == "some bio"
      assert speaker.urls == ["option1", "option2"]
    end

    test "create_speaker/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Library.create_speaker(@invalid_attrs)
    end

    test "update_speaker/2 with valid data updates the speaker" do
      speaker = speaker_fixture()
      update_attrs = %{name: "some updated name", slug: "some updated slug", bio: "some updated bio", urls: ["option1"]}

      assert {:ok, %Speaker{} = speaker} = Library.update_speaker(speaker, update_attrs)
      assert speaker.name == "some updated name"
      assert speaker.slug == "some updated slug"
      assert speaker.bio == "some updated bio"
      assert speaker.urls == ["option1"]
    end

    test "update_speaker/2 with invalid data returns error changeset" do
      speaker = speaker_fixture()
      assert {:error, %Ecto.Changeset{}} = Library.update_speaker(speaker, @invalid_attrs)
      assert speaker == Library.get_speaker!(speaker.id)
    end

    test "delete_speaker/1 deletes the speaker" do
      speaker = speaker_fixture()
      assert {:ok, %Speaker{}} = Library.delete_speaker(speaker)
      assert_raise Ecto.NoResultsError, fn -> Library.get_speaker!(speaker.id) end
    end

    test "change_speaker/1 returns a speaker changeset" do
      speaker = speaker_fixture()
      assert %Ecto.Changeset{} = Library.change_speaker(speaker)
    end
  end

  describe "playlists" do
    alias Elixirtube.Library.Playlist

    import Elixirtube.LibraryFixtures

    @invalid_attrs %{description: nil, title: nil, location: nil, source: nil, slug: nil, urls: nil, thumbnails: nil, published_at: nil}

    test "list_playlists/0 returns all playlists" do
      playlist = playlist_fixture()
      assert Library.list_playlists() == [playlist]
    end

    test "get_playlist!/1 returns the playlist with given id" do
      playlist = playlist_fixture()
      assert Library.get_playlist!(playlist.id) == playlist
    end

    test "create_playlist/1 with valid data creates a playlist" do
      valid_attrs = %{description: "some description", title: "some title", locations: ["some location"], source: "some source", slug: "some slug", urls: ["option1", "option2"], thumbnails: %{}, published_at: ~U[2023-11-18 13:05:00Z]}

      assert {:ok, %Playlist{} = playlist} = Library.create_playlist(valid_attrs)
      assert playlist.description == "some description"
      assert playlist.title == "some title"
      assert playlist.location == "some location"
      assert playlist.source == "some source"
      assert playlist.slug == "some slug"
      assert playlist.urls == ["option1", "option2"]
      assert playlist.thumbnails == %{}
      assert playlist.published_at == ~U[2023-11-18 13:05:00Z]
    end

    test "create_playlist/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Library.create_playlist(@invalid_attrs)
    end

    test "update_playlist/2 with valid data updates the playlist" do
      playlist = playlist_fixture()
      update_attrs = %{description: "some updated description", title: "some updated title", locations: ["some updated location"], source: "some updated source", slug: "some updated slug", urls: ["option1"], thumbnails: %{}, published_at: ~U[2023-11-19 13:05:00Z]}

      assert {:ok, %Playlist{} = playlist} = Library.update_playlist(playlist, update_attrs)
      assert playlist.description == "some updated description"
      assert playlist.title == "some updated title"
      assert playlist.location == "some updated location"
      assert playlist.source == "some updated source"
      assert playlist.slug == "some updated slug"
      assert playlist.urls == ["option1"]
      assert playlist.thumbnails == %{}
      assert playlist.published_at == ~U[2023-11-19 13:05:00Z]
    end

    test "update_playlist/2 with invalid data returns error changeset" do
      playlist = playlist_fixture()
      assert {:error, %Ecto.Changeset{}} = Library.update_playlist(playlist, @invalid_attrs)
      assert playlist == Library.get_playlist!(playlist.id)
    end

    test "delete_playlist/1 deletes the playlist" do
      playlist = playlist_fixture()
      assert {:ok, %Playlist{}} = Library.delete_playlist(playlist)
      assert_raise Ecto.NoResultsError, fn -> Library.get_playlist!(playlist.id) end
    end

    test "change_playlist/1 returns a playlist changeset" do
      playlist = playlist_fixture()
      assert %Ecto.Changeset{} = Library.change_playlist(playlist)
    end
  end

  describe "playlists" do
    alias Elixirtube.Library.Playlist

    import Elixirtube.LibraryFixtures

    @invalid_attrs %{description: nil, title: nil, location: nil, source: nil, slug: nil, urls: nil, thumbnails: nil, published_at: nil}

    test "list_playlists/0 returns all playlists" do
      playlist = playlist_fixture()
      assert Library.list_playlists() == [playlist]
    end

    test "get_playlist!/1 returns the playlist with given id" do
      playlist = playlist_fixture()
      assert Library.get_playlist!(playlist.id) == playlist
    end

    test "create_playlist/1 with valid data creates a playlist" do
      valid_attrs = %{description: "some description", title: "some title", locations: ["some location"], source: "some source", slug: "some slug", urls: ["option1", "option2"], thumbnails: %{}, published_at: ~U[2023-11-18 13:06:00Z]}

      assert {:ok, %Playlist{} = playlist} = Library.create_playlist(valid_attrs)
      assert playlist.description == "some description"
      assert playlist.title == "some title"
      assert playlist.location == "some location"
      assert playlist.source == "some source"
      assert playlist.slug == "some slug"
      assert playlist.urls == ["option1", "option2"]
      assert playlist.thumbnails == %{}
      assert playlist.published_at == ~U[2023-11-18 13:06:00Z]
    end

    test "create_playlist/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Library.create_playlist(@invalid_attrs)
    end

    test "update_playlist/2 with valid data updates the playlist" do
      playlist = playlist_fixture()
      update_attrs = %{description: "some updated description", title: "some updated title", locations: ["some updated location"], source: "some updated source", slug: "some updated slug", urls: ["option1"], thumbnails: %{}, published_at: ~U[2023-11-19 13:06:00Z]}

      assert {:ok, %Playlist{} = playlist} = Library.update_playlist(playlist, update_attrs)
      assert playlist.description == "some updated description"
      assert playlist.title == "some updated title"
      assert playlist.location == "some updated location"
      assert playlist.source == "some updated source"
      assert playlist.slug == "some updated slug"
      assert playlist.urls == ["option1"]
      assert playlist.thumbnails == %{}
      assert playlist.published_at == ~U[2023-11-19 13:06:00Z]
    end

    test "update_playlist/2 with invalid data returns error changeset" do
      playlist = playlist_fixture()
      assert {:error, %Ecto.Changeset{}} = Library.update_playlist(playlist, @invalid_attrs)
      assert playlist == Library.get_playlist!(playlist.id)
    end

    test "delete_playlist/1 deletes the playlist" do
      playlist = playlist_fixture()
      assert {:ok, %Playlist{}} = Library.delete_playlist(playlist)
      assert_raise Ecto.NoResultsError, fn -> Library.get_playlist!(playlist.id) end
    end

    test "change_playlist/1 returns a playlist changeset" do
      playlist = playlist_fixture()
      assert %Ecto.Changeset{} = Library.change_playlist(playlist)
    end
  end

  describe "media" do
    alias Elixirtube.Library.Media

    import Elixirtube.LibraryFixtures

    @invalid_attrs %{description: nil, title: nil, source: nil, media_type: nil, slug: nil, raw_title: nil, speaker_names: nil, urls: nil, thumbnails: nil, published_at: nil}

    test "list_media/0 returns all media" do
      media = media_fixture()
      assert Library.list_media() == [media]
    end

    test "get_media!/1 returns the media with given id" do
      media = media_fixture()
      assert Library.get_media!(media.id) == media
    end

    test "create_media/1 with valid data creates a media" do
      valid_attrs = %{description: "some description", title: "some title", source: "some source", media_type: :video, slug: "some slug", raw_title: "some raw_title", speaker_names: ["option1", "option2"], urls: ["option1", "option2"], thumbnails: %{}, published_at: ~U[2023-11-18 13:38:00Z]}

      assert {:ok, %Media{} = media} = Library.create_media(valid_attrs)
      assert media.description == "some description"
      assert media.title == "some title"
      assert media.source == "some source"
      assert media.media_type == :video
      assert media.slug == "some slug"
      assert media.raw_title == "some raw_title"
      assert media.speaker_names == ["option1", "option2"]
      assert media.urls == ["option1", "option2"]
      assert media.thumbnails == %{}
      assert media.published_at == ~U[2023-11-18 13:38:00Z]
    end

    test "create_media/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Library.create_media(@invalid_attrs)
    end

    test "update_media/2 with valid data updates the media" do
      media = media_fixture()
      update_attrs = %{description: "some updated description", title: "some updated title", source: "some updated source", media_type: :audio, slug: "some updated slug", raw_title: "some updated raw_title", speaker_names: ["option1"], urls: ["option1"], thumbnails: %{}, published_at: ~U[2023-11-19 13:38:00Z]}

      assert {:ok, %Media{} = media} = Library.update_media(media, update_attrs)
      assert media.description == "some updated description"
      assert media.title == "some updated title"
      assert media.source == "some updated source"
      assert media.media_type == :audio
      assert media.slug == "some updated slug"
      assert media.raw_title == "some updated raw_title"
      assert media.speaker_names == ["option1"]
      assert media.urls == ["option1"]
      assert media.thumbnails == %{}
      assert media.published_at == ~U[2023-11-19 13:38:00Z]
    end

    test "update_media/2 with invalid data returns error changeset" do
      media = media_fixture()
      assert {:error, %Ecto.Changeset{}} = Library.update_media(media, @invalid_attrs)
      assert media == Library.get_media!(media.id)
    end

    test "delete_media/1 deletes the media" do
      media = media_fixture()
      assert {:ok, %Media{}} = Library.delete_media(media)
      assert_raise Ecto.NoResultsError, fn -> Library.get_media!(media.id) end
    end

    test "change_media/1 returns a media changeset" do
      media = media_fixture()
      assert %Ecto.Changeset{} = Library.change_media(media)
    end
  end
end
