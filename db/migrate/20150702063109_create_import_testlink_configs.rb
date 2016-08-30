class CreateImportTestlinkConfigs < ActiveRecord::Migration
  def change
    create_table :import_testlink_configs do |t|
      t.string :testplus_project
      t.string :testlink_project

      t.timestamps
    end
  end
end
