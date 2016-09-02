require "rubygems"
require "eventmachine"
require "#{File.dirname(__FILE__)}/client_conn"

module TestPlus
  class Client
    def start
      trap('INT'){EventMachine.stop}
      trap('TERM'){EventMachine.stop}

      EventMachine.run do
        EventMachine.connect('testplus.dev.istuary.com', 9527, ClientConn) do |conn|
          puts 'Client#connect'
        end
      end
    end

  end
end

TestPlus::Client.new.start
