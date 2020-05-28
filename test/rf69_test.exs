defmodule RF69Test do
  use ExUnit.Case
  import RF69Registers
  alias RF69.HAL.{CaptureGPIO, CaptureSPI}
  doctest RF69

  setup do
    ctx = %{
      reset_pin: :rand.uniform(10000),
      ss_pin: :rand.uniform(10000),
      irq_pin: :rand.uniform(10000),
      rx_pin: :rand.uniform(10000),
      tx_pin: :rand.uniform(10000),
      spi_bus_name: "spidev0.#{:rand.uniform(10000)}"
    }

    {:ok, ctx}
  end

  test "send packet", ctx do
    {:ok, pid} = RF69.start_link(ctx)
    CaptureSPI.set_response(ctx.spi_bus_name, <<175>>, <<0xAA>>)
    CaptureSPI.set_response(ctx.spi_bus_name, <<170>>, <<0x55>>)
    CaptureSPI.set_response(ctx.spi_bus_name, reg(:SYNCVALUE1), <<0x55>>)
    CaptureSPI.set_response(ctx.spi_bus_name, <<0x2F>>, <<0x55>>)
    CaptureSPI.set_response(ctx.spi_bus_name, <<0>>, <<0>>)

    Process.sleep(1000)
    refute CaptureGPIO.get(ctx.reset_pin)
  end
end
