require 'paas/shell'

$build_report = []

def build(name, options={}, &block)
  start = Time.now
  begin
    b = BuildBase.new(name, options)
    b.instance_eval(&block)
  ensure 
    interval = Time.now - start
    report = "******* package [#{name}] build use #{(interval/60).to_i} minutes #{(interval % 60).to_i} seconds"
    $build_report << [name, interval, report]     
    puts report 
  end
end

class BuildBase
  include PaaS::Shell

  attr_reader :build_cache, :build_target, :name, :vcap_home

  def initialize(name, options)
    @name = name

    @vcap_home = $VCAP_HOME || $PAAS_HOME + "vcap"

    build_dir = $HOME + "build_dir"

    @build_cache = build_dir + "cache" + name.to_s
    # 在使用build_cache之前，先清空@build_cache
    run "rm -rf #{@build_cache}", options

    @build_target = build_dir + "target"
    # 同样，如果编译前target已经存在，先清空target中的package
    package_target = @build_target + name.to_s
    if package_target.exist?
      if package_target.symlink?
        read_package_dir = package_target.readlink
        read_package_dir = @build_target + read_package_dir.to_s unless read_package_dir.to_s =~ /^\//
        run "rm -rf #{read_package_dir}", options
      end
      run "rm -rf #{package_target}", options
    end

    @release_dir = @build_target

    build_cache.mkpath
    build_target.mkpath

    cd build_cache
  end

  def at_place
    $at_place || :work
  end

  def git_clone(git_url, local_dir, &block)
    if git_url.is_a? Hash 
      git_url = git_url[at_place.to_sym]
    end

    # 如果git_url是http://git.ebcloud.com形式的，直接加上用于构建的用户名和密码
    if git_url =~ /http:\/\/git.ebcloud.com\/(.*)/
      git_url = "http://paasbuild:helloebupt@git.ebcloud.com/#{$1}"
    end

    run "git clone #{git_url} #{local_dir}" 
    cd(local_dir, &block) if block
  end

  def git_checkout(tag_version)
    run "git checkout -b #{tag_version} #{tag_version}"
  end

  def git_submodule_update
    run "git submodule update --init"
  end
  
  def auto_replace_gem_source
    run "sed -i 's/rubygems.org/ruby.taobao.org/g' Gemfile"
    run "sed -i 's/https:\\/\\/ruby.taobao.org/http:\\/\\/ruby.taobao.org/g' Gemfile"
  end

  def move_to_target(install_dir, link_name = name, sudo = false)
    if sudo 
      run "sudo mv #{install_dir}/ #{build_target}/"
    else
      run "mv  #{install_dir}/ #{build_target}/"
    end

    cd "#{build_target}"
    run "ln -s #{install_dir} #{link_name}" if link_name
  end


end
