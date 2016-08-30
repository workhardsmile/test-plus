class RemoveTestTypeFromMailNotifySettings < ActiveRecord::Migration
  def up
    remove_foreign_key :mail_notify_settings, :name => "fk_mns_tt"
    remove_index :mail_notify_settings, :name => "idx_mns_tt"
    remove_column :mail_notify_settings, :test_type_id
  end

  def down
    add_column :mail_notify_settings, :test_type_id, :integer
    add_index :mail_notify_settings, :test_type_id, :name => "idx_mns_tt"
    add_foreign_key :mail_notify_settings, :test_types, :dependent => :delete, :name => "fk_mns_tt"
  end
end
