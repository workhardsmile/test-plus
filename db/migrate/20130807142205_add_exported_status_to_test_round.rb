class AddExportedStatusToTestRound < ActiveRecord::Migration
  def change
    add_column :test_rounds, :exported_status, :string, :default => "N"
  end
end
