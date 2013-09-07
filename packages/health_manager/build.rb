# 编译health_manager
build :health_manager do
  HM_VERSION = "47f6d5365"
  HM_DIR = "health_manager_#{HM_VERSION}.git"

  git_url = {
    :home => "https://github.com/cloudfoundry/health_manager.git",
    :work => "http://git.ebcloud.com/paas-cf-v2/health_manager.git"
  }

  git_clone git_url, HM_DIR do
    git_checkout HM_VERSION
    bundle_install
  end

  move_to_target HM_DIR
end
