class SlaveLogsController < ApplicationController

  def index     
    unless params[:ip] == ""
      require 'time'
      start_time = params[:start_time] ? (Time.parse(params[:start_time].to_s) - 30).utc : (Time.now-900).utc
      end_time = params[:end_time] ? (Time.parse(params[:end_time].to_s) + 30).utc : Time.now.utc 
      @searched_logs = SlaveLog.where(:ip => params[:ip],:timestamp.gt => start_time,:timestamp.lt => end_time).asc(:_id)
    end
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @logs }
    end
  end

end