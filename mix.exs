defmodule Exgrafana.Mixfile do
  use Mix.Project

  @version "0.1.0"

  def project do
    [app: :exgrafana,
     version: @version,
     elixir: "~> 1.3",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  def application do
    [applications: [:logger, :httpoison]]
  end

  defp deps do
    [{:poison, "~> 2.2"},
     {:httpoison, "~> 0.11"}]
  end
end
