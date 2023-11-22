defmodule Elixirtube.Data.GitRepo do
  @moduledoc """
  Manage local clone of ElixirTube Git repository, fetch updates,
  and parse changed files in `priv/data` directory.
  """

  alias Elixirtube.Data.RawData

  @type commit_sha :: String.t()

  @spec fetch_changes!(commit_sha() | nil) :: {commit_sha(), [RawData.t()]}
  def fetch_changes!(before_commit) do
    branch = Keyword.get(config(), :branch, "main")
    path = Keyword.get(config(), :path, "/tmp/elixirtube")
    remote_url = Keyword.get(config(), :remote_url, "https://github.com/elixirtube/elixirtube.git")
    repo = %Git.Repository{path: path}

    with {:error, _} <- Git.rev_parse(repo),
         {:ok, _} <- File.rm_rf(repo.path),
         {:ok, ^repo} <- Git.clone([remote_url, repo.path]) do
      :ok
    else
      {:ok, _} -> :noop
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
      repo
      |> Git.rev_parse!([branch])
      |> String.trim()

    case after_commit do
      ^before_commit ->
        {after_commit, []}
      _ ->
        changes =
          repo
          |> Git.diff!(~w[--name-only #{before_commit} #{after_commit}])
          |> String.split("\n")
          |> Stream.filter(fn
            "priv/data" <> _ = p -> Path.extname(p) == ".yml"
            _ -> false
          end)
          |> Stream.map(&RawData.load!(repo, &1))
          |> Enum.to_list()
        {after_commit, changes}
    end
  end

  defp config do
    Application.get_env(:elixirtube, :git_repo, [])
  end
end
