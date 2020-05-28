# RF69HCW Elixir Interface

Interact with RFM69HCW radio modules via spi.

[datasheet](https://cdn.sparkfun.com/datasheets/Wireless/General/RFM69HCW-V1.1.pdf)

[Arduino compatible library](https://github.com/LowPowerLab/RFM69)

[Purchase from adafruit](https://www.adafruit.com/product/3070)

[Purchase from SparkFun](https://www.sparkfun.com/products/12775)

## Current Features / Known Issues / wants

* [x] Packet encryption/decryption
* [x] Send packets
* [x] Receive packets
* [x] Auto Ack packets
* [x] only 915 mhz is currently supported
* [x] AES encryption
* [ ] Usage documentation
* [x] RSSI value reading
* [x] Processing packet data outside of the library
* [ ] Packet recv/send telemetry (because why not?)
* [ ] Unit tests?

# WARNINGS

This library barely functions. Please don't put it into 
production.

Also be sure to check your local laws for legal radio bands.

## Compatability

Packets are encoded/decoded with the same format as 
LowPowerLabs RF69 library version 1.4 ([described here](https://lowpowerlab.com/2019/05/02/rfm69-10bit-node-addresses/)).
The goal is to have feature parity with the Arduino library.

## Wiring

Currently i've only tested on Raspberry Pi, but it should work
on any device that [ElixirCircuits](https://elixir-circuits.github.io/) supports.

## Usage

```elixir
iex()> {:ok, pid} = RF69.start_link [
  reset_pin: 16,
  ss_pin: 25,
  irq_pin: 13,
  spi_bus_name: "spidev0.0",
]
{:ok, #PID<0.1660.0>}
iex()>
packet received: %RF69.Packet{         
  ack_requested?: true,
  is_ack?: false,
  payload: "123 ABCDEFGHIJKLM",
  sender_id: 2,
  target_id: 1
}
```