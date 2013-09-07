
# 一步一步构建micro-paas

### 安装基础环境

1. 安装VirtualBox和vagrant。 http://www.vagrantup.com/

1. 使用vagrant创建ubuntu12.04的环境（干净的环境）

	```shell
mkdir micro-paas
cd micro-paas
vagrant init micro-paas http://file.ebcloud.com/box/ubuntu_server_12.04_64.box
vagrant up
vagrant ssh # 进入虚拟机，这里主要验证一下
	```

	说明：

	virtualbox 4.2.14似乎有问题，需要降级到4.2.10

	https://github.com/mitchellh/vagrant/issues/1847 最后有一个解决此问题的方式（在不对virtual box降级的情况下） :  mac下测试是成功的。

	Simply go into ~/.vagrant.d/boxes/BaseBoxName/virtualbox and do openssl sha1 *.vmdk *.ovf > box.mf,vagrant up, it is reported to be working fine with VirtualBox 4.2.14.

1. 下载paas-release

	注意先要在Host主机中创建git的ssh-key，具体参考gitlab上面提示。mac或者linux的示例如下：

	```shell
ssh-keygen -t rsa -C "zhangtieying@ebupt.com"
cat ~/.ssh/id_rsa.pub  # 将cat的输出拷贝,并在git.ebcloud.com上增加ssh-key（My Profile/SSH Keys）。
	```

	下载paas-relase最新代码

	```shell
cd micro-paas
git clone git@git.ebcloud.com:paas/paas-release.git paas-release.git
	```

1. 虚拟机环境准备

	进入micro-paas虚拟机

	```shell
vagrant ssh
	```

	准备git存取环境（和上面在主机中增加的步骤和方式是一样一样的）
	todo ：（这个需要重新整理一下，看看如何做）：可以考虑创建一个构建的账号，专门用于干这个，同时把这个key加入到box中


### 编译micro-paas

已经通过vagrant ssh进入虚拟机环境

```shell
cd
ln -s /vagrant/paas-release.git/ paas-release.git

cd paas-release.git

# 安装编译需要的基础软件，比如curl、git等等
bin/pre-build  

# 编译ruby
bin/paas-build ruby 

# 编译nats
bin/paas-build nats
bin/paas nats start # 验证是否有nats进程启动
bin/paas hats stop   # 关闭nats进程

# 编译router
bin/paas-build router 
# 启动测试并验证是否成功
# 遗留问题：
#   1. 安装golang-go的时候，中间会出现一个提示界面，这个需要去掉
#   2. job/router下的启动脚本，对router的标准输出和标准错误的重定向看起来是无用的，以后待验证后删除

# 编译uaa
bin/paas-build java
bin/paas-build maven  
#  遗留问题：
#   1. maven在install的时候，默认装在home/.m2目录下，这个恐怕不能做绿色包，需要考虑解决方案，比如类似bundle package这样的命令

bin/paas-build uaa

# 编译postgres
bin/paas-build postgres

# 编译cc
bin/paas-build cloud_controller_ng
# 遗留问题
#  1. 目前在bundle install的时候，pg需要postgres的头文件，目前是通过apt-get装了libpq-dev先跳过了这一步，正常应该使用系统内置的pq

#
# 安装cf验证(忽略)router nats cc uaa是否已经搭建好
#

# 将target ruby作为默认ruby
echo "RUBY_HOME=$HOME/build_dir/target/ruby" >> ~/.bashrc
echo "PATH=$RUBY_HOME/bin:$PATH" >> ~/.bashrc
echo "export PATH" >> ~/.bashrc
. ~/.bashrc

# 安装cf客户端
gem install cf

# 将api2.vcap.me放到/etc/hosts中
sudo sh -c "echo '127.0.0.1 api2.vcap.me uaa.vcap.me' >> /etc/hosts"

# 验证
cf target http://api2.vcap.me:8081    
# ---> Setting target to http://api2.vcap.me:8081... OK 
cf login

# 编译warden
bin/paas-build warden 

# 构建rootfs（必须在warden之后进行）
bin/paas-build rootfs
# 测试验证
bin/paas warden start
bin/paas warden client_start # 进入warden shell，测试create run destroy等命令是否正常

# 编译dea
bin/paas-build dea_ng


```