defmodule Exgrafana do
  @moduledoc """
  Grafana API.
  """
  use HTTPoison.Base

  @schema_version 14

  ############
  # Public API

  @doc """
  Creates a dashboard from a `dashboard` model. By default, the schema
  version is #{@schema_version}. To overwrite just pass a list of `options`
  with the option `:schema_version` as the desired version.
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
  Gets a dashboard by `name`.
  """
  @spec get_dashboard(binary) :: {:ok, map} | {:error, term}
  def get_dashboard(name) when is_binary(name) do
    path = "/api/dashboards/db/#{name}"
    case Exgrafana.get!(path) do
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
  Deletes a dashboard by `name`.
  """
  @spec delete_dashboard(binary) :: {:ok, map} | {:error, term}
  def delete_dashboard(name) when is_binary(name) do
    path = "/api/dashboards/db/#{name}"
    case Exgrafana.delete!(path) do
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
    case Exgrafana.post!(path, encoded) do
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

  #####################
  # HTTPoison callbacks

  @url Application.get_env(:exgrafana, :url, "")
  @token Application.get_env(:exgrafana, :token, "")

  @doc false
  def process_url(url) do
    @url <> url
  end

  @doc false
  def process_request_headers(headers) do
    [{"Authorization", "Bearer #{@token}"},
     {"Content-Type", "application/json"},
     {"Accept", "application/json"}
     | headers]
  end

  @doc false
  def process_response_body(body) do
    Poison.decode!(body)
  end
end
