class CreateOracleProjects < ActiveRecord::Migration
  def change
    create_table :oracle_projects do |t|
      t.string :name

      t.timestamps
    end
  end
end
