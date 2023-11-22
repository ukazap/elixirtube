defmodule Elixirtube.DataFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Elixirtube.Data` context.
  """

  @doc """
  Generate a unique data_import git_commit_sha.
  """
  def unique_data_import_git_commit_sha, do: "some git_commit_sha#{System.unique_integer([:positive])}"

  @doc """
  Generate a data_import.
  """
  def data_import_fixture(attrs \\ %{}) do
    {:ok, data_import} =
      attrs
      |> Enum.into(%{
        git_commit_sha: unique_data_import_git_commit_sha()
      })
      |> Elixirtube.Data.create_data_import()

    data_import
  end
end
