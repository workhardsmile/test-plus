namespace :test_round do

  desc "Init some user and project data"
  task :stop , [:test_round_id] => :environment  do |t, args|

    tr = TestRound.find(args[:test_round_id])
    if tr
      tr.automation_script_results.where(:state => 'scheduling').all.each do |asr|        
        sa = asr.slave_assignments.last
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

  end
end
