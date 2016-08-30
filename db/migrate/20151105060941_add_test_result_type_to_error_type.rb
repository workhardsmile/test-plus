class AddTestResultTypeToErrorType < ActiveRecord::Migration
  def change
    add_column :error_types, :result_type, :string
  end
end
