require 'paas/control'

class UaaControl < PaaS::Control

  def start
    if process_exist? pid_file
      puts "uaa already running, pid is #{get_pid(pid_file)}"
      return 
    end

    # 创建数据库  第一次时运行
    if first_run?
      set_sys_env("LD_LIBRARY_PATH", "#{release_dir}/postgres/lib")
      run "#{release_dir}/postgres/bin/dropdb -h localhost -p 5432 uaa"
      run "#{release_dir}/postgres/bin/createdb -h localhost -p 5432 uaa"
      run "#{release_dir}/postgres/bin/psql -h localhost -p 5432 -d uaa -c \"create role root SUPERUSER LOGIN INHERIT CREATEDB\""
      run "#{release_dir}/postgres/bin/psql -h localhost -p 5432 -d uaa -c \"alter role root with password 'changeme'\""
    end

    log_file = vcap_sys_log + "uaa.log"

    config_template = current_dir(__FILE__) + "uaa.yml.erb"
    generate_config(config_template, binding)

    cd package_dir do
      cd package_dir do 
        run "sed -i 's/mvn.*tomcat:run/mvn -Dmaven.repo.local=#{release_dir.to_s.gsub('/', '\/')}\\/maven_uaa_repository\\/repository tomcat:run/g' bin/uaa"
      end

      set_sys_env("CLOUD_FOUNDRY_CONFIG_PATH",vcap_sys_config.to_s) 
      set_sys_env("JAVA_HOME", "#{release_dir}/java")
      set_sys_path("#{release_dir}/maven/bin")

      ruby "bin/uaa >>#{vcap_sys_log}/uaa.stdout.log 2>>#{vcap_sys_log}/uaa.stderr.log &"
    end
  end

end