defmodule RF69.LoggerReceiver do
  @moduledoc """
  Sample receiver process that will log
  all received packets via Elixir's Logger
  """

  use GenServer
  require Logger

  def start_link(args, opts \\ []) do
    GenServer.start_link(__MODULE__, args, opts)
  end

  @impl GenServer
  def init(args) do
    {:ok, pid} = RF69.start_link(args)
    Process.send_after(self(), :test_packet, 1500)
    {:ok, %{rf69: pid}}
  end

  def handle_info(:test_packet, state) do
    RF69.send(state.rf69, 2, false, "abc")
    {:noreply, state}
  end

  @impl GenServer
  def handle_info(%RF69.Packet{} = packet, state) do
    Logger.debug("packet received: #{inspect(packet, pretty: true)}")
    {:noreply, state}
  end
end
