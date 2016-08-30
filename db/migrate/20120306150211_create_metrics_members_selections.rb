class CreateMetricsMembersSelections < ActiveRecord::Migration
  def change
    create_table :metrics_members_selections do |t|
      t.integer :widget_id
      t.references :team_member
    end
    add_foreign_key :metrics_members_selections, :team_members, :dependent => :delete, :name => "fk_mms_tm"
  end
end
