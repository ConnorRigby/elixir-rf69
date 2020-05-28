defmodule RF69.HAL.CaptureSPI do
  @behaviour RF69.HAL.SPI

  def get(bus) do
    maybe_start(bus)
    Agent.get(Module.concat([__MODULE__, bus]), fn %{messages: messages} -> messages end)
  end

  def set_response(bus, request, response) do
    maybe_start(bus)

    Agent.update(Module.concat([__MODULE__, bus]), fn state ->
      %{state | responses: Map.put(state.responses, request, response)}
    end)
  end

  def clear(bus) do
    maybe_start(bus)
    Agent.update(Module.concat([__MODULE__, bus]), fn state -> %{state | messages: []} end)
  end

  @impl RF69.HAL.SPI
  def open(bus, opts) do
    {:ok, pid} = maybe_start(bus)
    Agent.update(Module.concat([__MODULE__, bus]), fn state -> %{state | opts: opts} end)
    {:ok, pid}
  end

  def maybe_start(bus_name) do
    case Process.whereis(Module.concat([__MODULE__, bus_name])) do
      pid when is_pid(pid) ->
        {:ok, pid}

      nil ->
        Agent.start_link(
          fn ->
            %{
              opts: [],
              messages: [],
              responses: %{}
            }
          end,
          name: Module.concat([__MODULE__, bus_name])
        )
    end
  end

  # TODO this kind of needs to be stateful..?
  @impl RF69.HAL.SPI
  def transfer(spi, data) do
    IO.inspect(data, label: "transfer")

    Agent.get(spi, fn %{responses: responses} ->
      {:ok, responses[data] || <<0::8>>}
      {:ok, <<0x55>>}
    end)
  end
end
