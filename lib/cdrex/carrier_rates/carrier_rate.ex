defmodule CDRex.CarrierRates.CarrierRate do
  use CDRex.Schema

  schema "carrier_rates" do
    field :carrier_name, :string
    field :start_date, :date
    field :rate, :float
    field :service, CDRex.Enums.ServiceType
    field :direction, CDRex.Enums.DirectionType

    timestamps()
  end

  @fields [:carrier_name, :start_date, :rate, :service, :direction]

  def changeset(target \\ %__MODULE__{}, attrs) do
    target
    |> cast(attrs, @fields)
    |> validate_required(@fields)
    |> validate_length(:carrier_name, max: 255)
    |> unique_constraint([:direction, :service, :start_date, :carrier_name],
      name: :carrier_rates_unique_rate,
      message: "The rate for this carrier_name, start_date, service and direction already exists"
    )
  end
end
