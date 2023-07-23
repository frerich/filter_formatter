defmodule FilterFormatter.MixProject do
  use Mix.Project

  def project do
    [
      app: :filter_formatter,
      version: "0.1.0",
      elixir: "~> 1.15",
      start_permanent: Mix.env() == :prod,
      deps: deps(),

      # For documentation
      name: "FilterFormatter",
      source_url: "https://github.com/frerich/filter_formatter",
      docs: [
        main: "FilterFormatter",
        extras: ["LICENSE.md"]
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:rambo, "~> 0.3.0"},
      {:ex_doc, "~> 0.27", only: :dev, runtime: false}
    ]
  end
end
