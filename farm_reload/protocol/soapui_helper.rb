require "rubygems"
require "rest_client"
require "rexml/document"
require "httpclient"
require "yaml"
require "#{File.dirname(__FILE__)}/common_function"

class SoapuiHelper
  attr_accessor :ruby_path
  attr_accessor :server_ip

  SOAPUI_CONFIG = YAML.load(File.open("#{File.dirname(__FILE__)}/../client/soapui_config.yml"))
  SLIME_PATH = SOAPUI_CONFIG["slime_path"]
  SVN_PATH = SOAPUI_CONFIG["svn_path"]

  def initialize(ruby_path, server_ip)
    @ruby_path = ruby_path
    @server_ip = server_ip
  end

  def execute_soapui(msg)
    puts "\n command ====> #{msg}"
    if msg.match(/auto-run .*/)
      project_name = msg.split(":project=>")[1].split(" :")[0]
      test_round_id = msg.split(":test_round_id=>")[1].split(" :")[0]  # => Get test round id
      automation_script_name = msg.split(":script_name=>")[1].split(" :")[0]  # => Get automation script name
      environment = msg.split(":test_env=>")[1].split(" :")[0] 

      execute_command(project_name,test_round_id,automation_script_name,environment)
      sleep 5
      puts "excute command finished"
    else
      puts "====> Command is not correct!"
    end
  rescue Exception => e
    puts "Error in function execute_qtp: #{e.class}"
    puts "#{e}"
  end

  def execute_command(project_name,round_id,script_name,environment)
      script_project_name = script_name.split('$$').first
      script_suite_name = script_name.split('$$').last
      folder_path = "#{SLIME_PATH}\\SoapuiScripts\\#{script_project_name}\\"
      file_name = script_project_name.include?('##') ? script_project_name.split('##').last : 'tests.xml'
      case_path = search_case_file(folder_path,"#{file_name}")  # => Find test case

      if case_path
        # run soapui script
        system "cd #{SLIME_PATH} && slime.bat -r #{round_id} -e #{environment} -p #{script_project_name} -s #{script_suite_name}"
      else
        puts "#{file_name} ====> Not found!"
        post_result round_id,script_name,"not implemented"
      end

    rescue Exception => e
      puts "Error in function execute_command: #{e.class}"
      puts "#{e}"
  end

end
