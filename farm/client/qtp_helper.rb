require "rubygems"
require "win32/process"
require "win32ole"
#require "find"
require "rest_client"
require "rexml/document"
require "httpclient"
require "yaml"

class QTPHelper
  attr_accessor :ruby_path
  attr_accessor :server_ip

  AUTO_SERVER_YAML = YAML.load(File.open("#{File.dirname(__FILE__)}/autoserver.yml"))
  SVN_PATH = AUTO_SERVER_YAML["camps_code"]["svn_path"]
  RESULT_PATH = AUTO_SERVER_YAML["camps_code"]["result_path"]

  $regression_path = AUTO_SERVER_YAML["camps_code"]["regression_path"]
  $bvt_path = AUTO_SERVER_YAML["camps_code"]["bvt_path"]
  $package_path = AUTO_SERVER_YAML["camps_code"]["package_path"]
  $datapools_path = AUTO_SERVER_YAML["camps_code"]["datapools_path"]
  $screenshot_path = AUTO_SERVER_YAML["camps_code"]["screenshot_path"]

  def initialize(ruby_path_value, server_ip_value, log)
    @ruby_path = ruby_path_value
    @server_ip = server_ip_value
    @logger = log
    @logger.debug "QTPHelper class ruby path is : #{@ruby_path}"
    @logger.debug "the server ip is : #{@server_ip}"
  end

  def execute_qtp(msg)
    if msg.match(/qtp .*/)
      str_array = msg.split(" $")
      case_name = str_array[1]  # => Get test case name
      str_build_array = msg.split(" $BuildNumber=")
      str_build_number = str_build_array[1].split(" $")  # => Get build number
      str_time_array = msg.split(" $TimeOut=")
      str_time = str_time_array[1].split(" $")  # => Get timeout time
      command = str_time_array[0]
      command = command << str_time[1] unless str_time[1].nil?  # => Cut off $TimeOut=XX param
      @logger.info "creating a process to kill qtp when time out..."
      p = Process.create(:app_name =>"#{@ruby_path} 'time_count.rb' '#{str_time[0]}' '#{str_build_number[0]}' '#{case_name}' '#{@ruby_path}' '#{@server_ip}'")
      @logger.info "creating a process to kill qtp when time out finished"
      execute_command(command,str_build_number[0],case_name)
      @logger.info "excute command finished"
    else
      @logger.error "====> Command is not correct!"
    end
  rescue Exception => e
    @logger.error "Error in function execute_qtp: #{e.class}"
    @logger.error "#{e}"
  ensure
    begin
      Process.kill(1,p.process_id) unless p.nil?
    rescue Exception => e
      @logger.fatal "Error in function execute_qtp: #{e.class}"
      @logger.fatal "#{e}"
    end
  end

  #
  # => @method initialize_path (Initialize the value of the case folders path by matching market name.)
  # => @param market_name (The specified market name.)
  # => @return nil
  # => @version 1.0
  #
  def initialize_path(market_name)
    case market_name.downcase
      when "endurance"
        $regression_path = AUTO_SERVER_YAML["endurance_code"]["regression_path"]
        $bvt_path = AUTO_SERVER_YAML["endurance_code"]["bvt_path"]
        $package_path = AUTO_SERVER_YAML["endurance_code"]["package_path"]
        $datapools_path = AUTO_SERVER_YAML["endurance_code"]["datapools_path"]
        $screenshot_path = AUTO_SERVER_YAML["endurance_code"]["screenshot_path"]
      when "sports"
        $regression_path = AUTO_SERVER_YAML["sports_code"]["regression_path"]
        $bvt_path = AUTO_SERVER_YAML["sports_code"]["bvt_path"]
        $package_path = AUTO_SERVER_YAML["sports_code"]["package_path"]
        $datapools_path = AUTO_SERVER_YAML["sports_code"]["datapools_path"]
        $screenshot_path = AUTO_SERVER_YAML["sports_code"]["screenshot_path"]
    end
  end

  #
  # => @method start_server (Start a TCPServer.)
  # => @param address
  # => @param port
  # => @return nil
  # => @version 1.1
  #
  def execute_command(command,round_id,case_name)
      str_market_array = command.split(" $MarketName=")
      str_market = str_market_array[1].split(" $")  # => Get market name
      initialize_path(str_market[0])  # => Initialize the case global path by market name

      folder_path = $regression_path
      if case_name.match(/.*BVT.*/)
        folder_path = $bvt_path
      end

      case_path = search_case(folder_path,case_name)  # => Find test case
      if case_path.size==0
        update_folder SVN_PATH,folder_path # => Update whole regression/BVT path.
        case_path = search_case(folder_path,case_name)
      end

      if case_path.size>0
        @logger.info "#{case_path} ====> Found!"
        case_path.each do |path|
          update_folder SVN_PATH,$datapools_path # => Update the datapools folder
          update_folder SVN_PATH,$package_path  # => Update the package folder
          update_folder SVN_PATH,path # => Update the case.
          @logger.info "update folder finished. begin running qtp..."
          kill_qtp    # => Kill QTP process.
          path = path.gsub("\\\\","\\")
          run_qtp path,parse_command(command.split(" $")),RESULT_PATH # => Run QTP
          upload_img($screenshot_path)
        end
      else
        @logger.error "#{case_path} ====> Not found!"
        post_result round_id,case_name,"not implemented"
      end

    rescue Exception => e
      @logger.fatal "Error in function execute_command: #{e.class}"
      @logger.fatal "#{e}"
  end


  #
  # => @method search_case (Search a specified directory path to find the specified directory.)
  # => @param directory_path (The specified directory path to be searched.)
  # => @param case_name (The specified test case name need to find.)
  # => @return nil
  # => @version 1.0
  #
  def search_case(directory_path,case_name)
    @logger.info "====> Searching test case #{case_name}"
    case_array = Array.new
    if File.directory? directory_path
      Dir.foreach(directory_path) do |file|
        if file!="." and file!=".." and (file.include? case_name) and (File.directory?(directory_path+file))
          case_array << (directory_path+file)
        end
      end
    end
  rescue Exception => e
    @logger.fatal "Error in function search_case: #{e.class}"
    @logger.fatal "#{e}"
  ensure
    return case_array
  end

  #
  # => @method kill_process (Kill the specified process if it exists.)
  # => @param process_name (The specified process name to be killed.)
  # => @return nil
  # => @version 1.0
  #
  def kill_process(process_name)
    @logger.info "====> Killing process #{process_name}..."
    mgmt = WIN32OLE.connect('winmgmts:\\\\.')
    mgmt.ExecQuery("Select * from Win32_Process Where Name = '#{process_name}'").each{ |item| item.Terminate() }
  rescue Exception => e
    @logger.fatal "Error in function kill_process: #{e.class}"
    @logger.fatal "#{e}"
  end

  #
  # => @method parse_command  (Parse the command get from client, and turn it into a hash list and return.)
  # => @param str_array (The array of string to be parsed.)
  # => @return Hash (A hash list.)
  # => @version 1.0
  #
  def parse_command(str_array)
    hash_param = Hash.new("hash parameters")
    if(str_array.size>2)
      for i in 2..(str_array.size-1) do
        param = str_array[i].split("=")
        hash_param[param[0].to_s] = param[1].to_s unless param.size<2
      end
    end
  rescue Exception => e
    @logger.fatal "Error in function parse_command: #{e.class}"
    @logger.fatal "#{e}"
  ensure
    return hash_param
  end

  #
  # => @method update_folder (Using tortoise command to update the specified folder.)
  # => @param folder_path (The specified folder path to be updated.)
  # => @return nil
  # => @version 1.0
  #
  def update_folder(tortoise_path,folder_path)
    @logger.info "====> Updating #{folder_path} from SVN..."
  #system "#{tortoise_path} /command:update /path:\"#{folder_path}\" /closeonend:1" # => closeonend:1 (Close the svn update window once it's finished.)
    system "\"#{tortoise_path}\" up \"#{folder_path}\""
  rescue Exception => e
    @logger.fatal "Error in function update_folder: #{e.class}"
    @logger.fatal "#{e}"
  end

  #
  # => @method run_qtp (Run a QTP application to run the specified test case by calling win32 api.)
  # => @param test_name (The name of the specified test to be run.)
  # => @param hash_param (The hash list of the parameters to be set in the DataTable.)
  # => @return nil
  # => @version 1.2
  #
  def run_qtp(test_name,hash_param,result_path)
    sleep(3)
    @logger.info "====> Launching QTP..."
    qtp = WIN32OLE.new("QuickTest.Application")
    qtp.visible = true
    qtp.Launch
    qtp_result_option = WIN32OLE.new("QuickTest.RunResultsOptions")
    now = Time.now.strftime("%m_%d_%Y %I-%M-%S %p") # => Get current time as format 03_08_2011 10-12-50 AM
    qtp_result_option.ResultsLocation = "#{result_path}\\#{now}\\#{File.basename(test_name)}" # => Set the direvtory to store the QTP results.
    @logger.info "====> Openning test case - #{test_name}..."
    qtp.open test_name,1 #opens test in read-only mode
    qtp_test = qtp.Test
    data_table = qtp_test.DataTable
    hash_param.each { |param_name,param_value| data_table.setproperty("Value", param_name, 1, param_value) }  # => Set the parameters.
    @logger.info "====> Running test case..."
    qtp_test.Run qtp_result_option
    @logger.info "====> Finished running."
  rescue Exception => e
    @logger.fatal "Error in function run_qtp: #{e.class}"
    @logger.fatal "#{e}"
  ensure
    @logger.info "====> Quit QTP."
    qtp_test.Close unless qtp_test.nil?
    qtp.Quit unless qtp.nil?
  end

  #
  # => @method upload_img  (Upload the screenshots to AutomationDashboard.)
  # => @return nil
  # => @version 1.0
  #
  def upload_img(file_path)
    @logger.info "====> Uploading images..."
    Dir.foreach(file_path) do |file|
      if File.file?(file_path+file) and File.extname(file)=='.png'
        RestClient.post( "http://#{@server_ip}/screen_shots",{
          :screen_shot => { :screen_shot => File.new(file_path+file) }
        })
        File.delete(file_path+file)
      end
    end
    @logger.info "====> Uploading Done."
  rescue Exception => e
    @logger.fatal "Error in function upload_img: #{e.class}"
    @logger.fatal "#{e}"
  end

  def kill_qtp
    kill_process "QTPro.exe"  # => Kill the QTPro.exe
    kill_process "QTAutomationAgent.exe"  # => Kill the QTAutomationAgent.exe
  end

  #
  # => @method post_result (Post a message to the specified url.)
  # => @param test_round_id (The specified round id/build number.)
  # => @param test_plan_name (The specified test plan name.)
  # => @param status (The specified status of a round. start/killed/serviceerror/notimplemented)
  # => @return nil
  # => @version 1.0
  #
  def post_result(test_round_id,test_plan_name,plan_status)
    @logger.info "====> Posting status..."
    file = File.open("UpdateTestPlanStatus.xml")
    doc = REXML::Document.new file
    names = doc.elements
    round_id = doc.elements.to_a('//soapenv:Envelope/soapenv:Body/TestPlan/TestRoundId')
    plan_name = doc.elements.to_a('//soapenv:Envelope/soapenv:Body/TestPlan/TestPlanName')
    status = doc.elements.to_a('//soapenv:Envelope/soapenv:Body/TestPlan/Status')
    round_id[0].text = test_round_id
    plan_name[0].text = test_plan_name
    status[0].text = plan_status
    HTTPClient.post 'http://#{@server_ip}/status_service/update', doc, {"Content-Type" => "text/xml"}
    @logger.info "====> Posting done."
  rescue Exception => e
    @logger.fatal "Error in function post_result: #{e.class}"
    @logger.fatal "#{e}"
  end
end