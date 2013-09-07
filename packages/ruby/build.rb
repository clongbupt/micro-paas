
# 
# 从源码编译ruby虚拟机，同时为该虚拟机安装bundler。
#
build :ruby do 
  # （默认）当前目录为build_cache目录
  RUBY_BUILD_VERSION  = "ruby-1.9.3-p429"
  #  RUBY_BUILD_VERSION = "ruby-2.0.0-p247"  # 曾经测试过ruby2.0.0，但是与nats使用eventmachine 0.1.10版本不兼容(em需要1.0.1才支持ruby2.0)
  
  RUBY_SRC_FILE_NAME  = "#{RUBY_BUILD_VERSION}.tar.gz"
  RUBY_SRC_FILE_URL   = "http://file.ebcloud.com/ruby/#{RUBY_SRC_FILE_NAME}"
  RUBY_SRC_DIR        = "#{RUBY_BUILD_VERSION}-src"

  # 下载ruby虚拟机源码并解压
  run "curl #{RUBY_SRC_FILE_URL} -s -o #{RUBY_SRC_FILE_NAME}"
  run "tar zxvf #{RUBY_SRC_FILE_NAME}"
  run "mv #{RUBY_BUILD_VERSION} #{RUBY_SRC_DIR}"
  
  # 安装编译ruby需要的基础软件等（目前仅支持ubuntu环境）
  run "sudo apt-get -y build-dep ruby1.9.3"

  # 编译ruby
  cd RUBY_SRC_DIR do
    # --enable-load-relative 用来指示生成的ruby安装目录是可以当做绿色包拷贝或者移动的，否则该目录移动位置后会导致loaderror异常.
    run "./configure --prefix=#{build_cache + RUBY_BUILD_VERSION} --enable-load-relative --disable-install-doc"
    run "make"
    run "make install"
  end

  # 安装bundler，并修改bin/bundle的#!中写死的ruby路径
  run "#{RUBY_BUILD_VERSION}/bin/gem install bundler"
  run "sed -i 's/#!.*/#!\\/usr\\/bin\\/env ruby/g' #{RUBY_BUILD_VERSION}/bin/bundle" 

  # 拷贝编译好的ruby到target目录下
  move_to_target RUBY_BUILD_VERSION

  # 测试安装是否完成
  ruby "-e \"puts 'hello, world'\""
end
