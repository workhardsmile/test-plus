require 'rubygems'
require 'eventmachine'
require "socket"

class ServerConn < EM::Connection
  include EM::P::ObjectProtocol

  def serializer
    YAML
  end

  def get_ip_address
    port, ip = Socket.unpack_sockaddr_in(get_peername)
    ip
  end

  def set_server(server)
    @server = server
  end

  def receive_object(obj)
    obj.execute(@server, self)
  end

  def unbind
    @server.remove_client(self)
  end
end