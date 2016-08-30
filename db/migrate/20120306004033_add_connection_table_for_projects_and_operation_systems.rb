class AddConnectionTableForProjectsAndOperationSystems < ActiveRecord::Migration
  def change
    create_table(:project_operation_system_configs) do |t|
      t.references :project
      t.references :operation_system

      t.timestamps
    end

    add_index :project_operation_system_configs, :project_id, :name => "idx_posc_p"
    add_index :project_operation_system_configs, :operation_system_id, :name => "idx_posc_os"
  end

end
