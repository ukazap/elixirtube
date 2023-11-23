defmodule Elixirtube.Data.DataChangeTest do
  use ExUnit.Case, async: true
  alias Elixirtube.Data.DataChange
  alias Elixirtube.Library.Media
  alias Elixirtube.Library.Playlist
  alias Elixirtube.Library.Series
  alias Elixirtube.Library.Speaker

  setup_all do
    [repo: %Git.Repository{path: File.cwd!()}]
  end

  describe ".load/2" do
    test "load speaker", ctx do
      assert %DataChange{
               op: :update,
               schema: Speaker,
               attrs: %{"slug" => "robert-virding", "name" => "Robert Virding"}
             } =
               DataChange.load(ctx[:repo], "speakers/robert-virding.yml")

      assert %DataChange{op: :delete, schema: Speaker, attrs: %{"slug" => "john-cena"}} =
               DataChange.load(ctx[:repo], "speakers/john-cena.yml")
    end

    test "load series", ctx do
      assert %DataChange{
               op: :update,
               schema: Series,
               attrs: %{
                 "slug" => "elixirconf",
                 "title" => "ElixirConf",
                 "urls" => ["https://elixirconf.com/" | _]
               }
             } =
               DataChange.load(ctx[:repo], "series/elixirconf/series.yml")

      assert %DataChange{op: :delete, schema: Series, attrs: %{"slug" => "world-expo"}} =
               DataChange.load(ctx[:repo], "series/world-expo/series.yml")
    end

    test "load playlist", ctx do
      assert %DataChange{
               op: :update,
               schema: Playlist,
               attrs: %{
                 "slug" => "elixirconf-2014",
                 "series_slug" => "elixirconf",
                 "title" => "ElixirConf 2014",
                 "source" => "youtube:PLE7tQUdRKcyakbmyFcmznq2iNtL80mCsT",
                 "locations" => ["Austin, TX"]
               }
             } =
               DataChange.load(
                 ctx[:repo],
                 "series/elixirconf/elixirconf-2014/playlist.yml"
               )

      assert %DataChange{op: :delete, schema: Playlist, attrs: %{"slug" => "expo-2025"}} =
               DataChange.load(ctx[:repo], "series/world-expo/expo-2025/playlist.yml")
    end

    test "load media", ctx do
      assert %DataChange{
               op: :update,
               schema: Media,
               attrs: %{
                 "slug" => "elixirconf-2014-erlang-rationale",
                 "media_type" => :video,
                 "title" => "Erlang Rationale",
                 "source" => "youtube:rt8h_xeESLg",
                 "speaker_names" => ["Robert Virding"]
               }
             } =
               DataChange.load(
                 ctx[:repo],
                 "series/elixirconf/elixirconf-2014/media/0_erlang-rationale.yml"
               )

      assert %DataChange{
               op: :delete,
               schema: Media,
               attrs: %{"slug" => "expo-2025-dynamic-equilibrium-of-life"}
             } =
               DataChange.load(
                 ctx[:repo],
                 "series/world-expo/expo-2025/media/88_dynamic-equilibrium-of-life.yml"
               )
    end
  end

  describe ".to_entry/1" do
  end
end
