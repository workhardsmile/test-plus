require "rubygems"
require "rest_client"
require "rexml/document"
require "httpclient"
require "yaml"
require "#{File.dirname(__FILE__)}/common_function"

class RspecHelper
  attr_accessor :ruby_path
  attr_accessor :server_ip

  RSPEC_CONFIG = YAML.load(File.open("#{File.dirname(__FILE__)}/../client/rspec_config.yml"))
  SVN_PATH = RSPEC_CONFIG["svn_path"]
  $script_path = RSPEC_CONFIG["membership_code"]["script_path"]
  $common_path = RSPEC_CONFIG["membership_code"]["components_path"]
  $package_path = RSPEC_CONFIG["membership_code"]["package_path"]
  $components_path = RSPEC_CONFIG["membership_code"]["components_path"]
  $object_path = RSPEC_CONFIG["membership_code"]["objects_path"]  
  $screenshot_path = RSPEC_CONFIG["membership_code"]["screenshot_path"]

  def initialize(ruby_path, server_ip)
    @ruby_path = ruby_path
    @server_ip = server_ip
  end

  def initialize_path(market_name)
    case market_name.downcase
      when "membership"
        $script_path = RSPEC_CONFIG["membership_code"]["script_path"]
        $common_path = RSPEC_CONFIG["membership_code"]["common_path"]
        $package_path = RSPEC_CONFIG["membership_code"]["package_path"]
        $components_path = RSPEC_CONFIG["membership_code"]["components_path"]
        $object_path = RSPEC_CONFIG["membership_code"]["objects_path"]  
        $screenshot_path = RSPEC_CONFIG["membership_code"]["screenshot_path"]
        $main_path = RSPEC_CONFIG["membership_code"]["main_path"]
    end
  end
  def execute(msg)
    puts "\n command ====> #{msg}"
    if msg.match(/auto-run .*/)
      str_array = msg.split("auto-run ")
      project_name = msg.split(":project=>")[1].split(" :")[0]
      test_round_id = msg.split(":test_round_id=>")[1].split(" :")[0]  # => Get test round id
      script_name = msg.split(":script_name=>")[1].split(" :")[0]  # => Get automation script name
      test_env = msg.split(":test_env=>")[1].split(" :")[0] # => Get test environment
      # time_out_limit = msg.split(":time_out_limit=>")[1].split(" :")[0] # => Get timeout time
      
      initialize_path(project_name)  # => Initialize the case global path by market name
      folder_path = $script_path
      case_path = search_case(folder_path,script_name)  # => Find test case
      if case_path
        update_folder SVN_PATH,folder_path # => Update whole testuite path.
        case_path = search_case(folder_path,script_name)
      else
        puts "#{case_path} ====> Found!"
        update_folder SVN_PATH,$object_path # => Update the objects folder
        update_folder SVN_PATH,$components_path  # => Update the components folder
        update_folder SVN_PATH,$common_path # => Update the common folder
        update_folder SVN_PATH,$package_path  # => Update the package folder
        update_folder SVN_PATH,case_path # => Update the case.
        puts "update folder finished. begin running rspec..."
      end
      
      if case_path
        delete_img $screenshot_path
        system "cd #{$main_path} && #{@ruby_path} main.rb #{script_name} #{test_round_id} firefox #{test_env}"
      else
        puts "#{case_path} ====> Not found!"
        post_result round_id,script_name,"not implemented"
      end      
    else
      puts "Command is not correct!"
    end    
  rescue Exception => e
    puts "Error in function execute_rspec: #{e.class}"
    puts "#{e}"
  ensure
    upload_img $screenshot_path
  end
end
