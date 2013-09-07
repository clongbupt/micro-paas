require 'paas/ruby_core_ext'
require 'paas/shell'
require 'erb'
require 'socket'

module PaaS

  class Control
    include PaaS::Shell

    @@controls = {}
    
    def self.inherited(control_class)
      control_class.to_s =~ /(.*)Control$/
      name = $1.snake_case # 将ProcessExitCheck变为process_exit
      control_class.name = name
      @@controls[name] = control_class
    end

    def self.find(control_name)
      @@controls[control_name.to_s]
    end

    def self.name 
      @name
    end

    def self.name=(name)
      @name = name
    end

    attr_accessor :release_dir, :package_dir
    attr_accessor :vcap_home, :vcap_sys_run, :vcap_sys_dir, :vcap_sys_config, :vcap_sys_log, :vcap_sys_data, :vcap_sys_socket
    attr_accessor :config_file, :pid_file

    def initialize
      @release_dir = $HOME + "build_dir" + "target" 
      @package_dir = release_dir + self.class.name

      # paas运行数据存放处（暂用）
      @vcap_home = $VCAP_HOME || $PAAS_HOME + "vcap"
      @vcap_sys_dir = vcap_home + "sys"
      @vcap_sys_log = vcap_sys_dir + "log"
      @vcap_sys_run = vcap_sys_dir + "run" # 
      @vcap_sys_config = vcap_sys_dir + "config"
      @vcap_sys_data = vcap_sys_dir + "data"
      @vcap_sys_socket = vcap_sys_dir + 'socket'

      [vcap_sys_log, vcap_sys_run, vcap_sys_config, vcap_sys_data, vcap_sys_socket].each { |d| d.mkpath }
 
      @config_file = vcap_sys_config + "#{self.class.name}.yml"
      @pid_file = vcap_sys_run + "#{self.class.name}.pid"
      
      @local_ip = local_ip
    end

    def stop
      stop_it
    end

    def stop_it(sudo = nil)
      kill_and_wait pid_file, 10, sudo
    end

    def restart
      stop 
      start
    end

    # 自动实现status，必要时也可以集成
    def status
      puts "#{self.class.name}\t[#{process_exist?(pid_file).inspect}]"
    end

    def generate_config(config_template, context)
      erb = ERB.new(config_template.read)
      config = erb.result(context)
      File.open(config_file, "w") do |file|
        file.write config
      end
    end

    # 判断系统中pid进程是否存在
    def process_exist?(pid_or_file)
      if pid = get_pid(pid_or_file)
        File.exist? "/proc/#{pid}"
      else
        false
      end
    end

    def get_pid(pid_or_file)
      if pid_or_file.respond_to? :exist?
        if pid_or_file.exist?
          return File.read(pid_or_file).to_i
        end
        nil
      else
        pid = pid_or_file.to_i
        pid == 0 ? nil : pid
      end
    end

    def kill_and_wait(pid_or_file, wait_seconds = 10, sudo = nil)
      pid = get_pid(pid_or_file)
      return unless pid

      run "#{sudo} kill #{pid}"

      sleep_seconds = 0
      while true
        return unless process_exist? pid
        sleep 0.1
        sleep_seconds += 0.1
        if sleep_seconds > wait_seconds
          kill_9 pid, sudo
        end
      end
    end

    def kill_9(pid, sudo = nil)
      run "#{sudo} kill -9 #{pid}"
    end  

    def first_run?
      not File.exist? @config_file
    end

    def local_ip(route = '198.41.0.4')
      route ||= '198.41.0.4'
      orig, Socket.do_not_reverse_lookup = Socket.do_not_reverse_lookup, true
      UDPSocket.open {|s| s.connect(route, 1); s.addr.last }
    ensure
      Socket.do_not_reverse_lookup = orig
    end

  end

end
