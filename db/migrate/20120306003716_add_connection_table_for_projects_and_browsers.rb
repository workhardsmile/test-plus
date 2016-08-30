class AddConnectionTableForProjectsAndBrowsers < ActiveRecord::Migration
  def change
    create_table(:project_browser_configs) do |t|
      t.references :project
      t.references :browser

      t.timestamps
    end

    add_index :project_browser_configs, :project_id, :name => "idx_pbc_p"
    add_index :project_browser_configs, :browser_id, :name => "idx_pbc_b"
  end
end
