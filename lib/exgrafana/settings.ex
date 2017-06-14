defmodule Exgrafana.Settings do
  @moduledoc """
  Configuration settings for `Exgrafana`.
  """
  use Skogsra

  @doc """
  Grafana module. Only for tests purposes. Defaults to `Exgrafana.Base`.

  ```
  config :exgrafana,
    module: Exgrafana.Sandbox.Api
  ```
  """
  app_env :exgrafana_module, :exgrafana, :module, default: Exgrafana.Base

  @doc """
  Grafana server URL. Defaults to `"http://localhost:3000"`

  It looks for the value following this order:

    1. The OS environment variable `$EXGRAFANA_URL`.
    2. The configuration file.
    3. The default value `"http://localhost:3000"`.

  ```
  config :exgrafana,
    url: "https://my-grafana.server"
  ```
  """
  app_env :exgrafana_url, :exgrafana, :url, default: "http://localhost:3000"

  @doc """
  Grafana access token. Defaults to `""`

  It looks for the value following this order:

    1. The OS environment variable `$EXGRAFANA_TOKEN`.
    2. The configuration file.
    3. The default value `""`.

  ```
  config :exgrafana,
    token: "my-token"
  ```
  """
  app_env :exgrafana_token, :exgrafana, :token, default: ""

  @doc """
  Grafana protocol version. Defaults to `14`

  It looks for the value following this order:

    1. The OS environment variable `$EXGRAFANA_VERSION`.
    2. The configuration file.
    3. The default value `""`.

  ```
  config :exgrafana,
    version: 15
  ```
  """
  app_env :exgrafana_version, :exgrafana, :version, default: 14
end
