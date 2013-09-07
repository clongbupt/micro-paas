#安装redis
build :redis do

  REDIS_BUILD_VERSION = "redis-2.6.13"
  REDIS_SRC_FILE_NAME = "#{REDIS_BUILD_VERSION}.tar.gz"
  REDIS_SRC_FILE_URL  = "http://file.ebcloud.com/redis/#{REDIS_SRC_FILE_NAME}"
  REDIS_SRC_DIR       = "#{REDIS_BUILD_VERSION}-src"
  
  #下载redis源码并解压
  run "curl #{REDIS_SRC_FILE_URL} -s -o #{REDIS_SRC_FILE_NAME}"
  run "tar zxvf #{REDIS_SRC_FILE_NAME}"
  run "mv #{REDIS_BUILD_VERSION} #{REDIS_SRC_DIR}"
  
  cd REDIS_SRC_DIR do
    # 编译安装 默认安装到src目录下
    run "make"

    # 将编译后的src文件移动到target位置    
    run "mv src #{build_target + REDIS_BUILD_VERSION}"

    cd build_target do 
      run "ln -s #{REDIS_BUILD_VERSION} redis"
    end
  end

 end
