require "#{File.dirname(__FILE__)}/testng_helper"

class RunTestngProcess

  def initialize(ruby_path, server_ip, command)
    @ruby_path = ruby_path
    @server_ip = server_ip
    @command_value = command
  end

  def start_run
    puts "start running SoapUI in process..."
    testng_helper = TestngHelper.new(@ruby_path, @server_ip)
    testng_helper.execute_testng(@command_value)

  rescue Exception => e
    puts "Error: #{e.class}"
    puts "#{e}"
  end
end

RunTestngProcess.new(ARGV[0],ARGV[1],ARGV[2]).start_run
