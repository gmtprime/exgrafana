# Exgrafana

[![Build Status](https://travis-ci.org/gmtprime/exgrafana.svg?branch=master)](https://travis-ci.org/gmtprime/exgrafana) [![Hex pm](http://img.shields.io/hexpm/v/exgrafana.svg?style=flat)](https://hex.pm/packages/exgrafana) [![hex.pm downloads](https://img.shields.io/hexpm/dt/exgrafana.svg?style=flat)](https://hex.pm/packages/exgrafana) [![Deps Status](https://beta.hexfaktor.org/badge/all/github/gmtprime/exgrafana.svg)](https://beta.hexfaktor.org/github/gmtprime/exgrafana) [![Inline docs](http://inch-ci.org/github/gmtprime/exgrafana.svg?branch=master)](http://inch-ci.org/github/gmtprime/exgrafana)

(Incomplete) Grafana client library for Elixir using `HTTPoison`.

The available functions are:

```elixir
@spec create_dashboard(map) :: {:ok, map} | {:error, term}
@spec create_dashboard(map, Keyword.t) :: {:ok, map} | {:error, term}

@spec get_dashboard(binary) :: {:ok, map} | {:error, term}

@spec update_dashboard(map) :: {:ok, map} | {:error, term}
@spec update_dashboard(map, Keyword.t) :: {:ok, map} | {:error, term}

@spec delete_dashboard(binary) :: {:ok, map} | {:error, term}
```

For more information about the dashboard model structure and the slugs look
at
[Grafana HTTP API reference](http://docs.grafana.org/reference/http_api/).

## Configuration

The following are the configuration arguments available:

  * `:url` - URL of your Grafana server.
  * `:token` - Your API token.
  * `:version` - Schema version (Default is 14).

e.g:

```elixir
config :exgrafana
  url: "<URL of your Grafana server>",
  token: "<your API token>"
```

The OS environment variables `$EXGRAFANA_URL`, `$EXGRAFANA_TOKEN` and
`$EXGRAFANA_VERSION` can be used instead.

## Installation

`Exgrafana` is available as a Hex package. To install, add it to your
dependencies in your `mix.exs` file:

```elixir
def deps do
  [{:exgrafana, "~> 0.1"}]
end
```

and ensure `httpoison` is started before your application:

```elixir
def application do
  [applications: [:httpoison]]
end
