# Docker

[返回主目录](../../SUMMARY.md)


* [Docker 基础](#docker-基础)
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

# Docker 基础
* Docker 三大核心概念
    - 镜像 Image
    - 容器 Container
    - 仓库 Repository

* 命令
    - `docker inspect` IMAGE-ID
        + 返回JSON 格式信息
    - 导入导出镜像
        + `docker save -o` image.tar image
        + `docker load <` image.tar
    - 导入导出容器
        + `docker export` abc > new_container
        + `docker import`

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
