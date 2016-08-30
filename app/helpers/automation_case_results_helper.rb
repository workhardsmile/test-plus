module AutomationCaseResultsHelper
  def format_error_message(error_message)
    regex = /(\[\d+-\d+-\d+\s*\d+:\d+:\d+\])/
    errors = error_message.split(regex)
    #TODO: error handling
    safe_concat("<p>")
    1.upto(errors.length - 1) do |i|
      next if i%2 == 0
      datetime = errors[i]
      begin
        messages = errors[i+1].split("\n")
      rescue Exception => e
        messages =[]
      end
      safe_concat("<p><span class='datetime'>" + datetime + "</span>")
      messages.each do |msg|
        safe_concat("<span class='message'>" + msg + "</span></p>")
      end
    end
    safe_concat("</p>")
  end
end
