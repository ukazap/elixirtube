defmodule Elixirtube.DataTest do
  use Elixirtube.DataCase

  alias Elixirtube.Data

  describe "data_imports" do
    alias Elixirtube.Data.DataImport

    import Elixirtube.DataFixtures

    @invalid_attrs %{git_commit_sha: nil}

    test "list_data_imports/0 returns all data_imports" do
      data_import = data_import_fixture()
      assert Data.list_data_imports() == [data_import]
    end

    test "get_data_import!/1 returns the data_import with given id" do
      data_import = data_import_fixture()
      assert Data.get_data_import!(data_import.id) == data_import
    end

    test "create_data_import/1 with valid data creates a data_import" do
      valid_attrs = %{git_commit_sha: "some git_commit_sha"}

      assert {:ok, %DataImport{} = data_import} = Data.create_data_import(valid_attrs)
      assert data_import.git_commit_sha == "some git_commit_sha"
    end

    test "create_data_import/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Data.create_data_import(@invalid_attrs)
    end

    test "update_data_import/2 with valid data updates the data_import" do
      data_import = data_import_fixture()
      update_attrs = %{git_commit_sha: "some updated git_commit_sha"}

      assert {:ok, %DataImport{} = data_import} = Data.update_data_import(data_import, update_attrs)
      assert data_import.git_commit_sha == "some updated git_commit_sha"
    end

    test "update_data_import/2 with invalid data returns error changeset" do
      data_import = data_import_fixture()
      assert {:error, %Ecto.Changeset{}} = Data.update_data_import(data_import, @invalid_attrs)
      assert data_import == Data.get_data_import!(data_import.id)
    end

    test "delete_data_import/1 deletes the data_import" do
      data_import = data_import_fixture()
      assert {:ok, %DataImport{}} = Data.delete_data_import(data_import)
      assert_raise Ecto.NoResultsError, fn -> Data.get_data_import!(data_import.id) end
    end

    test "change_data_import/1 returns a data_import changeset" do
      data_import = data_import_fixture()
      assert %Ecto.Changeset{} = Data.change_data_import(data_import)
    end
  end
end
