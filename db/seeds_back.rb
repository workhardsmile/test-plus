# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
[User, ProjectCategory, Project, TestPlan, TestCase, AutomationScript,
  AutomationCase, TestSuite, TestRound, TestType, AutomationScriptResult, AutomationCaseResult,
  TestEnvironment, TargetService].each{|t| t.delete_all}
automator = User.create({
  email: 'automator@testplus.com',
  password: '111111',
  display_name: 'TestPlus Automator'
})

tyrael = User.create({
  email: 'tyrael.tong@activenetwork.com',
  password: '111111',
  display_name: 'Tyrael Tong'
})

eric = User.create({
  email: 'eric.yang@activenetwork.com',
  password: '111111',
  display_name: 'Eric Yang'
})

aw = ProjectCategory.create({
  :name => 'Active Works'
})

other = ProjectCategory.create({
  :name => 'Others'
})

camps = Project.create({
  :name => 'Camps',
  :leader => tyrael,
  :project_category => aw,
  :state => 'ongoing',
  :source_control_path => 'http://fndsvn.dev.activenetwork.com/camps',
  :icon_image_file_name => 'camps.png',
  :icon_image_content_type => 'image/png',
  :icon_image_file_size => 7763
})

endurance = Project.create({
  :name => 'Endurance',
  :leader => eric,
  :project_category => aw,
  :state => 'ongoing',
  :source_control_path => 'http://fndsvn.dev.activenetwork.com/endurance',
  :icon_image_file_name => 'endurance.png',
  :icon_image_content_type => 'image/png',
  :icon_image_file_size => 18857
})

sports = Project.create({
  :name => 'Sports',
  :leader => tyrael,
  :project_category => aw,
  :state => 'ongoing',
  :source_control_path => 'http://fndsvn.dev.activenetwork.com/sports',
  :icon_image_file_name => 'sports.png',
  :icon_image_content_type => 'image/png',
  :icon_image_file_size => 16291
})

tp1 = TestPlan.create({
  :name => 'CUI BVT',
  :project => camps
})

tp2 = TestPlan.create({
  :name => 'AUI BVT',
  :project => camps
})

tc1 = TestCase.create({
  :name => 'click me',
  :case_id => "1.0",
  :version => "1.0",
  :automated_status => "automated",
  :priority => "P1",
  :test_plan => tp1
})

tc2 = TestCase.create({
  :name => 'click me',
  :case_id => "1.0",
  :version => "1.0",
  :automated_status => "automated",
  :priority => "P1",
  :test_plan => tp1
})

tc3 = TestCase.create({
  :name => 'click me',
  :case_id => "1.0",
  :version => "1.0",
  :automated_status => "automated",
  :priority => "P1",
  :test_plan => tp1
})

as1 = AutomationScript.create({
  :name => "CUI BVT",
  :status => "draft",
  :version => "1.0",
  :test_plan => tp1,
  :owner => tyrael,
  :project => camps,
})

as2 = AutomationScript.create({
  :name => "AUI BVT",
  :status => "draft",
  :version => "1.0",
  :test_plan => tp1,
  :owner => eric,
  :project => camps,
})

ac1 = AutomationCase.create({
  :name => "Login home page",
  :case_id => "1.01",
  :version => "1.0",
  :priority => "P1",
  :automation_script => as1
})

ac2 = AutomationCase.create({
  :name => "Click new button",
  :case_id => "1.02",
  :version => "1.0",
  :priority => "P2",
  :automation_script => as1
})

ac3 = AutomationCase.create({
  :name => "Click continue",
  :case_id => "1.03",
  :version => "1.0",
  :priority => "P1",
  :automation_script => as1
})

bvt = TestType.create({
  :name => "BVT",
})

regression = TestType.create({
  :name => "Regression",
})

ts1 = TestSuite.create({
  :name => "BVT Suite",
  :status => "complete",
  :project => camps,
  :creator => tyrael,
  :test_type => regression
})

