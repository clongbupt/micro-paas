require 'paas/control'

class CloudControllerNgControl < PaaS::Control 

  # 默认当前路径为package目录？
  def start 
    if process_exist? pid_file
      puts "cloud controller already running, pid is #{get_pid(pid_file)}"
      return 
    end

    first = first_run?

    # 生成配置文件
    log_file = vcap_sys_log + "cloud_controller.log"
    config_template = current_dir(__FILE__) + "cloud_controller_ng.yml.erb"
    generate_config(config_template, binding)
    
    # 插入cloud_controller数据表
    if first
      cd package_dir do 
        set_sys_env("LD_LIBRARY_PATH", "#{release_dir}/postgres/lib")

        # 先删除旧的数据库(假设存在的话)
        run "#{release_dir}/postgres/bin/dropdb -h localhost -p 5432 cloud_controller"

        # 创建cloud_controller数据库
        run "#{release_dir}/postgres/bin/createdb -h localhost -p 5432 cloud_controller"
        run "#{release_dir}/postgres/bin/psql -h localhost -p 5432 -d cloud_controller -c \"create role root SUPERUSER LOGIN INHERIT CREATEDB\""
        run "#{release_dir}/postgres/bin/psql -h localhost -p 5432 -d cloud_controller -c \"alter role root with password 'changeme'\""
        
        # 安装citext拓展
        run "#{release_dir}/postgres/bin/psql -p 5432 -h localhost -d cloud_controller -c \"create extension citext\""

        set_sys_env("CLOUD_CONTROLLER_NG_CONFIG","#{vcap_sys_config}/cloud_controller_ng.yml") 
        bundle_exec "#{release_dir}/ruby/bin/rake --trace db:migrate"
      end
    end 

    cd package_dir do 
      set_sys_env("LD_LIBRARY_PATH", "#{release_dir}/postgres/lib")
      ruby "bin/cloud_controller -m -c #{config_file} >>#{vcap_sys_log}/cloud_controller_ng.stdout.log 2>>#{vcap_sys_log}/cloud_controller_ng.stderr.log &"
    end
  end

end
