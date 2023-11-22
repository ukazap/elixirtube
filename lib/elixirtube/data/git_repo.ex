defmodule Elixirtube.Data.GitRepo do
  alias Elixirtube.Data.RawData

  @type commit_sha :: String.t()

  @spec fetch_changes!(commit_sha() | nil) :: {commit_sha(), [RawData.t()]}
  def fetch_changes!(before_commit) do
    repo = %Git.Repository{path: path()}

    with {:error, _} <- Git.rev_parse(repo),
         {:ok, _} <- File.rm_rf(repo.path),
         {:ok, ^repo} <- Git.clone([remote_url(), repo.path]) do
      :ok
    else
      {:ok, status} when is_binary(status) -> :ok
    end

    Git.clean!(repo, ~w[-d -f])
    Git.checkout!(repo, [branch()])
    Git.reset!(repo, ~w[--hard])
    Git.pull!(repo, ~w[--rebase origin #{branch()}])

    before_commit =
      case before_commit do
        nil -> repo |> Git.rev_list!(~w[--max-parents=0 HEAD]) |> String.trim()
        _ -> before_commit
      end

    after_commit = repo |> Git.rev_parse!([branch()]) |> String.trim()

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

  defp path do
    Keyword.get(config(), :path, "/tmp/elixirtube")
  end

  defp remote_url do
    Keyword.get(config(), :remote_url, "https://github.com/elixirtube/elixirtube.git")
  end

  defp branch do
    Keyword.get(config(), :branch, "main")
  end

  defp config do
    Application.get_env(:elixirtube, :data, [])
  end
end
