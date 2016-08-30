class AddStatusToSlaves < ActiveRecord::Migration
  def change
    add_column :slaves, :status, :string
  end
end
