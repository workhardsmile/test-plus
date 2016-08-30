require "rubygems"
require 'win32/changenotify'
require "rest_client"
require "logger"
include Win32

# Indefinitely wait for a change in 'C:\some\path' and any of its
# subdirectories.  Print the file and action affected.

class MonitorScreenshot

  def initialize(folder_path, server_ip)
    @path = folder_path
    @server_ip = server_ip
	@logger = Logger.new('monito_screenshot.log')
  end

  #
  # => @method upload_img  (Upload the screenshots to server.)
  # => @return nil
  # => @version 2.0
  #
  def upload_img(file_path)
    @logger.info "====> Uploading screenshot: #{file_path}"
    RestClient.post( "http://#{@server_ip}/screen_shots",{
      :screen_shot => { :screen_shot => File.new(file_path) }
    })
    File.delete(file_path)
    @logger.info "====> Uploading Done."
  rescue Exception => e
    @logger.info "Error in function upload_img: #{e.class}"
    @logger.info "#{e}"
  end

  def monitor
    filter = ChangeNotify::FILE_NAME | ChangeNotify::DIR_NAME
    cn = ChangeNotify.new(@path, true, filter)

    cn.wait{ |arr|
      arr.each do |info|
        # p info.file_name
        # p info.action
        if info.action == "added" and ['.png','.jpg'].include?(File.extname(info.file_name).downcase)
          upload_img info.file_name
        end
      end
    }

    cn.close
  end

end

MonitorScreenshot.new(ARGV[0],ARGV[1]).monitor

# OR

# ChangeNotify.new(@path, true, filter) do |events|
#   events.each{ |event|
#     p event.file_name
#     p event.action
#   }
# end