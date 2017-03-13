defmodule ExgrafanaTest do
  use ExUnit.Case

  test "create_dashboard/1" do
    dashboard = %{"title" => "Create Dashboard"}
    assert {:ok, %{"status" => "success"}} = Exgrafana.create_dashboard(dashboard)
    assert {:error, _} = Exgrafana.create_dashboard(dashboard)
  end

  test "get_dashboard/1" do
    dashboard = %{"title" => "Get Dashboard"}
    assert {:ok, %{"status" => "success"}} = Exgrafana.create_dashboard(dashboard)
    assert {:ok, %{"dashboard" => dashboard}} = Exgrafana.get_dashboard("get-dashboard")
    assert is_integer(dashboard["id"])
  end

  test "update_dashboard/1" do
    dashboard = %{"title" => "Update Dashboard"}
    {:ok, %{"status" => "success"}} = Exgrafana.create_dashboard(dashboard)
    {:ok, %{"dashboard" => dashboard}} = Exgrafana.get_dashboard("update-dashboard")
    new_dashboard = Map.put_new(dashboard, "blah", "blah")
    assert {:ok, %{"version" => 1}} = Exgrafana.update_dashboard(new_dashboard)
  end

  test "delete_dashboard/1" do
    dashboard = %{"title" => "Delete Dashboard"}
    {:ok, %{"status" => "success"}} = Exgrafana.create_dashboard(dashboard)
    {:ok, %{"dashboard" => _}} = Exgrafana.get_dashboard("delete-dashboard")
    assert {:ok, %{"title" => "Delete Dashboard"}} = Exgrafana.delete_dashboard("delete-dashboard")
    assert {:error, _} = Exgrafana.get_dashboard("delete-dashboard")
  end
end
