require 'rubygems'
require 'eventmachine'
require 'client_conn'
require 'yaml'

class Client
  AUTO_SERVER_YAML = YAML.load(File.open("#{File.dirname(__FILE__)}/autoserver.yml"))
  SERVER_IP_ADDRESS = AUTO_SERVER_YAML["server_ip"]
  def start
    trap('INT'){EventMachine.stop}
    trap('TERM'){EventMachine.stop}
    EventMachine.run do
        EventMachine.connect(SERVER_IP_ADDRESS, 9527, ClientConn) do |conn|
          puts "Connect to server - #{SERVER_IP_ADDRESS} successfully"
          #conn.send_data_to_server("free","free")
          EventMachine::add_periodic_timer( 45 ) { conn.send_object "--- keep hearting " }
          conn.send_init_data_to_server
        end
    end
  end
end

Client.new.start
