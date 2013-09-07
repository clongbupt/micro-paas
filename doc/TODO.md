项目每天记录
=========

## 2013/6/28

1. 对于CF项目本身的各大组件来说通过control启动比较好，但是对于postgres/mysql等软件服务是通过build配置好? 还是control启动好?

2. control的操作主要是对组件进行start/stop进行控制

## 2013/6/30

1. cotrol类 阅读

	a. bin/paas

			load "#{$PAAS_HOME}/jobs/#{job_name}/control.rb"   // 载入继承类
	  		job_class = PaaS::Control.find(job_name)           // 检查是否已经载入
	  		job = job_class.new                                // new 会调用父类的self.inherited

	  		job.send command.to_sym   // 调用command方法, 相当于 job.command

	b. lib/paas/control

			def self.inherited(control_class)     // control类继承时调用, 传入子类类名
		      control_class.to_s =~ /(.*)Control$/   // 判断子类名
		      name = $1.snake_case # 将ProcessExitCheck变为process_exit
		      control_class.name = name
		      @@controls[name] = control_class
		    end

2. ruby类中常见的回调函数
	
	* 调用一个不存的对象方法（method_missing）
	* 模块被混含（included/extended）
	* 类被继承（inherited）
	* 类或模块定义实例方法（method_added）
	* 对象新增加一个单例方法（singleton_method_added）
	* 实例方法被删除或取消（method_removed/method_undefined）
	* 对象的单例方法被取消或被取消（singleton_method_removed/singleton_undefined）
	* 引用一个不存在的常量（const_missing）

## 2013/7/1

1. 修改shell.rb中的set_sys_env方法   运行mvn命令和uaa命令会用到
	
		ENV[name] = value if name.is_a? String and value.is_a? String

2. 添加shell.rb中的set_sys_path方法  运行uaa命令会用到

		puts ENV["PATH"]
		ENV["PATH"] = ENV["PATH"] + ":" + name
		puts ENV["PATH"]

3. 补充测试postgres, 发现同手动安装版本的postgres有差异, 差异为尚未测试uaa/control.rb中的代码

		# 创建数据库   TODO 测试  手动添加
		run <<-EOH 
		#{release_dir}/postgres/bin/createdb -p 5432 uaa
		psql -p 5432 -d uaa -c \"create role root SUPERUSER LOGIN INHERIT CREATEDB\"
		psql -p 5432 -d uaa -c \"alter role root with password 'changeme'\"
		EOH

4. uaa启动成功, 不过如何保证同时在后台运行并且输出日志

		ruby "bin/uaa & >>#{vcap_sys_log}/uaa.stdout.log 2>>#{vcap_sys_log}/uaa.stderr.log"

5. 验证nats

		bin/paas-build nats
		bin/paas nats start

启动失败。
修改代码将`bundle_exec ...` 修改为 `ruby ...`后，启动成功

6. vagrant相关

* vagrant打包

		vagrant package

* vagrant初始化

		vagrant init vm_name box_name

* vagrant启动

		vagrant up

* vagrant ssh连接

		host: 127.0.0.1
		post: 2222
		user: vagrant
		password: vagrant

7. cloud_controller 配置

		./paas-build cloud_controller

* `bundle install` 报 `debugger` 错误. 解决方案：

		For future reference: I checked the debugger-ruby_core_source source code to see if the necessary ruby version is listed. In my case, 1.9.3-p429. It was, so I installed the latest version of the gem:

		gem install debugger-ruby_core_source -v 1.2.2

		Then bundle install worked normally.

* `bundle install` 报 `nokogiri` 错误. 解决方案：

		apt-get install libxml2-dev libxslt-dev 

* `bundle install` 报 `mysql` `sqlite`

		apt-get install libmysqlclient-dev libsqlite3-dev

* `bundle exec rake db:migrate` 报 `rake command not found` 错误

		/home/vagrant/build_dir/target/ruby/bin/bundle exec /home/vagrant/build_dir/target/ruby/bin/rake db:migrate

* `db:migrate` 执行失败, 查看postgres的cloud_controller表没有内容, 原因在cloud_controller_ng/Rakefile第83行：

		config_file = ENV["CLOUD_CONTROLLER_NG_CONFIG"]

在执行`db:migrate`时, 注意设置环境变量`CLOUD_CONTROLLER_NG_CONFIG`即可, 参见packages/cloud_controller_ng/build.rb第20行：

		set_sys_env("CLOUD_CONTROLLER_NG_CONFIG","#{$PAAS_HOME}/vcap/sys/config/cloud_controller_ng.yml") 

* `citext` 报错, 需要安装citext拓展：

		a. cd /home/vagrant/build_dir/cache/postgres/postgresql-9.2.4-src/contrib/citext
		b. make && make install
		此处不需要指定编译路径，因为pg_config已经放到用户path下，可以在make时被找到
		c. psql cloud_controller，执行create extension citext;

### TODO

1. cloud_controller 模块有两部分内容需要解决

