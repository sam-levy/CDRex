defmodule CDRex.Enums do
  import EctoEnum

  defenum(DirectionType, :direction_type, [:inbound, :outbound])
  defenum(ServiceType, :service_type, [:sms, :mms, :voice])
end
