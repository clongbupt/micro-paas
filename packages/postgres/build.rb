# 安装postgres
build :postgres do 
  POSTGRES_BUILD_VERSION = "postgresql-9.2.4"
  POSTGRES_SRC_FILE_NAME  = "#{POSTGRES_BUILD_VERSION}.tar.bz2"
  POSTGRES_SRC_FILE_URL   = "http://file.ebcloud.com/postgres/#{POSTGRES_SRC_FILE_NAME}"
  #POSTGRES_SRC_FILE_URL  = "http://ftp.postgresql.org/pub/source/v9.2.4/postgresql-9.2.4.tar.bz2"
  POSTGRES_SRC_DIR        = "#{POSTGRES_BUILD_VERSION}-src"

  # 下载postgres源码并解压
  run "curl #{POSTGRES_SRC_FILE_URL} -s -o #{POSTGRES_SRC_FILE_NAME}"
  run "tar jxvf #{POSTGRES_SRC_FILE_NAME}"
  run "mv #{POSTGRES_BUILD_VERSION} #{POSTGRES_SRC_DIR}"

  # 编译安装postgres
  installed_dir = "#{build_cache + POSTGRES_BUILD_VERSION}"
  cd POSTGRES_SRC_DIR do
    run "./configure --prefix=#{installed_dir}"
    run "make"
    run "make install"
  end

  # 编译citext拓展
  cd POSTGRES_SRC_DIR + "/contrib/citext" do
    set_sys_env("PG_CONFIG", "#{installed_dir}/bin/pg_config")
    run "make"
    run "make install"
  end

  # 拷贝编译好的postgres到target目录下
  move_to_target POSTGRES_BUILD_VERSION
end