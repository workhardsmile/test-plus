namespace :dash do

  desc "Init some user and project data"
  task :init_data => :environment do
    AbilityDefinition.delete_all
    ProjectsRolesUsers.delete_all
    ProjectsRoles.delete_all
    RolesUsers.delete_all
    Role.delete_all
    RolesUsers.delete_all
    AutomationCaseResult.delete_all
    AutomationCase.delete_all
    AutomationScriptResult.delete_all
    AutomationScript.delete_all
    TestCase.delete_all
    TestPlan.delete_all
    TestRound.delete_all
    TestSuite.delete_all
    SuiteSelection.delete_all
    TargetService.delete_all
    Project.delete_all
    ProjectCategory.delete_all
    User.delete_all
    TestType.delete_all
    TestEnvironment.delete_all
    AutomationDriver.delete_all
    Browser.delete_all
    Capability.delete_all
    CiMapping.delete_all
    JiraIssue.delete_all
    Machine.delete_all
    MailNotifySetting.delete_all
    ProjectCategory.delete_all
    RunTask.delete_all
    Slave.delete_all

    win = OperationSystem.find{|os| os.name == 'windows' and os.version == 'xp'}
    win ||= OperationSystem.create!(:name => 'windows', :version => 'xp')
    ie = Browser.find{|b| b.name == 'ie' and b.version == '6.0'}
    ie ||= Browser.create!(:name => 'ie', :version => '6.0')
    firefox = Browser.find{|b| b.name == 'firefox' and b.version == '3.5'}
    firefox ||= Browser.create!(:name => 'firefox', :version => '3.5')
    chrome = Browser.find{|b| b.name == 'chrome' and b.version == '17'}
    chrome ||= Browser.create!(:name => 'chrome', :version => '17')

    aw = ProjectCategory.new(:name => 'ActiveWorks')
    aw.save
    other = ProjectCategory.new(:name => 'Others')
    other.save

    TestType.create(:name => 'BVT').save
    TestType.create(:name => 'Regression').save

    TestEnvironment.create(:name => 'INT Latest', :value => 'INT').save
    TestEnvironment.create(:name => 'INT Released', :value => 'INTR').save
    TestEnvironment.create(:name => 'QA Latest', :value => 'QA').save
    TestEnvironment.create(:name => 'QA Regression', :value => 'QAR').save
    TestEnvironment.create(:name => 'QA Staging', :value => 'QAS').save
    TestEnvironment.create(:name => 'Platform INT', :value => 'PINT').save
    TestEnvironment.create(:name => 'Platform QA', :value => 'PQA').save

    admin_role = Role.create(:name => "admin")
    qa_manager_role = Role.create(:name => "qa_manager")
    qa_developer_role = Role.create(:name => "qa_developer")
    qa_role = Role.create(:name => "qa")

    admins = []
    qa_managers = []
    qa_developers = []
    qas = []

    admins << automator = { "email" => 'automator@testplus.com', "name" => 'TestPlus Automator' }
    admins << tyrael = { "email" => 'tyrael.tong@activenetwork.com', "name" => 'Tyrael Tong' }
    admins << chris = { "email" => 'chris.zhang@activenetwork.com', "name" => 'Chris Zhang' }
    admins << eric = { "email" => 'eric.yang@activenetwork.com', "name" => 'Eric Yang' }
    admins << leo = {"email" => 'leo.yin@active.com', "name" => 'Leo Yin'}

    qa_managers << smart = { "email" => 'smart.huang@activenetwork.com', "name" => 'Smart Huang' }
    qa_managers << jabco = { "email" => 'jabco.shen@activenetwork.com', "name" => 'Jabco Shen' }
    qa_managers << fiona = { "email" => 'fiona.zhou@activenetwork.com', "name" => 'Fiona Zhou' }

    qa_developers << tina = { "email" => 'tina.xu@activenetwork.com', "name" => 'Tina Xu' }
    qa_developers << sky = { "email" => 'sky.li@activenetwork.com', "name" => 'Sky Li' }
    qa_developers << justin = { "email" => 'justin.luo@activenetwork.com', "name" => 'Justin Luo' }
    qa_developers << evonne = { "email" => 'evonne.fu@activenetwork.com', "name" => 'Evonne Fu' }
    qa_developers << toby = { "email" => 'toby.tang@activenetwork.com', "name" => 'Toby tang' }
    qa_developers << randy = { "email" => 'randy.zhang@activenetwork.com', "name" => 'Randy Zhang' }
    qa_developers << james = { "email" => 'james.lv@activenetwork.com', "name" => 'James Lv' }

    qas << sophie = { "email" => 'sophie.du@activenetwork.com', "name" => 'Sophie Du' }

    role_hashes = Hash.new
    role_hashes["admin"] = admins
    role_hashes["qa_manager"] = qa_managers
    role_hashes["qa_developer"] = qa_developers
    role_hashes["qa"] = qas

    role_hashes.each do |k,v|
      role = Role.find_by_name(k)
      project_role = ProjectsRoles.new(:role_id => role.id, :project_id => nil)
      project_role.save
      v.each do |user|
        u = User.new(
          :email => user["email"],
          :display_name => user["name"],
          :password => "111111"
        )
        u.projects_roles << project_role
        # u.roles << role
        u.save
      end
    end

    resources = %w(CiMapping MailNotifySetting TestRound TestSuite TestPlan AutomationScript AutomationScriptResult AutomationCase AutomationCaseResult AutomationDriverConfig)
    abilities = %w(manage create update)
    abilities.each do |ability|
      resources.each do |resource|
        ability_definition = AbilityDefinition.new(:ability => ability, :resource => resource)
        ability_definition.save
      end
    end

    # qa_manager get all manage abilities
    qa_manager_role.ability_definitions << AbilityDefinition.find_all_by_ability(:manage)
    qa_manager_role.ability_definitions << AbilityDefinition.find_or_create_by_ability_and_resource(:update, :Project)
    qa_manager_role.ability_definitions << AbilityDefinition.find_or_create_by_ability_and_resource(:manage, :Slave)
    qa_manager_role.ability_definitions.flatten
    qa_manager_role.save
    # qa_developer abilities
    create_tr = AbilityDefinition.find_or_create_by_ability_and_resource(:create, :TestRound)
    manage_ts = AbilityDefinition.find_or_create_by_ability_and_resource(:manage, :TestSuite)
    update_asr = AbilityDefinition.find_or_create_by_ability_and_resource(:update, :AutomationScriptResult)
    qa_developer_role.ability_definitions << [create_tr, manage_ts, update_asr]
    qa_developer_role.ability_definitions.flatten
    qa_developer_role.save
    # qa abilities
    qa_role.ability_definitions << create_tr
    qa_role.ability_definitions.flatten
    qa_role.save

    smart = User.find_by_email("smart.huang@activenetwork.com")
    jabco = User.find_by_email("jabco.shen@activenetwork.com")
    fiona = User.find_by_email("fiona.zhou@activenetwork.com")

    camps = Project.create(
      :name => 'Camps',
      :leader => smart,
      :project_category => aw,
      :state => 'ongoing',
      :source_control_path => 'http://fndsvn.dev.activenetwork.com/camps',
      :icon_image_file_name => 'camps.png',
      :icon_image_content_type => 'image/png',
      :icon_image_file_size => 7763,
      :browsers => [ie, firefox, chrome],
      :operation_systems => [win],
      :display_order => 0
    ).save

    endurance = Project.create(
      :name => 'Endurance',
      :leader => jabco,
      :project_category => aw,
      :state => 'ongoing',
      :source_control_path => 'http://fndsvn.dev.activenetwork.com/endurance',
      :icon_image_file_name => 'endurance.png',
      :icon_image_content_type => 'image/png',
      :icon_image_file_size => 18857,
      :browsers => [ie, firefox, chrome],
      :operation_systems => [win],
      :display_order => 1
    ).save

    sports = Project.create(
      :name => 'Sports',
      :leader => fiona,
      :project_category => aw,
      :state => 'ongoing',
      :source_control_path => 'http://fndsvn.dev.activenetwork.com/sports',
      :icon_image_file_name => 'sports.png',
      :icon_image_content_type => 'image/png',
      :icon_image_file_size => 16291,
      :browsers => [ie, firefox, chrome],
      :operation_systems => [win],
      :display_order => 2
    ).save
  end

  desc "Delete duplicated data from dre report."
  task :delete_duplicated_data => :environment do
    Report::Project.all.each do |p|
      p.dres.each do |d|
        d.destroy unless p.dres.where(date: d.date).count == 1
      end

      p.bugs_by_severities.each do |bbs|
        bbs.destroy unless p.bugs_by_severities.where(date: bbs.date).count == 1
      end

      p.bugs_by_who_founds.each do |bbw|
        bbw.destroy unless p.bugs_by_who_founds.where(date: bbw.date).count == 1
      end

      p.technical_debts.each do |td|
        td.destroy unless p.technical_debts.where(date: td.date).count == 1
      end

      p.external_bugs_by_day_alls.each do |ebbda|
        ebbda.destroy unless p.external_bugs_by_day_alls.where(date: ebbda.date).count == 1
      end

      p.external_bugs_found_by_days.each do |ebbd|
        ebbd.destroy unless p.external_bugs_found_by_days.where(date: ebbd.date).count == 1
      end
    end
  end

  task :reset_specified_data , [:date] => :environment do |t, args|
    specified_date = args[:date]
    markets = ["Endurance","Camps","Sports","Swimming","Membership","Platform","Framework"]
    date = Date.strptime(specified_date,"%Y-%m-%d")
    markets.each do |m|
      pre = nil
      pre = Report::Project.where(name: m).first.bugs_by_who_founds.where(date: (date = date-1).strftime("%y-%m-%d")).first until pre
      if pre
        current = Report::Project.where(name: m).first.bugs_by_who_founds.where(date: specified_date).first
        current.closed_requirements = pre.closed_requirements
        current.external = pre.external
        current.internal = pre.internal
        current.save
      end
    end

  end

  task :delete_specified_data => :environment do
    specified_date = "2011-11-06"
    dres = []
    bugs_by_severities = []
    bugs_by_who_founds = []
    technical_debts = []
    external_bugs_by_day_alls = []
    external_bugs_found_by_days = []
    Report::Project.all.each do |p|
      p.dres.each do |d|
        dres << d if d.date.to_s == specified_date
      end

      p.bugs_by_severities.each do |bbs|
        bugs_by_severities << bbs if bbs.date.to_s == specified_date
      end

      p.bugs_by_who_founds.each do |bbw|
        bugs_by_who_founds << bbw if bbw.date.to_s == specified_date
      end

      p.technical_debts.each do |td|
        technical_debts << td if td.date.to_s == specified_date
      end

      p.external_bugs_by_day_alls.each do |ebbda|
        external_bugs_by_day_alls << ebbda if ebbda.date.to_s == specified_date
      end

      p.external_bugs_found_by_days.each do |ebbd|
        external_bugs_found_by_days << ebbd if ebbd.date.to_s == specified_date
      end
    end

    dres.each do |d|
      d.destroy
    end

    bugs_by_severities.each do |d|
      d.destroy
    end

    bugs_by_who_founds.each do |d|
      d.destroy
    end

    technical_debts.each do |d|
      d.destroy
    end

    external_bugs_by_day_alls.each do |d|
      d.destroy
    end

    external_bugs_found_by_days.each do |d|
      d.destroy
    end
  end

  desc "add initial mail notify groups"
  task :add_initial_mail_notify_groups => :environment do
    MailNotifyGroup.create(:name => 'test_round_finish')
    MailNotifyGroup.create(:name => 'test_round_triaged')
  end

  desc "adding NA QA users"
  task :add_NA_users => :environment do
    qa_managers = []
    qa_developers = []

    qa_managers << doreen = { "email" => 'Doreen.Xue@activenetwork.com'}
    qa_managers << justin = { "email" => 'Justin.Lakin@activenetwork.com'}
    qa_managers << karen = { "email" => 'Karen.Bishop@activenetwork.com'}
    qa_managers << adan = { "email" => 'adam.english@activenetwork.com'}
    qa_managers << huiping = { "email" => 'Huiping.Zheng@activenetwork.com'}

    qa_developers << rob = { "email" => 'Rob.Wallace@activenetwork.com'}
    qa_developers << michael = { "email" => 'Michael.Begley@activenetwork.com'}
    qa_developers << ophelia = { "email" => 'Ophelia.Chan@activenetwork.com'}

    role_hashes = Hash.new
    role_hashes["qa_manager"] = qa_managers
    role_hashes["qa_developer"] = qa_developers

    role_hashes.each do |k,v|
      role = Role.find_by_name(k)
      project_role = ProjectsRoles.find_by_role_id(role.id)
      v.each do |user|
        name = user["email"].split("@").first
        display_name = "#{name.split(".").first.capitalize} #{name.split(".").last.capitalize}"
        u = User.new(
          :email => user["email"],
          :display_name => display_name,
          :password => "111111"
        )
        u.projects_roles << project_role
        # u.roles << role
        u.save
      end
    end
  end


  # Matrix of automation script results
  # *Test Result *Script Status    *State Result   *Triage  *Error Type
  # PASS         Completed         done            Pass    N/A
  # PASS         Completed         done            Pass    Framework Issue
  # PASS         Completed         done            Pass    Dynamic Issue
  # PASS         Completed         done            Pass    Environment Issue
  # PASS         Completed         done            Pass    Product Change
  # PASS         Completed         done            Pass    Data Issue
  # PASS         Completed         done            Pass    Script Issue
  # FAILED       Completed         done            Failed  Product Error
  # FAILED       Completed         done            Failed  N/A
  # N/A          Known Bug         not implemented Failed  Not Ready
  # N/A          Test Data Issue   not implemented Failed  Not Ready
  # N/A          Work In Progress  not implemented Failed  Not Ready
  # N/A          Disabled          not implemented Failed  Not Ready
  # N/A          Completed         not implemented Failed  Not in Branch
  desc "initial error_type of triage result"
  task :init_error_type=> :environment do
    ErrorType.delete_all

    ErrorType.create(:name=> "Framework Issue", :result_type => "pass").save
    ErrorType.create(:name=> "Dynamic Issue", :result_type => "pass").save
    ErrorType.create(:name=> "Environment Error", :result_type => "pass").save
    ErrorType.create(:name=> "Product Change", :result_type => "pass").save
    ErrorType.create(:name=> "Data Issue", :result_type => "pass").save
    ErrorType.create(:name=> "Script Issue", :result_type => "pass").save

    ErrorType.create(:name=> "Product Error", :result_type => "failed").save

    ErrorType.create(:name=> "Not in Branch", :result_type => 'N/A').save
    ErrorType.create(:name=> "Not Ready", :result_type => 'N/A').save
  end


end
