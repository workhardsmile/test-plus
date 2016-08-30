camps = Project.find_by_name("Camps")
eric = User.find_by_email('eric.yang@activenetwork.com')
tyrael = User.find_by_email('tyrael.tong@activenetwork.com')

tp = TestPlan.find_by_name("Demo Plan")
as = AutomationScript.find_by_name("Demo Script")

tp.delete if tp
as.delete if as

tp1 = TestPlan.create({
  :name => 'Demo Plan',
  :project => camps
})

tp2 = TestPlan.create({
  :name => 'Demo Plan2',
  :project => camps
})

tc1 = TestCase.create({
  :name => 'Input user name',
  :case_id => "1.01",
  :version => "1.0",
  :automated_status => "automated",
  :priority => "P1",
  :test_plan => tp1
})

tc2 = TestCase.create({
  :name => 'Input password',
  :case_id => "1.02",
  :version => "1.0",
  :automated_status => "automated",
  :priority => "P1",
  :test_plan => tp1
})

tc3 = TestCase.create({
  :name => 'Click login button',
  :case_id => "1.03",
  :version => "1.0",
  :automated_status => "automated",
  :priority => "P1",
  :test_plan => tp1
})

tc4 = TestCase.create({
  :name => 'Login AUI',
  :case_id => "1.01",
  :version => "1.0",
  :automated_status => "automated",
  :priority => "P1",
  :test_plan => tp2
})

tc5 = TestCase.create({
  :name => 'Register a season with two sessions.',
  :case_id => "1.02",
  :version => "1.0",
  :automated_status => "automated",
  :priority => "P1",
  :test_plan => tp2
})

tc6 = TestCase.create({
  :name => 'Check sessions data',
  :case_id => "1.03",
  :version => "1.0",
  :automated_status => "automated",
  :priority => "P1",
  :test_plan => tp2
})

as1 = AutomationScript.create({
  :name => "Demo Script",
  :status => "draft",
  :version => "1.0",
  :test_plan => tp1,
  :owner => eric,
  :project => camps,
})

as2 = AutomationScript.create({
  :name => "Demo Script2",
  :status => "draft",
  :version => "1.0",
  :test_plan => tp2,
  :owner => tyrael,
  :project => camps,
})

ac1 = AutomationCase.create({
  :name => "Input user name",
  :case_id => "1.01",
  :version => "1.0",
  :priority => "P1",
  :automation_script => as1
})

ac2 = AutomationCase.create({
  :name => "Input user password",
  :case_id => "1.02",
  :version => "1.0",
  :priority => "P1",
  :automation_script => as1
})

ac3 = AutomationCase.create({
  :name => "Click Login button",
  :case_id => "1.03",
  :version => "1.0",
  :priority => "P1",
  :automation_script => as1
})

ac4 = AutomationCase.create({
  :name => "Login AUI",
  :case_id => "1.01",
  :version => "1.0",
  :priority => "P1",
  :automation_script => as2
})

ac5 = AutomationCase.create({
  :name => "Register a season with two session.",
  :case_id => "1.02",
  :version => "1.0",
  :priority => "P1",
  :automation_script => as2
})

ac6 = AutomationCase.create({
  :name => "Check sessions data",
  :case_id => "1.03",
  :version => "1.0",
  :priority => "P1",
  :automation_script => as2
})

ts = TestSuite.create({
  :name => "BVT Suite"
})
ts.automation_scripts << as1
ts.automation_scripts << as2
ts.save!
