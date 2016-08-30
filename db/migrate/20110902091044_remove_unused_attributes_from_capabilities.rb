class RemoveUnusedAttributesFromCapabilities < ActiveRecord::Migration
  def up
    remove_column :capabilities, :status
    remove_column :capabilities, :allowed
  end

  def down
    add_column :capabilities, :status, :string
    add_column :capabilities, :allowed, :boolean
  end
end
