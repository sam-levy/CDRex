defmodule CDRex.CDRs.CDR do
  use CDRex.Schema

  schema "cdrs" do
    field :client_name, :string
    field :client_code, :string
    field :carrier_name, :string
    field :source_number, :string
    field :destination_number, :string
    field :direction, CDRex.Enums.DirectionType
    field :service, CDRex.Enums.ServiceType
    field :number_of_units, :integer
    field :success, :boolean
    field :timestamp, :naive_datetime
    field :amount, :float

    timestamps()
  end

  @fields [
    :client_name,
    :client_code,
    :carrier_name,
    :source_number,
    :destination_number,
    :direction,
    :service,
    :number_of_units,
    :success,
    :timestamp
  ]

  def fields, do: @fields

  def changeset(target \\ %__MODULE__{}, attrs) do
    target
    |> base_changeset(attrs)
    |> validate_required([:amount])
    |> unique_constraint([:client_code, :carrier_name, :source_number, :service, :timestamp],
      name: :cdrs_unique,
      message: "the CDR already exists"
    )
  end

  def base_changeset(target \\ %__MODULE__{}, attrs) do
    target
    |> cast(attrs, [:amount | @fields])
    |> validate_required(@fields)
    |> validate_length(:client_name, max: 255)
    |> validate_length(:client_code, max: 255)
    |> validate_length(:carrier_name, max: 255)
  end

  def put_changeset_amount(%Ecto.Changeset{} = changeset, amount) do
    put_change(changeset, :amount, amount)
  end
end
