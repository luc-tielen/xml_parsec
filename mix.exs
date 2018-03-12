defmodule XmlParsec.MixProject do
  use Mix.Project

  def project do
    [
      app: :xml_parsec,
      version: "0.1.0",
      elixir: ">= 1.4.0",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:combine, "~> 0.10.0"},
      {:focus, "~> 0.3.5"},
      {:credo, "~> 0.9.0-rc1", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 0.5", only: :dev, runtime: :false},
      {:mix_test_watch, "~> 0.5", only: :dev, runtime: false},
    ]
  end
end
