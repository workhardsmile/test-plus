class AddNoteToAutomationScript < ActiveRecord::Migration
  def change
    add_column :automation_scripts, :note, :text
  end
end
