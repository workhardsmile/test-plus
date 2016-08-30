class BrowserInfo
  attr_accessor :name
  attr_accessor :version
  attr_accessor :allowed
end

class MachineInfo
  attr_accessor :name
  attr_accessor :os
  attr_accessor :version
  attr_accessor :browsers_info
end

class CapabilityInfo
  attr_accessor :name
  attr_accessor :version
  attr_accessor :status
  attr_accessor :allowed
end

class ClientConfig
  attr_accessor :identity
  attr_accessor :market
  attr_accessor :ip_address
  attr_accessor :machine_info
  attr_accessor :capabilities
end

class ClientAllowed
  attr_accessor :market
  attr_accessor :browsers
  attr_accessor :capabilities
end


class CapabilityStatusCommand
  attr_accessor :name
  attr_accessor :status
  attr_accessor :identity
end