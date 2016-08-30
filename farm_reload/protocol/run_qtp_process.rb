require "#{File.dirname(__FILE__)}/qtp_helper"

class RunQtpProcess

  def initialize(ruby_path, server_ip, command)
    # puts ruby_path_value
    # puts server_ip_value
    # puts command_value
    @ruby_path = ruby_path
    @server_ip = server_ip
    @command_value = command
  end

  def start_run
    puts "start running QTP in process..."
    qtp_helper = QTPHelper.new(@ruby_path, @server_ip)
    qtp_helper.execute(@command_value)

  rescue Exception => e
    puts "Error: #{e.class}"
    puts "#{e}"
  ensure
    #qtp_helper.post_result @test_round_id, @test_round_name, "killed"
  end
end


# RunQtpProcess.new(ARGV[0],ARGV[1],ARGV[2]).start_run
