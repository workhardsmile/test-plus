require "win32ole"

class ClientHelper
  def initialize log
    @logger = log
  end

  #
  # => @method get_os_information (Get operating system information)
  # => @return Hash {:name=>XXX,:version=>XXX}
  # => @version 1.0
  #
  def get_os_information()
    mgmt = WIN32OLE.connect('winmgmts:\\\\.')
    name = ""
    version = ""
    mgmt.ExecQuery("select * from Win32_OperatingSystem" ).each do |m|
      name = m.Caption
      version = "SP#{m.ServicePackMajorVersion} #{m.version}"
    end
    @logger.debug "get os information sucessfully\nname=#{name} version=#{version}"
    os_info = {:name=>name,:version=>version}
  rescue Exception => e
    @logger.fatal "Error in function get_os_information #{e.class}"
    @logger.fatal "#{e}"
  end

  #
  # => @method get_ip_address (Get ip address)
  # => @return string eg:10.109.0.39
  # => @version 1.0
  #
  def get_ip_address()
    mgmt = WIN32OLE.connect('winmgmts:\\\\.\\root\\cimv2')
    ip = ""
    mgmt.ExecQuery("Select IPAddress from Win32_NetworkAdapterConfiguration Where IPEnabled=TRUE" ).each do |m|
      ip = m.IPAddress[0]
    end
    @logger.debug "get ip sucessfully\nip=#{ip}"
    return ip
  rescue Exception => e
    @logger.fatal "Error in function get_ip_address #{e.class}"
    @logger.fatal "#{e}"
  end

  #
  # => @method get_browser_information (Get the browser information)
  # => @return Hash {:name=>XXX,:version=>XXX}
  # => @version 1.0
  #
  def get_browser_information()
    mgmt = WIN32OLE.connect('winmgmts:\\\\.\\root\\cimv2\\Applications\\MicrosoftIE')
    name = ""
    version = ""
    mgmt.ExecQuery("select * from MicrosoftIE_Summary" ).each do |m|
      name = m.name
      version = m.version
    end
    @logger.debug "get browser information sucessfully\nname=#{name} version=#{version}"
    browser_info = {:name=>name,:version=>version}
  rescue Exception => e
    @logger.fatal "Error in function get_browser_information #{e.class}"
    @logger.fatal "#{e}"
  end

  def get_fileversion_by_path(path)
    result = ""
    fileOLE = WIN32OLE.new("Scripting.FileSystemObject")
    if fileOLE.FileExists(path)
      result = fileOLE.GetFileVersion(path)
    end
    @logger.info "get_fileversion_by_path #{path} result= #{result} "
    result
  rescue Exception => e
    @logger.fatal "Error in function - get_fileversion_by_path #{path}"
    @logger.fatal "#{e}"
  end

  def get_fileversion_for_soapui(path)
    result = "3.5.1"
  rescue Exception => e
    @logger.fatal "Error in function - get_fileversion_for_soapui #{path}"
    @logger.fatal "#{e}"
  end

  #
  # => @method get_machine_name (Get the machine name)
  # => @return string
  # => @version 1.0
  #
  def get_machine_name()
    mgmt = WIN32OLE.connect('winmgmts:\\\\.\\root\\cimv2')
    name = ""
    mgmt.ExecQuery("select * from Win32_ComputerSystem" ).each do |m|
      name = m.name
    end
    @logger.debug "get machine name sucessfully\nname=#{name}"
    return name
  rescue Exception => e
    @logger.fatal "Error in function get_machine_name #{e.class}"
    @logger.fatal "#{e}"
  end
end
