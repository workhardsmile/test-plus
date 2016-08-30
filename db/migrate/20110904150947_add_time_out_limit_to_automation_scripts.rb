class AddTimeOutLimitToAutomationScripts < ActiveRecord::Migration
  def change
    add_column :automation_scripts, :time_out_limit, :integer
  end
end
