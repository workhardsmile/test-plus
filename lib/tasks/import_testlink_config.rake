namespace :testlink do

  desc "config for importing test cases from TestLink"
  task :import_config => :environment do
    ImportTestlinkConfig.delete_all
    project_mappings = []
    project_mappings << {"testplus_project" => 'Camps',"testlink_project"  => 'Camps'}
    project_mappings << {"testplus_project" => 'Membership',"testlink_project"  => 'Membership'}
    project_mappings << {"testplus_project" => 'ActiveNet',"testlink_project"  => 'ActiveNet'}
    project_mappings << {"testplus_project" => 'Endurance',"testlink_project"  => 'Endurance'}
    project_mappings << {"testplus_project" => 'LeagueOne',"testlink_project"  => 'LeagueOne'}
    project_mappings << {"testplus_project" => 'ACL',"testlink_project"  => 'ACL'}
    project_mappings << {"testplus_project" => 'USTA', "testlink_project" => 'USTA'}
    project_mappings << {"testplus_project" => 'RTP', "testlink_project" => 'RTP-Revolution'}
    project_mappings << {"testplus_project" => 'RTPOneContainer', "testlink_project" => 'RTPOneContainer'}
    project_mappings << {"testplus_project" => 'RTP-MooseCreek', "testlink_project" => 'RTP-MooseCreek'}
    project_mappings << {"testplus_project" => 'Sports', "testlink_project" => "Sports"}
    project_mappings << {"testplus_project" => 'Platform-Checkout', "testlink_project" => "Platform-Checkout"}
    project_mappings << {"testplus_project" => 'RTP-eStore', "testlink_project" => "RTP-eStore"}
    project_mappings << {"testplus_project" => 'Platform-Commerce', "testlink_project" => "Platform-Commerce"}

    project_mappings.each do |config|
      c = ImportTestlinkConfig.new(:testplus_project => config['testplus_project'], :testlink_project => config['testlink_project'])
      c.save
    end

  end

end
