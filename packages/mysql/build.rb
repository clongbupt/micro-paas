#安装mysql
build :mysql do

  MYSQL_BUILD_VERSION = "mysql-5.5.32"
  MYSQL_SRC_FILE_NAME = "#{MYSQL_BUILD_VERSION}.tar.gz"
  MYSQL_SRC_FILE_URL  = "http://file.ebcloud.com/mysql/#{MYSQL_SRC_FILE_NAME}"
  MYSQL_SRC_DIR       = "#{MYSQL_BUILD_VERSION}-src"
  
  # 安装cmake
  run "sudo apt-get -y install cmake"
  
  #下载mysql源码并解压
  run "curl #{MYSQL_SRC_FILE_URL} -s -o #{MYSQL_SRC_FILE_NAME}"
  run "tar zxvf #{MYSQL_SRC_FILE_NAME}"
  run "mv #{MYSQL_BUILD_VERSION} #{MYSQL_SRC_DIR}"
  
  # 由于mysql编译后无法移动, 直接将其编译到target位置
  installed_dir = "#{build_target + MYSQL_BUILD_VERSION}"
  
  # 设置mysql的socket和data位置
#  vcap_home = $PAAS_HOME + "vcap"
  vcap_sys_dir = vcap_home + "sys"
  data_dir = vcap_sys_dir + "data"
  mysql_data_dir = data_dir + "mysql"
  socket_dir = vcap_sys_dir + "socket"
  
  mysql_data_dir.mkpath
  socket_dir.mkpath
  
  # 安装位置
  installed_dir = "#{build_cache + MYSQL_BUILD_VERSION}"
  
  #编译安装
  cd MYSQL_SRC_DIR do
    run <<EOH
      cmake -DCMAKE_INSTALL_PREFIX=#{installed_dir} \
			-DMYSQL_DATADIR=#{mysql_data_dir} \
      -DMYSQL_UNIX_ADDR=#{socket_dir}/mysql.sock\
			-DEXTRA_CHARSETS=all \
			-DDEFAULT_CHARSET=utf8 \
			-DDEFAULT_COLLATION=utf8_general_ci \
			-DWITH_READLINE=1 \
			-DWITH_SSL=bundled \
			-DWITH_EMBEDDED_SERVER=1 \
			-DENABLED_LOCAL_INFILE=1 \
			-DWITH_INNOBASE_STORAGE_ENGINE=1 \
			-DWITHOUT_PARTITION_STORAGE_ENGINE=1 \
			-DWITH_DEBUG=0
EOH
    run "make"
    run "make install"
  end
  
  # 拷贝编译好的mysql到target目录下
  move_to_target MYSQL_BUILD_VERSION  
 end
