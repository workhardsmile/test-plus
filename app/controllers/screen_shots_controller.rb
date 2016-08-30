class ScreenShotsController < InheritedResources::Base
  def create
    logger.info "------request parameters-------------"
    logger.info "#{request.request_parameters}"
    logger.info "-------------------"
    @screen_shot = ScreenShot.new(request.request_parameters)

    acr = AutomationCaseResult.where("screen_shot LIKE ?","%#{@screen_shot.screen_shot_file_name}%").last
    if acr
      logger.warn "------- acr.screen_shot : #{@screen_shot.screen_shot_file_name} -----" if acr.screen_shots.count > 2
      @screen_shot.automation_case_result = acr
    else
      logger.warn "-------A screen shot uploaded without finding a corresponding Automation Case Result: #{@screen_shot.screen_shot_file_name}"
    end

    respond_to do |format|
      if @screen_shot.save
        format.html { redirect_to(@screen_shot, :notice => 'Screen Shot was successfully created.') }
        format.xml  { render :xml => @screen_shot, :status => :created, :location => @screen_shot }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @screen_shot.errors, :status => :unprocessable_entity }
      end
    end
  end
end
