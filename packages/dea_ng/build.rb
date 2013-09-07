build :dea_ng do
  DEA_VERSION = "c6ab6dd85"
  DEA_NG_DIR="dea_ng_#{DEA_VERSION}.git"

  run "sudo apt-get -y install libcurl4-openssl-dev"
  run "sudo apt-get -y install bzr"
  run "sudo apt-get -y install libxml2-dev"
  run "sudo apt-get -y install libxslt-dev"
  run "sudo apt-get -y install golang-go"

  git_url = {
    :home => "https://github.com/cloudfoundry/dea_ng.git",
    :work => "http://git.ebcloud.com/paas-cf-v2/dea_ng.git"
  }

  git_clone git_url, DEA_NG_DIR do
    git_checkout DEA_VERSION
    git_submodule_update
    bundle_install false

    run "./go/bin/go get launchpad.net/goyaml"  # 这一步是干什么？
    bundle_exec_rake("dir_server:install")

    cd "buildpacks/vendor/ruby/lib/language_pack/" do 
      run "sed -i 's/   fetch_from_blobstore/#fetch_from_blobstore/g' package_fetcher.rb"
      run "sed -i 's/https:\\/\\/s3.amazonaws.com\\/heroku-buildpack-ruby/http:\\/\\/file.ebcloud.com\\/heroku-buildpack-ruby/g' base.rb" 
    end 
  end

  move_to_target DEA_NG_DIR
end

