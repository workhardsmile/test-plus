require "spec_helper"

describe AutomationScriptResult do
  let(:asr){Factory(:automation_script_result)}

  it "can be instantiated" do
    AutomationScriptResult.new.should be_an_instance_of(AutomationScriptResult)
  end

  it "should have counters set initially" do
    asr.pass.should eql 0
    asr.warning.should eql 0
    asr.failed.should eql 0
    asr.not_run.should eql 0
  end

  it "should have the state set initially" do
    asr.state.should eql "scheduling"
    asr.result.should eql "pending"
    asr.triage_result.should eql "N/A"
  end

  it "should change the state correctly during the running" do
    expect do
      asr.update_state!("start")
    end.to change{asr.state}.from("scheduling").to("start")

    expect do
      asr.update_state!("end")
    end.to change{asr.state}.from("start").to("end")
  end

  it "should change the counters correctly according to the case results" do
    acr = stub(:result => "pass")
    expect do
      asr.update_counters_by_case_result!(acr)
    end.to change{asr.pass}.from(0).to(1)

    acr2 = stub(:result => "pass")
    expect do
      asr.update_counters_by_case_result!(acr2)
    end.to change{asr.pass}.from(1).to(2)

    acr3 = stub(:result => "warning")
    expect do
      asr.update_counters_by_case_result!(acr3)
    end.to change{asr.warning}.from(0).to(1)

    acr4 = stub(:result => "failed")
    expect do
      asr.update_counters_by_case_result!(acr4)
    end.to change{asr.failed}.from(0).to(1)
  end

  it "should have the result set to 'pass' if all the cases are passed" do
    asr.update_state!("start")
    4.times do
      acr = stub(:result => "pass")
      asr.update_counters_by_case_result!(acr)
    end

    expect do
      asr.update_state!("end")
    end.to change{asr.result}.from("pending").to("pass")
    asr.passed?.should be_true
    asr.end?.should be_true
  end

  it "should have the result set to 'failed' if all the cases are failed" do
    asr.update_state!("start")
    4.times do
      acr = stub(:result => "failed")
      asr.update_counters_by_case_result!(acr)
    end

    expect do
      asr.update_state!("end")
    end.to change{asr.result}.from("pending").to("failed")
    asr.passed?.should_not be_true
    asr.end?.should be_true
  end

  it "should have the result set to 'failed' if any of the cases are failed" do
    asr.update_state!("start")
    4.times do
      acr = stub(:result => "pass")
      asr.update_counters_by_case_result!(acr)
    end

    acr = stub(:result => "failed")
    asr.update_counters_by_case_result!(acr)

    expect do
      asr.update_state!("end")
    end.to change{asr.result}.from("pending").to("failed")
    asr.passed?.should_not be_true
    asr.end?.should be_true
  end

  it "should have the result set to 'pass' even if all of the cases are warning" do
    asr.update_state!("start")
    4.times do
      acr = stub(:result => "warning")
      asr.update_counters_by_case_result!(acr)
    end

    expect do
      asr.update_state!("end")
    end.to change{asr.result}.from("pending").to("pass")
    asr.passed?.should be_true
    asr.end?.should be_true
  end

  it "should have the result set to 'pass' if part of the cases are warning but others are pass" do
    asr.update_state!("start")
    4.times do
      acr = stub(:result => 'pass')
      asr.update_counters_by_case_result!(acr)
    end
    acr = stub(:result => 'warning')
    asr.update_counters_by_case_result!(acr)

    expect do
      asr.update_state!("end")
    end.to change{asr.result}.from("pending").to("pass")

    asr.passed?.should be_true
    asr.end?.should be_true
  end

  it "should set the result to failed if triage result is 'Product Error'" do
    asr.result = "failed"
    expect do
      asr.update_triage!("Product Error")
    end.to_not change{asr.result}
  end

  it "should set the result to pass if triage result is 'Script Error'" do
    asr.result = "failed"
    expect do
      asr.update_triage!("Script Error")
    end.to change{asr.result}.from("failed").to("pass")
  end

  # it "should set the start_time when started" do
  #   expect do
  #     asr.update_state!("start")
  #   end.to change{asr.start_time}.from(nil)
  # end

  it "should have no duration if it's not end running" do
    asr.update_state!("start")
    asr.duration.should eql nil
  end

  # it "should have duration set if it's ended" do
  #   asr.update_state!("start")
  #   expect do
  #     asr.update_state!("end")
  #   end.to change{asr.duration}.from(nil)
  #   asr.end_time.should_not be_nil
  #   asr.duration.should eql (asr.end_time - asr.start_time)
  # end

end
