defmodule Exgrafana.Mixfile do
  use Mix.Project

  @version "0.1.0"

  def project do
    [app: :exgrafana,
     version: @version,
     elixir: "~> 1.3",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     description: description(),
     package: package(),
     docs: docs(),
     deps: deps()]
  end

  def application do
    [applications: [:logger, :httpoison]]
  end

  defp deps do
    [{:poison, "~> 2.2"},
     {:httpoison, "~> 0.11"},
     {:earmark, ">= 0.0.0", only: :dev},
     {:ex_doc, "~> 0.13", only: :dev},
     {:inch_ex, "~> 0.5", only: [:dev, :test]},
     {:credo, "~> 0.6", only: [:dev, :test]}]
  end

  defp docs do
    [source_url: "https://github.com/gmtprime/exgrafana",
     source_ref: "v#{@version}",
     main: Exgrafana]
  end

  defp description do
    """
    Grafana client library.
    """
  end

  def package do
    [maintainers: ["Alexander de Sousa"],
     licenses: ["MIT"],
     links: %{"Github" => "https://github.com/gmtprime/exgrafana"}]
  end
end
