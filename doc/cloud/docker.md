# Docker

* [centos7安装docker](#centos7安装docker)
	* [一 准备](#一-准备)
		* [1. centos7 x86-64](#1-centos7-x86-64)
		* [2. 查看版本：](#2-查看版本)
	* [二 安装docker](#二-安装docker)
		* [1. 更新系统：](#1-更新系统)
		* [2. 添加docker版本仓库:](#2-添加docker版本仓库)
		* [3. 安装docker](#3-安装docker)
		* [4. 设置docker开机自启动](#4-设置docker开机自启动)
		* [5. 启动Docker daemon：](#5-启动docker-daemon)
		* [6. 验证docker安装是否成功](#6-验证docker安装是否成功)
		* [7. 创建docker组](#7-创建docker组)
	* [三 卸载docker](#三-卸载docker)
		* [1. 列出安装的docker](#1-列出安装的docker)
		* [2. 删除安装包](#2-删除安装包)
		* [3. 删除数据文件](#3-删除数据文件)
* [Docker 使用](#docker-使用)
	* [Docker 三大核心概念](#docker-三大核心概念)
	* [Docker 镜像使用](#docker-镜像使用)


# centos7安装docker 
## 一 准备
### 1. centos7 x86-64
### 2. 查看版本：
```
#uname -r    
3.10.0-123.el7.x86_64
```
## 二 安装docker 
### 1. 更新系统：
```
#yum update -y
```
### 2. 添加docker版本仓库: 
```
cat >/etc/yum.repos.d/docker.repo <<-'EOF'  
[dockerrepo]  
name=Docker Repository  
baseurl=https://yum.dockerproject.org/repo/main/centos/7  
enabled=1  
gpgcheck=1  
gpgkey=https://yum.dockerproject.org/gpg  
EOF
```
### 3. 安装docker
```
#yum install docker-engine
```
### 4. 设置docker开机自启动 
```
#systemctl enable docker.service
```
### 5. 启动Docker daemon：
```
#systemctl start docker
```
### 6. 验证docker安装是否成功
```
#docker run --rm hello-world
---------------------------------------------------以下是程序输出
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
### 7. 创建docker组
```
sudo usermod -aG docker your_username
```
    
## 三 卸载docker 
### 1. 列出安装的docker
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
镜像就是一个只读的模板。比如，一个镜像可以包含一个完整的Centos系统，并且安装了zabbix
镜像可以用来创建Docker容器。
其他人制作好镜像，我们可以拿过来轻松的使用。这就是吸引我的特性。
- 容器 Container
Docker用容器来运行应用。容器是从镜像创建出来的实例（好有面向对象的感觉，类和对象），它可以被启动、开始、停止和删除。
- 仓库 Repository
个好理解了，就是放镜像的文件的场所。比如最大的公开仓库是Docker Hub。

## Docker 镜像使用

当运行容器时，使用的镜像如果在本地中不存在，docker 就会自动从 docker 镜像仓库中下载，默认是从 Docker Hub 公共镜像源下载。
下面我们来学习：

> * 管理和使用本地 Docker 主机镜像
> * 拖取公共镜像源中的镜像
> * 创建镜像
