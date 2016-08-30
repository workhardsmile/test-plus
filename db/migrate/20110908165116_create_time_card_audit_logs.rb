class CreateTimeCardAuditLogs < ActiveRecord::Migration
  def change
    create_table :time_card_audit_logs do |t|
      t.integer :week
      t.integer :year
      t.float :time_card_needed
      t.float :time_card_actual

      t.timestamps
    end
  end
end
