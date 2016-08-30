require 'csv'

class HomeController < ApplicationController
  layout 'no_sidebar'

  def index
    #@overall_dre = Rails.cache.fetch('overall_dre'){Report::Project.where(name: 'Overall').first.dres.last.value}

    #@endurance_dre = Rails.cache.fetch('endurance_dre'){Report::Project.where(name: 'Endurance').first.dres.last.value}

    #@camps_dre = Rails.cache.fetch('camps_dre'){Report::Project.where(name: 'Camps').first.dres.last.value}

    #@sports_dre = Rails.cache.fetch('sports_dre'){Report::Project.where(name: 'Sports').first.dres.last.value}

    #@framework_dre = Rails.cache.fetch('framework_dre'){Report::Project.where(name: 'Framework').first.dres.last.value}

    #@platform_dre = Rails.cache.fetch('platform_dre'){Report::Project.where(name: 'Platform').first.dres.last.value}

    #@membership_dre = Rails.cache.fetch('membership_dre'){Report::Project.where(name: 'Membership').first.dres.last.value}

    #@swimming_dre = Rails.cache.fetch('swimming_dre'){Report::Project.where(name: 'Swimming').first.dres.last.value}

    @project_count = Project.count
    @automation_script_count = AutomationScript.count
    @automation_case_count = AutomationCase.count
    @test_round_count = TestRound.count
    # @activities = Activity.scoped.order('created_at desc').page(0).per(5)

    @activities = Audit.where(:auditable_type => "TestRound", :action => "create").order('created_at desc').limit(5)
    @activities.each do |activity|
      if activity.user.nil?
        activity.user = User.automator
        activity.save
      end
    end
    %w(Endurance Sports Membership RTP Camps).each do |m|
      p = Project.find_by_name(m)
      eval "@#{m.downcase}_link = url_for([:coverage,p])"
      eval "@#{m.downcase}_automated = p.count_test_case_by_plan_type_and_options('regression',{:automated_status => 'Automated'})"
      eval "@#{m.downcase}_automatable = p.count_test_case_by_plan_type_and_options('regression',{:automated_status => 'Automatable'})"
      eval "@#{m.downcase}_update_needed = p.count_test_case_by_plan_type_and_options('regression',{:automated_status => 'Update Needed'})"
      eval "@#{m.downcase}_update_manual = p.count_test_case_by_plan_type_and_options('regression',{:automated_status => 'Update Manual'})"
      eval "@#{m.downcase}_not_ready = p.count_test_case_by_plan_type_and_options('regression',{:automated_status => 'Not Ready for Automation'})"
      eval "@#{m.downcase}_not_candidate = p.count_test_case_by_plan_type_and_options('regression',{:automated_status => 'Not a Candidate'})"
      eval "@#{m.downcase}_total = p.count_test_case_by_plan_type_and_options('regression')"
      eval "@#{m.downcase}_overall_coverage = Project.caculate_coverage_by_project_and_priority_and_type('#{m.downcase}', 'Overall','regression')"
    end

  end

  def get_activities_by_project
    name = params[:name]

    if name.blank?
      @activities = Audit.where(:auditable_type => "TestRound", :action => "create").order('created_at desc').limit(5)
    else
      project = Project.find_by_name(name)
      tr_ids = project.test_rounds.collect{|tr| tr.id}
      @activities = Audit.where(:auditable_type => "TestRound", :action => "create",  :auditable_id => tr_ids).order('created_at desc').limit(5)
    end

    @activities.each do |activity|
      if activity.user.nil?
        activity.user = User.automator
        activity.save
      end
    end
    render :partial => "home/activities"
  end
end
