require 'rubygems'
require 'socket'
require 'eventmachine'
require 'yaml'
require "#{File.dirname(__FILE__)}/../protocol/client_info"
require "#{File.dirname(__FILE__)}/../protocol/automation_command"

class ClientConn < EM::Connection
  include EM::P::ObjectProtocol

  def serializer
    YAML
  end

  def connection_completed
    slave_config = YAML::load(File.open('config.yml'))
    slave_config.name = Socket.gethostname
    send_object(slave_config)
    puts 'Client#info_sent'
  end

  def receive_object obj
    puts "Client#receive_object"
    puts "\b#{obj.inspect}"
    slave_config = YAML::load(File.open('config.yml'))
    slave_config.name = Socket.gethostname
    obj.execute(self)
    send_object(slave_config)
  end

  def unbind
    puts 'Client#unbind'
    EventMachine.stop
  end

  def get_ip_address
    port, ip = Socket.unpack_sockaddr_in(get_peername)
    ip
  end
end