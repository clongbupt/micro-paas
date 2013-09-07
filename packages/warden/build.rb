# 编译warden
build :warden do
  WARDEN_VERSION = "2fd4fcd33"
  WARDEN_DIR = "warden_#{WARDEN_VERSION}.git"

  run "sudo apt-get -y install debootstrap quota apparmor-profiles"

  git_url = {
    :home => "https://github.com/cloudfoundry/warden.git",
    :work => "http://git.ebcloud.com/paas-cf-v2/warden.git"
  }

  git_clone git_url, WARDEN_DIR do
    git_checkout WARDEN_VERSION

    cd "warden" do
      bundle_install

      run "sed -i 's/Warden::Server.setup/File.open(config[\"server\"][\"pid_file\"], \"w\") { |f| f.write Process.pid }\\nWarden::Server.setup/g' Rakefile"

      # 编译wshd
      bundle_exec_rake " --trace setup:bin"
    end
  end

  move_to_target WARDEN_DIR
end
