defmodule Exgrafana do
  @moduledoc """
  Grafana (incomplete) API.

  For more information about the dashboard model structure and the slugs look
  at
  [Grafana HTTP API reference](http://docs.grafana.org/reference/http_api/).
  """
  alias Exgrafana.Settings

  @schema_version Settings.exgrafana_version()
  @module Settings.exgrafana_module()

  ############
  # Public API

  @doc """
  Creates a dashboard from a `dashboard` model. By default, the schema
  version is #{@schema_version}. To overwrite just pass a list of `options`
  with the option `:schema_version` as the desired version.

      iex> Exgrafana.create_dashboard(%{"title" => "Create Dashboard"})
      {:ok, %{"slug" => "create-dashboard", "version" => 0, (...)}}
  """
  @spec create_dashboard(map) :: {:ok, map} | {:error, term}
  @spec create_dashboard(map, Keyword.t) :: {:ok, map} | {:error, term}
  def create_dashboard(dashboard, options \\ [])
  def create_dashboard(%{"id" => id}, _) when not is_nil(id) do
    {:error, "ID must be nil"}
  end
  def create_dashboard(dashboard, options) do
    schema_version = Keyword.get(options, :schema_version, @schema_version)
    slug = get_slug(dashboard)
    with {:error, _} <- get_dashboard(slug) do
      dashboard =
        dashboard
        |> Map.put("version", 0)
        |> Map.put("schemaVersion", schema_version)
      body = %{"dashboard" => dashboard, "overwrite" => false}
      do_set_dashboard(body)
    else
      {:ok, _} ->
        {:error, "Dashboard already exists"}
    end
  end

  @doc """
  Gets a dashboard by `slug`.

      iex> Exgrafana.get_dashboard("get-dashboard")
      {:ok, %{"dashboard" => (...)}}
  """
  @spec get_dashboard(binary) :: {:ok, map} | {:error, term}
  def get_dashboard(slug) when is_binary(slug) do
    path = "/api/dashboards/db/#{slug}"
    case @module.get!(path) do
      %HTTPoison.Response{status_code: 200, body: body} ->
        {:ok, body}
      %HTTPoison.Response{status_code: 404} ->
        {:error, "Dashboard not found"}
      %HTTPoison.Error{reason: message} ->
        {:error, message}
    end
  end

  @doc """
  Updates a dashboard from a `dashboard` model. By default, it does not
  overwrites the dashboard. To overwrite just pass a list of `options` with the
  option `:overwrite` as `true`.

      iex> Exgrafana.update_dashboard(%{"id" => 1, (...)})
      {:ok, %{"slug" => "update-dashboard", "version" => 1, (...)}}
  """
  @spec update_dashboard(map) :: {:ok, map} | {:error, term}
  @spec update_dashboard(map, Keyword.t) :: {:ok, map} | {:error, term}
  def update_dashboard(dashboard, options \\ [])
  def update_dashboard(%{"id" => id} = dashboard, options) when not is_nil(id) do
    slug = get_slug(dashboard)
    with {:ok, current} <- get_dashboard(slug) do
      version = get_version(current) + 1
      schema_version = get_schema_version(current)
      overwrite = Keyword.get(options, :overwrite, false)
      dashboard =
        dashboard
        |> Map.put("version", version)
        |> Map.put("schemaVersion", schema_version)
      body = %{"dashboard" => dashboard, "overwrite" => overwrite}
      do_set_dashboard(body)
    else
      {:error, _} = error -> error
    end
  end
  def update_dashboard(_, _), do: {:error, "No ID supplied"}

  @doc """
  Deletes a dashboard by `slug`.

      iex> Exgrafana.delete_dashboard("delete-dashboard")
      {:ok, %{"title" => "Delete Dashboard"}}
  """
  @spec delete_dashboard(binary) :: {:ok, map} | {:error, term}
  def delete_dashboard(slug) when is_binary(slug) do
    path = "/api/dashboards/db/#{slug}"
    case @module.delete!(path) do
      %HTTPoison.Response{status_code: 200, body: body} ->
        {:ok, body}
      %HTTPoison.Response{status_code: 404} ->
        {:error, "Dashboard not found"}
      %HTTPoison.Error{reason: message} ->
        {:error, message}
    end
  end

  #########
  # Helpers

  @doc false
  def get_slug(%{"title" => title}) do
    title
    |> String.split
    |> Enum.map(&String.downcase/1)
    |> Enum.join("-")
  end

  @doc false
  def get_version(%{"dashboard" => %{"version" => version}}), do: version

  @doc false
  def get_schema_version(%{"dashboard" => %{"schemaVersion" => version}}) do
     version
  end

  @doc false
  def do_set_dashboard(body) do
    path = "/api/dashboards/db"
    encoded = Poison.encode!(body)
    case @module.post!(path, encoded) do
      %HTTPoison.Response{status_code: 200, body: response} ->
        {:ok, response}
      %HTTPoison.Response{status_code: 400, body: %{"message" => message}} ->
        {:error, message}
      %HTTPoison.Response{status_code: 401} ->
        {:error, "Unauthorized"}
      %HTTPoison.Response{status_code: 412, body: %{"message" => message}} ->
        {:error, message}
      %HTTPoison.Error{reason: message} ->
        {:error, message}
    end
  end
end
