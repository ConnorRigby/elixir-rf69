defmodule RF69.Util do
  @moduledoc false
  alias Circuits.{GPIO, SPI}

  import RF69Registers
  use Bitwise

  def write_reg(rf69, addr, value) when is_atom(addr) do
    write_reg(rf69, reg(addr), value)
  end

  def write_reg(rf69, addr, value) when is_integer(value) do
    write_reg(rf69, addr, <<value::8>>)
  end

  def write_reg(rf69, addr, value) when is_atom(value) do
    write_reg(rf69, addr, rf(value))
  end

  def write_reg(rf69, addr, value) when is_integer(addr) and is_binary(value) do
    select(rf69)
    # IO.puts("WRITE_REG(#{inspect(addr, base: :hex)}, #{inspect(value, base: :hex)})")
    {:ok, _} = SPI.transfer(rf69.spi, <<1::integer-1, addr::integer-7>>)
    {:ok, <<return::integer-8>>} = SPI.transfer(rf69.spi, value)
    unselect(rf69)
    return
  end

  def read_reg(rf69, addr) when is_atom(addr) do
    read_reg(rf69, reg(addr))
  end

  def read_reg(rf69, addr) when is_integer(addr) do
    <<register::8>> = read_reg_bin(rf69, addr)
    register
  end

  def read_reg_bin(rf69, addr) when is_atom(addr) do
    read_reg_bin(rf69, reg(addr))
  end

  def read_reg_bin(rf69, addr) when is_integer(addr) do
    select(rf69)
    {:ok, _reg} = SPI.transfer(rf69.spi, <<0::integer-1, addr::integer-7>>)
    {:ok, register} = SPI.transfer(rf69.spi, <<0::integer-8>>)
    unselect(rf69)
    register
  end

  def set_mode(%{mode: mode} = rf69, mode), do: rf69

  def set_mode(rf69, mode) do
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
        # IO.inspect(value, base: :binary, label: "MODE")
        write_reg(rf69, :OPMODE, value)
        %{rf69 | mode: :SLEEP}

      :STANDBY ->
        value = <<sequencer_off::1, listen_on::1, listen_abort::1, 0b001::3, unused::2>>
        # IO.inspect(value, base: :binary, label: "MODE")
        write_reg(rf69, :OPMODE, value)
        %{rf69 | mode: :STANDBY}

      :FS ->
        value = <<sequencer_off::1, listen_on::1, listen_abort::1, 0b010::3, unused::2>>
        # IO.inspect(value, base: :binary, label: "MODE")
        write_reg(rf69, :OPMODE, value)
        %{rf69 | mode: :FS}

      :RX ->
        value = <<sequencer_off::1, listen_on::1, listen_abort::1, 0b100::3, unused::2>>
        # IO.inspect(value, base: :binary, label: "MODE")
        write_reg(rf69, :OPMODE, value)
        if rf69.isRFM69HW, do: set_high_power_regs(rf69, false)
        %{rf69 | mode: :RX}

      :TX ->
        value = <<sequencer_off::1, listen_on::1, listen_abort::1, 0b011::3, unused::2>>
        # IO.inspect(value, base: :binary, label: "MODE")
        write_reg(rf69, :OPMODE, value)
        if rf69.isRFM69HW, do: set_high_power_regs(rf69, true)
        %{rf69 | mode: :TX}
    end
  end

  def set_high_power_regs(rf69, false) do
    write_reg(rf69, reg(:TESTPA1), 0x55)
    write_reg(rf69, reg(:TESTPA2), 0x70)
    rf69
  end

  def set_high_power_regs(rf69, true) do
    write_reg(rf69, reg(:TESTPA1), 0x5D)
    write_reg(rf69, reg(:TESTPA2), 0x7C)
    rf69
  end

  # writeReg(REG_OCP, _isRFM69HW ? RF_OCP_OFF : RF_OCP_ON);
  # writeReg(REG_PALEVEL, (readReg(REG_PALEVEL) & 0x1F) | RF_PALEVEL_PA1_ON | RF_PALEVEL_PA2_ON); // enable P1 & P2 amplifier stages
  def set_high_power(rf69) do
    if rf69.isRFM69HW, do: write_reg(rf69, :OCP, :OCP_OFF)
    <<pa0::1, _::2, power::5>> = read_reg_bin(rf69, :PALEVEL)
    write_reg(rf69, :PALEVEL, <<pa0::1, 1::1, 1::1, power::5>>)
    rf69
  end

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
          :ok
        else
          block_until_packet_sent(rf69, timer)
        end
    end
  end

  def write_reg_while(rf69, {write_reg, write_value}, {read_reg, read_value}, timeout) do
    write_reg(rf69, write_reg, write_value)
    read_until(rf69, {read_reg, read_value}, timeout)
  end

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

  def select(rf69) do
    GPIO.write(rf69.ss, 0)
  end

  def unselect(rf69) do
    GPIO.write(rf69.ss, 1)
  end

  def reset(rf69) do
    GPIO.write(rf69.reset, 1)
    GPIO.write(rf69.reset, 0)
  end

  def write_config(rf69) do
    write_reg(
      rf69,
      reg(:OPMODE),
      rf(:OPMODE_SEQUENCER_ON) ||| rf(:OPMODE_LISTEN_OFF) ||| rf(:OPMODE_STANDBY)
    )

    write_reg(
      rf69,
      reg(:DATAMODUL),
      rf(:DATAMODUL_DATAMODE_PACKET) ||| rf(:DATAMODUL_MODULATIONTYPE_FSK) |||
        rf(:DATAMODUL_MODULATIONSHAPING_00)
    )

    write_reg(rf69, reg(:BITRATEMSB), rf(:BITRATEMSB_55555))
    write_reg(rf69, reg(:BITRATELSB), rf(:BITRATELSB_55555))
    write_reg(rf69, reg(:FDEVMSB), rf(:FDEVMSB_50000))
    write_reg(rf69, reg(:FDEVLSB), rf(:FDEVLSB_50000))
    write_reg(rf69, reg(:FRFMSB), rf(:FRFMSB_915))
    write_reg(rf69, reg(:FRFMID), rf(:FRFMID_915))
    write_reg(rf69, reg(:FRFLSB), rf(:FRFLSB_915))

    # write_reg(
    #   rf69,
    #   reg(:PALEVEL),
    #   rf(:PALEVEL_PA0_ON) ||| rf(:PALEVEL_PA1_OFF) ||| rf(:PALEVEL_PA2_OFF) |||
    #     rf(:PALEVEL_OUTPUTPOWER_11111)
    # )

    # write_reg(rf69, reg(:OCP), rf(:OCP_ON) ||| rf(:OCP_TRIM_95))
    # write_reg(rf69, reg(:RXBW), rf(:RXBW_DCCFREQ_010) ||| rf(:RXBW_MANT_24) ||| rf(:RXBW_EXP_5))
    write_reg(rf69, reg(:RXBW), rf(:RXBW_DCCFREQ_010) ||| rf(:RXBW_MANT_16) ||| rf(:RXBW_EXP_2))
    # write_reg(rf69, reg(:RXBW), rf(:RXBW_DCCFREQ_010) ||| rf(:RXBW_MANT_24) ||| rf(:RXBW_EXP_3))
    write_reg(rf69, reg(:DIOMAPPING1), rf(:DIOMAPPING1_DIO0_01))
    write_reg(rf69, reg(:DIOMAPPING2), rf(:DIOMAPPING2_CLKOUT_OFF))
    write_reg(rf69, reg(:IRQFLAGS2), rf(:IRQFLAGS2_FIFOOVERRUN))
    write_reg(rf69, reg(:RSSITHRESH), 220)

    # write_reg(rf69, reg(:PREAMBLELSB), rf(:PREAMBLESIZE_LSB_VALUE))

    write_reg(
      rf69,
      reg(:SYNCCONFIG),
      rf(:SYNC_ON) ||| rf(:SYNC_FIFOFILL_AUTO) ||| rf(:SYNC_SIZE_2) ||| rf(:SYNC_TOL_0)
    )

    write_reg(rf69, reg(:SYNCVALUE1), 0x2D)
    write_reg(rf69, reg(:SYNCVALUE2), rf69.network_id)

    # write_reg(rf69, reg(:SYNCVALUE3), 0xAA)
    # write_reg(rf69, reg(:SYNCVALUE4), 0xBB)

    write_reg(
      rf69,
      reg(:PACKETCONFIG1),
      rf(:PACKET1_FORMAT_VARIABLE) ||| rf(:PACKET1_DCFREE_OFF) ||| rf(:PACKET1_CRC_ON) |||
        rf(:PACKET1_CRCAUTOCLEAR_ON) ||| rf(:PACKET1_ADRSFILTERING_OFF)
    )

    write_reg(rf69, reg(:PAYLOADLENGTH), 66)

    # write_reg(rf69, reg(:NODEADRS), rf69.node_id)

    write_reg(
      rf69,
      reg(:FIFOTHRESH),
      rf(:FIFOTHRESH_TXSTART_FIFONOTEMPTY) ||| rf(:FIFOTHRESH_VALUE)
    )

    write_reg(
      rf69,
      reg(:PACKETCONFIG2),
      rf(:PACKET2_RXRESTARTDELAY_2BITS) ||| rf(:PACKET2_AUTORXRESTART_ON) ||| rf(:PACKET2_AES_OFF)
    )

    # write_reg(
    #   rf69,
    #   reg(:PACKETCONFIG2),
    #   rf(:PACKET2_RXRESTARTDELAY_NONE) ||| rf(:PACKET2_AUTORXRESTART_ON) ||| rf(:PACKET2_AES_OFF)
    # )

    write_reg(rf69, reg(:TESTDAGC), rf(:DAGC_IMPROVED_LOWBETA0))
    write_reg(rf69, 0x255, 0x0)
  end

  def read_all_reg_values(rf69) do
    read_all_reg_values(rf69, 1, [])
  end

  def read_all_reg_values(rf69, addr, buffer) when addr <= 0x4F do
    select(rf69)
    {:ok, _} = SPI.transfer(rf69.spi, <<addr &&& 0x7F>>)
    {:ok, <<value::integer-8>>} = SPI.transfer(rf69.spi, <<0>>)
    unselect(rf69)
    reg = :io_lib.format("~.16.0B - ~.16.0B - ~.2.0B", [addr, value, value])
    read_all_reg_values(rf69, addr + 1, [reg | buffer])
  end

  def read_all_reg_values(_rf69, _, buffer),
    do: Enum.reverse(buffer) |> Enum.join("\n") |> IO.puts()
end
