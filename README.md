# Exgrafana

(Incomplete) Grafana client library for Elixir using `HTTPoison`.

## Configuration

The following are the configuration arguments available:

  * `:url` - URL of your Grafana server.
  * `:token` - Your API token.
  * `version` - Schema version (Default is 14).

i.e:

```elixir
config :exgrafana
  url: "<URL of your Grafana server>",
  token: "<your API token>"
```

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
