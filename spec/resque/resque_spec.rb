require "spec_helper"

class TestTask
  @queue = :test_resque
  def test(id, method)
    Resque.enqueue(TestTask, id, method)
  end

  def self.perform
  end
end

describe Resque do
  before do
    ResqueSpec.reset!
  end

  it "Resque should connect to the redis server" do
    Resque.to_s.should match /connected/
  end

  it "Should enqueue my task" do
    test_task = TestTask.new
    test_task.test("id", :calculate)
    TestTask.should have_queued("id", :calculate)
  end

  it "should enqueue test round distribute task" do
    tr = TestRound.new
    ts = TestSuite.new
    ts.test_type = TestType.new
    tr.test_suite = ts

    TestRoundDistributor.distribute(tr.id)
    TestRoundDistributor.should have_queued(tr.id)

#     TestRoundMailer.finish_mail(tr).deliver
#     TestRoundMailer.should have_queued(TestRoundMailer, :finish_mail, tr)
  end

  it "should enqueue automation script result rerun task" do
    asr = AutomationScriptResult.create!
    AutomationScriptResultRunner.rerun(asr.id)
    AutomationScriptResultRunner.should have_queued(asr.id)
  end
end
