class AddMonitorFlagToProject < ActiveRecord::Migration
  def change
    add_column :projects, :monitor_flag, :boolean, :default => false
  end
end
