defmodule Wowlr.Repo.Migrations.CreateCombatEvents do
  use Ecto.Migration

  def change do
    create table(:combat_events) do
      add :event, :string
      add :offset, :integer
      add :source_guid, :string
      add :source_name, :string
      add :source_flags, :integer
      add :source_raidflags, :integer
      add :dest_guid, :string
      add :dest_name, :string
      add :dest_flags, :integer
      add :dest_raidflags, :integer
      add :prefix_params, :map
      add :info_guid, :string
      add :owner_guid, :string
      add :hp_current, :integer
      add :hp_max, :integer
      add :attack_power, :integer
      add :spell_power, :integer
      add :armor, :integer
      add :absorb, :integer
      add :power_type, :integer
      add :power_current, :integer
      add :power_max, :integer
      add :power_cost, :integer
      add :position_x, :float
      add :position_y, :float
      add :map_id, :string
      add :facing, :float
      add :suffix_params, :map
      add :other, :map

      timestamps()
    end
  end
end
