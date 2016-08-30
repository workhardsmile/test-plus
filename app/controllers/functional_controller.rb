require 'csv'

class FunctionalController < ApplicationController

  layout 'no_sidebar'
  respond_to :csv

  before_filter :authenticate_user!

  def rmf_original_estimate
  end

  def rmf_original_estimate_query

    if params['project']
      project = params['project']
      release = params['release']
      task_type = params['task_type']
      requirements = get_requirements_of_a_project_release(project, release)
      logger.info requirements
    else
      calculation_results = []
      get_original_estimate_of_a_roadmap_feature(params['rmf_key'], params['task_type'], calculation_results)
      reference_dict = {}
      calculation_results.each do |cr|
        reference_dict[cr[0]] = [cr[1], cr[2]]
      end

      requirements = get_requirements_of_a_roadmap_feature(params['rmf_key'])

      csv_string = CSV.generate do |csv|
        csv << ['Requirement', 'Original Time Estimate in hour', "count of #{params['task_type']}"]
        requirements.each do |req|
          if reference_dict.has_key? req[0]
            csv << [req[0], reference_dict[req[0]]].flatten
          else
            csv << [req[0], 'Not Available', '0']
          end
        end
      end
    end


    respond_to do |format|
      format.csv {send_data csv_string, :filename => "#{params['rmf_key']}_original_estimate.csv"}
    end
  end

  def bug_report
    # get_endurance_latest_24hr_bugs_data
    # get_sports_latest_24hr_bugs_data
    # get_camps_latest_24hr_bugs_data
  end

  def generate_bug_report
    @project_name = params[:project]
    @from = params[:from]
    @to = params[:to]

    jira_query = "
    select j2.pkey as 'req number',
    j1.pkey as 'bug number',
    j2.priority as 'req priority',
    j1.priority as 'sub task priority',
    cfv1.STRINGVALUE as 'How bug was found',
    cfv2.STRINGVALUE as 'Defect Origin',
    j1.summary as 'sub task summary',
    j2.summary as 'req summary'
    from jiraissue j1
    join project p on p.id = j1.project
    left join issuelink i1 on j1.id = i1.destination and i1.linktype = 10000
    left join jiraissue j2 on j2.id = i1.source
    left join customfieldvalue cfv1 on j1.id = cfv1.ISSUE and cfv1.CUSTOMFIELD = 10023
    left join customfieldvalue cfv2 on j1.id = cfv2.ISSUE and cfv2.CUSTOMFIELD = 10081
    where j1.issuetype in (select id from issuetype where issuetype.pname='Bug' or issuetype.pname = 'Bug Sub-Task')
    and p.pname = '#{@project_name}'
    and j1.created >= '#{@from}'
    and j1.created <= '#{@to}'
    "
    result = FndJira.connection.execute(jira_query)

    logger.info "#{result.count}"

    csv_string = CSV.generate do |csv|
      csv << ['req number', 'bug number', 'req priority', 'bug priority', 'How bug was found', 'Defect Origin', 'sub task summary', 'req summary']
      result.each do |row|
        csv << row
      end
    end

    respond_to do |format|
      format.csv {send_data csv_string, :filename => 'bug.csv'}
    end
  end

  def endurance_qa_effort_report
    if request.remote_ip != '127.0.0.1'
      render :text => "Not allowed to generate from anywhere other than the server itself."
    else
      tdate = Time.now
      pdate = tdate - (24*60*60)
      sql_pdate = pdate.strftime("%Y-%m-%d %H:%M:%S")
      sql_tdate = tdate.strftime("%Y-%m-%d %H:%M:%S")
      jira_query = "
      select w.startdate,
      w.author,
      w.timeworked,
      j.pkey,
      j.summary,
      w.worklogbody
      from worklog w
      inner join jiraissue j on j.id = w.issueid
      where w.author in ('pzhong', 'czheng', 'ewang3', 'ftang', 'atang', 'shuang3', 'kcai', 'jlakin', 'jxiao')
      and w.startdate > '#{sql_pdate}' and w.startdate < '#{sql_tdate}'
      order by w.author asc
      limit 100
      "
      result = FndJira.connection.execute(jira_query)
      @work_logs = []
      result.each do |t|
        @work_logs << {
          "name" => t[1],
          "ticket" => t[3],
          "summary" => t[4],
          "work_time" => t[2]
        }
      end
      FunctionalMailer.endurance_qa_effort(tdate, @work_logs).deliver
    end
  end

  def generate_rejected_bug_report
    @project_name = params[:project]
    @from = params[:from]
    @to = params[:to]

    get_rejected_bugs_query ="
    select DISTINCT(j.pkey) as 'Bug Key',
    j.summary as 'Summary',
    u.display_name as 'Rejected By',
    cg.created as 'Rejected Time',
    cg.id 'ChangeGroup ID'
    from changeitem ci
    join changegroup cg on cg.id = ci.groupid
    join jiraissue j on j.id = cg.issueid
    join project p on p.id = j.project
    join cwd_user u on cg.author = u.lower_user_name
    where ci.OLDVALUE = '10005'
    and ci.NEWVALUE = '3'
    and p.pname = '#{@project_name}'
    and cg.created >= '#{@from}'
    and cg.created <= '#{@to}'
    and (j.issuetype = '1' or j.issuetype = '3')
    "
    result = FndJira.connection.execute(get_rejected_bugs_query)
    logger.info "#{result.count}"
    csv_string = CSV.generate do |csv|
      csv << ['Bug Key','Bug Summary','Rejected Time','Who Rejected','Developer']
      result.each do |row|
        get_developer_name_query = "
        select j.pkey,
        max(ci.id),
        u.display_name
        from changeitem ci
        join changegroup cg on cg.id = ci.groupid
        join jiraissue j on j.id = cg.issueid
        join cwd_user u on cg.author = u.lower_user_name
        where j.pkey = '#{row[0]}'
        and ci.OLDVALUE = '3'
        and ci.NEWVALUE = '10005'
        and ci.groupid <= '#{row[4]}'
        "
        result2 = FndJira.connection.execute(get_developer_name_query)

        result2.each do |t|
          csv <<[row[0],row[1],row[3],row[2],t[2]]
        end
      end
    end
    respond_to do |format|
      format.csv {send_data csv_string, :filename => 'rejected_bugs.csv'}
    end
  end


  def generate_automation_status_report
    date_today = Time.now.strftime('%d-%b-%y')
    @projects = params[:projects]
    csv_string = CSV.generate do |csv|
      csv << ['Date','Application','Automated','Update Needed','Automatable','Not a Candidate','Not Ready','Unknown','Total Test Cases','QA Backlog','% Automated','% Automatable','% Automation Progress','Owner']
      @projects.each do |project_name|
        project = Project.find_by_name(project_name)
        project_owner = project.project_category.name
        application = project.dashboard_name
        automation_status = project.current_automation_status
        automatable_rate =  automation_status['automatable_rate'] > 0 ? format('%.2f',automation_status['automatable_rate']*100) : 0
        csv << [
          date_today,
          application,
          automation_status['automated'],
          automation_status['update_needed']+automation_status['update_manual'],
          automation_status['automatable'],
          automation_status['not_candidate'],
          automation_status['not_ready'],
          automation_status['unknown'],
          automation_status['total_case'],
          format_percent(automation_status['qa_backlog']),
          format_percent(automation_status['automated_rate']),
          automatable_rate,
          format_percent(automation_status['automation_progress']),
          project_owner]
        end
      end
      respond_to do |format|

        format.csv {
          send_data csv_string, :filename => "automation_status_#{Time.now.strftime('%d_%b_%y').downcase}.csv"
        }
      end
    end


    def generate_update_needed_script_report
      @project_name = params[:project]
      p = Project.find_by_name(@project_name)
      csv_string = CSV.generate do |csv|
        csv << ['TestPlan Name','Num of P1',"Case IDs for P1",'Num of P2',"Case IDs for P2",'Num of P3',"Case IDs for P3"]
        p.test_plans.each do |tp|
          if tp.status == 'completed'
            numbers = []
            case_ids = []
            %w(P1 P2 P3).each do |priority|
              numbers << TestCase.includes("test_plan").where(:priority => priority, :automated_status => "Update Needed", :test_plans => {:id => tp.id,:status => "completed"}).count
              cases = []
              tp.test_cases.where(:priority => priority,:automated_status => "Update Needed").each do |tc|
                cases << tc.case_id
              end
              case_ids << cases
              # TestCase.includes("test_plan").where(:priority => priority, :automated_status => "Update Needed", :test_plans => {:id => tp.id,:status => "completed"}).select("case_id")
            end
            csv << [tp.name,numbers[0],case_ids[0],numbers[1],case_ids[1],numbers[2],case_ids[2]] if numbers[0]+numbers[1]+numbers[2] > 0
          end
        end
      end
      today = Date.today
      today_str = "#{today.month}_#{today.day}_#{today.year}"
      respond_to do |format|
        format.csv {send_data csv_string, :filename => "update_needed_script_#{today_str}.csv"}
      end
    end

    def generate_automation_results_report
      test_round = TestRound.find(params['test_round_id'])
      csv_string = CSV.generate do |csv|
        if test_round
          # Test Round General Info
          csv << ['TestRound ID', params['test_round_id']]
          csv << ['Environment', test_round.test_environment.name]
          csv << ['OS',test_round.operation_system.name]
          csv << ['Browser Type',test_round.browser.name]
          csv << ['Test Result Count ']
          csv << ['Total Pass',test_round.pass_count]
          csv << ['Total Failed',test_round.failed_count]
          csv << ['Total Not-Run', test_round.not_run_count]
          csv << ['Triage Result']
          triage_result_analysis = test_round.triage_result_analysis
          triage_result_analysis.each do |k,v|
            csv <<[k,v]
          end
          csv << ['Test Plan Name','Script Name','Case Name','Case ID','Result','Automation Status','Error Type','Triage Message','Testlink ID']
          test_round_result = test_round.get_test_result_hash
          project_test_plans = test_round.project.get_test_plans_and_automation_scripts

          project_test_plans.each do |plan_name,plan_info|
            plan_info['test_cases'].each do |case_id,case_info|
              if test_round_result.has_key? case_id
                csv << [
                  plan_name,
                  test_round_result[case_id]['script_name'],
                  case_info['name'],
                  case_id,
                  test_round_result[case_id]['result'],
                  case_info['automated_status'],
                  test_round_result[case_id]['error_type'],
                  test_round_result[case_id]['triage_result'],
                  case_info['test_link_id'],
                  case_info['plan_type']
                ]
              else
                csv << [
                  plan_name,
                  "",
                  case_info['name'],
                  case_id,
                  "",
                  case_info['automated_status'],
                  "",
                  "",
                  case_info['test_link_id'],
                  case_info['plan_type']
                ]
              end
            end
          end

        end
      end
      respond_to do |format|
        file_name =  "test_round_#{params['test_round_id']}_result_#{Time.now.strftime("%Y%m%d_%H%M%S")}.csv"
        format.csv {send_data(csv_string, :filename => file_name)}
      end
    end

    private
    def get_jira_projects
      projects = []
      query = "select id, pname from project"
      FndJira.connection.execute(query).each{|project| projects << project}
      projects
    end

    def get_releases_of_a_jira_project(project)
      releases = []
      query = "select id, vname from projectversion where project = #{project} and vname like 'Release%'"
      FndJira.connection.execute(query).each{|release| releases << release}
      releases
    end

    def get_requirements_of_a_project_release(project, release)
      requirements = []
      query = "select pv.id from projectversion pv join project p on p.pname='#{project}' and pv.project=p.id and pv.vname='#{release}'"

      release_id = FndJira.connection.execute(query).first[0]

      query = "select j1.id from jiraissue j1 join nodeassociation n on n.SINK_NODE_ID=#{release_id} and association_type='IssueFixVersion' and n.source_node_id=j1.id and j1.issuetype=14"
      FndJira.connection.execute(query).each{|req| requirements << req}
      requirements
    end

    def get_count_of_sub_task_of_requirements(requirments)
      query = "select "
    end

    def get_requirements_of_a_roadmap_feature(rmf_key)
      query = "select j1.pkey as 'req number'
      from jiraissue j1
      join issuelink i1 on j1.id = i1.destination
      join jiraissue j2 on j2.id = i1.source and i1.linktype=10020
      where j2.pkey='#{rmf_key}'
      "
      results = []
      FndJira.connection.execute(query).each do |result|
        results << result
      end
      results
    end

    def get_original_estimate_of_a_roadmap_feature(rmf_key, task_type, results)
      query = "select j2.pkey as 'req number',
      SUM(j1.timeoriginalestimate)/3600 as 'Estimate',
      COUNT(j1.pkey) as 'count of subtasks'
      from jiraissue j1
      join issuelink i1 on j1.id = i1.destination
      join jiraissue j2 on j2.id = i1.source and i1.linktype=10000
      join issuelink i2 on j2.id = i2.destination
      join jiraissue j3 on j3.id = i2.source and i2.linktype=10020
      join issuetype it on it.id = j1.issuetype and it.pname='#{task_type}'
      where j3.pkey='#{rmf_key}'
      group by j2.pkey"

      FndJira.connection.execute(query).each do |result|
        results << result
      end
    end

    def get_latest_24hr_bugs_query(project_name, priority)
      query = "select count(*) from jiraissue j1 join project p on p.id = j1.project where j1.issuetype in (select id from issuetype where issuetype.pname = 'Bug' or issuetype.pname = 'Bug Sub-Task') and j1.created >= '#{Date.today - 1}' and p.pname = '" + project_name + "'"
      unless priority.nil?
        query = query + " and j1.priority = #{priority}"
      end
      query
    end

    def get_endurance_latest_24hr_bugs_data
      project_name = 'Endurance'

      jira_query = get_latest_24hr_bugs_query(project_name, nil)
      all_count = FndJira.connection.execute(jira_query).first[0]
      logger.info "all: #{all_count}"

      jira_query = get_latest_24hr_bugs_query(project_name, 1)
      p0_count = FndJira.connection.execute(jira_query).first[0]
      logger.info "priority 1: #{p0_count}"

      jira_query = get_latest_24hr_bugs_query(project_name, 2)
      p1_count = FndJira.connection.execute(jira_query).first[0]
      logger.info "priority 1: #{p1_count}"

      jira_query = get_latest_24hr_bugs_query(project_name, 3)
      p2_count = FndJira.connection.execute(jira_query).first[0]
      logger.info "priority 1: #{p2_count}"

      jira_query = get_latest_24hr_bugs_query(project_name, 4)
      p3_count = FndJira.connection.execute(jira_query).first[0]
      logger.info "priority 1: #{p3_count}"

      jira_query = get_latest_24hr_bugs_query(project_name, 5)
      p4_count = FndJira.connection.execute(jira_query).first[0]
      logger.info "priority 1: #{p4_count}"

      today = Date.today
      today_str = "#{today.month}/#{today.day}/#{today.year.to_s[2, 2]}"

      CSV.open(File.join(Rails.root, 'public', 'metrics', 'endurance_latest_24hr_bugs.csv'), 'a') do |csv|
        csv << [today_str, all_count, p0_count, p1_count, p2_count, p3_count, p4_count]
      end
    end

    def get_camps_latest_24hr_bugs_data
      project_name = 'Camps'
      jira_query = get_latest_24hr_bugs_query(project_name, nil)
      all_count = FndJira.connection.execute(jira_query).first[0]
      logger.info "all: #{all_count}"

      jira_query = get_latest_24hr_bugs_query(project_name, 1)
      p0_count = FndJira.connection.execute(jira_query).first[0]
      logger.info "priority 1: #{p0_count}"

      jira_query = get_latest_24hr_bugs_query(project_name, 2)
      p1_count = FndJira.connection.execute(jira_query).first[0]
      logger.info "priority 1: #{p1_count}"

      jira_query = get_latest_24hr_bugs_query(project_name, 3)
      p2_count = FndJira.connection.execute(jira_query).first[0]
      logger.info "priority 1: #{p2_count}"

      jira_query = get_latest_24hr_bugs_query(project_name, 4)
      p3_count = FndJira.connection.execute(jira_query).first[0]
      logger.info "priority 1: #{p3_count}"

      jira_query = get_latest_24hr_bugs_query(project_name, 5)
      p4_count = FndJira.connection.execute(jira_query).first[0]
      logger.info "priority 1: #{p4_count}"

      today = Date.today
      today_str = "#{today.month}/#{today.day}/#{today.year.to_s[2, 2]}"

      CSV.open(File.join(Rails.root, 'public', 'metrics', 'camps_latest_24hr_bugs.csv'), 'a') do |csv|
        csv << [today_str, all_count, p0_count, p1_count, p2_count, p3_count, p4_count]
      end
    end

    def get_sports_latest_24hr_bugs_data
      project_name = 'Team Sports'
      jira_query = get_latest_24hr_bugs_query(project_name, nil)
      all_count = FndJira.connection.execute(jira_query).first[0]
      logger.info "all: #{all_count}"

      jira_query = get_latest_24hr_bugs_query(project_name, 1)
      p0_count = FndJira.connection.execute(jira_query).first[0]
      logger.info "priority 1: #{p0_count}"

      jira_query = get_latest_24hr_bugs_query(project_name, 2)
      p1_count = FndJira.connection.execute(jira_query).first[0]
      logger.info "priority 1: #{p1_count}"

      jira_query = get_latest_24hr_bugs_query(project_name, 3)
      p2_count = FndJira.connection.execute(jira_query).first[0]
      logger.info "priority 1: #{p2_count}"

      jira_query = get_latest_24hr_bugs_query(project_name, 4)
      p3_count = FndJira.connection.execute(jira_query).first[0]
      logger.info "priority 1: #{p3_count}"

      jira_query = get_latest_24hr_bugs_query(project_name, 5)
      p4_count = FndJira.connection.execute(jira_query).first[0]
      logger.info "priority 1: #{p4_count}"

      today = Date.today
      today_str = "#{today.month}/#{today.day}/#{today.year.to_s[2, 2]}"

      CSV.open(File.join(Rails.root, 'public', 'metrics', 'sports_latest_24hr_bugs.csv'), 'a') do |csv|
        csv << [today_str, all_count, p0_count, p1_count, p2_count, p3_count, p4_count]
      end

    end
    def format_percent(number)
      if number > 0
        "#{format('%.2f',number.to_f*100)}%"
      else
        '0%'
      end
    end

  end
