class EnhanceProjectToRole < ActiveRecord::Migration

  def up

    begin
      if !table_exists?(:projects_roles)
        create_table :projects_roles do |t|
          t.references :project
          t.references :role
        end

        add_index :projects_roles, :project_id, :name => "idx_pr_p"
        add_index :projects_roles, :role_id, :name => "idx_pr_r"

        add_foreign_key :projects_roles, :projects, :name => "fk_pr_p"
        add_foreign_key :projects_roles, :roles, :name => "fk_pr_r"
      else
        say "Table :projects_roles already exists."
      end

      if !table_exists?(:projects_roles_users)
        create_table :projects_roles_users, :id => false do |t|
          t.references :user
          t.integer :projects_roles_id
        end

        add_index :projects_roles_users, :user_id, :name => "idx_pru_u"
        add_index :projects_roles_users, :projects_roles_id, :name => "idx_pru_pr"

        add_foreign_key :projects_roles_users, :users, :name => "fk_pru_u"
        add_foreign_key :projects_roles_users, :projects_roles, :column => "projects_roles_id", :name => "fk_pru_pr"
      else
        say "Table :projects_roles_users already exists."
      end

      # create project_role for role and using nil as project 
      execute <<-SQL
        DELETE FROM projects_roles_users
      SQL

      execute <<-SQL
        INSERT INTO projects_roles(role_id)
          SELECT DISTINCT(role_id) FROM roles_users
      SQL

      execute <<-SQL
        INSERT INTO projects_roles_users(user_id, projects_roles_id)
          SELECT ru.user_id, pr.id FROM roles_users ru
            INNER JOIN projects_roles pr ON ru.role_id = pr.role_id      
      SQL

      # todo: delete table/model: roles_users

    rescue
      say "Error occurs. Deleting table :projects_roles_users and :projects_roles."
      down
      raise
    end

  end

  def down

    drop_table :projects_roles_users if table_exists?(:projects_roles_users)
    drop_table :projects_roles if table_exists?(:projects_roles)

  end 

end
