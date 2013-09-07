
# 安装gorouter
build :router do 
  GOROUTER_COMMIT = "950f268"
  GOROUTER_DIR = "router_#{GOROUTER_COMMIT}.git"

  # 安装go编译器
  # 
  # DEBIAN_FRONTEND=noninteractive ：
  #    golang-go在运行package configration的时候，会弹出一个交互式确认界面，这个选项用于屏蔽此界面
  #    参见 : http://serverfault.com/questions/227190/how-do-i-ask-apt-get-to-skip-any-interactive-post-install-configuration-steps
  run "sudo DEBIAN_FRONTEND=noninteractive apt-get -y install golang-go"

  git_clone "http://git.ebcloud.com/paas-cf-v2/gorouter.git", GOROUTER_DIR do
    git_checkout GOROUTER_COMMIT
    git_submodule_update
    run "./bin/go install router/router"
  end

  move_to_target GOROUTER_DIR
end