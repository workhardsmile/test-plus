class AddActiveToImportTestlinkConfig < ActiveRecord::Migration
  def change
    add_column :import_testlink_configs, :active, :boolean, :default => true
  end
end
