class AddPriorityAndTestTypeAndActiveToSlave < ActiveRecord::Migration
  def change
    add_column :slaves, :test_type, :string, :default => "*"
    add_column :slaves, :priority, :integer, :default => 10
    add_column :slaves, :active, :boolean, :default => true
  end
end
