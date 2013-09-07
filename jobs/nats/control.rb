require 'paas/control'

class NatsControl < PaaS::Control 

  # 默认当前路径为package目录？
  def start 
    if process_exist? pid_file
      puts "nats already running, pid is #{get_pid(pid_file)}"
      return 
    end

    log_file = vcap_sys_log + "nats.log"

    config_template = current_dir(__FILE__) + "nats.yml.erb"
    generate_config(config_template, binding)
    
    cd package_dir do 
      bundle_exec "bin/nats-server -d -c #{config_file} >>#{vcap_sys_log}/nats.stdout.log 2>>#{vcap_sys_log}/nats.stderr.log"
    end
  end

end
