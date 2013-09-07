
build :rootfs, :sudo => 'sudo' do
  ROOTFS_DIR = "rootfs"

  if $rebuild_rootfs
    # 从本地直接重新构建rootfs

    # 检查warden是否安装好，没有warden的话直接退出
    warden_target = release_dir + "warden"
    unless warden_target.exist?
      red "must first install warden, please run 'paas-build warden' before create rootfs"
      exit 
    end
  
    rootfs = build_cache + ROOTFS_DIR
    cd "#{warden_target + 'warden'}" do
      run <<-EOH
        sed -i \"s/suite=\\"lucid\\"/suite=\\"precise\\"/g\" root/linux/rootfs/ubuntu.sh
        sed -i 's/mirror=.*/mirror=\"http:\\/\\/mirrors.sohu.com\\/ubuntu\\/\"/g' root/linux/rootfs/ubuntu.sh
      EOH
          
      set_sys_env("CONTAINER_ROOTFS_PATH", rootfs)
      
      # 设置DEBUG环境变量是为跟踪rootfs的脚本运行的情况而设，具体内容不要紧，只要不为空即可
      # 这里将rake setup原来一个命令，拆分为两个（bin和rootfs），其中bin放到warden的构建中运行
      # 另外：DEBUG不能在bin前面设置，会导致setup:bin执行失败，具体原因不明。
      set_sys_env("DEBUG", 'true')
      bundle_exec_rake "--trace setup:rootfs"

      def chroot(rootfs, cmd)
        run "echo \"#{cmd}\" | sudo chroot \"#{rootfs}\" env -i $(cat #{rootfs}/etc/environment) /bin/bash"
      end

      chroot(rootfs, "apt-get update")
      chroot(rootfs, "apt-get -y install zip")
      chroot(rootfs, "apt-get -y install wget")
      chroot(rootfs, "apt-get -y install curl")
      chroot(rootfs, "apt-get -y install git")
      chroot(rootfs, "apt-get -y install ruby1.9.3")
    end
  else
    # 直接下载file.ebcloud.com中已经编译好的rootfs
    ROOTFS_FILE_NAME  = "rootfs-v0.1.tar.gz"
    ROOTFS_FILE_URL   = "http://file.ebcloud.com/rootfs/#{ROOTFS_FILE_NAME}"

    # 下载rootfs文件并解压
    run "sudo curl #{ROOTFS_FILE_URL} -s -o #{ROOTFS_FILE_NAME}"
    run "sudo tar zxvf #{ROOTFS_FILE_NAME}"
  end

  move_to_target ROOTFS_DIR, nil, true
end