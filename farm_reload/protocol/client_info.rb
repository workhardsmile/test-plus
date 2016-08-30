module TestPlus
  module Protocol
    class OperationSystem
      attr_accessor :name
      attr_accessor :version
    end

    class AutomationDriver
      attr_accessor :name
      attr_accessor :version
    end

    class ClientInfo
      attr_accessor :name
      attr_accessor :project_name
      attr_accessor :operation_system
      attr_accessor :automation_drivers

      def initialize
        @automation_drivers = []
      end

      def execute(server, connection)
        server.add_or_update_client(self, connection)
      end
    end
  end
end
