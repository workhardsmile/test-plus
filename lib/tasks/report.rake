require 'csv'

namespace :report do

  desc "Init report data in MongoDB"
  task :init => :environment do
    puts "Deleting all the existing projects..."
    Report::Project.delete_all
    %w(Overall Endurance Camps Sports Swimming Membership Platform Framework).each do |project|
      p = Report::Project.create(name: project)
      puts "Created #{project}, start to import old DRE data for it..."
      old_dres = CSV.read(File.join(Rails.root, 'public', 'metrics', project.downcase + '_dre.csv'))
      old_dres.each do |old_dre|
        d = p.dres.build
        d.date = Date.strptime(old_dre[0], "%m/%d/%y")
        d.value = old_dre[1]
        d.save
      end
      puts "imported #{p.dres.count} old dre data for #{project}."

      puts "start to import bugs by severity..."
      if File.exists? File.join(Rails.root, 'public', 'metrics', project.downcase + '_bugs_by_severity.csv')
        old_bugs_by_severities = CSV.read(File.join(Rails.root, 'public', 'metrics', project.downcase + '_bugs_by_severity.csv'))
        old_bugs_by_severities.each do |old_bugs_by_severity|
          b = p.bugs_by_severities.build
          b.date = Date.strptime(old_bugs_by_severity[0], "%m/%d/%y")
          b.severity_1 = old_bugs_by_severity[1]
          b.severity_2 = old_bugs_by_severity[2]
          b.severity_3 = old_bugs_by_severity[3]
          b.severity_4 = old_bugs_by_severity[4]
          b.severity_nyd = old_bugs_by_severity[5]
          b.save
        end
      end
      puts "imported #{p.bugs_by_severities.count} old bugs by severity data for #{project}."

      puts "start to import bugs by who found data..."
      if File.exists? File.join(Rails.root, 'public', 'metrics', project.downcase + '_bugs_by_who_found.csv')
        old_bugs_by_who_founds = CSV.read File.join(Rails.root, 'public', 'metrics', project.downcase + '_bugs_by_who_found.csv')
        old_bugs_by_who_founds.each do |old_bugs_by_who_found|
          b = p.bugs_by_who_founds.build
          b.date = Date.strptime(old_bugs_by_who_found[0], "%m/%d/%y")
          b.external = old_bugs_by_who_found[1]
          b.internal = old_bugs_by_who_found[2]
          b.closed_requirements = old_bugs_by_who_found[3]
          b.save
        end
      end
      puts "imported #{p.bugs_by_who_founds.count} old bugs by who found data for #{project}."

      puts "start to import old technical debt data..."
      if File.exists? File.join(Rails.root, 'public', 'metrics', project.downcase + '_tech_debt.csv')
        old_tech_debts = CSV.read File.join(Rails.root, 'public', 'metrics', project.downcase + '_tech_debt.csv')
        old_tech_debts.each do |old_tech_debt|
          b = p.technical_debts.build
          b.date = Date.strptime(old_tech_debt[0], "%m/%d/%y")
          b.priority_0 = old_tech_debt[1]
          b.priority_1 = old_tech_debt[2]
          b.priority_2 = old_tech_debt[3]
          b.priority_3 = old_tech_debt[4]
          b.priority_4 = old_tech_debt[5]
          b.save
        end
      end
      puts "imported #{p.technical_debts.count} old technical debt data for #{project}."
    end
  end

end