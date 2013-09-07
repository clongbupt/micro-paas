
# 安装mysql_service
build :mysql_service do 
  CF_SERVICE_VERSION = "8ddb28fa6"
  CF_SERVICES_DIR = "cf-services-release.git"
  MYSQL_SERVICE_DIR = "mysql_service_#{CF_SERVICES_DIR}.git"

  run "sudo apt-get -y install libcurl4-openssl-dev"

  # 下载service
  git_url = {
    :home => "https://github.com/cloudfoundry/cf-services-release.git",
    :work => "http://git.ebcloud.com/paas-cf-v2/cf-services-release.git"
  }

  git_clone git_url, CF_SERVICES_DIR do
    git_checkout CF_SERVICE_VERSION
    git_submodule_update

    cd "src/mysql_service" do
      bundle_install
    end
    
    cd 'src' do
      run "mv mysql_service #{MYSQL_SERVICE_DIR}"
      move_to_target MYSQL_SERVICE_DIR
    end
  end

end