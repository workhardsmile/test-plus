require "spec_helper"

describe AutomationCaseResult do
  let(:acr){Factory(:automation_case_result)}
  let(:data){
    {
      "result" => "pass",
      "error" => "Fatal Error",
      "screen_shot" => "screen001.jpg"
    }
  }

  it "should have the initial result set to 'not-run'" do
    acr = AutomationCaseResult.new
    acr.set_default_values
    acr.result.should eql "not-run"
  end

  it "should update the result when given a data hash" do
    acr.update!(data)
    acr.result.should eql "pass"
  end

  it "should set error message and screen shot when given a data hash" do
    acr.update!(data)
    acr.error_message.should eql "Fatal Error"
    acr.screen_shot.should eql "screen001.jpg"
  end

end
