class CreateCiMappings < ActiveRecord::Migration
  def change
    create_table :ci_mappings do |t|
      t.references :project
      t.references :test_suite
      t.string :ci_value

      t.timestamps
    end
    add_index :ci_mappings, :project_id, :name => "idx_cm_p"
    add_index :ci_mappings, :test_suite_id, :name => "idx_cm_ts"

    add_foreign_key :ci_mappings, :projects, :dependent => :delete, :name => "fk_cm_p"
    add_foreign_key :ci_mappings, :test_suites, :dependent => :delete, :name => "fk_cm_ts"

  end
end
