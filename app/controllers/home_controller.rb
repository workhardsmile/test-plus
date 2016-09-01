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
    # %w(Endurance Sports Membership RTP Camps).each do |m|
    @project_coverages = []
    Project.find(:all,:order=>'name').each do |p|
      unless %w(camps rtp).include?(p.name.downcase)
        @project_coverage = {}
        @project_coverage["name"] = p.name
        @project_coverage["link"] = url_for([:coverage,p])
        @project_coverage["automated"] = p.count_test_case_by_plan_type_and_options('regression',{:automated_status => 'Automated'})
        @project_coverage["automatable"] = p.count_test_case_by_plan_type_and_options('regression',{:automated_status => 'Automatable'})
        @project_coverage["update_needed"] = p.count_test_case_by_plan_type_and_options('regression',{:automated_status => 'Update Needed'})
        @project_coverage["update_manual"] = p.count_test_case_by_plan_type_and_options('regression',{:automated_status => 'Update Manual'})
        @project_coverage["not_ready"] = p.count_test_case_by_plan_type_and_options('regression',{:automated_status => 'Not Ready for Automation'})
        @project_coverage["not_candidate"] = p.count_test_case_by_plan_type_and_options('regression',{:automated_status => 'Not a Candidate'})
        @project_coverage["total"] = p.count_test_case_by_plan_type_and_options('regression')
        @project_coverage["overall_coverage"] = Project.caculate_coverage_by_project_and_priority_and_type(p.name, 'Overall','regression')
        @project_coverages = @project_coverages << @project_coverage
      end
    end
    @project_coverages   
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
