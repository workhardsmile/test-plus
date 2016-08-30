require "rubygems"
require "win32/process"
require "win32ole"
require "rest_client"
require "rexml/document"
require "httpclient"
require "yaml"
require "#{File.dirname(__FILE__)}/common_function"

class QTPHelper
  attr_accessor :ruby_path
  attr_accessor :server_ip

  QTP_CONFIG = YAML.load(File.open("#{File.dirname(__FILE__)}/../client/qtp_config.yml"))
  SVN_PATH = QTP_CONFIG["camps_code"]["svn_path"]
  RESULT_PATH = QTP_CONFIG["camps_code"]["result_path"]
  $regression_path = QTP_CONFIG["camps_code"]["regression_path"]
  $bvt_path = QTP_CONFIG["camps_code"]["bvt_path"]
  $package_path = QTP_CONFIG["camps_code"]["package_path"]
  $datapools_path = QTP_CONFIG["camps_code"]["datapools_path"]
  $screenshot_path = QTP_CONFIG["camps_code"]["screenshot_path"]

  def initialize(ruby_path, server_ip)
    @ruby_path = ruby_path
    @server_ip = server_ip
  end
  
  def initialize_path(market_name)
    case market_name.downcase
      when "endurance"
        $regression_path = QTP_CONFIG["endurance_code"]["regression_path"]
        $bvt_path = QTP_CONFIG["endurance_code"]["bvt_path"]
        $package_path = QTP_CONFIG["endurance_code"]["package_path"]
        $datapools_path = QTP_CONFIG["endurance_code"]["datapools_path"]
        $screenshot_path = QTP_CONFIG["endurance_code"]["screenshot_path"]
      when "sports"
        $regression_path = QTP_CONFIG["sports_code"]["regression_path"]
        $bvt_path = QTP_CONFIG["sports_code"]["bvt_path"]
        $package_path = QTP_CONFIG["sports_code"]["package_path"]
        $datapools_path = QTP_CONFIG["sports_code"]["datapools_path"]
        $screenshot_path = QTP_CONFIG["sports_code"]["screenshot_path"]
      when "backoffice"
        $regression_path = QTP_CONFIG["backoffice_code"]["regression_path"]
        $bvt_path = QTP_CONFIG["backoffice_code"]["bvt_path"]
        $package_path = QTP_CONFIG["backoffice_code"]["package_path"]
        $datapools_path = QTP_CONFIG["backoffice_code"]["datapools_path"]
        $screenshot_path = QTP_CONFIG["backoffice_code"]["screenshot_path"]
      when "giving"
        $regression_path = QTP_CONFIG["endurance_code"]["regression_path"]
        $bvt_path = QTP_CONFIG["endurance_code"]["bvt_path"]
        $package_path = QTP_CONFIG["endurance_code"]["package_path"]
        $datapools_path = QTP_CONFIG["endurance_code"]["datapools_path"]
        $screenshot_path = QTP_CONFIG["endurance_code"]["screenshot_path"]
    end
  end

  def execute(msg)
    puts "\n command ====> #{msg}"
    if msg.match(/auto-run .*/)
      str_array = msg.split("auto-run ")
      project_name = msg.split(":project=>")[1].split(" :")[0]  # => Get project name
      test_round_id = msg.split(":test_round_id=>")[1].split(" :")[0]  # => Get test round id
      script_name = msg.split(":script_name=>")[1].split(" :")[0]  # => Get automation script name
      test_type = msg.split(":test_type=>")[1].split(" :")[0] # => Get test type
      time_out_limit = msg.split(":time_out_limit=>")[1].split(" :")[0] # => Get timeout time
      
      command = msg.gsub(/:driver[^:]*/, "")  #Cut off driver
      command = command.gsub(/:script_name[^:]*/, "")  #Cut off script_name
      command = command.gsub(/:test_type[^:]*/, "")  #Cut off test_type
      command = command.gsub(/:time_out_limit[^:]*/, "")  #Cut off time_out_limit
      
      initialize_path(project_name)  # => Initialize the case global path by market name

      puts "creating a process to kill qtp when time out..."
      p1 = Process.create(:app_name =>"#{@ruby_path} '#{File.dirname(__FILE__)}/time_count.rb' '#{time_out_limit}' '#{test_round_id}' '#{script_name}' '#{@ruby_path}' '#{@server_ip}'")

      # puts "creating a process to monitor screenshot folder..."
      # p2 = Process.create(:app_name =>"#{@ruby_path} '#{File.dirname(__FILE__)}/monitor_screenshot.rb' '#{$screenshot_path}' '#{@server_ip}'")
      
      execute_command(project_name,test_type,test_round_id,script_name,parse_command(command))
      
      sleep 5
      puts "excute command finished"
    else
      puts "====> Command is not correct!"
    end
  rescue Exception => e
    post_result test_round_id, script_name, "killed"
    puts "Error in function execute_qtp: #{e.class}"
    puts "#{e}"
  ensure
    Process.kill(1,p1.process_id) unless p1.nil?
    # Process.kill(1,p2.process_id) unless p2.nil?
  end

  def execute_command(project_name,test_type,round_id,script_name,qtp_params)
      folder_path = $regression_path
      if test_type.strip.downcase == "bvt"
        folder_path = $bvt_path
      end

      case_path = search_case(folder_path,script_name)  # => Find test case
      if case_path.nil?
        update_folder SVN_PATH,folder_path # => Update whole regression/BVT path.
        case_path = search_case(folder_path,script_name)
      else
        puts "#{case_path} ====> Found!"
        update_folder SVN_PATH,$datapools_path # => Update the datapools folder
        update_folder SVN_PATH,$package_path  # => Update the package folder
        update_folder SVN_PATH,case_path # => Update the case.
        puts "update folder finished. begin running QTP..."
      end

      if case_path
        delete_img $screenshot_path
        kill_qtp    # => Kill QTP process.
        case_path = case_path.gsub("\\\\","\\")
        run_qtp case_path,qtp_params,RESULT_PATH # => Run QTP
      else
        puts "#{case_path} ====> Not found!"
        post_result round_id,script_name,"not implemented"
      end

    rescue Exception => e
      puts "Error in function execute_command: #{e.class}"
      puts "#{e}"
    ensure
      kill_qtp
      upload_img $screenshot_path
  end

  #
  # => @method parse_command  (Parse the command get from client, and turn it into a hash list and return.)
  # => @param str_array (The array of string to be parsed.)
  # => @return Hash (A hash list.)
  #
  def parse_command(command)
    command = command.gsub("project","MarketName")
    command = command.gsub("test_round_id","BuildNumber")
    command = command.gsub("test_env","AUT_ENV")
    str_array = command.split(" :")
    hash_param = Hash.new("hash parameters")
    if str_array
      str_array.each do |str|
        param = str.split("=>")
        hash_param[param[0].to_s] = param[1].to_s.strip unless param.size<2
      end
    end
  rescue Exception => e
    puts "Error in function parse_command: #{e.class}"
    puts "#{e}"
  ensure
    return hash_param
  end

  #
  # => @method run_qtp (Run a QTP application to run the specified test case by calling win32 api.)
  # => @param test_name (The name of the specified test to be run.)
  # => @param hash_param (The hash list of the parameters to be set in the DataTable.)
  # => @return nil
  #
  def run_qtp(test_name,hash_param,result_path)
    sleep(3)
    puts "====> Launching QTP..."
    qtp = WIN32OLE.new("QuickTest.Application")
    qtp.visible = true
    qtp.Launch
    qtp_result_option = WIN32OLE.new("QuickTest.RunResultsOptions")
    now = Time.now.strftime("%m_%d_%Y %I-%M-%S %p") # => Get current time as format 03_08_2011 10-12-50 AM
    qtp_result_option.ResultsLocation = "#{result_path}\\#{now}\\#{File.basename(test_name)}" # => Set the direvtory to store the QTP results.
    puts "====> Openning test case - #{test_name}..."
    qtp.open test_name,1 #opens test in read-only mode
    qtp_test = qtp.Test
    data_table = qtp_test.DataTable
    hash_param.each { |param_name,param_value| data_table.setproperty("Value", param_name, 1, param_value) }  # => Set the parameters.
    puts "====> Running test case..."
    qtp_test.Run qtp_result_option
    puts "====> Finished running."
  rescue Exception => e
    puts "Error in function run_qtp: #{e.class}"
    puts "#{e}"
  ensure
    puts "====> Quit QTP."
    qtp_test.Close unless qtp_test.nil?
    qtp.Quit unless qtp.nil?
  end

  def kill_qtp
    kill_process "QTPro.exe"  # => Kill the QTPro.exe
    kill_process "QTAutomationAgent.exe"  # => Kill the QTAutomationAgent.exe
  end
end