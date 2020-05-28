defmodule RF69 do
  @moduledoc """
  Server for using a RF69HCW radio
  """

  use GenServer

  import RF69.Util
  alias RF69.HAL

  defstruct reset: nil,
            ss: nil,
            irq: nil,
            spi: nil,
            rx: nil,
            tx: nil,
            network_id: 100,
            node_id: 1,
            mode: nil,
            isRFM69HW: true,
            reset_pin: 16,
            ss_pin: 25,
            irq_pin: 13,
            rx_pin: nil,
            tx_pin: nil,
            spi_bus_name: "spidev0.0"

  defmodule Packet do
    defstruct target_id: nil,
              sender_id: nil,
              ack_requested?: nil,
              is_ack?: nil,
              payload: nil
  end

  @type node_id() :: integer()

  @type t :: %RF69{
          reset: HAL.gpio(),
          ss: HAL.gpio(),
          irq: HAL.gpio(),
          spi: HAL.spi(),
          rx: HAL.gpio() | nil,
          tx: HAL.gpio() | nil,
          network_id: RF69.node_id(),
          node_id: RF69.node_id(),
          mode: atom,
          reset_pin: integer(),
          ss_pin: integer(),
          irq_pin: integer(),
          rx_pin: integer() | nil,
          tx_pin: integer() | nil,
          spi_bus_name: Striing.t()
        }

  @type packet :: %Packet{
          target_id: RF69.node_id(),
          sender_id: RF69.node_id(),
          ack_requested?: boolean(),
          is_ack?: boolean(),
          payload: binary()
        }

  @doc """
  Start a connection to a radio. `args` is a map or keyword list of
  configuration data.

  * node_id: integer (default: 1)
  * network_id: integer (default: 100)
  * isRFM69HW: boolean (default: true)
  * reset_pin: pin number
  * ss_pin: pin number
  * irq_pin: pin number
  * spi_bus_name: bus name
  * rx_pin: pin number (optional)
  * tx_pin: pin number (optional)
  """
  def start_link(args) do
    GenServer.start_link(__MODULE__, args)
  end

  @doc """
  Send a packet out on the radio.
  `message` must be less than or equal to 66 bytes wide
  """
  def send(rf69_pid, node_id, ack?, message) when byte_size(message) <= 66 do
    GenServer.call(rf69_pid, {:send_packet, node_id, ack?, message})
  end

  def send(_pid, _target_id, _ack, _message) do
    raise ArgumentError, "Message must be less than or equal to 66 bytes in length"
  end

  @impl GenServer
  def init(args) do
    send(self(), :init)
    {:ok, struct(RF69, args)}
  end

  @impl GenServer
  def handle_call({:send_packet, target_id, ack?, message}, _from, rf69) do
    packet = %Packet{
      target_id: target_id,
      sender_id: rf69.node_id,
      is_ack?: false,
      ack_requested?: ack?,
      payload: message
    }

    rf69 = send_packet(packet, rf69)
    {:reply, :ok, rf69}
  end

  @impl GenServer
  def handle_info(:init, rf69) do
    with {:ok, reset} <- HAL.gpio_open(rf69.reset_pin, :output, initial_value: 0),
         {:ok, ss} <- HAL.gpio_open(rf69.ss_pin, :output, initial_value: 1),
         {:ok, irq} <- HAL.gpio_open(rf69.irq_pin, :input),
         {:ok, spi} <- HAL.spi_open(rf69.spi_bus_name, mode: 0, speed_hz: 8_000_000) do
      send(self(), :reset)
      {:noreply, %{rf69 | reset: reset, ss: ss, irq: irq, spi: spi}}
    else
      error ->
        {:stop, error, rf69}
    end
  end

  def handle_info(:reset, rf69) do
    reset(rf69)
    # 0xAA = write_reg_while(rf69, {:SYNCVALUE1, 0xAA}, {:SYNCVALUE1, 0xAA}, 50)
    0x55 = write_reg_while(rf69, {:SYNCVALUE1, 0x55}, {:SYNCVALUE1, 0x55}, 50)
    write_config(rf69)
    rf69 = set_high_power(rf69)

    :ok = HAL.gpio_set_interrupts(rf69.irq, :rising)

    rf69 = set_mode(rf69, :STANDBY)
    # read_all_reg_values(rf69)
    send(self(), :receive_begin)
    {:noreply, rf69}
  end

  def handle_info(:receive_begin, rf69) do
    <<
      _fifo_full::1,
      _fifo_not_empty::1,
      _fifo_level::1,
      _fifo_overrun::1,
      _packet_sent::1,
      payload_ready::1,
      _crc_ok::1,
      _unused::1
    >> = read_reg_bin(rf69, :IRQFLAGS2)

    if payload_ready == 1 do
      IO.puts("setting restart_rx bit")

      <<interpacket_rx_delay::4, unused::1, _restart_rx::1, auto_rx_restart::1, aes_on::1>> =
        read_reg_bin(rf69, :PACKETCONFIG2)

      write_reg(
        rf69,
        :PACKETCONFIG2,
        <<interpacket_rx_delay::4, unused::1, 1::1, auto_rx_restart::1, aes_on::1>>
      )
    end

    write_reg(rf69, :DIOMAPPING1, :DIOMAPPING1_DIO0_01)
    rf69 = set_mode(rf69, :RX)
    {:noreply, rf69}
  end

  def handle_info(info, rf69) do
    if HAL.gpio_interupt?(info) do
      handle_interupt(rf69)
    else
      {:stop, info, rf69}
    end
  end

  def handle_interupt(rf69) do
    <<
      _fifo_full::1,
      _fifo_not_empty::1,
      _fifo_level::1,
      _fifo_overrun::1,
      _packet_sent::1,
      payload_ready::1,
      _crc_ok::1,
      _unused::1
    >> = read_reg_bin(rf69, :IRQFLAGS2)

    if payload_ready == 1 do
      rf69 = recv_packet(rf69)
      rf69 = set_mode(rf69, :RX)
      {:noreply, rf69}
    else
      {:noreply, rf69}
    end
  end

  defp handle_ack(
         %Packet{ack_requested?: true, target_id: id} = packet,
         %RF69{node_id: id} = rf69
       ) do
    ack = %Packet{
      packet
      | is_ack?: true,
        ack_requested?: false,
        target_id: packet.sender_id,
        sender_id: id,
        payload: <<>>
    }

    send_packet(ack, rf69)
  end

  defp handle_ack(%Packet{is_ack?: true}, rf69) do
    rf69
  end

  defp handle_ack(_, rf69) do
    rf69
  end

  defp recv_packet(rf69) do
    rf69 = set_mode(rf69, :STANDBY)
    select(rf69)

    # select fifo register
    {:ok, _} = HAL.spi_transfer(rf69.spi, <<0::8>>)

    # read header
    {:ok, <<length::8, target_id::8, sender_id::8, ctl::bits-8>>} =
      HAL.spi_transfer(rf69.spi, <<0::32>>)

    # ctl contains the most signifigant two bits of target and sender
    <<is_ack::1, ack_requested::1, _rssi_req::1, _::1, target_id_msb::2, sender_id_msb::2>> = ctl

    <<target_id::10, sender_id::10>> =
      <<target_id_msb::2, target_id::8, sender_id_msb::2, sender_id::8>>

    size = length * 8

    # RF69 library tacks on three bytes. not really sure why..
    length = length - 3

    {:ok, <<payload::binary-size(length), _::binary-3>>} =
      HAL.spi_transfer(rf69.spi, <<0::size(size)>>)

    packet = %Packet{
      target_id: target_id,
      sender_id: sender_id,
      ack_requested?: ack_requested == 1,
      is_ack?: is_ack == 1,
      payload: payload
    }

    IO.inspect(packet, label: "packet received")

    unselect(rf69)
    handle_ack(packet, rf69)
  end

  defp send_packet(%Packet{} = packet, rf69) do
    rf69 = set_mode(rf69, :STANDBY)

    select(rf69)

    <<target_msb::2, target_lsb::8, sender_msb::2, sender_lsb::8>> =
      <<packet.target_id::10, packet.sender_id::10>>

    is_ack = if packet.is_ack?, do: 1, else: 0
    ack_requested = if packet.ack_requested?, do: 1, else: 0

    length = byte_size(packet.payload) + 3
    # reverse sender and target for ack
    send_packet = <<
      length::8,
      target_lsb::8,
      sender_lsb::8,
      is_ack::1,
      ack_requested::1,
      0::2,
      target_msb::2,
      sender_msb::2,
      packet.payload::binary
    >>

    # select FIFO register
    {:ok, _} = HAL.spi_transfer(rf69.spi, <<0b10000000>>)
    {:ok, _} = HAL.spi_transfer(rf69.spi, send_packet)
    unselect(rf69)

    rf69 = set_mode(rf69, :TX)
    # hack to wait for the fifo to flush.. there's a flag for this
    # Process.sleep(1000)
    :ok = block_until_packet_sent(rf69, 50)

    set_mode(rf69, :RX)
  end
end
