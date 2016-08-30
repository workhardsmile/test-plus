class CreateOfferMonitoringRecords < ActiveRecord::Migration
  def change
    create_table :offer_monitoring_records do |t|
      t.datetime :timestamp
      t.string :market
      t.string :user_email
      t.string :order_id

      t.timestamps
    end
  end
end
