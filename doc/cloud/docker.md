# Docker

<!-- vim-markdown-toc GFM -->
* [centos7 安装 docker](#centos7-安装-docker)
    * [一 准备](#一-准备)
        * [1. centos7 x86-64](#1-centos7-x86-64)
        * [2. 查看版本：](#2-查看版本)
    * [二 安装 docker](#二-安装-docker)
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
### 1. 更新系统：
```
#yum update -y
```
### 2. 添加 docker 版本仓库：
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
### 3. 安装 docker

docker 在 17 年 3 月份后，Docker 分成了企业版（EE）和社区版（CE），转向基于时间的 YY.MM 形式的版本控制方案，17.03 相当于 1.13.1 版本
```
#yum install docker-ce
```
安装旧版本 (1.12) 方法 `yum install docker-engine`

### 4. 设置 docker 开机自启动
```
#systemctl enable docker.service
```
### 5. 启动 Docker daemon：
```
#systemctl start docker
```
### 6. 验证 docker 安装是否成功
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
### 7. 创建 docker 组

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
