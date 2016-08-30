class AddParameterAndBranchNameToTestRound < ActiveRecord::Migration
  def change
    add_column :test_rounds, :parameter, :string
    add_column :test_rounds, :branch_name, :string
  end
end
