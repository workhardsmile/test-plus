class ProjectsController < InheritedResources::Base
  def index
    if params[:search]
      @project = Project.find_by_name(params[:search])
      redirect_to project_path(@project) if @project
    end
    @projects = Project.scoped
  end

  def coverage
    @project = Project.find(params[:id])
    project_name = @project.name

    @cui_coverage = []
    @aui_coverage = []
    @coverage = []
    @regression_coverage = []
    %w(Overall P1 P2 P3).each do |priority|
      @cui_coverage << Project.caculate_coverage_by_project_and_priority_and_type(project_name, priority,"CUI")
      @aui_coverage << Project.caculate_coverage_by_project_and_priority_and_type(project_name, priority,"AUI")
      @regression_coverage << Project.caculate_coverage_by_project_and_priority_and_type(project_name, priority,"regression")
      @coverage << Project.caculate_coverage_by_project_and_priority(project_name,priority)
    end
    #count regression test plans only when in below projects
    if %W(Endurance Camps Sports Membership Platform-Checkout RTP-Revolution  RTP-MooseCreek RTPOneContainer ActiveNet LeagueOne).include? project_name
      %W(P1 P2 P3).each do |priority|
        eval "@#{priority}_automated = @project.count_test_case_by_plan_type_and_options('regression',{:automated_status => 'Automated',:priority => '#{priority}'})"
        eval "@#{priority}_update_needed = @project.count_test_case_by_plan_type_and_options('regression',{:automated_status => 'Update Needed',:priority => '#{priority}'})"
        eval "@#{priority}_update_manual = @project.count_test_case_by_plan_type_and_options('regression',{:automated_status => 'Update Manual',:priority => '#{priority}'})"
        eval "@#{priority}_not_candidate = @project.count_test_case_by_plan_type_and_options('regression',{:automated_status => 'Not a Candidate',:priority => '#{priority}'})"
        eval "@#{priority}_not_ready = @project.count_test_case_by_plan_type_and_options('regression',{:automated_status => 'Not Ready for Automation',:priority => '#{priority}'})"
        eval "@#{priority}_automatable = @project.count_test_case_by_plan_type_and_options('regression',{:automated_status => 'Automatable',:priority => '#{priority}'})"
        eval "@#{priority}_total = @project.count_test_case_by_plan_type_and_options('regression',{:priority => '#{priority}'})"
      end
      @total_automated =  @project.count_test_case_by_plan_type_and_options('regression',:automated_status => "Automated")
      @total_update_needed = @project.count_test_case_by_plan_type_and_options('regression',:automated_status => "Update Needed")
      @total_update_manual = @project.count_test_case_by_plan_type_and_options('regression',:automated_status => "Update Manual")
      @total_not_candidate = @project.count_test_case_by_plan_type_and_options('regression',:automated_status => "Not a Candidate")
      @total_not_ready = @project.count_test_case_by_plan_type_and_options('regression',:automated_status => "Not Ready for Automation")
      @total_automatable = @project.count_test_case_by_plan_type_and_options('regression',:automated_status => "Automatable")

      @total = @project.count_test_case_by_plan_type_and_options('regression',{})
    else
      @regression_coverage = @coverage
      %W(P1 P2 P3).each do |priority|
        eval "@#{priority}_automated = @project.count_test_case_by_options({:automated_status => 'Automated',:priority => '#{priority}'})"
        eval "@#{priority}_update_needed = @project.count_test_case_by_options({:automated_status => 'Update Needed',:priority => '#{priority}'})"
        eval "@#{priority}_update_manual = @project.count_test_case_by_options({:automated_status => 'Update Manual',:priority => '#{priority}'})"
        eval "@#{priority}_not_candidate = @project.count_test_case_by_options({:automated_status => 'Not a Candidate',:priority => '#{priority}'})"
        eval "@#{priority}_not_ready = @project.count_test_case_by_options({:automated_status => 'Not Ready for Automation',:priority => '#{priority}'})"
        eval "@#{priority}_automatable = @project.count_test_case_by_options({:automated_status => 'Automatable',:priority => '#{priority}'})"
        eval "@#{priority}_total = @project.count_test_case_by_options({:priority => '#{priority}'})"
      end
      @total_automated =  @project.count_test_case_by_options(:automated_status => "Automated")
      @total_update_needed = @project.count_test_case_by_options(:automated_status => "Update Needed")
      @total_update_manual= @project.count_test_case_by_options(:automated_status => "Update Manual")
      @total_not_candidate = @project.count_test_case_by_options(:automated_status => "Not a Candidate")
      @total_not_ready = @project.count_test_case_by_options(:automated_status => "Not Ready for Automation")
      @total_automatable = @project.count_test_case_by_options(:automated_status => "Automatable")

      @total = @project.count_test_case_by_options
    end

  end

end
