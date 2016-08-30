require "rubygems"
require "rest_client"
require "rexml/document"
require "httpclient"
require "yaml"

def post_script_result(test_round_id,automation_script_name,script_status)
  puts "====> Posting script results..."

  doc = REXML::Document.new
  protocol = doc.add_element("protocol")
  what = protocol.add_element("what")
  what.add_text "Script"
  round_id = protocol.add_element("round_id")
  round_id.add_text test_round_id
  data = protocol.add_element("data")
  start_time = data.add_element("start_time")
  start_time.add_text Time.now.to_s
  end_time = data.add_element("end_time")
  end_time.add_text Time.now.to_s
  script_name = data.add_element("script_name")
  script_name.add_text automation_script_name
  state = data.add_element("state")
  state.add_text script_status

  service_info = "Service1##1.0.1"
  service_info.split("||").each do |s|
    info = s.split('##')
    services = data.add_element("service")
    service_name = services.add_element("name")
    service_name.add_text info[0]
    service_version = services.add_element("version")
    service_version.add_text info[1]
  end

  puts "xml to be post --> #{doc.to_s}"
  url = "http://localhost:3000/status/update"
  puts url

  HTTPClient.post url, doc, {"Content-Type" => "text/xml"}

  puts "Posting script done."

rescue Exception => e
  puts "Error in function post_result: #{e.class}"
  puts "#{e}"
end

def post_case_result(tr_id,automation_script_name,ac_id,tc_result,tc_error,screen_shot_name)
  puts "====> Posting case results..."

  doc = REXML::Document.new
  protocol = doc.add_element("protocol")
  what = protocol.add_element("what")
  what.add_text "Case"
  round_id = protocol.add_element("round_id")
  round_id.add_text tr_id
  data = protocol.add_element("data")
  script_name = data.add_element("script_name")
  script_name.add_text automation_script_name
  case_id = data.add_element("case_id")
  case_id.add_text ac_id
  result = data.add_element("result")
  result.add_text tc_result
  error = data.add_element("error")
  error.add_text tc_error
  screen_shot = data.add_element("screen_shot")
  screen_shot.add_text screen_shot_name

  puts "xml to be post --> #{doc.to_s}"
  url = "http://localhost:3000/status/update"
  puts "url --> #{url}"

  HTTPClient.post url, doc, {"Content-Type" => "text/xml"}

  puts "Posting case done."

rescue Exception => e
  puts "Error in function post_result: #{e.class}"
  puts "#{e}"
end

def upload_img(file_path)
  puts "====> Uploading screenshot: #{file_path}"
  file = File.new(file_path)
  RestClient.post( "http://localhost:3000/screen_shots",{:screen_shot => { :screen_shot => file}})
  puts "====> Uploading Done."
rescue Exception => e
  puts "Error in function upload_img: #{e.class}"
  puts "#{e}"
end

$ROUND_ID = "24"
$SCRIPT_NAME = "Demo Script"
$SCREEN_SHOT = "/Users/yangeric/Pictures/test1.png"


post_script_result $ROUND_ID,$SCRIPT_NAME,"start"
#sleep 3
post_case_result $ROUND_ID,$SCRIPT_NAME,"1.01","pass","",""
post_case_result $ROUND_ID,$SCRIPT_NAME,"1.02","failed","Password is not correct!","test1.png"
upload_img $SCREEN_SHOT
post_case_result $ROUND_ID,$SCRIPT_NAME,"1.03","pass","",""


post_script_result $ROUND_ID,$SCRIPT_NAME,"end"