* 安装citext拓展, pg_config 有问题, 位于cache中，需要修改为直接编译到target中
  
		cd "#{$HOME}/build_dir/cache/postgres/postgresql-9.2.4-src/contrib/citext" do
			set_sys_env("PG_CONFIG", "#{release_dir}/postgres/bin/pg_config")
			run <<-EOH
			make
			make install 
			EOH
		end

* 插入cloud_controller数据表  TODO 判断是否第一次执行
		
		set_sys_env("CLOUD_CONTROLLER_NG_CONFIG","#{$PAAS_HOME}/vcap/sys/config/cloud_controller_ng.yml") 
		bundle_exec "#{release_dir}/ruby/bin/rake db:migrate"


## 2013/7/2

1. 配置gorouter  			__完成__

* go语言的支持

		run "sudo apt-get -y install golang-go"


2. 配置health_manager __完成__

 问题不大, 注意set一个env, 其实不set也行

		set_sys_env("BUNDLE_GEMFILE", "#{package_dir}/Gemfile")

3. 配置warden __正在配置__

* `rubygems` load出错, 原因是bundler或者rake会调用系统的ruby环境，解决方案：在rake前加上当前ruby的路径

		run "sudo #{release_dir}/ruby/bin/ruby #{release_dir}/ruby/bin/bundle exec #{release_dir}/ruby/bin/ruby #{release_dir}/ruby/bin/rake setup[#{config_file}]"

* `mknod` 报错, 原因debootstrap设置的目录不能为被mount过的目录, 即/vagrant目录不能被设置,解决方案：

		rootfs_path = $HOME + "warden/rootfs"
		container_path = $HOME +  "warden/container"

## TODO 测试方案

预处理, 清除`/home/vagrant/build_dir`下的文件

			rm -rf /home/vagrant/build_dir 

1. ruby -> nats测试

	* ruby配置：

		执行命令 
			
				/vagrant/pass-release.git/bin/paas-build ruby

		观察结果, 看ruby能否正确启动, 即`/home/vagrant/build_dir/target/ruby`中是否有ruby目录和软链接，同时终端输出能否出现`hello world`字样

	* nats配置：

		执行命令

				/vagrant/pass-release.git/bin/paas-build nats

		观察结果，查看`/home/vagrant/build_dir/target/nats`中是否有nats目录和软链接

		启动nats-server

				/vagrant/pass-release.git/bin/paas nats start

		即查看/vagrant/vcap/sys/log/nats.stdout.log和nats.stderr.log 是否输出正常


2. java -> maven -> postgres -> uaa

	* java配置：

	执行命令 
		
			/vagrant/pass-release.git/bin/paas-build java

	观察结果, 看java能否正确启动, 即`/home/vagrant/build_dir/target/ruby`中是否有java目录和软链接，同时终端输出能否出现`java的版本号`等字样

	* maven配置：

	执行命令 
		
			/vagrant/pass-release.git/bin/paas-build maven

	观察结果, 看maven能否正确启动, 即`/home/vagrant/build_dir/target/maven`中是否有maven目录和软链接，同时终端输出能否出现`maven的版本号`等字样

	* postgres配置：

	执行命令 
		
			/vagrant/pass-release.git/bin/paas-build postgres

	观察结果, 看postgres能否正确启动, 即`/home/vagrant/build_dir/target/postgres`中是否有postgres目录和软链接，同时终端输出能否出现`postgres的版本号`等字样

	postgres常用命令：

		* `/home/vagrant/build_dir/target/postgres/bin/psql` 这个是连接postgres常用的命令 `--help`可以查看其选项，主要有:
			* -p 5432 端口号
			* -h 127.0.0.1 域名
			* -U root 用户名
			* -d uaa 数据库名

		示例：
			 
			/home/vagrant/build_dir/target/postgres/bin/psql -p 5432 -h 127.0.0.1 -U root uaa

	* uaa配置：

	执行命令 
		
			/vagrant/pass-release.git/bin/paas-build uaa

	观察结果, 查看`/home/vagrant/build_dir/target/uaa`中是否有uaa目录和软链接

	启动uaa

			/vagrant/pass-release.git/bin/paas uaa start

	即查看/vagrant/vcap/sys/log/uaa.stdout.log和uaa.stderr.log 是否输出正常

3. postgres 拓展 -> cloud_controller

4. gorouter

5. health_manager

## 2013/7/3

1. 完成第一次运行的判断, 代码在lib/shell.rb first_run?方法, 通过对组件的配置文件进行判断

			def first_run?
				if File.exist? @config_file
					false
				else
					true
				end
			end

2. 第一次运行判断目前用在 CC/UAA/warden的control文件中，使用时需注意放在generate_config方法前

3. 配置warden的客户端, 可以通过 `/vagrant/paas-release.git/bin/paas warden client_start` 来启动

4. 配置dea_ng

5. 配置mysql和redis服务

			sudo apt-get install mysql-server redis-server

	ubuntu默认的版本为mysql-server5.5 和 redis-server2.2

