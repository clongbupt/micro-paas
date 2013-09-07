require 'paas/control'

class DeaNgControl < PaaS::Control
  def start
    if process_exist? pid_file
      puts "dea_ng already running, pid is #{get_pid(pid_file)}"
      return
    end

    ruby_path = "#{release_dir}/ruby/bin"

    dea_ruby = "/usr/bin/ruby"

    config_template = current_dir(__FILE__) + "dea.yml.erb"
    generate_config(config_template, binding)

    run "rm #{pid_file}"

    cd package_dir do
      bundle_exec "bin/dea #{config_file} >>#{vcap_sys_log}/dea_ng.stdout.log 2>>#{vcap_sys_log}/dea_ng.stderr.log &"
    end

  end
end

