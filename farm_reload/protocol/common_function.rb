require "rubygems"
require "win32/process"
require "win32ole"
require "rest_client"
require "rexml/document"
require "httpclient"
require "yaml"
require "find"

# => @method update_folder (Using tortoise command to update the specified folder.)
# => @param folder_path (The specified folder path to be updated.)
# => @return nil
#
def update_folder(tortoise_path,folder_path)
  puts "====> Updating #{folder_path} from SVN..."
  # system "#{tortoise_path} /command:update /path:\"#{folder_path}\" /closeonend:1" # => closeonend:1 (Close the svn update window once it's finished.)
  system "\"#{tortoise_path}\" up \"#{folder_path}\""
rescue Exception => e
  puts "Error in function update_folder: #{e.class}"
  puts "#{e}"
end

# => @method search_case (Search a specified directory path to find the specified directory.)
# => @param directory_path (The specified directory path to be searched.)
# => @param case_name (The specified test case name to be searched.)
# => @return array
#
def search_case(folder_path,script_file_name)
  puts "====> Searching script: '#{script_file_name}' under folder: '#{folder_path}'"
  script_file = nil
  if File.directory? folder_path
    Dir.foreach(folder_path) do |file|
      if file!="." and file!=".." and (File.directory?(folder_path+file)) and file == script_file_name
        script_file = folder_path + file
        break
      end
    end
  end
rescue Exception => e
  puts "Error in function search_case: #{e.class}"
  puts "#{e}"
ensure
  return script_file
end

# => @method search_case_file (Search a specified file path to find the specified directory.)
# => @param directory_path (The specified directory path to be searched.)
# => @param case_file_name (The specified test case file name to be searched.)
# => @return array
#
def search_case_file(folder_path,script_file_name)
  puts "====> Searching script: '#{script_file_name}' under folder: '#{folder_path}'"
  script_file = nil
  if File.directory? folder_path
    Dir.foreach(folder_path) do |file|
      if file != "." and file != ".." and File.file?(folder_path + file) and file == script_file_name
        script_file = folder_path + file
        break
      end
    end
  end
rescue Exception => e
  puts "Error in function search_case_file:"
  puts "#{e.class}:\n#{e}"
ensure
  return script_file
end

def search_case_file_recursive(folder_path,script_file_name)
  puts "====> Searching script: '#{script_file_name}' under folder: '#{folder_path}'"
  script_file = nil
  if File.directory? folder_path
    Find.find(folder_path) do |file_path|
      if File.file?(file_path) and File.basename(file_path) == script_file_name
        script_file = file_path
        break
      end
    end
  end
rescue Exception => e
  puts "Error in function search_case_file:"
  puts "#{e.class}:\n#{e}"
ensure
  return script_file
end

# => @method kill_process (Kill the specified process if it exists.)
# => @param process_name (The specified process name to be killed.)
# => @return nil
#
def kill_process(process_name)
  puts "====> Killing process #{process_name}..."
  mgmt = WIN32OLE.connect('winmgmts:\\\\.')
  mgmt.ExecQuery("Select * from Win32_Process Where Name = '#{process_name}'").each{ |item| item.Terminate() }
rescue Exception => e
  puts "Error in function kill_process: #{e.class}"
  puts "#{e}"
end

def delete_img(file_path)
  p "====> Deleting all images from #{file_path}..."
  Dir.foreach(file_path) do |file|
    if File.file?(file_path+file) and File.extname(file)=='.png'
      File.delete(file_path+file)
    end
  end
  p "====> Deleting Done."
rescue Exception => e
  p "Error in function delete_img: #{e.class}"
  p "#{e}"
end

def upload_img(file_path)
  p "====> Uploading images from #{file_path}..."
  Dir.foreach(file_path) do |file|
    if File.file?(file_path+file) and File.extname(file)=='.png'
      puts "======> Uploading #{file_path+file}"
      RestClient.post( "http://#{@server_ip}/screen_shots",{
        :screen_shot => { :screen_shot => File.new(file_path+file) }
      })
      File.delete(file_path+file)
    end
  end
  p "====> Uploading Done."
rescue Exception => e
  p "Error in function upload_img: #{e.class}"
  p "#{e}"
end

# => @method post_result (Post a message to the specified url.)
# => @param test_round_id (The specified round id/build number.)
# => @param automation_script_name (The specified automation script name.)
# => @param script_status (The specified status of a round. start/end/killed/service error/not implemented)
# => @return nil
#
def post_result(test_round_id,automation_script_name,script_status)
  puts "====> Posting results..."

  doc = REXML::Document.new
  protocol = doc.add_element("protocol")
  what = protocol.add_element("what")
  what.add_text "Script"
  round_id = protocol.add_element("round_id")
  round_id.add_text test_round_id
  data = protocol.add_element("data")
  script_name = data.add_element("script_name")
  script_name.add_text automation_script_name
  state = data.add_element("state")
  state.add_text script_status

  # puts "xml to be post --> #{doc.to_s}"
  url = "http://#{@server_ip}/status/update"
  #puts url
  HTTPClient.post url, doc, {"Content-Type" => "text/xml"}
  puts "====> Posting done."
rescue Exception => e
  puts "Error in function post_result: #{e.class}"
  puts "#{e}"
end
