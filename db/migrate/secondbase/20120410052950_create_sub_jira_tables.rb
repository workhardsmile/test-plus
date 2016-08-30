class CreateSubJiraTables < ActiveRecord::Migration
  ############################################################
  # Database migration targeting the SecondBase!
  # Generated using: rails generator secondbase:migration [MigrationName]
  
  def self.up
    create_table :jiraissue do |t|
      t.integer :id
      t.string :pkey
      t.integer :project
      t.string :issuetype
      t.datetime :created
      t.datetime :resolutiondate
      t.string :priority
      t.string :resolution
      t.string :issuestatus
      t.string :issuetype
    end
    
    create_table :priority do |t|
      t.string :id
      t.string :pname
    end

    create_table :resolution do |t|
      t.string :id
      t.string :pname
    end

    create_table :issuestatus do |t|
      t.string :id
      t.string :pname
    end

    create_table :issuetype do |t|
      t.string :id
      t.string :pname
    end

    create_table :customfieldvalue do |t|
      t.integer :id
      t.integer :issue
      t.integer :customfield
      t.string :stringvalue
      t.integer :numbervalue
    end

    create_table :customfieldoption do |t|
      t.integer :id
      t.string :customvalue
      t.integer :customfield
    end   

    create_table :worklog do |t|
      t.integer :id
      t.integer :issueid
      t.string :author
      t.datetime :startdate
      t.datetime :updated
      t.integer :timeworked
    end

    create_table :issuelink do |t|
      t.integer :id
      t.integer :linktype
      t.integer :source
      t.integer :destination
    end 

    create_table :nodeassociation do |t|
      t.integer :source_node_id
      t.integer :sink_node_id
      t.string :association_type
    end

    create_table :project do |t|
      t.integer :id
      t.string :pname
    end

    create_table :projectversion do |t|
      t.integer :id
      t.string :vname
    end

    create_table :changeitem do |t|
      t.integer :id
      t.string :change_field
      t.text :oldvalue
      t.text :newvalue
      t.text :oldstring
      t.text :newstring
      t.integer :groupid
    end

    create_table :changegroup do |t|
      t.integer :id
      t.integer :issueid
      t.string :author
      t.datetime :created
    end

    create_table :cwd_user do |t|
      t.integer :id
      t.string :user_name
      t.string :display_name
      t.string :credential
    end

    create_table :cwd_membership do |t|
      t.integer :id
      t.string :parent_name
    end
  end

  def self.down
    
  end
end
