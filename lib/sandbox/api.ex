defmodule Exgrafana.Sandbox.Api do
  @moduledoc """
  This module defines a `HTTPoison` sandbox for testing.
  """
  use GenServer

  @doc """
  Starts the sandbox server.
  """
  def start_link do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  @doc """
  Stops the sandbox server.
  """
  def stop do
    GenServer.stop(__MODULE__)
  end

  @doc false
  def get!(path) do
    slug = get_slug(path)
    GenServer.call(__MODULE__, {:get, slug})
  end

  @doc false
  def post!(path, body) do
    if String.ends_with?(path, "/db") do
      %{"dashboard" => dashboard} = Poison.decode!(body)
      slug = Exgrafana.get_slug(dashboard)
      GenServer.call(__MODULE__, {:post, slug, dashboard})
    else
      %{"dashboard" => dashboard} = Poison.decode!(body)
      slug = get_slug(path)
      GenServer.call(__MODULE__, {:post, slug, dashboard})
    end
  end

  @doc false
  def delete!(path) do
    slug = get_slug(path)
    GenServer.call(__MODULE__, {:delete, slug})
  end

  @doc false
  def gen_slug(dashboard) do
    Exgrafana.get_slug(dashboard)
  end

  @doc false
  def get_slug(path) do
    path
    |> String.split("/")
    |> List.last()
  end

  #####################
  # GenServer callbacks

  @doc false
  def init(_) do
    {:ok, %{}}
  end

  @doc false
  def handle_call({:get, slug}, _from, dashboards) do
    case Map.get(dashboards, slug) do
      nil ->
        {:reply, %HTTPoison.Response{status_code: 404}, dashboards}
      dashboard ->
        body = %{"dashboard" => dashboard}
        {:reply, %HTTPoison.Response{status_code: 200, body: body}, dashboards}
    end
  end
  def handle_call({:delete, slug}, _from, dashboards) do
    case Map.pop(dashboards, slug) do
      {nil, _} ->
        {:reply, %HTTPoison.Response{status_code: 404}, dashboards}
      {dashboard, dashboards} ->
        body = %{"title" => dashboard["title"]}
        {:reply, %HTTPoison.Response{status_code: 200, body: body}, dashboards}
    end
  end
  def handle_call({:post, slug, %{"id" => id} = dashboard}, _from, dashboards)
      when not is_nil(id) do
    with %{"id" => ^id} <- Map.get(dashboards, slug) do
      dashboards = Map.put(dashboards, slug, dashboard)
      body = %{
        "slug" => slug,
        "status" => "success",
        "version" => dashboard["version"]
      }
      {:reply, %HTTPoison.Response{status_code: 200, body: body}, dashboards}
    else
      _ ->
      error = %{"message" => "ID mismatch"}
      {:reply, %HTTPoison.Response{status_code: 400, body: error}, dashboards}
    end
  end
  def handle_call({:post, slug, dashboard}, _from, dashboards) do
    with nil <- Map.get(dashboards, slug) do
      dashboard = Map.put(dashboard, "id", :erlang.phash2(dashboard))
      dashboards = Map.put(dashboards, slug, dashboard)
      body = %{
        "slug" => slug,
        "status" => "success",
        "version" => dashboard["version"]
      }
      {:reply, %HTTPoison.Response{status_code: 200, body: body}, dashboards}
    else
      _ ->
      error = %{"message" => "Already exists"}
      {:reply, %HTTPoison.Response{status_code: 400, body: error}, dashboards}
    end
  end
end
