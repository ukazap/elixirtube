defmodule Elixirtube.Data.BulkUpdate do
  @moduledoc false
  import Ecto.Query, warn: false
  alias Ecto.Multi
  alias Elixirtube.Data.DataChange

  @type parent_schema :: module()
  @type parent_slug_key :: String.t()
  @type parent_tuple :: {parent_schema(), parent_slug_key()}

  @type opts :: [
          {:parent, parent_tuple()}
          | {:insert_all, Keyword.t()}
        ]

  @doc false
  @spec run(Multi.t(), atom(), module()) :: Multi.t()
  @spec run(Multi.t(), atom(), module(), opts()) :: Multi.t()
  def run(multi, name, schema, opts \\ []) do
    Multi.run(multi, name, fn repo, %{data_changes: {_, changes}} ->
      with changes <- Map.get(changes, schema, %{}),
           d_result = {c, _} when is_integer(c) <- bulk_delete(repo, changes, schema),
           u_result = {c, _} when is_integer(c) <- bulk_upsert(repo, changes, schema, opts) do
        {:ok, [deletes: d_result, upserts: u_result]}
      else
        error -> {:error, error}
      end
    end)
  end

  defp bulk_delete(repo, changes, schema) do
    slugs =
      changes
      |> Map.get(:delete, [])
      |> Enum.map(fn %{attrs: %{"slug" => slug}} -> slug end)

    from(entry in schema, where: entry.slug in ^slugs)
    |> repo.delete_all()
  end

  @insert_all_defaults [
    on_conflict: {:replace_all_except, [:id, :inserted_at]},
    conflict_target: [:slug]
  ]
  defp bulk_upsert(repo, changes, schema, opts) do
    parent = Keyword.get(opts, :parent)
    parent_id_lookup = create_parent_id_lookup(repo, changes, parent)

    entries =
      changes
      |> Map.get(:update, [])
      |> Enum.map(&DataChange.to_entry(&1, parent_id_lookup))

    opts = Keyword.get(opts, :insert_all, [])
    repo.insert_all(schema, entries, Keyword.merge(@insert_all_defaults, opts))
  end

  defp create_parent_id_lookup(repo, changes, {parent_schema, parent_slug_key})
       when is_atom(parent_schema) and is_binary(parent_slug_key) do
    parent_slugs =
      changes
      |> Map.get(:update, [])
      |> Enum.map(fn %{attrs: attrs} -> Map.get(attrs, parent_slug_key) end)
      |> Enum.filter(&is_binary/1)
      |> Enum.uniq()

    from(p in parent_schema, select: {p.slug, p.id}, where: p.slug in ^parent_slugs)
    |> repo.all()
    |> Enum.into(%{})
  end

  defp create_parent_id_lookup(_, _, _), do: %{}
end
