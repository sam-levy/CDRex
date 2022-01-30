defmodule CDRex.CDRs.ReporterTest do
  use CDRex.DataCase, async: true

  alias CDRex.CDRs.Reporter

  def init(_context) do
    #### LIB25 Jan 21

    ## Voice
    insert(:cdr,
      client_code: "LIB25",
      service: :voice,
      amount: 10.0,
      timestamp: ~N[2021-01-01 00:00:00]
    )

    insert(:cdr,
      client_code: "LIB25",
      service: :voice,
      amount: 12.0,
      timestamp: ~N[2021-01-01 00:00:00]
    )

    insert(:cdr,
      client_code: "LIB25",
      service: :voice,
      amount: 0.0,
      success: false,
      timestamp: ~N[2021-01-01 00:00:00]
    )

    ## SMS
    insert(:cdr,
      client_code: "LIB25",
      service: :sms,
      amount: 10.0,
      timestamp: ~N[2021-01-01 00:00:00]
    )

    insert(:cdr,
      client_code: "LIB25",
      service: :sms,
      amount: 15.0,
      timestamp: ~N[2021-01-01 00:00:00]
    )

    insert(:cdr,
      client_code: "LIB25",
      service: :sms,
      amount: 0.0,
      success: false,
      timestamp: ~N[2021-01-01 00:00:00]
    )

    ## MMS
    insert(:cdr,
      client_code: "LIB25",
      service: :mms,
      amount: 15.0,
      timestamp: ~N[2021-01-01 00:00:00]
    )

    insert(:cdr,
      client_code: "LIB25",
      service: :mms,
      amount: 0.0,
      success: false,
      timestamp: ~N[2021-01-01 00:00:00]
    )

    #### LIB25 Feb 21

    ## Voice
    insert(:cdr,
      client_code: "LIB25",
      service: :voice,
      amount: 20.0,
      timestamp: ~N[2021-02-01 00:00:00]
    )

    insert(:cdr,
      client_code: "LIB25",
      service: :voice,
      amount: 0.0,
      success: false,
      timestamp: ~N[2021-02-01 00:00:00]
    )

    ## SMS
    insert(:cdr,
      client_code: "LIB25",
      service: :sms,
      amount: 20.0,
      timestamp: ~N[2021-02-01 00:00:00]
    )

    insert(:cdr,
      client_code: "LIB25",
      service: :sms,
      amount: 25.0,
      timestamp: ~N[2021-02-01 00:00:00]
    )

    ## MMS
    insert(:cdr,
      client_code: "LIB25",
      service: :mms,
      amount: 0.0,
      success: false,
      timestamp: ~N[2021-02-01 00:00:00]
    )

    #### Other client TO IGNORE

    ## Voice
    insert(:cdr,
      client_code: "BIZ00",
      service: :voice,
      amount: 30.0,
      timestamp: ~N[2021-02-01 00:00:00]
    )

    ## SMS
    insert(:cdr,
      client_code: "BIZ00",
      service: :sms,
      amount: 30.0,
      timestamp: ~N[2021-02-01 00:00:00]
    )

    ## MMS
    insert(:cdr,
      client_code: "BIZ00",
      service: :mms,
      amount: 35.0,
      timestamp: ~N[2021-02-01 00:00:00]
    )

    :ok
  end

  describe "client_summary_by_month/3" do
    setup :init

    test "returns a summary by client and month" do
      assert Reporter.client_summary_by_month("LIB25", 1, 2021) ==
               {:ok,
                %{
                  voice: %{count: 2, total_price: 22.0},
                  sms: %{count: 2, total_price: 25.0},
                  mms: %{count: 1, total_price: 15.0},
                  total: %{count: 5, total_price: 62.0}
                }}
    end

    test "disconsiders not succedded CDRs" do
      assert Reporter.client_summary_by_month("LIB25", 2, 2021) ==
               {:ok,
                %{
                  voice: %{count: 1, total_price: 20.0},
                  sms: %{count: 2, total_price: 45.0},
                  total: %{count: 3, total_price: 65.0}
                }}
    end

    test "when client has no CDR for the month" do
      assert Reporter.client_summary_by_month("LIB25", 3, 2021) ==
               {:ok,
                %{
                  total: %{count: 0, total_price: 0}
                }}
    end

    test "when client has no CDR" do
      assert Reporter.client_summary_by_month("RAB11", 2, 2021) ==
               {:ok,
                %{
                  total: %{count: 0, total_price: 0}
                }}
    end

    test "when month is invalid" do
      assert Reporter.client_summary_by_month("RAB11", 13, 2021) == {:error, "invalid attrs"}
    end
  end
end
