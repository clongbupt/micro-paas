
# 安装uaa
build :uaa do 
  UAA_VERSION = "890d2d6" # ~= 1.4.3
  UAA_DIR = "uaa_#{UAA_VERSION}.git"

  git_url = {
    :home => "https://github.com/cloudfoundry/uaa.git",
    :work => "http://git.ebcloud.com/paas-cf-v2/uaa.git"
  }

  git_clone git_url, UAA_DIR do
    git_checkout UAA_VERSION
    git_submodule_update
    bundle_install false

    # 删除bin/uaa里面的"-P vcap"这一块。否则启动时uaa无法找到正确的配置文件
    run "sed -i 's/-P vcap//g' bin/uaa"

    mvn "-Dmaven.repo.local=#{build_target}/maven_uaa_repository/repository install"
  end

  move_to_target UAA_DIR
end