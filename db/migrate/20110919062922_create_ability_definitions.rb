class CreateAbilityDefinitions < ActiveRecord::Migration
  def change
    create_table :ability_definitions do |t|
      t.references :role
      t.string :ability
      t.string :resource

      t.timestamps
    end
    add_index :ability_definitions, :role_id, :name => "idx_ad_r"
  end
end
