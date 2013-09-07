

build :cloud_controller_ng do
  CC_VERSION = "d7e51a0c4"
  CC_DIR = "cloud_controller_ng_#{CC_VERSION}.git"

  git_url = {
    :home => "https://github.com/cloudfoundry/cloud_controller_ng.git",
    :work => "http://git.ebcloud.com/paas-cf-v2/cloud_controller_ng.git"
  }

  git_clone git_url, CC_DIR do
    git_checkout CC_VERSION
    git_submodule_update

#    gem_install "debugger-ruby_core_source -v 1.2.2" # 为解决bundle install时debugger编译失败的问题
    run "sudo apt-get -y install libxml2-dev libxslt-dev" # 解决nokogiri的编译依赖问题
    run "sudo apt-get -y install libmysqlclient-dev" # for mysql gem 
    run "sudo apt-get -y install libsqlite3-dev"  # for sqlite gem
    run "sudo apt-get -y install libpq-dev"  # for postgres 'pg' gem
    bundle_install
  end

  move_to_target CC_DIR
end