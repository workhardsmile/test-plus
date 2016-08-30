class CreateMailNotifyGroups < ActiveRecord::Migration
  def change
    create_table :mail_notify_groups do |t|
      t.string :name

      t.timestamps
    end
  end
end
