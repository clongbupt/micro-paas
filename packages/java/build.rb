
# 安装Java
build :java do

  # 配置Java环境
  JAVA_BUILD_VERSION = "jdk1.7.0_21"
  JAVA_SRC_FILE_NAME  = "jdk-7u21-linux-x64.tar.gz"
  JAVA_SRC_FILE_URL   = "http://file.ebcloud.com/java/#{JAVA_SRC_FILE_NAME}"
  # JAVA_SRC_DIR        = "#{JAVA_BUILD_VERSION}-src"

  # 下载Java源码并解压
  run "curl #{JAVA_SRC_FILE_URL} -s -o #{JAVA_SRC_FILE_NAME}"
  run "tar zxvf #{JAVA_SRC_FILE_NAME}"

  move_to_target JAVA_BUILD_VERSION

  # 测试Java能否启动
  java "-version"
end