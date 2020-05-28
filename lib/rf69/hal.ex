defmodule RF69.HAL do
  @moduledoc """
  Hardware abstraction layer for abstracting gpio and spi
  """

  defmodule GPIO do
    @moduledoc false

    @callback open(pin :: term, mode :: atom, opts :: Keyword.t()) :: {:ok, RF69.HAL.gpio()}
    @callback set_interrupts(RF69.HAL.gpio(), mode :: atom) :: :ok | {:error, reason :: any()}
    @callback write(RF69.HAL.gpio(), value :: integer) :: :ok | {:error, reason :: any()}
    @callback gpio_interupt?(message :: any) :: boolean()
  end

  defmodule SPI do
    @moduledoc false

    @callback open(bus_name :: String.t(), opts :: Keyword.t()) :: {:ok, RF69.HAL.spi()}
    @callback transfer(RF69.HAL.spi(), data :: binary()) ::
                {:ok, data :: binary()} | {:error, reason :: any()}
  end

  @type gpio() :: any()
  @type spi() :: any()

  def gpio_open(pin, mode, opts \\ []) do
    config()[:gpio].open(pin, mode, opts)
  end

  def gpio_set_interrupts(gpio, mode) do
    config()[:gpio].set_interrupts(gpio, mode)
  end

  def gpio_interupt?(info) do
    config()[:gpio].gpio_interupt?(info)
  end

  def gpio_write(gpio, value) do
    config()[:gpio].write(gpio, value)
  end

  def spi_open(bus, opts) do
    config()[:spi].open(bus, opts)
  end

  def spi_transfer(spi, data) do
    config()[:spi].transfer(spi, data)
  end

  def config do
    Application.get_env(:rf69, __MODULE__) ||
      [
        spi: RF69.HAL.CircuitsSPI,
        gpio: RF69.HAL.CircuitsGPIO
      ]
  end
end
