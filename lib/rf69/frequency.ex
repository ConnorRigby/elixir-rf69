defmodule RF69.Frequency do
  @moduledoc false

  import RF69.Util, only: [write_reg: 3]

  @type t() ::
          314
          | 315
          | 316
          | 433
          | 434
          | 435
          | 863
          | 864
          | 865
          | 866
          | 867
          | 868
          | 869
          | 870
          | 902
          | 903
          | 904
          | 905
          | 906
          | 907
          | 908
          | 909
          | 910
          | 911
          | 912
          | 913
          | 914
          | 915
          | 916
          | 917
          | 918
          | 919
          | 920
          | 921
          | 922
          | 923
          | 924
          | 925
          | 926
          | 927

  def set_frequency(%{frequency: 314} = rf69) do
    rf69
    |> write_reg(:FRFMSB, :FRFMSB_314)
    |> write_reg(:FRFMID, :FRFMID_314)
    |> write_reg(:FRFLSB, :FRFLSB_314)
  end

  def set_frequency(%{frequency: 315} = rf69) do
    rf69
    |> write_reg(:FRFMSB, :FRFMSB_315)
    |> write_reg(:FRFMID, :FRFMID_315)
    |> write_reg(:FRFLSB, :FRFLSB_315)
  end

  def set_frequency(%{frequency: 316} = rf69) do
    rf69
    |> write_reg(:FRFMSB, :FRFMSB_316)
    |> write_reg(:FRFMID, :FRFMID_316)
    |> write_reg(:FRFLSB, :FRFLSB_316)
  end

  def set_frequency(%{frequency: 433} = rf69) do
    rf69
    |> write_reg(:FRFMSB, :FRFMSB_433)
    |> write_reg(:FRFMID, :FRFMID_433)
    |> write_reg(:FRFLSB, :FRFLSB_433)
  end

  def set_frequency(%{frequency: 434} = rf69) do
    rf69
    |> write_reg(:FRFMSB, :FRFMSB_434)
    |> write_reg(:FRFMID, :FRFMID_434)
    |> write_reg(:FRFLSB, :FRFLSB_434)
  end

  def set_frequency(%{frequency: 435} = rf69) do
    rf69
    |> write_reg(:FRFMSB, :FRFMSB_435)
    |> write_reg(:FRFMID, :FRFMID_435)
    |> write_reg(:FRFLSB, :FRFLSB_435)
  end

  def set_frequency(%{frequency: 863} = rf69) do
    rf69
    |> write_reg(:FRFMSB, :FRFMSB_863)
    |> write_reg(:FRFMID, :FRFMID_863)
    |> write_reg(:FRFLSB, :FRFLSB_863)
  end

  def set_frequency(%{frequency: 864} = rf69) do
    rf69
    |> write_reg(:FRFMSB, :FRFMSB_864)
    |> write_reg(:FRFMID, :FRFMID_864)
    |> write_reg(:FRFLSB, :FRFLSB_864)
  end

  def set_frequency(%{frequency: 865} = rf69) do
    rf69
    |> write_reg(:FRFMSB, :FRFMSB_865)
    |> write_reg(:FRFMID, :FRFMID_865)
    |> write_reg(:FRFLSB, :FRFLSB_865)
  end

  def set_frequency(%{frequency: 866} = rf69) do
    rf69
    |> write_reg(:FRFMSB, :FRFMSB_866)
    |> write_reg(:FRFMID, :FRFMID_866)
    |> write_reg(:FRFLSB, :FRFLSB_866)
  end

  def set_frequency(%{frequency: 867} = rf69) do
    rf69
    |> write_reg(:FRFMSB, :FRFMSB_867)
    |> write_reg(:FRFMID, :FRFMID_867)
    |> write_reg(:FRFLSB, :FRFLSB_867)
  end

  def set_frequency(%{frequency: 868} = rf69) do
    rf69
    |> write_reg(:FRFMSB, :FRFMSB_868)
    |> write_reg(:FRFMID, :FRFMID_868)
    |> write_reg(:FRFLSB, :FRFLSB_868)
  end

  def set_frequency(%{frequency: 869} = rf69) do
    rf69
    |> write_reg(:FRFMSB, :FRFMSB_869)
    |> write_reg(:FRFMID, :FRFMID_869)
    |> write_reg(:FRFLSB, :FRFLSB_869)
  end

  def set_frequency(%{frequency: 870} = rf69) do
    rf69
    |> write_reg(:FRFMSB, :FRFMSB_870)
    |> write_reg(:FRFMID, :FRFMID_870)
    |> write_reg(:FRFLSB, :FRFLSB_870)
  end

  def set_frequency(%{frequency: 902} = rf69) do
    rf69
    |> write_reg(:FRFMSB, :FRFMSB_902)
    |> write_reg(:FRFMID, :FRFMID_902)
    |> write_reg(:FRFLSB, :FRFLSB_902)
  end

  def set_frequency(%{frequency: 903} = rf69) do
    rf69
    |> write_reg(:FRFMSB, :FRFMSB_903)
    |> write_reg(:FRFMID, :FRFMID_903)
    |> write_reg(:FRFLSB, :FRFLSB_903)
  end

  def set_frequency(%{frequency: 904} = rf69) do
    rf69
    |> write_reg(:FRFMSB, :FRFMSB_904)
    |> write_reg(:FRFMID, :FRFMID_904)
    |> write_reg(:FRFLSB, :FRFLSB_904)
  end

  def set_frequency(%{frequency: 905} = rf69) do
    rf69
    |> write_reg(:FRFMSB, :FRFMSB_905)
    |> write_reg(:FRFMID, :FRFMID_905)
    |> write_reg(:FRFLSB, :FRFLSB_905)
  end

  def set_frequency(%{frequency: 906} = rf69) do
    rf69
    |> write_reg(:FRFMSB, :FRFMSB_906)
    |> write_reg(:FRFMID, :FRFMID_906)
    |> write_reg(:FRFLSB, :FRFLSB_906)
  end

  def set_frequency(%{frequency: 907} = rf69) do
    rf69
    |> write_reg(:FRFMSB, :FRFMSB_907)
    |> write_reg(:FRFMID, :FRFMID_907)
    |> write_reg(:FRFLSB, :FRFLSB_907)
  end

  def set_frequency(%{frequency: 908} = rf69) do
    rf69
    |> write_reg(:FRFMSB, :FRFMSB_908)
    |> write_reg(:FRFMID, :FRFMID_908)
    |> write_reg(:FRFLSB, :FRFLSB_908)
  end

  def set_frequency(%{frequency: 909} = rf69) do
    rf69
    |> write_reg(:FRFMSB, :FRFMSB_909)
    |> write_reg(:FRFMID, :FRFMID_909)
    |> write_reg(:FRFLSB, :FRFLSB_909)
  end

  def set_frequency(%{frequency: 910} = rf69) do
    rf69
    |> write_reg(:FRFMSB, :FRFMSB_910)
    |> write_reg(:FRFMID, :FRFMID_910)
    |> write_reg(:FRFLSB, :FRFLSB_910)
  end

  def set_frequency(%{frequency: 911} = rf69) do
    rf69
    |> write_reg(:FRFMSB, :FRFMSB_911)
    |> write_reg(:FRFMID, :FRFMID_911)
    |> write_reg(:FRFLSB, :FRFLSB_911)
  end

  def set_frequency(%{frequency: 912} = rf69) do
    rf69
    |> write_reg(:FRFMSB, :FRFMSB_912)
    |> write_reg(:FRFMID, :FRFMID_912)
    |> write_reg(:FRFLSB, :FRFLSB_912)
  end

  def set_frequency(%{frequency: 913} = rf69) do
    rf69
    |> write_reg(:FRFMSB, :FRFMSB_913)
    |> write_reg(:FRFMID, :FRFMID_913)
    |> write_reg(:FRFLSB, :FRFLSB_913)
  end

  def set_frequency(%{frequency: 914} = rf69) do
    rf69
    |> write_reg(:FRFMSB, :FRFMSB_914)
    |> write_reg(:FRFMID, :FRFMID_914)
    |> write_reg(:FRFLSB, :FRFLSB_914)
  end

  def set_frequency(%{frequency: 915} = rf69) do
    rf69
    |> write_reg(:FRFMSB, :FRFMSB_915)
    |> write_reg(:FRFMID, :FRFMID_915)
    |> write_reg(:FRFLSB, :FRFLSB_915)
  end

  def set_frequency(%{frequency: 916} = rf69) do
    rf69
    |> write_reg(:FRFMSB, :FRFMSB_916)
    |> write_reg(:FRFMID, :FRFMID_916)
    |> write_reg(:FRFLSB, :FRFLSB_916)
  end

  def set_frequency(%{frequency: 917} = rf69) do
    rf69
    |> write_reg(:FRFMSB, :FRFMSB_917)
    |> write_reg(:FRFMID, :FRFMID_917)
    |> write_reg(:FRFLSB, :FRFLSB_917)
  end

  def set_frequency(%{frequency: 918} = rf69) do
    rf69
    |> write_reg(:FRFMSB, :FRFMSB_918)
    |> write_reg(:FRFMID, :FRFMID_918)
    |> write_reg(:FRFLSB, :FRFLSB_918)
  end

  def set_frequency(%{frequency: 919} = rf69) do
    rf69
    |> write_reg(:FRFMSB, :FRFMSB_919)
    |> write_reg(:FRFMID, :FRFMID_919)
    |> write_reg(:FRFLSB, :FRFLSB_919)
  end

  def set_frequency(%{frequency: 920} = rf69) do
    rf69
    |> write_reg(:FRFMSB, :FRFMSB_920)
    |> write_reg(:FRFMID, :FRFMID_920)
    |> write_reg(:FRFLSB, :FRFLSB_920)
  end

  def set_frequency(%{frequency: 921} = rf69) do
    rf69
    |> write_reg(:FRFMSB, :FRFMSB_921)
    |> write_reg(:FRFMID, :FRFMID_921)
    |> write_reg(:FRFLSB, :FRFLSB_921)
  end

  def set_frequency(%{frequency: 922} = rf69) do
    rf69
    |> write_reg(:FRFMSB, :FRFMSB_922)
    |> write_reg(:FRFMID, :FRFMID_922)
    |> write_reg(:FRFLSB, :FRFLSB_922)
  end

  def set_frequency(%{frequency: 923} = rf69) do
    rf69
    |> write_reg(:FRFMSB, :FRFMSB_923)
    |> write_reg(:FRFMID, :FRFMID_923)
    |> write_reg(:FRFLSB, :FRFLSB_923)
  end

  def set_frequency(%{frequency: 924} = rf69) do
    rf69
    |> write_reg(:FRFMSB, :FRFMSB_924)
    |> write_reg(:FRFMID, :FRFMID_924)
    |> write_reg(:FRFLSB, :FRFLSB_924)
  end

  def set_frequency(%{frequency: 925} = rf69) do
    rf69
    |> write_reg(:FRFMSB, :FRFMSB_925)
    |> write_reg(:FRFMID, :FRFMID_925)
    |> write_reg(:FRFLSB, :FRFLSB_925)
  end

  def set_frequency(%{frequency: 926} = rf69) do
    rf69
    |> write_reg(:FRFMSB, :FRFMSB_926)
    |> write_reg(:FRFMID, :FRFMID_926)
    |> write_reg(:FRFLSB, :FRFLSB_926)
  end

  def set_frequency(%{frequency: 927} = rf69) do
    rf69
    |> write_reg(:FRFMSB, :FRFMSB_927)
    |> write_reg(:FRFMID, :FRFMID_927)
    |> write_reg(:FRFLSB, :FRFLSB_927)
  end

  def set_frequency(%{frequency: freq}) do
    raise "Unknown frequency: #{freq}"
  end
end
