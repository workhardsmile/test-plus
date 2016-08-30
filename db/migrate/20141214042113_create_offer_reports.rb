class CreateOfferReports < ActiveRecord::Migration
  def change
    create_table :offer_reports do |t|
      t.datetime :timestamp
      t.string :market
      t.string :offer_type
      t.string :result
      t.integer :test_round_id
      t.string :description

      t.timestamps
    end
  end
end
