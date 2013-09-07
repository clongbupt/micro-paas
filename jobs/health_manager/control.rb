require 'paas/control'

class HealthManagerControl < PaaS::Control 

  # 默认当前路径为package目录？
  def start 
    if process_exist? pid_file
      puts "health manager already running, pid is #{get_pid(pid_file)}"
      return 
    end

    log_file = vcap_sys_log + "health_manager.log"

    config_template = current_dir(__FILE__) + "health_manager.yml.erb"
    generate_config(config_template, binding)
    
    run "rm #{pid_file}"
    cd "#{package_dir}/bin" do 
      set_sys_env("BUNDLE_GEMFILE", "#{package_dir}/Gemfile")
      ruby "./health_manager -c #{config_file} >>#{vcap_sys_log}/health_manager.stdout.log 2>>#{vcap_sys_log}/health_manager.stderr.log &"
    end
  end

end