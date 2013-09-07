require 'paas/control'

class PostgresControl < PaaS::Control

  # 默认当前路径为package目录？
  def start 
    cd package_dir do 
      pg_ctl('start', true, true)
    end
  end

  def stop
    cd package_dir do 
      pg_ctl('stop', true, true)
    end
  end

  def status
    cd package_dir do 
      pg_ctl('status', false, false, "2>&1")
    end
  end

  def restart
    cd package_dir do 
      pg_ctl('restart', true, true)
    end
  end

  def pg_ctl(command, redirect, backend, other=nil)
    init
    
    cmdline = "LD_LIBRARY_PATH=#{package_dir}/lib #{package_dir}/bin/pg_ctl #{command} -D #{vcap_sys_data}/postgres"
    cmdline += " >>#{vcap_sys_log}/postgres.stdout.log 2>>#{vcap_sys_log}/postgres.stderr.log " if redirect
    cmdline += "& " if backend
    cmdline += " #{other}" if other
    run cmdline
  end
  
  def init
    # 配置postgres的数据位置
    data_dir = vcap_sys_data + "postgres"
    
    if !data_dir.exist? 
      data_dir.mkpath
      
      # 初始化数据库
      run "#{package_dir}/bin/initdb -D #{data_dir}"

      # 修改pg_hba.conf
      run "echo host cloud_controller root 0.0.0.0/0 md5 >> #{data_dir}/pg_hba.conf "
      run "echo host uaa root 0.0.0.0/0 md5 >> #{data_dir}/pg_hba.conf "

      # 修改postgresql.conf
      tmp_shell = "s/#listen_addresses\\ =\\ 'localhost'/listen_addresses\\ =\\ '#{local_ip},localhost'/g"
      run "sed -i \"#{tmp_shell}\" #{data_dir}/postgresql.conf"
    end
  end

end
