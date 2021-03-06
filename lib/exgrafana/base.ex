defmodule Exgrafana.Base do
  @moduledoc """
  This module defines the basic Grafana API protocol.
  """
  use HTTPoison.Base

  alias Exgrafana.Settings

  @url Settings.exgrafana_url()
  @token Settings.exgrafana_token()

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
