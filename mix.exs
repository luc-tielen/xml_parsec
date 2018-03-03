defmodule XmlParsec.MixProject do
  use Mix.Project

  def project do
    [
      app: :xml_parsec,
      version: "0.1.0",
      elixir: "~> 1.6",
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
      {:mix_test_watch, "~> 0.5", only: :dev, runtime: false}
    ]
  end
end
