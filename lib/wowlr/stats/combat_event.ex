defmodule Wowlr.Stats.CombatEvent do
  use Ecto.Schema
  import Ecto.Changeset

  schema "combat_events" do
    field :absorb, :integer
    field :armor, :integer
    field :attack_power, :integer
    field :dest_flags, :integer
    field :dest_guid, :string
    field :dest_name, :string
    field :dest_raidflags, :integer
    field :event, :string
    field :facing, :float
    field :hp_current, :integer
    field :hp_max, :integer
    field :info_guid, :string
    field :map_id, :string
    field :offset, :integer
    field :other, :map
    field :owner_guid, :string
    field :position_x, :float
    field :position_y, :float
    field :power_cost, :integer
    field :power_current, :integer
    field :power_max, :integer
    field :power_type, :integer
    field :prefix_params, :map
    field :source_flags, :integer
    field :source_guid, :string
    field :source_name, :string
    field :source_raidflags, :integer
    field :spell_power, :integer
    field :suffix_params, :map

    timestamps()
  end

  @doc false
  def changeset(combat_event, attrs) do
    combat_event
    |> cast(attrs, [
      :event,
      :offset,
      :source_guid,
      :source_name,
      :source_flags,
      :source_raidflags,
      :dest_guid,
      :dest_name,
      :dest_flags,
      :dest_raidflags,
      :prefix_params,
      :info_guid,
      :owner_guid,
      :hp_current,
      :hp_max,
      :attack_power,
      :spell_power,
      :armor,
      :absorb,
      :power_type,
      :power_current,
      :power_max,
      :power_cost,
      :position_x,
      :position_y,
      :map_id,
      :facing,
      :suffix_params,
      :other
    ])
    |> validate_required([
      :event,
      :offset
    ])
  end
end
