require 'xmlrpc/client'
class TestlinkAPIClient
  # substitute your server URL Here
  SERVER_URL = "http://10.109.0.164/testlink/lib/api/xmlrpc.php"

  def initialize(dev_key)
    @server = XMLRPC::Client.new2(SERVER_URL)
    @devKey = dev_key
  end

  def check_dev_key
    @server.call("tl.checkDevKey", {"devKey"=>@devKey})
  end

  def reportTCResult(case_id, testlink_id, tpid, build_id, platform_id,tc_result,tc_notes)
    args = {"devKey"=>@devKey,
            "testcaseid"=>testlink_id,
            "testplanid"=>tpid,
            "buildid"=>build_id,
            "status"=>tc_result,
            "notes"=>tc_notes}
    args["platformid"]=platform_id unless platform_id.nil? or platform_id == ""
    puts "Get result info ===>> #{args}"
    result = @server.call("tl.reportTCResult", args)
    return {:status => result[0]['status'],
            :message => result[0]['message'],
            :case_id => case_id,
            :testlink_id => testlink_id,
            :tc_result => tc_result.upcase
            }
  end

  def get_test_plan_id_by_name(project_name,tp_name)
    unless project_name.nil? or tp_name.nil?
      args = {"devKey"=>@devKey, "testprojectname"=>project_name, "testplanname"=>tp_name}
      result = @server.call("tl.getTestPlanByName", args)
      result[0]["id"]
    else
      raise "ProjectName or TestPlan Name should not be empty"
    end
  end

  def get_test_platform_id_by_name(testplan_id,platform_name)
    unless testplan_id.nil? or platform_name.nil?
      args = {"devKey"=>@devKey,
              "testplanid"=>testplan_id}
      results = @server.call("tl.getTestPlanPlatforms", args)
      results.each do |platform|
        return platform['id'] if platform['name'] == platform_name
      end
      return nil
    else
      raise "Platform or TestPlan should not be empty"
    end
  end

  def get_build_id_by_name(testplan_id,build_name)
    unless testplan_id.nil? or build_name.nil?

      args = {"devKey"=>@devKey,
              "testplanid"=>testplan_id}
      results = @server.call("tl.getBuildsForTestPlan", args)
      results.each do |build|
        return build['id'] if build['name'] == build_name
      end
      return nil
    else
      raise "Build or TestPlan should not be empty"
    end
  end
end

class SaveResultToTestlink
  @queue = :testlink_save_result
  @message = Hash.new
  @message['notes'] = []
  @message['export_results']= []
  def self.perform(test_round_id,tl_dev_key,tl_project_name,tl_plan_name,tl_build_name,tl_platform_name,email)
    # substitute your Dev Key Here
    begin
      client = TestlinkAPIClient.new(tl_dev_key)
      if client.check_dev_key == true
        tp_id = client.get_test_plan_id_by_name(tl_project_name,tl_plan_name)
        @message['notes'] << "Get test plan id #{tp_id} by #{tl_project_name} and #{tl_plan_name}\n"
        build_id = client.get_build_id_by_name(tp_id,tl_build_name)
        @message['notes'] << "Get build id #{build_id} by #{tl_plan_name} and #{tl_build_name}\n"
        unless tl_platform_name.nil?
          platform_id = client.get_test_platform_id_by_name(tp_id,tl_platform_name)
          @message['notes'] << "Get platform id #{platform_id} by #{tl_plan_name} and #{tl_platform_name}\n"
        end
        test_round = TestRound.find(test_round_id)
        test_round.get_result_details.each do |result|
          result_notes = "Result from TestPlus. Get service_info #{result['service_info']}\n"
          if result['result'] == 'pass'
            @message['export_results'] << client.reportTCResult(result['case_id'],result['test_link_id'],tp_id,build_id,platform_id,'p',result_notes)
          elsif result['result'] == 'failed'
            @message['export_results'] << client.reportTCResult(result['case_id'],result['test_link_id'],tp_id,build_id,platform_id,'f',result_notes)
          end
        end
        test_round.exported_status = 'Y'
        test_round.save
      else
        @message['notes'] << "The devKey given is not valid, please check."
      end
    rescue Exception => e
      test_round = TestRound.find(test_round_id)
      test_round.exported_status = 'N'
      test_round.save
      @message['notes'] << "Got error ===> #{e}"
    end
    NotificationMailer.save_to_testlink_notification(email,@message,test_round_id,tl_project_name).deliver
  end

  def self.save(test_round_id,tl_dev_key,tl_project_name,tl_plan_name,tl_build_name,tl_platform_name,email)
    Resque.enqueue(SaveResultToTestlink,test_round_id,tl_dev_key,tl_project_name,tl_plan_name,tl_build_name,tl_platform_name,email)
  end
end
