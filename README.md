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
* [x] Basic Usage documentation
* [x] RSSI value reading
* [x] Processing packet data outside of the library
* [ ] Packet recv/send telemetry (because why not?)
* [ ] Unit tests?

# WARNINGS

Be sure to check your local laws for legal radio bands.

## Compatability

Packets are encoded/decoded with the same format as 
LowPowerLabs RF69 library version 1.4 ([described here](https://lowpowerlab.com/2019/05/02/rfm69-10bit-node-addresses/)).
The goal is to have feature parity with the Arduino library.

## Wiring

Currently i've only tested on Raspberry Pi, but it should work
on any device that [ElixirCircuits](https://elixir-circuits.github.io/) supports.

# Usage

```elixir
iex()> {:ok, pid} = RF69.start_link [
  reset_pin: 16,
  ss_pin: 25,
  irq_pin: 13,
  spi_bus_name: "spidev0.0",
]
{:ok, #PID<0.1660.0>}
iex()> receive do
...()>  %RF69.Packet{} = packet ->
...()>  IO.inspect(packet, label: "received packet")
...()>  :ok
...()> end
packet received: %RF69.Packet{
  ack_requested?: true,
  is_ack?: false,
  payload: "123 ABCDEFGHIJK",
  rssi: -42,
  sender_id: 2,
  target_id: 1
}
:ok
iex()> RF69.send(pid, 2, "hello node 2 from gateway node!")
:ok
iex()> 
```

## Examples

The API defined is pretty low level. If you want to use it, you should probably
wrap the radio server in your own genserver. See the [`Logger` Example](lib/rf69/logger_receiver.ex)
for an example.

[There is a repo here](https://github.com/ConnorRigby/elixir-rf69-examples) with some more examples

## Acking

By default the rf69 server will respond to acks If your implementation requires user acking, when starting
the rf69 server, pass in `auto_ack?: false`.
This will require that in your code when you receive a packet, you will be responsible for acking it in
the configured amount of time required by your other nodes. Here's an example:

```elixir
def handle_info(%Packet{requires_ack?: true} = packet, state) do
  # Process the packet (whatever that means to your application)
  case process_packet(packet) do
    :ok -> 
      # packet processed successfully.
      RF69.ack(state.rf69, packet)
    :error -> 
      # packet processed unsuccessfully.
      # The protocol has no concept of "nack"ing, so the lack of
      # an ack should be considered a "nack"
      Logger.error "Not acking #{inspect(packet)}"
  end
  {:noreply, state}
end
```

## Encryption

AES Encryption is handled at the hardware level. All you as a developer need to 
do is load the encryption key when starting the server.

> WARNING:
> This key must be **EXACTLY** 16 bytes wide.

```elixir
{:ok, pid} = RF69.start_link(encrypt_key: "sampleEncryptKey")
```