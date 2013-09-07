
build :nats do 
  NATS_VERSION = "v0.4.28"
  NATS_DIR = "nats-#{NATS_VERSION}.git"

  git_clone "http://git.ebcloud.com/paas-cf-v2/nats.git", NATS_DIR do
    git_checkout NATS_VERSION
    bundle_install
  end

  move_to_target NATS_DIR
end
