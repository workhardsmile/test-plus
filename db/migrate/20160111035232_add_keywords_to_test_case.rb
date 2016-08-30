class AddKeywordsToTestCase < ActiveRecord::Migration
  def change
    add_column :test_cases, :keywords, :string
  end
end
