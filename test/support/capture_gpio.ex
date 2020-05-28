defmodule RF69.HAL.CaptureGPIO do
  @moduledoc false

  def get(pin) do
    name = Module.concat([__MODULE__, to_string(pin)])
    Agent.get(name, fn %{messages: messages} -> messages end)
  end

  def clear(pin) do
    name = Module.concat([__MODULE__, to_string(pin)])
    Agent.update(name, fn state -> %{state | messages: []} end)
  end

  @behaviour RF69.HAL.GPIO

  @impl RF69.HAL.GPIO
  def open(pin, mode, opts) do
    Agent.start_link(
      fn ->
        %{pin: pin, mode: mode, opts: opts, messages: []}
      end,
      name: Module.concat([__MODULE__, to_string(pin)])
    )
  end

  @impl RF69.HAL.GPIO
  def set_interrupts(gpio, mode) do
    Agent.update(gpio, fn
      %{messages: messages} = state ->
        %{state | messages: [{:set_interrupts, mode} | messages]}
    end)
  end

  @impl RF69.HAL.GPIO
  def write(gpio, value) do
    Agent.update(gpio, fn
      %{messages: messages} = state ->
        %{state | messages: [{:write, value} | messages]}
    end)
  end

  @impl RF69.HAL.GPIO
  def gpio_interupt?(_), do: false
end
