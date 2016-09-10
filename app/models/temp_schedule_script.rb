# == Schema Information
#
# Table name: temp_schedule_scripts
#
# `id` int(11) NOT NULL AUTO_INCREMENT,
# `platform` varchar(255) DEFAULT NULL,
# `ip` varchar(255) DEFAULT NULL,
# `test_round_id` int(11) DEFAULT NULL,
# `script_result_id` int(11) DEFAULT NULL,
# `timeout_limit` int(11) DEFAULT NULL,
# `script_name` varchar(255) DEFAULT NULL,
# `project_name` varchar(255) DEFAULT NULL,
# `branch_name` varchar(255) DEFAULT NULL,
# `source_path` varchar(255) DEFAULT NULL,
# `source_cmd` varchar(255) DEFAULT NULL,
# `exec_path` varchar(255) DEFAULT NULL,
# `exec_cmd` varchar(255) DEFAULT NULL,
# `env_name` varchar(255) DEFAULT NULL,
# `deleted` tinyint(1) DEFAULT 0,
#
class TempScheduleScript < ActiveRecord::Base
end