class ChangeWidgetToString< ActiveRecord::Migration
  def up
    change_column :metrics_members_selections, :widget_id, :string
  end

  def down
    change_column :metrics_members_selections, :widget_id, :string
  end
end
