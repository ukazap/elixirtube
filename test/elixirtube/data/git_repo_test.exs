defmodule Elixirtube.Data.GitRepoTest do
  use ExUnit.Case, async: true
  alias Elixirtube.Data.DataChange
  alias Elixirtube.Data.GitRepo
  alias Elixirtube.Library.Media
  alias Elixirtube.Library.Playlist
  alias Elixirtube.Library.Series
  alias Elixirtube.Library.Speaker

  describe ".fetch_changes!/1" do
    test "get changes since first commit" do
      assert {lates_commit_sha, changes} = GitRepo.fetch_changes!(nil)
      assert 40 = String.length(lates_commit_sha)

      assert %{
               Speaker => %{update: [%DataChange{schema: Speaker} | _]},
               Series => %{update: [%DataChange{schema: Series} | _]},
               Playlist => %{update: [%DataChange{schema: Playlist} | _]},
               Media => %{update: [%DataChange{schema: Media} | _]}
             } = changes
    end

    test "get changes afb4b..9eee7" do
      before_commit = "afb4b47f90e03666bd14887cd70f5d1437fd8900"
      after_commit = "9eee71aa0a22c50dcdd4d11d104b9e7e50062ea7"
      assert {^after_commit, changes} = GitRepo.fetch_changes!(before_commit, after_commit)

      assert %{
               Series => %{delete: [%DataChange{schema: Series, attrs: %{"slug" => "misc"}}]}
             } = changes
    end

    test "get changes 9eee7..9eee7" do
      before_commit = after_commit = "9eee71aa0a22c50dcdd4d11d104b9e7e50062ea7"
      assert {^after_commit, nil} = GitRepo.fetch_changes!(before_commit, after_commit)
    end
  end
end