5. 配置mysql_gateway, mysql_gateway最近有更新, 并且由于项目名更换, 无法正常回退, 只能硬着头皮研究了, 注意mysql_gateway配置文件的修改

			cc_api_version: v2
			service_auth_tokens: 
			   mysql_core: "2fdb2546b7a94b10" 

			uaa_client_id: cf 
			uaa_endpoint: http://uaa.vcap.me:8081 
			uaa_client_auth_credentials: 
			   username: admin
			   password: admin 

6. mysql_gateway的执行线路图

	`bin/mysql_gateway` -> `vcap-service-base/lib/base/gateway` -> `vcap-service-base/lib/base/asynchronous_service_gateway` -> `vcap-services-base/lib/base/catalog_manager_v2` -> `vcap-services-base/lib/base/gateway_service_catalog` -> `vcap-services-base/lib/base/http_handler` -> `/cf-uaa-lib-master/lib/uaa/token_issuer.rb` -> `/cf-uaa-lib-master/lib/uaa/http.rb`

7. mysql_gateway的调试语句位置, TODO 明天注意清除

			 vim /home/vagrant/build_dir/target/ruby-1.9.3-p429/lib/ruby/gems/1.9.1/gems/cf-uaa-lib-1.3.10/lib/uaa/http.rb

8. uaa访问测试文件uaa_test.rb, 位于`/vagrant/clong/uaa_test.rb`

9. 通过对比`cf target`和`cf login`调用`cf-uaa-lib`包与`mysql_gateway`调用时的区别, 发现问题在url请求上, 修改mysq_gateway的配置文件如下：

			uaa_client_id: vmc   // 这个与uaa的redirect_uri的尾部匹配
			uaa_endpoint: http://localhost:8080/uaa    // 这个是通过cf发现的

10. 对于`mysql_gateway.yaml`的`cloud_controller_uri`属性也需要进行修改

			cloud_controller_uri: http://api.vcap.me:8181

11. 配置mysql_node, 配置文件`mysql_node.yml.erb`修改, 否则无法启动, 主要是看/vcap-services-base/vcap-services-base-ff993291861a/lib/base/node_bin.rb各个options项是否为optional, 如果不是则必须在配置文件中配置

			supported_versions: ["mysql-5.5"]
			default_version: "mysql-5.5"
			mysql:
				mysql-5.5:
					host: localhost
					port: 3306
					user: root
					pass: mysql
			connection_pool_size: 
				min: 5
				max: 10
			database_lock_file: /vagrant/paas-release.git/vcap/sys/run/mysql/LOCK
			local_db: sqlite3:/vagrant/paas-release.git/vcap/sys/data/mysql_node.db
			base_dir: /usr/lib/mysql/

## 2013/7/5

### TODO

1. 需要在启动各个组件后安装cf客户端, 目前是手动安装

2. 测试`mysql_gateway`的情况

`mysql_gateway`连接cloud_controller并注册自己的信息,

信息主要是两条一条是向cloud_controller的service表插入一条mysql服务的记录, 一条是向service_plans表插入一条plan记录

cf调用create-service命令时先到CC的`model/service_instance`下, 然后先调用plan.service.service_token查看token是否合理

	* 此处为了通过有两个修改： 向cloud_controller库的servie_auth_token插入一条记录

			insert into service_auth_tokens(guid,created_time,name,label,token,salt) values(1,'20130706','mysql','mysql','0xdeadbeef','deadbeef');

	* 修改CC源码 `model/service_auth_token.rb`的token方法第29行

			def token
				return super
				#return unless super
				VCAP::CloudController::Encryptor.decrypt(super, salt)
			end


3. 注意： 理清mysql_gateway同mysql_node之间的版本关系, 主要是配置文件中的各个version含义version, supported_version, version_alias等

大致流程是, mysql_gateway启动后会向CC数据库注册, 插入label和version

然后cf命令创建service时, 在验证token需要保证label和name一致，同时在gateway中会找出version合适的node

vcap-services-base/base/gateway.rb  第88行， 将配置文件中的name和version组成label

			@config[:service][:label] = "#{@config[:service][:name]}-#{@config[:service][:version]}"

vcap-service/base/gateway_service_catalog.rb   第11行， 解析label

			id, version = VCAP::Services::Api::Util.parse_label(service[:label])

最终组成catalog数据结构， 大致包括如下内容

			catalog[catalog_key] = {
		        "id" => id,
		        "version" => version,
		        "label" => service[:label],
		        "url" => service[:url],
		        "plans" => plans,
		        "cf_plan_id" => service[:cf_plan_id],
		        "tags" => service[:tags],
		        "active" => true,
		        "description" => service[:description],
		        "plan_options" => service[:plan_options],
		        "acls" => service[:acls],
		        "timeout" => service[:timeout],
		        "provider" => provider,
		        "default_plan" => service[:default_plan],
		        "supported_versions" => service[:supported_versions],
		        "version_aliases" => service[:version_aliases],
	      	}.merge(extra).merge(unique_id)



4. cloud_controller库的更新, 更新为7月6日版本