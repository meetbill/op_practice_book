# Docker

<!-- vim-markdown-toc GFM -->

* [1 CentOS7 安装 Docker](#1-centos7-安装-docker)
    * [1.1 准备](#11-准备)
    * [1.2 安装 Docker](#12-安装-docker)
        * [1.2.1 本地源安装](#121-本地源安装)
        * [1.2.2 网络源安装](#122-网络源安装)
    * [1.3 卸载 Docker](#13-卸载-docker)
        * [1.3.1 列出安装的 Docker](#131-列出安装的-docker)
        * [1.3.2 删除安装包](#132-删除安装包)
        * [1.3.3 删除数据文件](#133-删除数据文件)
    * [1.4 日志](#14-日志)
* [2 Docker 基础](#2-docker-基础)
    * [2.1 Docker 三大核心概念](#21-docker-三大核心概念)
    * [2.2 Docker 镜像使用](#22-docker-镜像使用)
        * [2.2.1 Docker tag](#221-docker-tag)
        * [2.2.2 导入导出镜像](#222-导入导出镜像)
    * [2.3 Docker 网络](#23-docker-网络)
    * [2.4 私有仓库](#24-私有仓库)
        * [2.4.1 环境准备](#241-环境准备)
        * [2.4.2 搭建](#242-搭建)
            * [搭建步骤](#搭建步骤)
            * [常见问题](#常见问题)
        * [2.4.3 在 docker 客户机验证](#243-在-docker-客户机验证)
* [3 Dockerfile 最佳实践](#3-dockerfile-最佳实践)
    * [3.1 Dockerfile 建议](#31-dockerfile-建议)
    * [3.2 编写 Dockerfile](#32-编写-dockerfile)
* [4 Docker 应用](#4-docker-应用)
    * [4.1 MySQL](#41-mysql)
* [5 其他](#5-其他)
    * [5.1 CentOS 6.5 上安装 Docker](#51-centos-65-上安装-docker)
    * [5.2 Alpine Linux](#52-alpine-linux)
* [6 Docker 常见问题](#6-docker-常见问题)
    * [6.1 Docker 容器故障致无法启动解决实例](#61-docker-容器故障致无法启动解决实例)
    * [6.2 启动容器失败](#62-启动容器失败)
    * [6.3 CentOS7 上运行容器挂载卷没有写入权限](#63-centos7-上运行容器挂载卷没有写入权限)
* [7 原理](#7-原理)
    * [7.1 Docker 背后的内核知识](#71-docker-背后的内核知识)

<!-- vim-markdown-toc -->

# 1 CentOS7 安装 Docker
## 1.1 准备
CentOS7 x86-64

查看版本
```
#uname -r
3.10.0-123.el7.x86_64
```
## 1.2 安装 Docker
### 1.2.1 本地源安装

CentOS 7.3 离线安装 Docker-ce(1703)

```
[root@meetbill ~]#curl -o docker_install.tar.gz https://raw.githubusercontent.com/meetbill/op_practice_code/master/cloud/docker/docker_install.tar.gz
[root@meetbill ~]#tar -zxvf docker_install.tar.gz
[root@meetbill ~]#cd docker_install
[root@meetbill ~]#sh install.sh
[root@meetbill ~]#systemctl start docker

```
### 1.2.2 网络源安装
**添加 Docker 版本仓库**
```
cat >/etc/yum.repos.d/docker.repo <<-'EOF'
[dockerrepo]
name=Docker Repository
baseurl=https://yum.dockerproject.org/repo/main/centos/7
enabled=1
gpgcheck=1
gpgkey=https://yum.dockerproject.org/gpg

[docker-ce-stable]
name=Docker CE Stable - $basearch
baseurl=https://download.docker.com/linux/centos/7/$basearch/stable
enabled=1
gpgcheck=1
gpgkey=https://download.docker.com/linux/centos/gpg
EOF
```
**安装 Docker**

docker 在 17 年 3 月份后，Docker 分成了企业版（EE）和社区版（CE），转向基于时间的 YY.MM 形式的版本控制方案，17.03 相当于 1.13.1 版本
```
#yum install docker-ce
```
安装旧版本 (1.12) 方法 `yum install docker-engine`

**设置 Docker 开机自启动**
```
#systemctl enable docker.service
```
**启动 Docker daemon**
```
#systemctl start docker
```
**验证 Docker 安装是否成功**
```
#docker run --rm hello-world
--------------------------------------------------- 以下是程序输出
Unable to find image 'hello-world:latest' locally
latest: Pulling from library/hello-world
c04b14da8d14: Pull complete
Digest: sha256:0256e8a36e2070f7bf2d0b0763dbabdd67798512411de4cdcf9431a1feb60fd9
Status: Downloaded newer image for hello-world:latest

Hello from Docker!
This message shows that your installation appears to be working correctly.

To generate this message, Docker took the following steps:
   1. The Docker client contacted the Docker daemon.
   2. The Docker daemon pulled the "hello-world" image from the Docker Hub.
   3. The Docker daemon created a new container from that image which runs the
      executable that produces the output you are currently reading.
   4. The Docker daemon streamed that output to the Docker client, which sent it to your terminal.

To try something more ambitious, you can run an Ubuntu container with:
$ docker run -it ubuntu bash

Share images, automate workflows, and more with a free Docker Hub account:
 https://hub.docker.com

For more examples and ideas, visit:
 https://docs.docker.com/engine/userguide/
```
**创建 Docker 组**

将 host 下的普通用户添加到 docker 组中后，可以不使用 sudo 即可执行 docker 程序（只是减少了每次使用 sudo 时输入密码的过程罢了，其实 docker 本身还是以 sudo 的权限在运行的。)
```
sudo usermod -aG docker your_username
```
**其他配置**

设置 ipv4 转发 (CentOS 上需要配置），实践中发现 Ubuntu 和 SUSE 上无需配置

查看
```
[root@meetbill ~]#sysctl net.ipv4.ip_forward
```
临时更改
```
[root@meetbill ~]#sysctl -w net.ipv4.ip_forward=1

```
永久更改
```
[root@meetbill ~]#echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
[root@meetbill ~]#sysctl -p
[root@meetbill ~]#sysctl net.ipv4.ip_forward

```
## 1.3 卸载 Docker
### 1.3.1 列出安装的 Docker
```
yum list installed | grep docker
```
### 1.3.2 删除安装包
```
sudo yum -y remove docker-engine.x86_64
```
### 1.3.3 删除数据文件
```
rm -rf /var/lib/docker
```

## 1.4 日志

Docker daemon 日志的位置，根据系统不同各不相同。

* Ubuntu - /var/log/upstart/docker.log
* CentOS - /var/log/daemon.log | grep docker
* Red Hat Enterprise Linux Server - /var/log/messages | grep docker

# 2 Docker 基础
## 2.1 Docker 三大核心概念
- 镜像 Image
镜像就是一个只读的模板。比如，一个镜像可以包含一个完整的 CentOS 系统，并且安装了 zabbix
镜像可以用来创建 Docker 容器。
其他人制作好镜像，我们可以拿过来轻松的使用。这就是吸引我的特性。
- 容器 Container
Docker 用容器来运行应用。容器是从镜像创建出来的实例（好有面向对象的感觉，类和对象），它可以被启动、开始、停止和删除。
- 仓库 Repository
个好理解了，就是放镜像的文件的场所。比如最大的公开仓库是 Docker Hub。

## 2.2 Docker 镜像使用

当运行容器时，使用的镜像如果在本地中不存在，docker 就会自动从 docker 镜像仓库中下载，默认是从 Docker Hub 公共镜像源下载。
下面我们来学习：

> * 管理和使用本地 Docker 主机镜像
> * 拖取公共镜像源中的镜像
> * 创建镜像

### 2.2.1 Docker tag

docker tag : 标记本地镜像，将其归入某一仓库。

**语法**
```
docker tag [OPTIONS] IMAGE[:TAG] [REGISTRYHOST/][USERNAME/]NAME[:TAG]
```
**实例**

将镜像 Ubuntu:15.10 标记为 runoob/ubuntu:v3 镜像。
```
root@runoob:~# docker tag ubuntu:15.10 runoob/ubuntu:v3
root@runoob:~# docker images   runoob/ubuntu:v3
REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
runoob/ubuntu       v3                  4e3b13c8a266        3 months ago        136.3 MB
```

### 2.2.2 导入导出镜像

导出 #docker save -o zabbix.tar meetbill/zabbix

导入 #docker load -i zabbix.tar

```
注意：导出镜像时使用 imagesid 导出后，如下，导入镜像时 REPOSITORY 和 TAG 会为 <none>（我个人认为是一个 imagesid 可对应多组 REPOSITORY 和 TAG 的原因）
#docker save -o zabbix.tar imagesid
```

## 2.3 Docker 网络

Docker 的网络模式大致可以分成四种类型，在安装完 Docker 之后，宿主机上会创建三个网络，分别是 bridge 网络，host 网络，none 网络，可以使用 docker network ls 命令查看。

bridge 方式（默认）、none 方式、host 方式、container 复用方式

1、Bridge 方式： --network=bridge

容器与 Host 网络是连通的：
eth0 实际上是 veth pair 的一端，另一端（vethb689485）连在 docker0 网桥上
通过 Iptables 实现容器内访问外部网络

2、None 方式： --network=none

这样创建出来的容器完全没有网络，将网络创建的责任完全交给用户。可以实现更加灵活复杂的网络。
另外这种容器可以可以通过 link 容器实现通信。

3、Host 方式： --network=host

容器和主机公用网络资源，使用宿主机的 IP 和端口
这种方式是不安全的。如果在隔离良好的环境中（比如租户的虚拟机中）使用这种方式，问题不大。

4、Container 复用方式： --network=container:name or id

新创建的容器和已经存在的一个容器共享一个 IP 网络资源

## 2.4 私有仓库
### 2.4.1 环境准备

ip
```
role	ip
docker 仓库机	192.168.1.52
docker 客户机	192.168.1.136
```

### 2.4.2 搭建

#### 搭建步骤

**(1) 搭建仓库 registry**
```
docker pull regsity
```
**基于私有仓库镜像运行容器**
```
> docker run -d --name registry --restart always -p 5000:5000 -v  /data/registry:/var/lib/registry registry
```
**(2) 访问私有仓库**
```
>curl -X GET http://192.168.1.52:5000/v2/_catalog
{"repositories":[]}   #私有仓库为空，没有提交新镜像到仓库中
```
**(3) 为基础镜像打个标签**

根据 images 建立 tag,xxxxxxx 为某镜像 id 或 name

docker tag xxxxxxx 192.168.1.52:5000/zabbix

**(4) 改 Docker 配置文件制定私有仓库 url**

> echo '{ "insecure-registries":["192.168.1.52:5000"] }' > /etc/docker/daemon.json
> systemctl restart docker

ps:
```
此步因系统而异，有些是修改 /etc/sysconfig/docker 文件
```

**(5) 提交镜像到本地私有仓库中**

docker push 192.168.1.52:5000/zabbix

**(6) 查看私有仓库是否存在对应的镜像**

root@localhost ~
> `curl -X GET http://192.168.1.52:5000/v2/_catalog`
```
{"repositories":["zabbix"]}
```
> curl -X GET http://192.168.1.52:5000/v2/zabbix/tags/list
```
{"name":"zabbix","tags":["latest"]}
```
#### 常见问题

提交镜像到本地仓库时异常：

> 提示非 https
```
启动项增加
--insecure-registry  192.168.1.52:5000
```

> [received unexpected HTTP status: 500 Internal Server](https://github.com/docker/distribution-library-image/issues/89)
```
使用 registry:2.6.2 image
```

### 2.4.3 在 docker 客户机验证

**(1) 修改 Docker 配置文件**

```
echo '{ "insecure-registries":["192.168.1.52:5000"] }' > /etc/docker/daemon.json
systemctl restart docker
```
**(2) 从私有仓库中下载已有的镜像**

```
docker pull 192.168.1.52:5000/centos
```
至此，私有仓库已 OK

# 3 Dockerfile 最佳实践

## 3.1 Dockerfile 建议

**1、挑选合适的基础镜像**

基础镜像尽量选最小的镜像

如果是对系统没有过深入学习的可使用比较成熟的基础镜像，如 `Ubuntu`,`CentOS` 等，因为基础镜像只需要下载一次即可共享，并不会造成太多的存储空间浪费。它的好处是这些镜像的生态比较完整，方便我们调试

**2、优化 apt-get/yum 相关操作**

将多个安装软件操作合并成一个，安装完成后使用 clean 清理一下

**3、动静分离**

经常变化的内容和基本不会变化的内容要分开，把不怎么变化的内容放在下层，创建出来不同基础镜像供上层使用。比如可以创建各种语言的基础镜像， `python2.7`、`python3.5`、`go1.7`、`java7`等等，这些镜像包含了最基本的语言库，每个组可以在上面继续构建应用级别的镜像。

**4、最小原则：只安装必需的东西**

很多人构建镜像时，会将可能用到的东西都打包到镜像中。必须要遏制这种想法，镜像中应该***只包含必需的东西***，任何可以有也可以没有的东西就不需要放在里面了。因为镜像的扩展很容易，而且运行容器的时候也很方便地对其进行修改。这样可以保证镜像尽可能的小，构建的时候尽可能的快，也保证未来的更快传输、更省网络资源。

**5、使用更少的层**

虽然看起来把不同的命令尽量分开来，写在多个命令中容易阅读和理解。但是这样会导致出现太多的镜像层，从而不好管理和分析镜像，而且镜像的层是有限的。尽量把内容相关的内容放到同一个层，使用换行符进行分割，这样可以进一步减小镜像大小，并且方便查看镜像历史。

**6、减少每层的内容**

尽管只安装必须的内容，在这个过程中也可能会产生额外的内容或者临时文件，我们要尽量让每层安装的东西保持最小。
	- 比如使用 `--no-install-recommends` 参数告诉 `apt-get` 不要安装推荐的软件包
	- 安装完软件包，清除 `/var/lib/apt/list/` 缓存
	- 删除中间文件：比如下载的压缩包，或者是只用了一次的软件包
	- 删除临时文件：如果命令产生了临时文件，也要及时删除

**7、不要在 `Dockerfile` 中修改文件的权限**

因为 `docker` 镜像是分层的，任何修改都会新增一个层，修改文件或者目录权限也是如此。如果修改大文件或者目录的权限，会把这些文件复制一份，这样很容易导致镜像很大。<br>
解决方案也很简单，要么在添加到 `Dockerfile` 之前就把文件的权限和用户设置好，要么在容器启动脚本 (**entrypoint**) 中做些修改。

**8、合理使用 ADD 命令**

> * DD 命令和 COPY 命令在很大程度上功能是一样的，但是 COPY 语义更加直接。但是唯一例外的是 ADD 命令自带解压功能，如果需要拷贝并解压一个文件到镜像中，我们可以使用 ADD 命令，除此之外，推荐使用 COPY。<br>
> * 如果是使用 ADD 命令来获取网络资源，是不推荐的。网络资源应该使用 RUN wget 或者 curl 命令来获取。

总之，优先使用 COPY

## 3.2 编写 Dockerfile

> COPY
```
(1) 如果源路径是个文件，且目标路径是以 / 结尾， 则 docker 会把目标路径当作一个目录，会把源文件拷贝到该目录下。
如果目标路径不存在，则会自动创建目标路径。

(2) 如果源路径是个文件，且目标路径是不是以 / 结尾，则 docker 会把目标路径当作一个文件。
如果目标路径不存在，会以目标路径为名创建一个文件，内容同源文件；
如果目标文件是个存在的文件，会用源文件覆盖它，当然只是内容覆盖，文件名还是目标文件名。
如果目标文件实际是个存在的目录，则会源文件拷贝到该目录下。 注意，这种情况下，最好显示的以 / 结尾，以避免混淆。

(3) 如果源路径是个目录，且目标路径不存在，则 docker 会自动以目标路径创建一个目录，把源路径目录下的文件拷贝进来。
如果目标路径是个已经存在的目录，则 docker 会把源路径目录下的文件拷贝到该目录下。
```

# 4 Docker 应用
## 4.1 MySQL
**(1) 拉取镜像**
这里我们拉取官方的镜像，标签为 5.6

meetbill@Linux:~$ docker pull mysql:5.6

等待下载完成后，我们就可以在本地镜像列表里查到 REPOSITORY 为 mysql, 标签为 5.6 的镜像。

**(2) 使用 mysql 镜像**

运行容器
```
meetbill@Linux:~$mkdir mysql;cd mysql
meetbill@Linux:~/mysql$ docker run -d \
--restart always \
-p 3306:3306 \
--name mymysql \
-v $PWD/data:/var/lib/mysql \
-e MYSQL_ROOT_PASSWORD=123456  mysql:5.6
```
命令说明：
> * -p 3306:3306：将容器的 3306 端口映射到主机的 3306 端口
> * -v $PWD/data:/var/lib/mysql：将主机当前目录下的 data 目录挂载到容器的 /mysql_data
> * -e MYSQL_ROOT_PASSWORD=123456：初始化 root 用户的密码

**(3) 进入 mysql 容器**

```
$docker ps
$docker exec -it 775c7c9ee1e1 /bin/bash
or
$docker exec -it mymysql /bin/bash
```

# 5 其他

## 5.1 CentOS 6.5 上安装 Docker

```
rpm -ivh http://dl.Fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm
rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-6
yum -y install docker-io
// 更新 device-mapper-libs
yum install device-mapper-*
/etc/init.d/docker start
```
**常见错误**
```
启动 docker 报错，错误 log：
INFO[0000] Listening for HTTP on unix (/var/run/docker.sock)
WARN[0000] You are running linux kernel version 2.6.32-431.el6.x86_64, which might be unstable running docker. Please upgrade your kernel to 3.10.0.

docker: relocation error: docker: symbol dm_task_get_info_with_deferred_remove, version Base not defined in file libdevmapper.so.1.02 with link time reference

原因：是因为 libdevmapper 版本太旧，需要 update【yum install device-mapper-*】
```

## 5.2 Alpine Linux
Alpine Linux 打出的包非常小

Alpine Linux, 一个只有 5M 的 Docker 镜像


# 6 Docker 常见问题

## 6.1 Docker 容器故障致无法启动解决实例
docker zabbix-server 启动异常退出后，启动失败，解决的方法如下

查找启动文件
```
root@ubuntu:~#find / -name 'docker-zabbix'
/xxxx/subvolumes/2086357831.../bin/docker-zabbix
/xxxx/subvolumes/080fd911a6.../bin/docker-zabbix
/xxxx/subvolumes/87bb2f9818...-init/bin/docker-zabbix
/xxxx/87bb2f98185649304c505.../bin/docker-zabbix
```
修改配置文件进行调试（多输出一些信息进行判断和调试）

## 6.2 启动容器失败
提示如下
```
Error response from daemon: driver failed programming external connectivity on endpoint zabbix (f76e6128eb80f9b9b2a50bc8642d7d9d25dc491b58fcccadcc700943487960bd):  (iptables failed: iptables --wait -t nat -A DOCKER -p tcp -d 0/0 --dport 10080 -j DNAT --to-destination 172.17.0.11:80 ! -i docker0: iptables: No chain/target/match by that name.
 (exit status 1))
Error: failed to start containers: zabbix
```
解决方法
```
重启 Docker
#systemctl restart docker
```

## 6.3 CentOS7 上运行容器挂载卷没有写入权限

在 CentOS7 中运行容器，发现挂载的本地目录在容器中没有执行权限，原因是 CentOS7 中的安全模块 selinux 把权限禁掉了，至少有以下三种方式解决挂载的目录没有权限的问题：

1，在运行容器的时候，给容器加特权：

示例：docker run -i -t --privileged=true -v /home/docs:/src waterchestnut/nodejs:0.12.0

2，临时关闭 selinux：

示例：su -c "setenforce 0"

之后执行：docker run -i -t -v /home/docs:/src waterchestnut/nodejs:0.12.0

注意：之后要记得重新开启 selinux，命令：su -c "setenforce 1"

3，添加 selinux 规则，将要挂载的目录添加到白名单：

示例：chcon -Rt svirt_sandbox_file_t /home/docs

之后执行：docker run -i -t -v /home/docs:/src waterchestnut/nodejs:0.12.0

# 7 原理

## 7.1 Docker 背后的内核知识

docker 容器的本质是宿主机上的一个进程。

Docker 通过 namespace 实现了资源隔离，通过 cgroups 实现了资源限制，通过*写时复制机制（copy-on-write）*实现了高效的文件操作。

> * Namespace：隔离技术的第一层，确保 Docker 容器内的进程看不到也影响不到 Docker 外部的进程。
> * Control Groups：LXC 技术的关键组件，用于进行运行时的资源限制。
> * UnionFS（文件系统）：容器的构件块，创建抽象层，从而实现 Docker 的轻量级和运行快速的特性
