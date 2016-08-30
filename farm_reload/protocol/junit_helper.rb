require "rubygems"
require "win32/process"
require "win32ole"
require "rest_client"
require "rexml/document"
require "httpclient"
require "yaml"
require "#{File.dirname(__FILE__)}/common_function"

class JunitHelper
  attr_accessor :ruby_path
  attr_accessor :server_ip

  JUNIT_CONFIG = YAML.load(File.open("#{File.dirname(__FILE__)}/../client/junit_config.yml"))
  CASE_PATH = JUNIT_CONFIG["case_path"]
  SVN_PATH = JUNIT_CONFIG["svn_path"]

  def initialize(ruby_path, server_ip)
    @ruby_path = ruby_path
    @server_ip = server_ip
  end

  def execute_junit(msg)
    puts "\n command ====> #{msg}"
    if msg.match(/auto-run .*/)
      # project_name = msg.split(":project=>")[1].split(" :")[0]
      test_round_id = msg.split(":test_round_id=>")[1].split(" :")[0]  # => Get test round id
      automation_script_name = msg.split(":script_name=>")[1].split(" :")[0]  # => Get automation script name
      # environment = msg.split(":test_env=>")[1].split(" :")[0] 
      execute_command(test_round_id,automation_script_name)
      sleep 5
      puts "excute command finished"
    else
      puts "====> Command is not correct!"
    end
  rescue Exception => e
    puts "Error in function execute_qtp: #{e.class}"
    puts "#{e}"
  end

  def execute_command(round_id,script_name)
      folder_path = CASE_PATH
      case_path = search_case_file(folder_path,"#{script_name}")  # => Find test case
      #Update the SVN folder

      # run JUnit test
      if case_path.size>0
        # the command is -- java -DRoundId=123 -DPlanName=PlanName org.junit.runner.JUnitCore TestCaseClassName        
        # system "java -DRoundId=#{round_id} -DPlanName=#{script_name} org.junit.runner.JUnitCore #{script_name}"
        puts "java -DRoundId=#{round_id} -DPlanName=#{script_name} org.junit.runner.JUnitCore #{script_name}"
      else
        puts "#{file_name} ====> Not found!"
        post_result round_id,script_name,"not implemented"
      end

    rescue Exception => e
      puts "Error in function execute_command: #{e.class}"
      puts "#{e}"
  end

end
