Factory.define :user do |u|
  u.sequence(:email) {|n| "tester#{n}@testplus.com"}
  u.password "111111"
  u.display_name "TestPlus Test"
end

Factory.define :automation_script_result do |asr|
  asr.state "scheduling"
  asr.pass 0
  asr.warning 0
  asr.failed 0
  asr.not_run 0
  asr.result "pending"
  asr.triage_result "N/A"
end

Factory.define :automation_case_result do |acr|
  acr.result "non-run"
  acr.association :automation_case
end

Factory.define :automation_case do |ac|
  ac.name "Automation Case"
  ac.version "1.0"
  ac.case_id "1.0"
  ac.priority "P1"
end

Factory.define :automation_script do |as|
  as.name "Automation Script"
  as.status "draft"
  as.version "1.0"
  # as.association :owner, :factory => :user
end

Factory.define :test_suite do |ts|
  ts.name "Test Suite"
end

Factory.define :test_round do |tr|
  tr.test_object "test object 1.01"
end
