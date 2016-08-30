class RemoveConfigFromSlaves < ActiveRecord::Migration
  def up
    remove_column :slaves, :config
  end

  def down
    add_column :slaves, :config, :string
  end
end
