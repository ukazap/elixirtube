defmodule Elixirtube.Data.GitRepo do
  @moduledoc """
  Manage local clone of ElixirTube Git repository, fetch updates,
  and parse changed files in `priv/data` directory.
  """

  alias Elixirtube.Data.DataChange

  @type commit :: String.t() | nil

  @spec fetch_changes!(commit(), commit()) :: {commit(), map() | nil}
  def fetch_changes!(before_commit, after_commit \\ nil) do
    branch = config(:branch, "main")
    path = config(:path, "/tmp/elixirtube")
    remote_url = config(:remote_url, "https://github.com/elixirtube/elixirtube.git")
    repo = %Git.Repository{path: path}

    with {:error, _} <- Git.rev_parse(repo),
         {:ok, _} <- File.rm_rf(repo.path),
         {:ok, ^repo} <- Git.clone([remote_url, repo.path]) do
      :ok
    end

    Git.clean!(repo, ~w[-d -f])
    Git.checkout!(repo, [branch])
    Git.reset!(repo, ~w[--hard])
    Git.pull!(repo, ~w[--rebase origin #{branch}])

    before_commit =
      case before_commit do
        nil -> repo |> Git.rev_list!(~w[--max-parents=0 HEAD]) |> String.trim()
        _ -> before_commit
      end

    after_commit =
      case after_commit do
        nil -> repo |> Git.rev_parse!([branch]) |> String.trim()
        _ -> after_commit
      end

    case after_commit do
      ^before_commit ->
        {after_commit, nil}

      _ ->
        changes =
          repo
          |> Git.diff!(~w[--name-only #{before_commit} #{after_commit}])
          |> String.split("\n")
          |> Stream.filter(fn
            "priv/data/" <> _ = p -> Path.extname(p) == ".yml"
            _ -> false
          end)
          |> Stream.map(fn "priv/data/" <> path -> DataChange.load(repo, path) end)
          |> Enum.group_by(fn %DataChange{schema: s} -> s end)
          |> Enum.reduce(%{}, fn {schema, list}, acc ->
            Map.put(acc, schema, Enum.group_by(list, & &1.op))
          end)

        {after_commit, changes}
    end
  end

  defp config(key, default) do
    Application.get_env(:elixirtube, :git_repo, [])
    |> Keyword.get(key, default)
  end
end
