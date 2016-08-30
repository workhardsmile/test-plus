class ExtractAbilityDefinitions < ActiveRecord::Migration

  def up

    begin

      if !table_exists?(:ability_definitions_roles)
        create_table :ability_definitions_roles, :id => false do |t|
          t.references :role
          t.references :ability_definition
        end

        add_index :ability_definitions_roles, :role_id, :name => "idx_adr_r"
        add_index :ability_definitions_roles, :ability_definition_id, :name => "idx_adr_ad"

        add_foreign_key :ability_definitions_roles, :roles, :name => "fk_adr_r"
        add_foreign_key :ability_definitions_roles, :ability_definitions, :name => "fk_adr_ad"
      else
        say "Table :ability_definitions_roles already exists."
      end

      if !table_exists?(:ability_definitions_users)
        create_table :ability_definitions_users do |t|
          t.references :user
          t.references :ability_definition
          t.references :project
        end

        add_index :ability_definitions_users, :user_id, :name => "idx_adu_u"
        add_index :ability_definitions_users, :ability_definition_id, :name => "idx_adu_ad"
        add_index :ability_definitions_users, :project_id, :name => "idx_adu_p"

        add_foreign_key :ability_definitions_users, :users, :name => "fk_adu_u"
        add_foreign_key :ability_definitions_users, :ability_definitions, :name => "fk_adu_ad"
        add_foreign_key :ability_definitions_users, :projects, :name => "fk_adu_p"
      else
        say "Table :ability_definitions_users already exists."
      end     

      change_table :ability_definitions do |t|
        t.remove :role_id
      end

      # Try to find out a role "admin". If it exists. then we're doing migrating and need do data migrating. Else ignore data.
      # This depends on model Role. If this model needs to be removed, re-write the process using SQL.
      admin = Role.find_by_name(:admin)
      if admin
        # migrate current data to new structure
        # create possible ability definitions at first
        say "Change table ability_definitions"
        AbilityDefinition.delete_all
        AbilityDefinition.reset_column_information
        say "Initiate abilities"
        resources = %w(CiMapping MailNotifySetting TestRound TestSuite TestPlan AutomationScript AutomationScriptResult AutomationCase AutomationCaseResult)
        abilities = %w(manage create update)
        abilities.each do |ability|
          resources.each do |resource|
            ability_definition = AbilityDefinition.new(:ability => ability, :resource => resource)
            ability_definition.save
          end
        end
                
        # assign appropriate ad to role
        # qa_manager get all manage abilities
        say "Assign appropriate ability_definitions to role"
        manager = Role.find_by_name(:qa_manager)
        manager.ability_definitions << AbilityDefinition.find_all_by_ability(:manage)
        manager.ability_definitions.flatten
        manager.save
        # qa_developer abilities
        developer = Role.find_by_name(:qa_developer)
        create_tr = AbilityDefinition.find_by_ability_and_resource(:create, :TestRound)
        update_ts = AbilityDefinition.find_by_ability_and_resource(:update, :TestSuite)
        update_asr = AbilityDefinition.find_by_ability_and_resource(:update, :AutomationScriptResult)
        developer.ability_definitions << [create_tr, update_ts, update_asr]
        developer.ability_definitions.flatten
        developer.save
        # qa abilities
        qa = Role.find_by_name(:qa)
        qa.ability_definitions << create_tr
        qa.ability_definitions.flatten
        qa.save

        # migrate data from user_abilitiy_definitions to ability_definitions_users
        execute <<-SQL
          INSERT INTO ability_definitions_users(user_id, ability_definition_id)
            SELECT uad.user_id, ad.id FROM user_ability_definitions uad
            INNER JOIN ability_definitions ad ON uad.ability=ad.ability AND uad.resource=ad.resource
        SQL
      end
      # Else no data needs to be migrated

    rescue => e
      puts e.inspect
      say "Error occurs. Deleting table :ability_definitions_users and :ability_definitions_roles. Reverting table :ability_definitions"
      down
      raise
    end

  end

  def down
    drop_table :ability_definitions_users if table_exists?(:ability_definitions_users)
    drop_table :ability_definitions_roles if table_exists?(:ability_definitions_roles)

    admin = Role.find_by_name(:admin)
    if admin 
      qa_manager_role = Role.find_by_name(:qa_manager)
      qa_developer_role = Role.find_by_name(:qa_developer)
      qa_role = Role.find_by_name(:qa)

      AbilityDefinition.delete_all
      change_table :ability_definitions do |t|
        t.references :role
      end
      add_index :ability_definitions, :role_id, :name => "idx_ad_r"
      AbilityDefinition.reset_column_information
      say "Reverting abilities for roles"
      %w(CiMapping MailNotifySetting TestRound TestSuite TestPlan AutomationScript AutomationScriptResult AutomationCase AutomationCaseResult).each do |resource|
        ad = AbilityDefinition.create
        ad.role_id = qa_manager_role.id
        ad.ability = :manage
        ad.resource = resource
        ad.save
      end

      ability_definition = AbilityDefinition.new do |ad|
        ad.role_id = qa_role.id
        ad.ability = :create
        ad.resource = 'TestRound'
      end 
      ability_definition.save

      ability_definition = AbilityDefinition.new do |ad|
        ad.role_id = qa_developer_role.id
        ad.ability = :create
        ad.resource = 'TestRound'
      end 
      ability_definition.save    

      ability_definition = AbilityDefinition.new do |ad|
        ad.role_id = qa_developer_role.id
        ad.ability = :update
        ad.resource = 'TestSuite'
      end
      ability_definition.save

      ability_definition = AbilityDefinition.new do |ad|
        ad.role_id = qa_developer_role.id
        ad.ability = :update
        ad.resource = 'AutomationScriptResult'
      end
      ability_definition.save
    end

    say "Reverting completed"
  end
end