te1 = TestEnvironment.create({
  :name => "INT",
  :value => "INT",
})

te2 = TestEnvironment.create({
  :name => "QA",
  :value => "QA",
})

te3 = TestEnvironment.create({
  :name => "Staging",
  :value => "Staging",
})

ts1.automation_scripts << as1
ts1.automation_scripts << as2
ts1.save

tr1 = TestRound.create({
  :start_time => Time.now,
  :end_time => Time.now + 100,
  :state => 'completed',
  :result => 'pass',
  :test_object => 'FndWebServer 1.0.1',
  :pass => 100,
  :failed => 20,
  :warning => 10,
  :not_run => 3,
  :pass_rate => 89.0,
  :duration => 100,
  :test_environment => te1,
  :test_suite => ts1,
  :project => camps,
  :creator => eric
})

tr2 = TestRound.create({
  :start_time => Time.now,
  :end_time => Time.now + 100,
  :state => 'completed',
  :result => 'failed',
  :test_object => 'FndWebServer 1.0.2',
  :pass => 100,
  :failed => 20,
  :warning => 10,
  :not_run => 3,
  :pass_rate => 89.0,
  :duration => 100,
  :test_environment => te1,
  :test_suite => ts1,
  :project => camps,
  :creator => eric
})

tr3 = TestRound.create({
  :start_time => Time.now,
  :end_time => Time.now + 100,
  :state => 'completed',
  :result => 'pass',
  :test_object => 'FndWebServer 1.0.3',
  :pass => 100,
  :failed => 0,
  :warning => 10,
  :not_run => 3,
  :pass_rate => 100.0,
  :duration => 100,
  :test_environment => te1,
  :test_suite => ts1,
  :project => camps,
  :creator => tyrael
})

asr1 = AutomationScriptResult.create({
  :state => "scheduling",
  :pass => 2,
  :failed => 1,
  :warning => 0,
  :not_run => 0,
  :result => "pending",
  :start_time => Time.now,
  :end_time => Time.now + 100,
  :test_round => tr1,
  :automation_script => as1
})

asr2 = AutomationScriptResult.create({
  :state => "running",
  :pass => 0,
  :failed => 0,
  :warning => 0,
  :not_run => 0,
  :result => "pending",
  :start_time => Time.now,
  :end_time => Time.now + 100,
  :test_round => tr1,
  :automation_script => as1
})

asr3 = AutomationScriptResult.create({
  :state => "scheduling",
  :pass => 0,
  :failed => 0,
  :warning => 0,
  :not_run => 0,
  :result => "pending",
  :start_time => Time.now,
  :end_time => Time.now + 100,
  :test_round => tr1,
  :automation_script => as1
})

acr1 = AutomationCaseResult.create({
  :result => "failed",
  :error_message => "Blah blah ...",
  :priority => "P1",
  :automation_case => ac1,
  :automation_script_result => asr1
})

acr2 = AutomationCaseResult.create({
  :result => "failed",
  :error_message => "Blah blah ...",
  :priority => "P2",
  :automation_case => ac2,
  :automation_script_result => asr1
})

acr2 = AutomationCaseResult.create({
  :result => "pass",
  :error_message => "",
  :priority => "P1",
  :automation_case => ac3,
  :automation_script_result => asr1
})

service1 = TargetService.create({
  :name => "FndWebServerCamps",
  :version => "2.12.0.7",
  :automation_script_result => asr1
})

service2 = TargetService.create({
  :name => "CampsSessionManagementService",
  :version => "2.12.0.0",
  :automation_script_result => asr1
})

service3 = TargetService.create({
  :name => "FndWebServerCui",
  :version => "3.7.0.27",
  :automation_script_result => asr1
})

service4 = TargetService.create({
  :name => "FndWebServerBackOffice",
  :version => "3.8.0.2",
  :automation_script_result => asr1
})
