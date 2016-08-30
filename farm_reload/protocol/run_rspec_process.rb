require "#{File.dirname(__FILE__)}/rspec_helper"

class RunRspecProcess

  def initialize(ruby_path, server_ip, command)
    @ruby_path = ruby_path
    @server_ip = server_ip
    @command_value = command
  end

  def start_run
    puts "start running Rspec in process..."
    rspec_helper = RspecHelper.new(@ruby_path, @server_ip)
    rspec_helper.execute(@command_value)

  rescue Exception => e
    puts "Error: #{e.class}"
    puts "#{e}"
  ensure
    #qtp_helper.post_result @test_round_id, @test_round_name, "killed"
  end
end


RunRspecProcess.new(ARGV[0],ARGV[1],ARGV[2]).start_run
