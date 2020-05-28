import Config

config :rf69, RF69.HAL,
  gpio: RF69.HAL.CaptureGPIO,
  spi: RF69.HAL.CaptureSPI
