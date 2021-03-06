defmodule RF69.MixProject do
  use Mix.Project

  def project do
    [
      app: :rf69,
      version: "0.1.0",
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      elixirc_paths: elixirc_paths(Mix.env()),
      deps: deps()
    ]
  end

  def elixirc_paths(:test) do
    ["./lib", "test/support"]
  end

  def elixirc_paths(_) do
    ["./lib"]
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
      {:circuits_spi, "~> 0.1.5"},
      {:circuits_gpio, "~> 0.4.5"},
      {:binpp, "~> 1.1"}
    ]
  end
end
