require "rubygems"
require "rest_client"
require "rexml/document"
require "httpclient"
require "yaml"
require "#{File.dirname(__FILE__)}/common_function"

class TestngHelper
  attr_accessor :ruby_path
  attr_accessor :server_ip

  TESTNG_CONFIG = YAML.load(File.open("#{File.dirname(__FILE__)}/../client/testng_config.yml"))
  SCRIPT_CLASS_FOLDER_PATH = TESTNG_CONFIG["script_class_folder_path"]

  TESTNG_JAR_PATH = TESTNG_CONFIG["testng_jar_path"]
  TestPlus_LISTNER_JAR_PATH = TESTNG_CONFIG["testplus_listener_path"]
  DOM_JAR_PATH = TESTNG_CONFIG["dom4j_path"]
  HTTPCLIENT_JAR_PATH = TESTNG_CONFIG["httpclient_path"]
  HTTPCORE_JAR_PATH = TESTNG_CONFIG["httpcore_path"]
  SELENIUM__SERVER_JAR_PATH = TESTNG_CONFIG["selenium_server_path"]

  def initialize(ruby_path, server_ip)
    @ruby_path = ruby_path
    @server_ip = server_ip
    # set_system_environment SCRIPT_CLASS_FOLDER_PATH+";"+TESTNG_JAR_PATH+";"+TestPlus_LISTNER_JAR_PATH+";"+DOM_JAR_PATH+";"+HTTPCLIENT_JAR_PATH+";"+HTTPCORE_JAR_PATH+";"+SELENIUM__SERVER_JAR_PATH
  end

  def set_system_environment(scripts_class_path)
    system "set CLASSPATH=#{scripts_class_path}"
  end

  def create_xml(project_name, round_id, script_name)
    doc = REXML::Document.new
    suite = doc.add_element("suite")
    suite_name = suite.add_attribute("name", project_name+round_id)

    test = suite.add_element("test")
    test_name = test.add_attribute("name", script_name)

    classes = test.add_element("classes")
    script_class = classes.add_element("class")
    class_name = script_class.add_attribute("name", script_name)
    doc.to_s
  end

  def get_script_class_name_including_package_path(script_folder_path, script_file_path)
    script_file = script_file_path.gsub("script_folder_path","").gsub("\\",".")
    return File.basename(script_file, ".class")
  end

  def execute_testng(msg)
    puts "\nCommand is: #{msg}"
    if msg.match(/auto-run .*/)
      project_name = msg.split(":project=>")[1].split(" :")[0]
      test_round_id = msg.split(":test_round_id=>")[1].split(" :")[0]  # => Get test round id
      automation_script_name = msg.split(":script_name=>")[1].split(" :")[0]  # => Get automation script name
      # environment = msg.split(":test_env=>")[1].split(" :")[0]

      script_file_path = search_case_file_recursive(SCRIPT_FOLDER_PATH, automation_script_name + ".class")
      if script_file_path
        script_file_name = get_script_class_name_including_package_path(SCRIPT_FOLDER_PATH, script_file_path)
        test_xml = create_xml(project_name, test_round_id, script_file_name)
        system "java -DRoundId=#{test_round_id} -DPlanName=#{automation_script_name} org.testng.TestNG -listener com.framework.testplus.LoggingListener #{test_xml}"
        puts "excute command finished.\n\n"
      else
        puts "Can't find the specific script: '#{automation_script_name}.class' under folder: '#{SCRIPT_FOLDER_PATH}'"
        post_result round_id,script_name,"not implemented"
      end
      
    else
      puts "Command is not correct!\n\n"
    end
  rescue Exception => e
    puts "Error in function execute_qtp: #{e.class}"
    puts "#{e}\n\n"
  end

end
