require 'paas/control'

class RouterControl < PaaS::Control 

  # 默认当前路径为package目录？
  def start 
    if process_exist? pid_file
      puts "router already running, pid is #{get_pid(pid_file)}"
      return 
    end

    log_file = vcap_sys_log + "router.log"
    access_log_file = vcap_sys_log + "router_access.log"

    config_template = current_dir(__FILE__) + "router.yml.erb"
    generate_config(config_template, binding)
    
    run "rm -f #{pid_file}"
    cd package_dir do 
      # todo 后续确认，在cofig_file中包含logging的配置后，stdout和stderr是否还会有内容，如无内容，可将下面重定向删除
      run "bin/router -c=#{config_file} >>#{vcap_sys_log}/router.stdout.log 2>>#{vcap_sys_log}/router.stderr.log &", :sudo => "sudo"
    end
  end

  def stop
    stop_it("sudo")
  end
  
end