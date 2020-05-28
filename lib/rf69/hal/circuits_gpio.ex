defmodule RF69.HAL.CircuitsGPIO do
  @moduledoc false
  @behaviour RF69.HAL.GPIO
  alias Circuits.GPIO

  @impl RF69.HAL.GPIO
  def open(pin, mode, opts) do
    GPIO.open(pin, mode, opts)
  end

  @impl RF69.HAL.GPIO
  def set_interrupts(gpio, mode) do
    GPIO.set_interrupts(gpio, mode)
  end

  @impl RF69.HAL.GPIO
  def write(gpio, value) do
    GPIO.write(gpio, value)
  end

  @impl RF69.HAL.GPIO
  def gpio_interupt?({:circuits_gpio, _, _, 1}), do: true
  def gpio_interupt?(_), do: false
end
