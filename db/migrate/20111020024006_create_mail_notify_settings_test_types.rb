class CreateMailNotifySettingsTestTypes < ActiveRecord::Migration
  def change
    create_table :mail_notify_settings_test_types, :id => false do |t|
      t.belongs_to :mail_notify_setting
      t.belongs_to :test_type

      t.timestamps
    end

    add_index :mail_notify_settings_test_types, :mail_notify_setting_id, :name => 'idx_mnstt_mns'
    add_index :mail_notify_settings_test_types, :test_type_id, :name => 'idx_mnstt_tt'

    add_foreign_key :mail_notify_settings_test_types, :mail_notify_settings, :name => 'fk_mnstt_mns',  :dependent => :delete
    add_foreign_key :mail_notify_settings_test_types, :test_types, :name => 'fk_mnstt_tt', :dependent => :delete
  end
end
