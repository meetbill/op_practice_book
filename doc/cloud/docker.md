# Docker

<!-- vim-markdown-toc GFM -->
* [centos7 安装 docker](#centos7-安装-docker)
    * [一 准备](#一-准备)
        * [1. centos7 x86-64](#1-centos7-x86-64)
        * [2. 查看版本：](#2-查看版本)
    * [二 安装 docker](#二-安装-docker)
        * [本地源安装](#本地源安装)
        * [网络源安装](#网络源安装)
            * [1. 更新系统：](#1-更新系统)
            * [2. 添加 docker 版本仓库：](#2-添加-docker-版本仓库)
            * [3. 安装 docker](#3-安装-docker)
            * [4. 设置 docker 开机自启动](#4-设置-docker-开机自启动)
            * [5. 启动 Docker daemon：](#5-启动-docker-daemon)
            * [6. 验证 docker 安装是否成功](#6-验证-docker-安装是否成功)
            * [7. 创建 docker 组](#7-创建-docker-组)
    * [三 卸载 docker](#三-卸载-docker)
        * [1. 列出安装的 docker](#1-列出安装的-docker)
        * [2. 删除安装包](#2-删除安装包)
        * [3. 删除数据文件](#3-删除数据文件)
* [Docker 使用](#docker-使用)
    * [Docker 三大核心概念](#docker-三大核心概念)
    * [Docker 镜像使用](#docker-镜像使用)
        * [导入导出镜像](#导入导出镜像)
    * [私有仓库](#私有仓库)
        * [一、环境准备](#一环境准备)
            * [1. ip](#1-ip)
        * [二、搭建](#二搭建)
            * [1. 搭建仓库 registry](#1-搭建仓库-registry)
        * [2. 基于私有仓库镜像运行容器](#2-基于私有仓库镜像运行容器)
            * [3. 访问私有仓库](#3-访问私有仓库)
            * [4. 为基础镜像打个标签](#4-为基础镜像打个标签)
            * [5. 改Docker配置文件制定私有仓库url](#5-改docker配置文件制定私有仓库url)
            * [6. 提交镜像到本地私有仓库中](#6-提交镜像到本地私有仓库中)
            * [7. 查看私有仓库是否存在对应的镜像](#7-查看私有仓库是否存在对应的镜像)
        * [三、在docker客户机验证](#三在docker客户机验证)
            * [1. 修改Docker配置文件](#1-修改docker配置文件)
            * [2. 从私有仓库中下载已有的镜像](#2-从私有仓库中下载已有的镜像)
    * [dockerfile 最佳实践](#dockerfile-最佳实践)

<!-- vim-markdown-toc -->

# centos7 安装 docker
## 一 准备
### 1. centos7 x86-64
### 2. 查看版本：
```
#uname -r
3.10.0-123.el7.x86_64
```
## 二 安装 docker
### 本地源安装

Centos 7.3 离线安装 docker-ce(1703)

```
[root@meetbill ~]#curl -o docker_install.tar.gz https://raw.githubusercontent.com/BillWang139967/op_practice_code/master/cloud/docker/docker_install.tar.gz
[root@meetbill ~]#tar -zxvf docker_install.tar.gz 
[root@meetbill ~]#cd docker_install
[root@meetbill ~]#sh install.sh
[root@meetbill ~]#systemctl start docker

```
### 网络源安装
#### 1. 更新系统：
```
#yum update -y
```
#### 2. 添加 docker 版本仓库：
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
#### 3. 安装 docker

docker 在 17 年 3 月份后，Docker 分成了企业版（EE）和社区版（CE），转向基于时间的 YY.MM 形式的版本控制方案，17.03 相当于 1.13.1 版本
```
#yum install docker-ce
```
安装旧版本 (1.12) 方法 `yum install docker-engine`

#### 4. 设置 docker 开机自启动
```
#systemctl enable docker.service
```
#### 5. 启动 Docker daemon：
```
#systemctl start docker
```
#### 6. 验证 docker 安装是否成功
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
#### 7. 创建 docker 组

将 host 下的普通用户添加到 docker 组中后，可以不使用 sudo 即可执行 docker 程序（只是减少了每次使用 sudo 时输入密码的过程罢了，其实 docker 本身还是以 sudo 的权限在运行的。)
```
sudo usermod -aG docker your_username
```

## 三 卸载 docker
### 1. 列出安装的 docker
```
yum list installed | grep docker
```
### 2. 删除安装包
```
sudo yum -y remove docker-engine.x86_64
```
### 3. 删除数据文件
```
rm -rf /var/lib/docker
```

# Docker 使用
## Docker 三大核心概念
- 镜像 Image
镜像就是一个只读的模板。比如，一个镜像可以包含一个完整的 Centos 系统，并且安装了 zabbix
镜像可以用来创建 Docker 容器。
其他人制作好镜像，我们可以拿过来轻松的使用。这就是吸引我的特性。
- 容器 Container
Docker 用容器来运行应用。容器是从镜像创建出来的实例（好有面向对象的感觉，类和对象），它可以被启动、开始、停止和删除。
- 仓库 Repository
个好理解了，就是放镜像的文件的场所。比如最大的公开仓库是 Docker Hub。

## Docker 镜像使用

当运行容器时，使用的镜像如果在本地中不存在，docker 就会自动从 docker 镜像仓库中下载，默认是从 Docker Hub 公共镜像源下载。
下面我们来学习：

> * 管理和使用本地 Docker 主机镜像
> * 拖取公共镜像源中的镜像
> * 创建镜像

### 导入导出镜像

导出 #docker save -o centos.tar imagesid

导入 #docker load -i centos.tar

## 私有仓库
### 一、环境准备

#### 1. ip

role	ip
docker仓库机	192.168.1.52
docker客户机	192.168.1.136

### 二、搭建

#### 1. 搭建仓库 registry

docker pull regsity

### 2. 基于私有仓库镜像运行容器
> docker run -d --name registry --restart always -p 5000:5000 -v  /data/registry:/var/lib/registry registry

#### 3. 访问私有仓库
>curl -X GET http://192.168.1.52:5000/v2/_catalog
{"repositories":[]}   #私有仓库为空，没有提交新镜像到仓库中

#### 4. 为基础镜像打个标签

根据 images 建立 tag,xxxxxxx为某镜像id或name

docker tag xxxxxxx 192.168.1.52:5000/zabbix

#### 5. 改Docker配置文件制定私有仓库url

> echo '{ "insecure-registries":["192.168.1.52:5000"] }' > /etc/docker/daemon.json
> systemctl restart docker

#### 6. 提交镜像到本地私有仓库中

docker push 192.168.1.52:5000/zabbix

#### 7. 查看私有仓库是否存在对应的镜像

root@localhost ~
> curl -X GET http://192.168.1.52:5000/v2/_catalog
{"repositories":["zabbix"]}
> curl -X GET http://192.168.1.52:5000/v2/zabbix/tags/list
{"name":"zabbix","tags":["latest"]}

### 三、在docker客户机验证

#### 1. 修改Docker配置文件

> echo '{ "insecure-registries":["192.168.1.52:5000"] }' > /etc/docker/daemon.json
> systemctl restart docker

#### 2. 从私有仓库中下载已有的镜像

> docker pull 192.168.1.52:5000/centos

至此，私有仓库已OK

## dockerfile 最佳实践


**1、挑选合适的基础镜像**

基础镜像尽量选最小的镜像

如果是对系统没有过深入学习的可使用比较成熟的基础镜像，如 `Ubuntu`,`Centos` 等，因为基础镜像只需要下载一次即可共享，并不会造成太多的存储空间浪费。它的好处是这些镜像的生态比较完整，方便我们调试

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
解决方案也很简单，要么在添加到 `Dockerfile` 之前就把文件的权限和用户设置好，要么在容器启动脚本(**entrypoint**)中做些修改。

**8、合理使用 ADD 命令**

> * DD 命令和 COPY 命令在很大程度上功能是一样的，但是 COPY 语义更加直接。但是唯一例外的是 ADD 命令自带解压功能，如果需要拷贝并解压一个文件到镜像中，我们可以使用 ADD 命令，除此之外，推荐使用 COPY。<br>
> * 如果是使用 ADD 命令来获取网络资源，是不推荐的。网络资源应该使用 RUN wget 或者 curl 命令来获取。

总之，优先使用COPY
