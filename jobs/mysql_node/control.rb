require 'paas/control'

class MysqlNodeControl < PaaS::Control 

  # 默认当前路径为package目录？
  def start 
    if process_exist? pid_file
      puts "mysql node already running, pid is #{get_pid(pid_file)}"
      return 
    end

    log_file = vcap_sys_log + "mysql_node.log"

    config_template = current_dir(__FILE__) + "mysql_node.yml.erb"
    generate_config(config_template, binding)
    
    run "rm #{pid_file}"
    
    cd "#{release_dir}/mysql_service" do
      set_sys_env("CLOUD_FOUNDRY_CONFIG_PATH",vcap_sys_config.to_s)
      ruby "bin/mysql_node -c #{config_file} >>#{vcap_sys_log}/mysql_node.stdout.log 2>>#{vcap_sys_log}/mysql_node.stderr.log &"
    end

  end

end