require 'paas/control'

class MysqlGatewayControl < PaaS::Control 

  # 默认当前路径为package目录？
  def start 
    if process_exist? pid_file
      puts "mysql gateway already running, pid is #{get_pid(pid_file)}"
      return 
    end

    sleep 4 while not (run("curl http://localhost:8080/uaa") == 0)

    log_file = vcap_sys_log + "mysql_gateway.log"

    config_template = current_dir(__FILE__) + "mysql_gateway.yml.erb"
    generate_config(config_template, binding)
    
    run "rm #{pid_file}"

#    run "sudo service mysql restart"

#    run "sudo service redis-server restart"

    cd "#{release_dir}/mysql_service" do
      set_sys_env("CLOUD_FOUNDRY_CONFIG_PATH",vcap_sys_config.to_s)
      ruby "bin/mysql_gateway -c #{config_file} >>#{vcap_sys_log}/mysql_gateway.stdout.log 2>>#{vcap_sys_log}/mysql_gateway.stderr.log &"
    end
  end

end