class CreateMailNotifySettings < ActiveRecord::Migration
  def change
    create_table :mail_notify_settings do |t|
      t.string :mail
      t.references :project
      t.references :test_type

      t.timestamps
    end
    add_index :mail_notify_settings, :project_id, :name => "idx_mns_p"
    add_index :mail_notify_settings, :test_type_id, :name => "idx_mns_tt"
    add_foreign_key :mail_notify_settings, :projects, :dependent => :delete, :name => "fk_mns_p"
    add_foreign_key :mail_notify_settings, :test_types, :dependent => :delete, :name => "fk_mns_tt"

  end
end
