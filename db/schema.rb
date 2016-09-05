# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20160901110005) do

  create_table "ability_definitions", :force => true do |t|
    t.string   "ability"
    t.string   "resource"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "ability_definitions_roles", :id => false, :force => true do |t|
    t.integer "role_id"
    t.integer "ability_definition_id"
  end

  add_index "ability_definitions_roles", ["ability_definition_id"], :name => "idx_adr_ad"
  add_index "ability_definitions_roles", ["role_id"], :name => "idx_adr_r"

  create_table "ability_definitions_users", :force => true do |t|
    t.integer "user_id"
    t.integer "ability_definition_id"
    t.integer "project_id"
  end

  add_index "ability_definitions_users", ["ability_definition_id"], :name => "idx_adu_ad"
  add_index "ability_definitions_users", ["project_id"], :name => "idx_adu_p"
  add_index "ability_definitions_users", ["user_id"], :name => "idx_adu_u"

  create_table "activities", :force => true do |t|
    t.text     "content"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "audits", :force => true do |t|
    t.integer  "auditable_id"
    t.string   "auditable_type"
    t.integer  "associated_id"
    t.string   "associated_type"
    t.integer  "user_id"
    t.string   "user_type"
    t.string   "username"
    t.string   "action"
    t.text     "audited_changes"
    t.integer  "version",         :default => 0
    t.string   "comment"
    t.string   "remote_address"
    t.datetime "created_at"
  end

  add_index "audits", ["associated_id", "associated_type"], :name => "associated_index"
  add_index "audits", ["auditable_id", "auditable_type"], :name => "auditable_index"
  add_index "audits", ["created_at"], :name => "index_audits_on_created_at"
  add_index "audits", ["user_id", "user_type"], :name => "user_index"

  create_table "automation_case_results", :force => true do |t|
    t.string   "result"
    t.text     "error_message"
    t.text     "screen_shot"
    t.string   "priority"
    t.integer  "automation_case_id"
    t.integer  "automation_script_result_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "server_log"
    t.string   "triage_result",               :default => "N/A"
  end

  add_index "automation_case_results", ["automation_case_id"], :name => "index_automation_case_results_on_automation_case_id"
  add_index "automation_case_results", ["automation_script_result_id"], :name => "index_automation_case_results_on_automation_script_result_id"

  create_table "automation_cases", :force => true do |t|
    t.string   "name"
    t.string   "case_id"
    t.string   "version"
    t.string   "priority"
    t.integer  "automation_script_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "automation_cases", ["automation_script_id"], :name => "index_automation_cases_on_automation_script_id"
  add_index "automation_cases", ["case_id"], :name => "index_automation_cases_on_case_id"

  create_table "automation_driver_configs", :force => true do |t|
    t.integer  "project_id"
    t.integer  "automation_driver_id"
    t.string   "name"
    t.string   "source_control"
    t.text     "extra_parameters"
    t.text     "source_paths"
    t.text     "script_main_path"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "sc_username"
    t.string   "sc_password"
  end

  add_index "automation_driver_configs", ["automation_driver_id"], :name => "index_automation_driver_configs_on_automation_driver_id"
  add_index "automation_driver_configs", ["project_id"], :name => "index_automation_driver_configs_on_project_id"

  create_table "automation_drivers", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "version"
  end

  create_table "automation_progresses", :force => true do |t|
    t.integer  "project_id"
    t.date     "record_date"
    t.integer  "total_case"
    t.integer  "total_automated"
    t.integer  "not_candidate"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "automatable",     :default => 0
    t.integer  "not_ready",       :default => 0
    t.integer  "update_manual",   :default => 0
    t.integer  "update_needed",   :default => 0
  end

  create_table "automation_script_results", :force => true do |t|
    t.string   "state"
    t.integer  "pass"
    t.integer  "failed"
    t.integer  "warning"
    t.integer  "not_run"
    t.string   "result"
    t.datetime "start_time"
    t.datetime "end_time"
    t.integer  "test_round_id"
    t.integer  "automation_script_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "triage_result"
    t.integer  "error_type_id"
    t.integer  "counter",              :default => 0
  end

  add_index "automation_script_results", ["automation_script_id"], :name => "index_automation_script_results_on_automation_script_id"
  add_index "automation_script_results", ["test_round_id"], :name => "index_automation_script_results_on_test_round_id"

  create_table "automation_scripts", :force => true do |t|
    t.string   "name"
    t.string   "status"
    t.string   "version"
    t.integer  "test_plan_id"
    t.integer  "owner_id"
    t.integer  "project_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "time_out_limit"
    t.integer  "automation_driver_config_id"
    t.text     "note"
  end

  add_index "automation_scripts", ["automation_driver_config_id"], :name => "index_automation_scripts_on_automation_driver_config_id"
  add_index "automation_scripts", ["project_id"], :name => "index_automation_scripts_on_project_id"
  add_index "automation_scripts", ["test_plan_id"], :name => "index_automation_scripts_on_test_plan_id"

  create_table "base_case_results", :force => true do |t|
    t.string   "automation_case_display_id"
    t.string   "case_name"
    t.string   "test_result"
    t.text     "triage_result"
    t.text     "error_message"
    t.integer  "automation_case_result_id"
    t.integer  "base_script_result_id"
    t.datetime "created_at",                 :null => false
    t.datetime "updated_at",                 :null => false
  end

  add_index "base_case_results", ["automation_case_display_id", "case_name"], :name => "idx_case_id_name_1"

  create_table "base_script_results", :force => true do |t|
    t.string   "automation_script_name"
    t.string   "environment"
    t.string   "browser"
    t.integer  "test_round_id"
    t.string   "test_result"
    t.text     "triage_result"
    t.string   "os_type"
    t.datetime "start_time"
    t.datetime "end_time"
    t.integer  "project_id"
    t.datetime "created_at",             :null => false
    t.datetime "updated_at",             :null => false
    t.integer  "pass_count"
    t.integer  "failed_count"
    t.integer  "warning_count"
    t.integer  "not_run_count"
    t.integer  "is_latest"
  end

  add_index "base_script_results", ["automation_script_name"], :name => "idx_bsr_name_1"
  add_index "base_script_results", ["browser"], :name => "idx_bsr_browser_1"
  add_index "base_script_results", ["environment"], :name => "idx_bsr_env_1"

  create_table "browsers", :force => true do |t|
    t.string   "name"
    t.string   "version"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "capabilities", :force => true do |t|
    t.string   "name"
    t.string   "version"
    t.integer  "slave_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "capabilities", ["slave_id"], :name => "index_capabilities_on_slave_id"

  create_table "changegroup", :force => true do |t|
    t.integer  "issueid"
    t.string   "author"
    t.datetime "created"
  end

  create_table "changeitem", :force => true do |t|
    t.string  "change_field"
    t.text    "oldvalue"
    t.text    "newvalue"
    t.text    "oldstring"
    t.text    "newstring"
    t.integer "groupid"
  end

  create_table "ci_mappings", :force => true do |t|
    t.integer  "project_id"
    t.integer  "test_suite_id"
    t.string   "ci_value"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "browser_id"
    t.integer  "operation_system_id"
  end

  add_index "ci_mappings", ["project_id"], :name => "index_ci_mappings_on_project_id"
  add_index "ci_mappings", ["test_suite_id"], :name => "index_ci_mappings_on_test_suite_id"

  create_table "customfieldoption", :force => true do |t|
    t.string  "customvalue"
    t.integer "customfield"
  end

  create_table "customfieldvalue", :force => true do |t|
    t.integer "issue"
    t.integer "customfield"
    t.string  "stringvalue"
    t.integer "numbervalue"
  end

  create_table "cwd_membership", :force => true do |t|
    t.string "parent_name"
  end

  create_table "cwd_user", :force => true do |t|
    t.string "user_name"
    t.string "display_name"
    t.string "credential"
  end

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",    :default => 0
    t.integer  "attempts",    :default => 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "period"
    t.string   "at"
    t.datetime "last_run_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], :name => "delayed_jobs_priority"

  create_table "error_types", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "result_type"
  end

  create_table "fnd_jira_issues", :force => true do |t|
    t.string   "key"
    t.string   "status"
    t.string   "resolution"
    t.datetime "jira_created"
    t.datetime "jira_resolved"
    t.string   "priority"
    t.string   "severity"
    t.string   "issue_type"
    t.string   "environment_bug_was_found"
    t.string   "who_found"
    t.string   "market"
    t.integer  "planning_estimate_level_two"
    t.string   "components"
    t.string   "known_production_issue"
    t.datetime "created_at",                  :null => false
    t.datetime "updated_at",                  :null => false
    t.string   "summary"
  end

  create_table "import_testlink_configs", :force => true do |t|
    t.string   "testplus_project"
    t.string   "testlink_project"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "active",           :default => true
  end

  create_table "issue_automation_scripts", :force => true do |t|
    t.integer  "issue_id"
    t.integer  "project_id"
    t.string   "automation_script_name"
    t.string   "found_case_id"
    t.string   "found_environment"
    t.string   "found_browser"
    t.string   "found_os_type"
    t.datetime "created_at",             :null => false
    t.datetime "updated_at",             :null => false
  end

  add_index "issue_automation_scripts", ["automation_script_name"], :name => "idx_ias_script_1"
  add_index "issue_automation_scripts", ["found_browser"], :name => "idx_ias_browser_1"
  add_index "issue_automation_scripts", ["found_case_id"], :name => "idx_ias_case_id_1"
  add_index "issue_automation_scripts", ["found_environment"], :name => "idx_ias_env_1"
  add_index "issue_automation_scripts", ["found_os_type"], :name => "idx_ias_os_1"

  create_table "issuelink", :force => true do |t|
    t.integer "linktype"
    t.integer "source"
    t.integer "destination"
  end

  create_table "issues", :force => true do |t|
    t.integer  "project_id"
    t.string   "issue_display_id"
    t.string   "issue_summary"
    t.string   "issue_url"
    t.string   "reporter"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

  add_index "issues", ["issue_display_id"], :name => "idx_issue_id_1"

  create_table "issuestatus", :force => true do |t|
    t.string "pname"
  end

  create_table "issuetype", :force => true do |t|
    t.string "pname"
  end

  create_table "jira_issues", :force => true do |t|
    t.string   "key"
    t.string   "status"
    t.string   "resolution"
    t.datetime "jira_created"
    t.datetime "jira_resolved"
    t.string   "priority"
    t.string   "severity"
    t.string   "issue_type"
    t.string   "environment_bug_was_found"
    t.string   "who_found"
    t.string   "market"
    t.integer  "planning_estimate_level_two"
    t.string   "components"
    t.string   "known_production_issue"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "jiraissue", :force => true do |t|
    t.string   "pkey"
    t.integer  "project"
    t.string   "issuetype"
    t.datetime "created"
    t.datetime "resolutiondate"
    t.string   "priority"
    t.string   "resolution"
    t.string   "issuestatus"
    t.string   "summary"
  end

  create_table "machines", :force => true do |t|
    t.string   "name"
    t.string   "os_name"
    t.string   "os_version"
    t.integer  "slave_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "machines", ["slave_id"], :name => "index_machines_on_slave_id"

  create_table "mail_notify_groups", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "mail_notify_groups_mail_notify_settings", :id => false, :force => true do |t|
    t.integer  "mail_notify_setting_id"
    t.integer  "mail_notify_group_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "mail_notify_groups_mail_notify_settings", ["mail_notify_group_id"], :name => "index_mng_on_mns"
  add_index "mail_notify_groups_mail_notify_settings", ["mail_notify_setting_id"], :name => "index_mns_on_mng"

  create_table "mail_notify_settings", :force => true do |t|
    t.string   "mail"
    t.integer  "project_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "mail_notify_settings", ["project_id"], :name => "index_mail_notify_settings_on_project_id"

  create_table "mail_notify_settings_test_types", :id => false, :force => true do |t|
    t.integer  "mail_notify_setting_id"
    t.integer  "test_type_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "mail_notify_settings_test_types", ["mail_notify_setting_id"], :name => "idx_mnstt_on_mns"
  add_index "mail_notify_settings_test_types", ["test_type_id"], :name => "idx_mnstt_on_tt"

  create_table "metrics_members_selections", :force => true do |t|
    t.string  "widget_id"
    t.integer "team_member_id"
  end

  add_index "metrics_members_selections", ["team_member_id"], :name => "fk_mms_tm"

  create_table "nodeassociation", :force => true do |t|
    t.integer "source_node_id"
    t.integer "sink_node_id"
    t.string  "association_type"
  end

  create_table "offer_monitoring_records", :force => true do |t|
    t.datetime "timestamp"
    t.string   "market"
    t.string   "user_email"
    t.string   "order_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "offer_reports", :force => true do |t|
    t.datetime "timestamp"
    t.string   "market"
    t.string   "offer_type"
    t.string   "result"
    t.integer  "test_round_id"
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "operation_system_infos", :force => true do |t|
    t.string   "name"
    t.string   "version"
    t.integer  "slave_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "operation_system_infos", ["slave_id"], :name => "index_operation_system_infos_on_slave_id"

  create_table "operation_systems", :force => true do |t|
    t.string   "name"
    t.string   "version"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "oracle_project_permissions", :force => true do |t|
    t.integer  "user_id"
    t.integer  "oracle_project_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "oracle_project_permissions", ["oracle_project_id"], :name => "index_oracle_project_permissions_on_oracle_project_id"
  add_index "oracle_project_permissions", ["user_id"], :name => "index_oracle_project_permissions_on_user_id"

  create_table "oracle_projects", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "priority", :force => true do |t|
    t.string "pname"
  end

  create_table "project", :force => true do |t|
    t.string "pname"
  end

  create_table "project_branch_scripts", :force => true do |t|
    t.integer  "project_id"
    t.string   "automation_script_name"
    t.string   "branch_name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "project_browser_configs", :force => true do |t|
    t.integer  "project_id"
    t.integer  "browser_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "project_browser_configs", ["browser_id"], :name => "idx_pbc_b"
  add_index "project_browser_configs", ["project_id"], :name => "idx_pbc_p"

  create_table "project_categories", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "project_operation_system_configs", :force => true do |t|
    t.integer  "project_id"
    t.integer  "operation_system_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "project_operation_system_configs", ["operation_system_id"], :name => "idx_posc_os"
  add_index "project_operation_system_configs", ["project_id"], :name => "idx_posc_p"

  create_table "project_test_environment_configs", :force => true do |t|
    t.integer  "project_id"
    t.integer  "test_environment_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "project_test_environment_configs", ["project_id"], :name => "idx_pec_p"
  add_index "project_test_environment_configs", ["test_environment_id"], :name => "idx_pec_e"

  create_table "projects", :force => true do |t|
    t.string   "name"
    t.integer  "leader_id"
    t.integer  "project_category_id"
    t.string   "source_control_path"
    t.string   "icon_image_file_name"
    t.string   "icon_image_content_type"
    t.integer  "icon_image_file_size"
    t.string   "state"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "display_order"
    t.string   "test_link_name"
    t.boolean  "monitor_flag",            :default => false
    t.string   "testplus_name"
    t.string   "dashboard_name"
  end

  add_index "projects", ["leader_id"], :name => "index_projects_on_leader_id"
  add_index "projects", ["project_category_id"], :name => "index_projects_on_project_category_id"

  create_table "projects_roles", :force => true do |t|
    t.integer "project_id"
    t.integer "role_id"
  end

  add_index "projects_roles", ["project_id"], :name => "idx_pr_p"
  add_index "projects_roles", ["role_id"], :name => "idx_pr_r"

  create_table "projects_roles_users", :id => false, :force => true do |t|
    t.integer "user_id"
    t.integer "projects_roles_id"
  end

  add_index "projects_roles_users", ["projects_roles_id"], :name => "idx_pru_pr"
  add_index "projects_roles_users", ["user_id"], :name => "idx_pru_u"

  create_table "projectversion", :force => true do |t|
    t.string "vname"
  end

  create_table "resolution", :force => true do |t|
    t.string "pname"
  end

  create_table "roles", :force => true do |t|
    t.string "name"
  end

  create_table "roles_users", :id => false, :force => true do |t|
    t.integer "role_id"
    t.integer "user_id"
  end

  add_index "roles_users", ["role_id"], :name => "index_roles_users_on_role_id"
  add_index "roles_users", ["user_id"], :name => "index_roles_users_on_user_id"

  create_table "run_tasks", :force => true do |t|
    t.string   "command"
    t.string   "priority"
    t.string   "status"
    t.string   "project"
    t.string   "capability"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "screen_shots", :force => true do |t|
    t.string   "screen_shot_file_name"
    t.string   "screen_shot_content_type"
    t.integer  "screen_shot_file_size"
    t.integer  "automation_case_result_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "screen_shots", ["automation_case_result_id"], :name => "screen_shots_automation_case_result_id_fk"

  create_table "service_project_mappings", :force => true do |t|
    t.string   "service_name"
    t.string   "project_mapping_name"
    t.integer  "project_id"
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
    t.boolean  "active",               :default => true
  end

  create_table "service_trigger_records", :force => true do |t|
    t.string   "project_mapping_name"
    t.integer  "project_id"
    t.integer  "test_round_id"
    t.string   "status"
    t.datetime "created_at",           :null => false
    t.datetime "updated_at",           :null => false
    t.string   "test_environment"
    t.integer  "test_suite_id"
  end

  create_table "slave_assignments", :force => true do |t|
    t.integer  "automation_script_result_id"
    t.integer  "slave_id"
    t.string   "status"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "browser_name"
    t.string   "browser_version"
    t.string   "operation_system_name"
    t.string   "operation_system_version"
  end

  add_index "slave_assignments", ["automation_script_result_id"], :name => "index_slave_assignments_on_automation_script_result_id"
  add_index "slave_assignments", ["slave_id"], :name => "index_slave_assignments_on_slave_id"

  create_table "slaves", :force => true do |t|
    t.string   "name"
    t.string   "ip_address"
    t.string   "project_name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "status"
    t.string   "test_type",    :default => "*"
    t.integer  "priority",     :default => 10
    t.boolean  "active",       :default => true
  end

  create_table "suite_selections", :id => false, :force => true do |t|
    t.integer  "test_suite_id"
    t.integer  "automation_script_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "suite_selections", ["automation_script_id"], :name => "index_suite_selections_on_automation_script_id"
  add_index "suite_selections", ["test_suite_id"], :name => "index_suite_selections_on_test_suite_id"

  create_table "taggings", :force => true do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.string   "taggable_type"
    t.integer  "tagger_id"
    t.string   "tagger_type"
    t.string   "context",       :limit => 128
    t.datetime "created_at"
  end

  add_index "taggings", ["tag_id", "taggable_id", "taggable_type", "context", "tagger_id", "tagger_type"], :name => "taggings_idx", :unique => true
  add_index "taggings", ["taggable_id", "taggable_type", "context"], :name => "index_taggings_on_taggable_id_and_taggable_type_and_context"

  create_table "tags", :force => true do |t|
    t.string  "name"
    t.integer "taggings_count", :default => 0
  end

  add_index "tags", ["name"], :name => "index_tags_on_name", :unique => true

  create_table "target_services", :force => true do |t|
    t.string   "name"
    t.string   "version"
    t.integer  "automation_script_result_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "target_services", ["automation_script_result_id"], :name => "index_target_services_on_automation_script_result_id"

  create_table "tc_steps", :force => true do |t|
    t.integer  "step_number"
    t.text     "step_action"
    t.text     "expected_result"
    t.integer  "test_case_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "test_link_id"
  end

  add_index "tc_steps", ["test_case_id"], :name => "tc_steps_test_case_id_fk"

  create_table "team_members", :force => true do |t|
    t.string   "name"
    t.string   "display_name"
    t.string   "email"
    t.string   "cc_list"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "manager"
    t.string   "location"
    t.string   "country"
    t.string   "project"
    t.string   "position"
    t.date     "start_date"
    t.date     "turn_date"
  end

  create_table "temp_schedule_scripts", :force => true do |t|
    t.string  "platform"
    t.string  "ip"
    t.integer "test_round_id"
    t.integer "script_result_id"
    t.integer "timeout_limit"
    t.string  "script_name"
    t.string  "project_name"
    t.string  "branch_name"
    t.string  "source_path"
    t.string  "source_cmd"
    t.string  "exec_path"
    t.string  "exec_cmd"
    t.string  "env_name"
    t.boolean "deleted",          :default => false
  end

  create_table "test_cases", :force => true do |t|
    t.string   "name"
    t.string   "case_id"
    t.string   "version"
    t.string   "automated_status"
    t.string   "priority"
    t.integer  "test_plan_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "test_link_id"
    t.string   "keywords"
  end

  add_index "test_cases", ["case_id"], :name => "index_test_cases_on_case_id"
  add_index "test_cases", ["test_plan_id"], :name => "index_test_cases_on_test_plan_id"

  create_table "test_environments", :force => true do |t|
    t.string   "name"
    t.string   "value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "test_plans", :force => true do |t|
    t.string   "name"
    t.string   "status"
    t.string   "version"
    t.integer  "project_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "plan_type"
  end

  add_index "test_plans", ["project_id"], :name => "index_test_plans_on_project_id"

  create_table "test_rounds", :force => true do |t|
    t.datetime "start_time"
    t.datetime "end_time"
    t.string   "state"
    t.string   "result"
    t.string   "test_object"
    t.integer  "pass"
    t.integer  "warning"
    t.integer  "failed"
    t.integer  "not_run"
    t.float    "pass_rate"
    t.integer  "duration"
    t.integer  "test_environment_id"
    t.integer  "project_id"
    t.integer  "creator_id"
    t.integer  "test_suite_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "browser_id"
    t.integer  "operation_system_id"
    t.string   "exported_status",     :default => "N"
    t.integer  "assigned_slave_id",   :default => 0,   :null => false
    t.string   "parameter"
    t.string   "branch_name"
    t.integer  "counter",             :default => 1
  end

  add_index "test_rounds", ["browser_id"], :name => "idx_tr_b"
  add_index "test_rounds", ["creator_id"], :name => "index_test_rounds_on_creator_id"
  add_index "test_rounds", ["operation_system_id"], :name => "idx_tr_os"
  add_index "test_rounds", ["project_id"], :name => "index_test_rounds_on_project_id"
  add_index "test_rounds", ["test_environment_id"], :name => "index_test_rounds_on_test_environment_id"
  add_index "test_rounds", ["test_suite_id"], :name => "index_test_rounds_on_test_suite_id"

  create_table "test_suites", :force => true do |t|
    t.string   "name"
    t.string   "status"
    t.integer  "project_id"
    t.integer  "creator_id"
    t.integer  "test_type_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "test_suites", ["project_id"], :name => "index_test_suites_on_project_id"
  add_index "test_suites", ["test_type_id"], :name => "index_test_suites_on_test_type_id"

  create_table "test_types", :force => true do |t|
    t.string "name"
  end

  create_table "time_card_audit_logs", :force => true do |t|
    t.integer  "week"
    t.integer  "year"
    t.float    "time_card_needed"
    t.float    "time_card_actual"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "time_cards", :force => true do |t|
    t.date     "from"
    t.date     "to"
    t.string   "name"
    t.integer  "time_working"
    t.integer  "time_submitted"
    t.integer  "time_approved"
    t.integer  "time_rejected"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "week"
  end

  create_table "user_ability_definitions", :force => true do |t|
    t.integer  "user_id"
    t.string   "ability"
    t.string   "resource"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "user_ability_definitions", ["user_id"], :name => "index_user_ability_definitions_on_user_id"

  create_table "users", :force => true do |t|
    t.string   "email",                               :default => "",   :null => false
    t.string   "encrypted_password",   :limit => 128, :default => "",   :null => false
    t.string   "reset_password_token"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                       :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "display_name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "active",                              :default => true
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

  create_table "worklog", :force => true do |t|
    t.integer  "issueid"
    t.string   "author"
    t.datetime "startdate"
    t.datetime "updated"
    t.integer  "timeworked"
  end

  add_foreign_key "ability_definitions_roles", "ability_definitions", :name => "fk_adr_ad"
  add_foreign_key "ability_definitions_roles", "roles", :name => "fk_adr_r"

  add_foreign_key "ability_definitions_users", "ability_definitions", :name => "fk_adu_ad"
  add_foreign_key "ability_definitions_users", "projects", :name => "fk_adu_p"
  add_foreign_key "ability_definitions_users", "users", :name => "fk_adu_u"

  add_foreign_key "automation_case_results", "automation_cases", :name => "automation_case_results_automation_case_id_fk", :dependent => :delete
  add_foreign_key "automation_case_results", "automation_script_results", :name => "automation_case_results_automation_script_result_id_fk", :dependent => :delete

  add_foreign_key "automation_cases", "automation_scripts", :name => "automation_cases_automation_script_id_fk", :dependent => :delete

  add_foreign_key "automation_driver_configs", "automation_drivers", :name => "fk_adc_ad", :dependent => :delete
  add_foreign_key "automation_driver_configs", "projects", :name => "fk_adc_p", :dependent => :delete

  add_foreign_key "automation_script_results", "automation_scripts", :name => "automation_script_results_automation_script_id_fk", :dependent => :delete
  add_foreign_key "automation_script_results", "test_rounds", :name => "automation_script_results_test_round_id_fk", :dependent => :delete

  add_foreign_key "automation_scripts", "projects", :name => "automation_scripts_project_id_fk", :dependent => :delete
  add_foreign_key "automation_scripts", "test_plans", :name => "automation_scripts_test_plan_id_fk", :dependent => :delete

  add_foreign_key "capabilities", "slaves", :name => "capabilities_slave_id_fk", :dependent => :delete

  add_foreign_key "ci_mappings", "projects", :name => "ci_mappings_project_id_fk", :dependent => :delete
  add_foreign_key "ci_mappings", "test_suites", :name => "ci_mappings_test_suite_id_fk", :dependent => :delete

  add_foreign_key "machines", "slaves", :name => "machines_slave_id_fk", :dependent => :delete

  add_foreign_key "mail_notify_groups_mail_notify_settings", "mail_notify_groups", :name => "fk_mngms_on_mng", :dependent => :delete
  add_foreign_key "mail_notify_groups_mail_notify_settings", "mail_notify_settings", :name => "fk_mngmns_on_mns", :dependent => :delete

  add_foreign_key "mail_notify_settings", "projects", :name => "mail_notify_settings_project_id_fk", :dependent => :delete

  add_foreign_key "mail_notify_settings_test_types", "mail_notify_settings", :name => "fk_mnstt_on_mns", :dependent => :delete
  add_foreign_key "mail_notify_settings_test_types", "test_types", :name => "fk_mnstt_on_tt", :dependent => :delete

  add_foreign_key "metrics_members_selections", "team_members", :name => "fk_mms_tm", :dependent => :delete

  add_foreign_key "operation_system_infos", "slaves", :name => "operation_system_infos_slave_id_fk", :dependent => :delete

  add_foreign_key "projects", "project_categories", :name => "projects_project_category_id_fk", :dependent => :delete
  add_foreign_key "projects", "users", :name => "projects_leader_id_fk", :column => "leader_id"

  add_foreign_key "projects_roles", "projects", :name => "fk_pr_p"
  add_foreign_key "projects_roles", "roles", :name => "fk_pr_r"

  add_foreign_key "projects_roles_users", "projects_roles", :name => "fk_pru_pr", :column => "projects_roles_id"
  add_foreign_key "projects_roles_users", "users", :name => "fk_pru_u"

  add_foreign_key "roles_users", "roles", :name => "roles_users_role_id_fk", :dependent => :delete
  add_foreign_key "roles_users", "users", :name => "roles_users_user_id_fk", :dependent => :delete

  add_foreign_key "screen_shots", "automation_case_results", :name => "screen_shots_automation_case_result_id_fk", :dependent => :delete

  add_foreign_key "slave_assignments", "automation_script_results", :name => "slave_assignments_automation_script_result_id_fk", :dependent => :delete
  add_foreign_key "slave_assignments", "slaves", :name => "slave_assignments_slave_id_fk", :dependent => :delete

  add_foreign_key "suite_selections", "automation_scripts", :name => "suite_selections_automation_script_id_fk", :dependent => :delete
  add_foreign_key "suite_selections", "test_suites", :name => "suite_selections_test_suite_id_fk", :dependent => :delete

  add_foreign_key "target_services", "automation_script_results", :name => "target_services_automation_script_result_id_fk", :dependent => :delete

  add_foreign_key "tc_steps", "test_cases", :name => "tc_steps_test_case_id_fk", :dependent => :delete

  add_foreign_key "test_cases", "test_plans", :name => "fk_tc_tp", :dependent => :delete
  add_foreign_key "test_cases", "test_plans", :name => "test_cases_test_plan_id_fk", :dependent => :delete

  add_foreign_key "test_plans", "projects", :name => "test_plans_project_id_fk", :dependent => :delete

  add_foreign_key "test_rounds", "browsers", :name => "fk_tr_b", :dependent => :delete
  add_foreign_key "test_rounds", "operation_systems", :name => "fk_tr_os", :dependent => :delete
  add_foreign_key "test_rounds", "projects", :name => "test_rounds_project_id_fk", :dependent => :delete
  add_foreign_key "test_rounds", "test_environments", :name => "test_rounds_test_environment_id_fk", :dependent => :delete
  add_foreign_key "test_rounds", "test_suites", :name => "test_rounds_test_suite_id_fk", :dependent => :delete

  add_foreign_key "test_suites", "projects", :name => "test_suites_project_id_fk", :dependent => :delete
  add_foreign_key "test_suites", "test_types", :name => "test_suites_test_type_id_fk", :dependent => :delete

end
