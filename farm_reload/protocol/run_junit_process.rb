require "#{File.dirname(__FILE__)}/junit_helper"

class RunJunitProcess

  def initialize(ruby_path, server_ip, command)
    # puts ruby_path_value
    # puts server_ip_value
    # puts command_value
    @ruby_path = ruby_path
    @server_ip = server_ip
    @command_value = command
  end

  def start_run
    puts "start running JUnit in process..."
    junit_helper = JunitHelper.new(@ruby_path, @server_ip)
    junit_helper.execute_junit(@command_value)

  rescue Exception => e
    puts "Error: #{e.class}"
    puts "#{e}"
  ensure
    #qtp_helper.post_result @test_round_id, @test_round_name, "killed"
  end
end


RunJunitProcess.new(ARGV[0],ARGV[1],ARGV[2]).start_run
