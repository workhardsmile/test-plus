class AddColumnsToBaseScriptResult < ActiveRecord::Migration
  def change
    add_column :base_script_results, :pass_count, :integer
    add_column :base_script_results, :failed_count, :integer
    add_column :base_script_results, :warning_count, :integer
    add_column :base_script_results, :not_run_count, :integer
    add_column :base_script_results, :is_latest, :integer
  end
end
