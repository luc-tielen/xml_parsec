defmodule XmlParsec.MixProject do
  use Mix.Project

  @github_url "https://github.com/luc-tielen/xml_parsec"


  def project do
    [
      app: :xml_parsec,
      version: "0.1.0",
      elixir: ">= 1.4.0",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: description(),
      package: package(),
      source_url: @github_url,
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        "coveralls": :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test,
      ],
    ]
  end

  def application, do: []

  defp deps do
    [
      {:combine, "~> 0.10.0"},
      {:focus, "~> 0.3.5"},
      {:excoveralls, "~> 0.8", only: :test, runtime: false},
      {:ex_doc, "~> 0.16", only: :dev, runtime: false},
      {:credo, "~> 0.9.0-rc1", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 0.5", only: :dev, runtime: :false},
      {:mix_test_watch, "~> 0.5", only: :dev, runtime: false},
    ]
  end

  defp description do
    ~S"""
    XmlParsec is a library based on [parser combinators](https://en.wikipedia.org/wiki/Parser_combinator),
    written in pure Elixir.
    """
  end

  defp package do
    [
      maintainers: ["Luc Tielen"],
      licenses: ["MIT"],
      links: %{"github" => @github_url}
    ]
  end
end
