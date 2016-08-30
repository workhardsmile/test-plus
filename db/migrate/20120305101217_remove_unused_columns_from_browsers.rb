class RemoveUnusedColumnsFromBrowsers < ActiveRecord::Migration
  def up
    remove_foreign_key :browsers, :name => "fk_b_m"
    remove_index :browsers, :name => "idx_b_m"
    remove_column :browsers, :machine_id
    remove_column :browsers, :allowed
  end

  def down
    add_column :browsers, :machine_id, :integer
    add_column :browsers, :allowed, :boolean
    add_index :browsers, :machine_id, :name => "idx_b_m"
    add_foreign_key :browsers, :machines, :dependent => :delete, :name => "fk_b_m"
  end
end
