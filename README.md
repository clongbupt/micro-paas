类似cf-release，此项目主要用于自动化构建eb的paas系统，目标是构建paas系统的绿色部署包。

### 当前集成的版本

* nats   v0.4.28 
* ruby   1.9.3-p429

## 构建流程

1. 安装virtualbox和vagrant http://www.vagrantup.com/

1. 创建虚拟机

```shell
mkdir micro-paas
cd micro-paas
vagrant init micro-paas http://file.ebcloud.com/box/ubuntu_server_12.04_64.box
vagrant up
vagrant ssh
```

