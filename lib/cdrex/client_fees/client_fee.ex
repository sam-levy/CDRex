defmodule CDRex.ClientFees.ClientFee do
  use CDRex.Schema

  schema "client_fees" do
    field :client_code, :string
    field :start_date, :date
    field :fee, :float
    field :service, CDRex.Enums.ServiceType
    field :direction, CDRex.Enums.DirectionType

    timestamps()
  end

  @fields [:client_code, :start_date, :fee, :service, :direction]

  def fields, do: @fields

  def changeset(target \\ %__MODULE__{}, attrs) do
    target
    |> cast(attrs, @fields)
    |> validate_required(@fields)
    |> validate_length(:client_code, max: 255)
    |> unique_constraint([:direction, :service, :start_date, :client_code],
      name: :client_fees_unique_fee,
      message: "The fee for this client_code, start_date, service and direction already exists"
    )
  end
end
