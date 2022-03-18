defmodule RF69.Util do
  @moduledoc """
  Helper functions for doing low level hardware access.
  Functions in this module should return an rf69 struct
  unless oterwise noted.
  """

  alias RF69.{HAL, Frequency}

  import RF69Registers
  use Bitwise
  require Logger

  @doc """
  Write a register.

  * `addr` can be one of:
    * an atom found in RF69Registers
    * an 8 bit wide binary
    * an 8 bit integer (0..255)
  * `value` can be one of:
    * an atom found in RF69Registers
    * an 8 bit integer (0..255)
    * a binary
  """
  def write_reg(rf69, addr, value) when is_atom(addr) do
    write_reg(rf69, reg(addr), value)
  end

  def write_reg(rf69, addr, value) when is_atom(value) do
    write_reg(rf69, addr, rf(value))
  end

  def write_reg(rf69, addr, value) when value <= 255 do
    write_reg(rf69, addr, <<value::8>>)
  end

  def write_reg(rf69, addr, value) when is_binary(value) do
    {:ok, _} = HAL.spi_transfer(rf69.spi, <<1::integer-1, addr::integer-7, value::binary>>)
    rf69
  end

  @doc """
  Read a register.

  * `addr` can be one of:
    * an atom found in RF69Registers
    * an 8 bit wide binary
    * an 8 bit integer (0..255)
  Returns an 8 bit integer
  """
  def read_reg(rf69, addr) when is_atom(addr) do
    read_reg(rf69, reg(addr))
  end

  def read_reg(rf69, addr) when is_integer(addr) do
    <<register::8>> = read_reg_bin(rf69, addr)
    register
  end

  @doc """
  Read a register returning the binary value.

  * `addr` can be one of:
    * an atom found in RF69Registers
    * an 8 bit wide binary
    * an 8 bit integer (0..255)
  Returns an 8 bit binary
  """
  def read_reg_bin(%{} = rf69, addr) when is_atom(addr) do
    read_reg_bin(rf69, reg(addr))
  end

  def read_reg_bin(%{} = rf69, addr) when is_integer(addr) do
    {:ok, <<_::8, register::binary>>} =
      HAL.spi_transfer(rf69.spi, <<0::integer-1, addr::integer-7, 0::8>>)

    register
  end

  def read_encrypt_key(rf69) do
    {:ok, <<_::8, register::binary>>} =
      HAL.spi_transfer(rf69.spi, <<0::integer-1, 0x3E::integer-7, 0::128>>)

    register
  end

  @doc "Sets the aes_on bit in the PACKETCONFIG2 register"
  def enable_encryption(%{} = rf69) do
    <<inter_packet_rx_delay::4, unused::1, restart_rx::1, auto_rx_restart_on::1, _aes_on::1>> =
      read_reg_bin(rf69, :PACKETCONFIG2)

    write_reg(
      rf69,
      :PACKETCONFIG2,
      <<inter_packet_rx_delay::4, unused::1, restart_rx::1, auto_rx_restart_on::1, 1::1>>
    )
  end

  @doc "Unsets the aes_on bit in the PACKETCONFIG2 register"
  def disable_encryption(%{} = rf69) do
    <<inter_packet_rx_delay::4, unused::1, restart_rx::1, auto_rx_restart_on::1, _aes_on::1>> =
      read_reg_bin(rf69, :PACKETCONFIG2)

    write_reg(
      rf69,
      :PACKETCONFIG2,
      <<inter_packet_rx_delay::4, unused::1, restart_rx::1, auto_rx_restart_on::1, 0::1>>
    )
  end

  @doc """
  Sets `current_mode` 3 bits on the OPMODE register.
  * `mode` can be one of:
    * :SLEEP
    * :STANDBY
    * :FS
    * :RX
    * :TX
  """
  def set_mode(%{mode: mode} = rf69, mode), do: rf69

  def set_mode(%{} = rf69, mode) do
    <<
      sequencer_off::1,
      listen_on::1,
      listen_abort::1,
      _current_mode::3,
      unused::2
    >> = read_reg_bin(rf69, :OPMODE)

    case mode do
      :SLEEP ->
        value = <<sequencer_off::1, listen_on::1, listen_abort::1, 0b000::3, unused::2>>
        write_reg(%{rf69 | mode: :SLEEP}, :OPMODE, value)

      :STANDBY ->
        value = <<sequencer_off::1, listen_on::1, listen_abort::1, 0b001::3, unused::2>>
        write_reg(%{rf69 | mode: :STANDBY}, :OPMODE, value)

      :FS ->
        value = <<sequencer_off::1, listen_on::1, listen_abort::1, 0b010::3, unused::2>>
        write_reg(%{rf69 | mode: :FS}, :OPMODE, value)

      :RX ->
        value = <<sequencer_off::1, listen_on::1, listen_abort::1, 0b100::3, unused::2>>
        rf69 = write_reg(%{rf69 | mode: :RX}, :OPMODE, value)
        if rf69.isRFM69HW, do: set_high_power_regs(rf69, false), else: rf69

      :TX ->
        value = <<sequencer_off::1, listen_on::1, listen_abort::1, 0b011::3, unused::2>>
        rf69 = write_reg(%{rf69 | mode: :TX}, :OPMODE, value)
        if rf69.isRFM69HW, do: set_high_power_regs(rf69, true), else: rf69
    end
  end

  @doc "sets `TESTPA1 and TESTPA2 registers to magic values"
  def set_high_power_regs(rf69, false) do
    rf69
    |> write_reg(reg(:TESTPA1), 0x55)
    |> write_reg(reg(:TESTPA2), 0x70)
  end

  def set_high_power_regs(rf69, true) do
    rf69
    |> write_reg(reg(:TESTPA1), 0x5D)
    |> write_reg(reg(:TESTPA2), 0x7C)
  end

  # writeReg(REG_OCP, _isRFM69HW ? RF_OCP_OFF : RF_OCP_ON);
  # writeReg(REG_PALEVEL, (readReg(REG_PALEVEL) & 0x1F) | RF_PALEVEL_PA1_ON | RF_PALEVEL_PA2_ON); // enable P1 & P2 amplifier stages
  @doc "Enables highpower in PALEVEL register. This is not the same as `set_high_power_regs`"
  def set_high_power(rf69) do
    rf69 = if rf69.isRFM69HW, do: write_reg(rf69, :OCP, :OCP_OFF), else: rf69
    <<pa0::1, _::2, power::5>> = read_reg_bin(rf69, :PALEVEL)
    write_reg(rf69, :PALEVEL, <<pa0::1, 1::1, 1::1, power::5>>)
  end

  @doc "Reads the RSSIVALUE register"
  def read_rssi(rf69) do
    rf69 =
      rf69
      |> write_reg(:RSSICONFIG, :RSSI_START)

    # |> block_until_rssi_done()

    # RSSI = -RssiValue/2 [dBm]
    -read_reg(rf69, :RSSIVALUE) |> Bitwise.bsr(1)
  end

  @doc "Blocks until packet_sent on IRQFLAGS2 is set. Timeout should be a low value"
  def block_until_packet_sent(rf69, timeout) when is_integer(timeout) do
    block_until_packet_sent(
      rf69,
      Process.send_after(self(), :block_until_packet_sent_timeout, timeout)
    )
  end

  def block_until_packet_sent(rf69, timer) do
    receive do
      :block_until_packet_sent_timeout -> :timeout
    after
      0 ->
        <<
          _fifo_full::1,
          _fifo_not_empty::1,
          _fifo_level::1,
          _fifo_overrun::1,
          packet_sent::1,
          _payload_ready::1,
          _crc_ok::1,
          _unused::1
        >> = read_reg_bin(rf69, :IRQFLAGS2)

        if packet_sent == 1 do
          Process.cancel_timer(timer)
          rf69
        else
          block_until_packet_sent(rf69, timer)
        end
    end
  end

  @doc "Blocks until packet_sent on IRQFLAGS2 is set. Timeout should be a low value"
  def block_until_packet_recv(rf69, timeout) when is_integer(timeout) do
    block_until_packet_recv(
      rf69,
      Process.send_after(self(), :block_until_packet_recv_timeout, timeout)
    )
  end

  def block_until_packet_recv(rf69, timer) do
    receive do
      :block_until_packet_recv_timeout -> :timeout
    after
      0 ->
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
          Process.cancel_timer(timer)
          rf69
        else
          block_until_packet_recv(rf69, timer)
        end
    end
  end

  def block_until_modeset(rf69, timeout) when is_integer(timeout) do
    block_until_modeset(
      rf69,
      Process.send_after(self(), :block_until_modeset_timeout, timeout)
    )
  end
  def  block_until_modeset(rf69, timer) do
      receive do
        :block_until_modeset_timeout -> :timeout
      after
        0 ->
          <<
          mode_ready::1,
          _rx_ready::1,
          _tx_ready::1,
          _pll_lock::1,
          _rssi::1,
          _timeout::1,
          _auto_mode::1,
          _sync_address_match::1
          >> = read_reg_bin(rf69, :IRQFLAGS1)

          if mode_ready == 1 do
            Process.cancel_timer(timer)
            rf69
          else
            block_until_packet_sent(rf69, timer)
          end
      end
    end

  @doc false
  def write_reg_while(rf69, {write_reg, write_value}, {read_reg, read_value}, timeout) do
    write_reg(rf69, write_reg, write_value)
    read_until(rf69, {read_reg, read_value}, timeout)
  end

  @doc false
  def read_until(rf69, {read_reg, read_value}, timeout) when is_integer(timeout) do
    timer = Process.send_after(self(), :timeout, timeout)
    read_until(rf69, {read_reg, read_value}, timer)
  end

  def read_until(rf69, {read_reg, read_value}, timer) do
    receive do
      :timeout ->
        :timeout
    after
      0 ->
        value = read_reg(rf69, read_reg)

        if value != read_value do
          read_until(rf69, {read_reg, read_value}, timer)
        else
          Process.cancel_timer(timer)
          value
        end
    end
  end

  # TODO factor out the bitwise nonsense here.
  @doc "Writes the default config. This is the same as the RFM69 Low Power Labs library"
  def write_config(rf69) do
    rf69
    |> write_reg(
      :OPMODE,
      rf(:OPMODE_SEQUENCER_ON) ||| rf(:OPMODE_LISTEN_OFF) ||| rf(:OPMODE_STANDBY)
    )
    |> write_reg(
      :DATAMODUL,
      rf(:DATAMODUL_DATAMODE_PACKET) ||| rf(:DATAMODUL_MODULATIONTYPE_FSK) |||
        rf(:DATAMODUL_MODULATIONSHAPING_00)
    )
    |> write_reg(:BITRATEMSB, :BITRATEMSB_55555)
    |> write_reg(:BITRATELSB, :BITRATELSB_55555)
    |> write_reg(:FDEVMSB, :FDEVMSB_50000)
    |> write_reg(:FDEVLSB, :FDEVLSB_50000)
    |> Frequency.set_frequency()
    |> write_reg(:RXBW, rf(:RXBW_DCCFREQ_010) ||| rf(:RXBW_MANT_16) ||| rf(:RXBW_EXP_2))
    |> write_reg(:DIOMAPPING1, :DIOMAPPING1_DIO0_01)
    |> write_reg(:DIOMAPPING2, :DIOMAPPING2_CLKOUT_OFF)
    |> write_reg(:IRQFLAGS2, :IRQFLAGS2_FIFOOVERRUN)
    |> write_reg(:RSSITHRESH, 220)
    |> write_reg(
      :SYNCCONFIG,
      rf(:SYNC_ON) ||| rf(:SYNC_FIFOFILL_AUTO) ||| rf(:SYNC_SIZE_2) ||| rf(:SYNC_TOL_0)
    )
    |> write_reg(:SYNCVALUE1, 0x2D)
    |> write_reg(:SYNCVALUE2, rf69.network_id)
    |> write_reg(
      :PACKETCONFIG1,
      rf(:PACKET1_FORMAT_VARIABLE) ||| rf(:PACKET1_DCFREE_OFF) ||| rf(:PACKET1_CRC_ON) |||
        rf(:PACKET1_CRCAUTOCLEAR_ON) ||| rf(:PACKET1_ADRSFILTERING_OFF)
    )
    |> write_reg(:PAYLOADLENGTH, 66)
    |> write_reg(
      :FIFOTHRESH,
      rf(:FIFOTHRESH_TXSTART_FIFONOTEMPTY) ||| rf(:FIFOTHRESH_VALUE)
    )
    |> write_reg(
      :PACKETCONFIG2,
      rf(:PACKET2_RXRESTARTDELAY_2BITS) ||| rf(:PACKET2_AUTORXRESTART_ON) ||| rf(:PACKET2_AES_OFF)
    )
    |> write_reg(:TESTDAGC, :DAGC_IMPROVED_LOWBETA0)
    |> write_reg(0x255, 0x0)
  end
end
