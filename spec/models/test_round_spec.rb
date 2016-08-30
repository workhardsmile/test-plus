require "spec_helper"

describe TestRound do
  let(:tr) {Factory(:test_round)}
  let(:ts) {Factory(:test_suite)}

  after(:each) do
    ts.automation_scripts.each do |as|
      as.delete
    end
    tr.automation_script_results.each do |asr|
      asr.delete
    end
    User.delete_all
  end

  it "can be instantiated" do
    tr.should be_an_instance_of(TestRound)
  end

  it "should have the start_time as nil when initiated" do
    tr.start_time.should be_nil
  end

  # context "Run a Test Round" do
  #   before do
  #     2.times do
  #       ts.automation_scripts << Factory.create(:automation_script)
  #     end

  #     tr.test_suite = ts

  #     tr.save!
  #     tr.init_automation_script_result
  #     @asr = tr.automation_script_results[0]
  #     @asr2 = tr.automation_script_results[1]
  #   end

    # it "should change the start_time to the first result's start_tiem upon receive it" do
    #   @asr.update_state!("start")
    #   expect do
    #     tr.update_state!
    #   end.to change{tr.start_time}.from(nil).to(@asr.start_time)
    # end

    # it "should always have the start_time set as the earlist start_time amongest all of its recieved results" do
    #   @asr.update_state!("start")
    #   tr.update_state!
    #   @asr2.update_state!("start")

    #   expect do
    #     tr.update_state!
    #   end.to_not change{tr.start_time}.from(@asr.start_time).to(@asr2.start_time)

      # simulate re-run scenario
      # only re-run one of the results
      # tr.automation_script_results.each{|asr| asr.update_state!("end")}
      # tr.update_state!
      # @asr2.clear
      # @asr2.update_state!("start")
      # expect do
      #   tr.update_state!
      # end.to_not change{tr.start_time}.from(@asr.start_time).to(@asr2.start_time)

      # simulate re-run all of the results
      # tr.automation_script_results.each{|asr| asr.update_state!("end")}
      # tr.update_state!
      # @asr2.clear
      # @asr2.update_state!("start")
      # @asr.clear
      # @asr.update_state!("start")
      # expect do
      #   tr.update_state!
      # end.to change{tr.start_time}.to(@asr2.start_time)

    # end

    # it "should have the counters correctly set upon init" do

    # end

  # end

end
