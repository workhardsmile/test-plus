class CreateRolesUsers < ActiveRecord::Migration
  def change
    create_table :roles_users, :id => false do |t|
      t.references :role
      t.references :user
    end

    add_index :roles_users, :role_id, :name => "idx_ru_r"
    add_index :roles_users, :user_id, :name => "idx_ru_u"

    add_foreign_key :roles_users, :users, :dependent => :delete, :name => "fk_ru_u"
    add_foreign_key :roles_users, :roles, :dependent => :delete, :name => "fk_ru_r"
  end
end
