
# 安装 maven
build :maven do
  # 配置Maven环境
  MAVEN_BUILD_VERSION = "apache-maven-3.0.4"
  MAVEN_SRC_FILE_NAME  = "#{MAVEN_BUILD_VERSION}-bin.tar.gz"
  MAVEN_SRC_FILE_URL   = "http://file.ebcloud.com/maven/#{MAVEN_SRC_FILE_NAME}"

  # 下载Maven源码并解压
  run "curl #{MAVEN_SRC_FILE_URL} -s -o #{MAVEN_SRC_FILE_NAME}"
  run "tar zxvf #{MAVEN_SRC_FILE_NAME}"

  move_to_target MAVEN_BUILD_VERSION

  # 测试Maven能否启动
  mvn "-version"
end