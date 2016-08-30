class AddAutomatableAndNotReadyAndUpdateManualAndUpdateNeededToAutomationProgress < ActiveRecord::Migration
  def change
    add_column :automation_progresses, :automatable, :integer, :default => 0
    add_column :automation_progresses, :not_ready, :integer, :default => 0
    add_column :automation_progresses, :update_manual, :integer, :default => 0
    add_column :automation_progresses, :update_needed, :integer, :default => 0
  end
end
