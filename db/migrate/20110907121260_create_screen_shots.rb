class CreateScreenShots < ActiveRecord::Migration
  def change
    create_table :screen_shots do |t|
      t.string :screen_shot_file_name
      t.string :screen_shot_content_type
      t.integer :screen_shot_file_size

      t.references :automation_case_result

      t.timestamps
    end
    add_foreign_key :screen_shots, :automation_case_results, :dependent => :delete, :name => "fk_ss_acr"
  end
end
