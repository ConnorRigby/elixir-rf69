defmodule RF69.RSSI do
  @moduledoc """
  Taken from https://github.com/nerves-networking/vintage_net_wifi/blob/master/lib/vintage_net_wifi/utils.ex
  The defaults of `best` and `worst` dbm are close, but not quite perfect
  and it will very based on target frequency. 
  TODO make the a lookup table for best and worst based on frequency.
  """

  @doc """
  Convert power in dBm to a percent
  The returned percentage is intended to shown to users
  like to show a number of bars or some kind of signal
  strength.
  See [Displaying Associated and Scanned Signal
  Levels](https://web.archive.org/web/20141222024740/http://www.ces.clemson.edu/linux/nm-ipw2200.shtml).
  """
  @spec dbm_to_percent(number(), number(), number()) :: 1..100
  def dbm_to_percent(dbm, best_dbm \\ -26, worst_dbm \\ -83.7)

  def dbm_to_percent(dbm, best_dbm, _worst_dbm) when dbm >= best_dbm do
    100
  end

  def dbm_to_percent(dbm, best_dbm, worst_dbm) do
    delta = best_dbm - worst_dbm
    delta2 = delta * delta

    percent =
      100 -
        (best_dbm - dbm) * (15 * delta + 62 * (best_dbm - dbm)) /
          delta2

    # Constrain the percent to integers and never go to 0
    # (Kernel.floor/1 was added to Elixir 1.8, so don't use it)
    max(:erlang.floor(percent), 1)
  end
end
