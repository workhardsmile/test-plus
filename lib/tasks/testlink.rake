class TestLinkProject < ActiveRecord::Base
  set_table_name "old_projects"
  has_many :old_test_plans
end

class TestLinkPlan < ActiveRecord::Base
  set_table_name "old_test_plans"
  has_many :old_test_cases
  belongs_to :old_test_projects
end

class TestLinkCase < ActiveRecord::Base
  set_table_name "old_test_cases"
  has_many :old_test_steps
  belongs_to :old_test_plans
end
class TestLinkCaseStep < ActiveRecord::Base
  set_table_name "old_test_steps"
  belongs_to :old_test_cases
end

desc "import qa test cases to TestPlus for specifical project "
# task :import_test_cases => :environment , :mp_name , :p_name do |t,args|
task :import_test_cases , [:mp_name, :p_name] => :environment  do |t, args|
  host = "10.119.11.198"
  user = "active"
  pwd = "@ctive123"
  db = "testlink"
  puts "will start import data from #{host}/#{db}"
  [TestLinkProject,TestLinkPlan,TestLinkCase,TestLinkCaseStep].each do |klass|
    klass.establish_connection(
      :adapter => "mysql2",
      :host => host,
      :username  => user,
      :password  => pwd,
      :database  => db
    )
    # puts klass.to_s
    # puts klass.table_name
  end

  testplus_project_name = args[:mp_name]
  project_name = args[:p_name]
  mp = Project.find_by_name(testplus_project_name)
  puts "======>>> Import test plans to #{mp.name} in TestPlus"
  p= TestLinkProject.find_by_name(project_name)
  puts "======>>> Get test plans of #{p.name} in old database"
  mp.test_plans.all.each do |mtp|
    mtp.status = 'expired'
    mtp.save
  end
  # test = TestLinkPlan.find_all_by_old_project_id(project_id)
  TestLinkPlan.find_all_by_project_id(p.id).each do |tp|
    mtp = mp.test_plans.find_or_create_by_name(tp.name.strip.gsub(/\s+/,' '))
    mtp.status = "completed"
    mtp.version = tp.version
    mtp.save
    TestLinkCase.find_all_by_test_plan_id(tp.id).each do |tc|
      # puts tc.name
      mtc = mtp.test_cases.find_or_create_by_case_id(tc.case_id)
      mtc.tc_steps.delete_all
      mtc.name = tc.name.strip
      mtc.version = tc.version
      mtc.priority = "P#{4-tc.priority}"
      mtc.automated_status = tc.automated_status
      mtc.test_link_id = tc.test_link_id
      mtc.keywords = tc.keywords
      mtc.save
      TestLinkCaseStep.find_all_by_test_case_id(tc.id).each do |tcp|
        step = mtc.tc_steps.build(:test_link_id =>tcp.test_link_id,:step_number=>tcp.step_number,:step_action => tcp.action,:expected_result =>tcp.expected_result)
        step.save
      end
    end
  end
  puts "======>>>done the import for #{mp.name}"
end

desc "import the test cases for all market. will cover Camps/Endurance/Backoffice/Sports/Membership/UsableNet/iPhoneApp/PaoBuKong"
task :import_all_cases => :environment  do
  project_mappings = []
  project_mappings << {"testplus_project" => 'Camps',"testlink_project"  => 'Camps'}
  project_mappings << {"testplus_project" => 'Membership',"testlink_project"  => 'Membership'}
  project_mappings << {"testplus_project" => 'ActiveNet',"testlink_project"  => 'ActiveNet'}
  project_mappings << {"testplus_project" => 'Endurance',"testlink_project"  => 'Endurance'}
  project_mappings << {"testplus_project" => 'LeagueOne',"testlink_project"  => 'LeagueOne'}
  # project_mappings << {"testplus_project" => 'Plancast',"testlink_project"  => 'Plancast'}
  # project_mappings << {"testplus_project" => 'Class', "testlink_project" => 'Class'}
  project_mappings << {"testplus_project" => 'RTP', "testlink_project" => 'RTP-Revolution'}
  project_mappings << {"testplus_project" => 'RTPOneContainer', "testlink_project" => 'RTPOneContainer'}
  project_mappings << {"testplus_project" => 'RTP-MooseCreek', "testlink_project" => 'RTP-MooseCreek'}
  # project_mappings << {"testplus_project" => 'SNH', "testlink_project" => 'ROL - Beta'}
  # project_mappings << {"testplus_project" => 'WannaDo', "testlink_project" => 'WannaDo'}
  project_mappings << {"testplus_project" => 'Sports', "testlink_project" => "Sports"}
  project_mappings << {"testplus_project" => 'Platform-Checkout', "testlink_project" => "Platform-Checkout"}
  project_mappings << {"testplus_project" => 'Platform-Commerce', "testlink_project" => "Platform-Commerce"}

  host = "10.107.100.129"
  user = "smart"
  pwd = "start123"
  db = "testlink"
  puts "will start import data from #{host}/#{db}"
  [TestLinkProject,TestLinkPlan,TestLinkCase,TestLinkCaseStep].each do |klass|
    klass.establish_connection(
      :adapter => "mysql2",
      :host => host,
      :username  => user,
      :password  => pwd,
      :database  => db
    )
  end
  project_mappings.each do |mapping|
    testplus_project_name = mapping["testplus_project"]
    project_name = mapping["testlink_project"]
    mp = Project.find_by_name(testplus_project_name)
    p= TestLinkProject.find_by_name(project_name)

    if !mp.nil? and !p.nil?
      puts "======>>> #{p.name} in TestLink ======>>> will import to #{mp.name} in TestPlus"
      mp.test_plans.all.each do |mtp|
        mtp.status = 'expired'
        mtp.save
      end

      TestLinkPlan.find_all_by_project_id(p.id).each do |tp|
        mtp = mp.test_plans.find_or_create_by_name(tp.name.strip.gsub(/\s+/,' '))
        mtp.status = "completed"
        mtp.version = tp.version
        mtp.plan_type = tp.plan_type
        mtp.save

        TestLinkCase.find_all_by_test_plan_id(tp.id).each do |tc|
          # puts tc.name
          mtc = mtp.test_cases.find_or_create_by_case_id(tc.case_id)
          mtc.tc_steps.delete_all
          mtc.name = tc.name.strip
          mtc.version = tc.version
          mtc.priority = "P#{4-tc.priority}"
          mtc.automated_status = tc.automated_status
          mtc.test_link_id = tc.test_link_id
          mtc.keywords = tc.keywords
          mtc.save
          TestLinkCaseStep.find_all_by_test_case_id(tc.id).each do |tcp|
            step = mtc.tc_steps.build(:test_link_id =>tcp.test_link_id,:step_number=>tcp.step_number,:step_action => tcp.action,:expected_result =>tcp.expected_result)
            step.save
          end
        end
      end
      puts "======>>>done the import for #{mp.name}"
    end
  end
end
