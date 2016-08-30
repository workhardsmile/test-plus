class TestRoundKiller
  @queue = :testplus_farm

  def self.perform(test_round_id)
    tr = TestRound.find(test_round_id)
    if tr
      tr.automation_script_results.where(:state => 'scheduling').all.each do |asr|
        sa = asr.slave_assignments.last
        # remove SlaveAssignment from redis
        SlaveAssignmentsHelper.send_slave_assignment_to_list sa, "stop" if sa
        sa.status = 'complete'
        sa.save
        asr.state = 'killed'
        asr.result = 'failed'
        asr.save
      end

      tr.automation_script_results.where(:state => 'runnning').all.each do |asr|
        asr.state = "stopping"
        asr.save
        sa = asr.slave_assignments.last
        SlaveAssignmentsHelper.send_slave_assignment_to_list sa, "stop" if sa
      end
    end
    tr.state = 'completed'
    tr.result = 'failed'
    tr.save
    ServiceTriggerRecord.find_by_test_round_id(tr.id).update_attributes(status: 'done')
  end

  def self.kill(test_round_id)
    Resque.enqueue(TestRoundKiller, test_round_id)
  end

end
