class CreateOracleProjectPermissions < ActiveRecord::Migration
  def change
    create_table :oracle_project_permissions do |t|
      t.references :user
      t.references :oracle_project

      t.timestamps
    end
    add_index :oracle_project_permissions, :user_id, :name => "idx_opp_u"
    add_index :oracle_project_permissions, :oracle_project_id, :name => "idx_opp_op"
  end
end
