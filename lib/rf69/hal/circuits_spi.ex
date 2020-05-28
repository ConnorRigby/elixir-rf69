defmodule RF69.HAL.CircuitsSPI do
  @behaviour RF69.HAL.SPI
  alias Circuits.SPI

  @impl RF69.HAL.SPI
  def open(bus_name, opts) do
    SPI.open(bus_name, opts)
  end

  @impl RF69.HAL.SPI
  def transfer(spi, data) do
    SPI.transfer(spi, data)
  end
end
