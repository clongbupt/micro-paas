
build :cf do
  CF_DIR = "cf-4.1.1.git"

  git_url = {
    :home => "https://github.com/cloudfoundry/cf.git",
    :work => "http://git.ebcloud.com/paas-cf-v2/cf.git"
  }

  git_clone git_url, CF_DIR do
    git_checkout "v4.1.1"
    
    # 修改cf.gemspec中的下一行
    # s.add_runtime_dependency "cfoundry", ">= 2.2.0rc3", "< 3.0"
    # 为
    # s.add_runtime_dependency "cfoundry", ">= 2.2.0rc3", "< 2.4"
    # 原因是 cf的4.1.1版本和cfoundry的2.4.0版本不兼容
    run "sed -i 's/< 3.0/< 2.4/g' cf.gemspec"

    bundle_install

    run "mv bin/cf bin/cf.gem"
    run "mv bin/cf.dev bin/cf"

    run "sed -i 's/Bundler.require/cur = Dir.pwd\\nDir.chdir(File.expand_path(\"..\\/..\\/\", __FILE__))\\nBundler.require\\nDir.chdir(cur)/g' bin/cf"
    
  end

  move_to_target CF_DIR
end