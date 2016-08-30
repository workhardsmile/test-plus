class AddConnectionTableForProjectsAndTestEnvironments < ActiveRecord::Migration
  def change
    create_table(:project_test_environment_configs) do |t|
      t.references :project
      t.references :test_environment
      t.timestamps
    end
    add_index :project_test_environment_configs, :project_id, :name => "idx_pec_p"
    add_index :project_test_environment_configs, :test_environment_id, :name => "idx_pec_e"
  end
end
