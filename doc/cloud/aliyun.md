# 阿里云

<!-- vim-markdown-toc GFM -->
* [1 访问控制 (RAM)](#1-访问控制-ram)
    * [1.1 创建 ECS 管理员](#11-创建-ecs-管理员)
* [2 ECS](#2-ecs)
    * [2.1 使用 API 控制 ECS](#21-使用-api-控制-ecs)
    * [2.2 克隆实例](#22-克隆实例)
* [3 OSS](#3-oss)
    * [3.1 创建一个 OSS](#31-创建一个-oss)
        * [3.1.1 Bucket](#311-bucket)
        * [3.1.2 访问策略（访问控制）](#312-访问策略访问控制)
            * [需要一个 AccessKey](#需要一个-accesskey)
    * [3.2 OSSFS - 将 OSS 挂载到本地文件系统工具](#32-ossfs---将-oss-挂载到本地文件系统工具)
        * [3.2.1 简介](#321-简介)
        * [3.2.2 功能](#322-功能)
        * [3.2.3 安装](#323-安装)
        * [3.2.4 运行](#324-运行)
        * [3.2.5 常见问题处理](#325-常见问题处理)
        * [3.2.6 局限性](#326-局限性)
        * [3.2.6 相关链接](#326-相关链接)

<!-- vim-markdown-toc -->

# 1 访问控制 (RAM)

## 1.1 创建 ECS 管理员

**创建 ECS 管理员群组**

点击访问控制 -->群组管理 -->新建群组

在创建好的群组上点击授权，选择 AliyunECSFullAccess（管理云服务器服务 (ECS) 的权限） 和 AliyunBSSOrderAccess（在费用中心 (BSS) 查看订单、支付订单及取消订单的权限）

**创建用户**

点击用户管理 -->新建用户...->加入 ECS 管理员群组

# 2 ECS

## 2.1 使用 API 控制 ECS

[工具及简单使用说明](https://github.com/meetbill/op_practice_code/tree/master/cloud/aliyun/ecs)

## 2.2 克隆实例

* 系统盘 ---- 通过创建自定义镜像的方式，创建一个自定义镜像，然后使用这个自定义镜像创建 ECS 即可。
* 数据盘 ---- 对已经配置完成的数据盘进行打快照，然后在购买或者升级页面，添加磁盘的地方点：“用快照创建磁盘”，选择你要的快照即可。

# 3 OSS

## 3.1 创建一个 OSS

### 3.1.1 Bucket

创建好后需要用到的是 Bucket 名字和 endpoint

### 3.1.2 访问策略（访问控制）

#### 需要一个 AccessKey

使用 RAM 步骤

* (1) 自定义策略，使得策略只对新创建的 Bucket 有完全权限
```
{
    "Statement": [
        {
            "Action": "oss:*",
            "Effect": "Allow",
            "Resource": [
                "acs:oss:*:*:my-oss",
                "acs:oss:*:*:my-oss/*"
                      ]
                }
          ],
    "Version": "1"
}
```
* (2) 创建对应的群组，并授权对应的策略
* (3) 创建用户，并将此用户加入此群组中
* (4) 创建 AccessKey

## 3.2 OSSFS - 将 OSS 挂载到本地文件系统工具

### 3.2.1 简介

ossfs 能让您在 Linux/Mac OS X 系统中把 Aliyun OSS bucket 挂载到本地文件
系统中，您能够便捷的通过本地文件系统操作 OSS 上的对象，实现数据的共享。

### 3.2.2 功能

ossfs 基于 s3fs 构建，具有 s3fs 的全部功能。主要功能包括：

* 支持 POSIX 文件系统的大部分功能，包括文件读写，目录，链接操作，权限，
  uid/gid，以及扩展属性（extended attributes）
* 通过 OSS 的 multipart 功能上传大文件。
* MD5 校验保证数据完整性。

### 3.2.3 安装

**预编译的安装包**

我们为常见的 linux 发行版制作了安装包：

- Ubuntu-14.04
- CentOS-7.0/6.5/5.11

请从 [版本发布页面][releases] 选择对应的安装包下载安装，建议选择最新版本。

- 对于 Ubuntu，安装命令为：

```
sudo apt-get update
sudo apt-get install gdebi-core
sudo gdebi your_ossfs_package
```

- 对于 CentOS6.5 及以上，安装命令为：

```
sudo yum localinstall your_ossfs_package
```

- 对于 CentOS5，安装命令为：

```
sudo yum localinstall your_ossfs_package --nogpgcheck
```

**源码安装**

如果没有找到对应的安装包，您也可以自行编译安装。编译前请先安装下列依赖库：

Ubuntu 14.04:

```
sudo apt-get install automake autotools-dev g++ git libcurl4-gnutls-dev \
                     libfuse-dev libssl-dev libxml2-dev make pkg-config
```

CentOS 7.0:

```
sudo yum install automake gcc-c++ git libcurl-devel libxml2-devel \
                 fuse-devel make openssl-devel
```

然后您可以在 github 上下载源码并编译安装：

```
git clone https://github.com/aliyun/ossfs.git
cd ossfs
./autogen.sh
./configure
make
sudo make install
```

### 3.2.4 运行

设置 Bucket name, access key/id 信息，将其存放在 /etc/passwd-ossfs 文件中，
注意这个文件的权限必须正确设置，建议设为 640。

```
echo my-bucket:my-access-key-id:my-access-key-secret > /etc/passwd-ossfs
chmod 640 /etc/passwd-ossfs
```

将 OSS Bucket mount 到指定目录

```
ossfs my-bucket my-mount-point -ourl=my-oss-endpoint
```
**示例**

将`my-bucket`这个 Bucket 挂载到`/tmp/ossfs`目录下，AccessKeyId 是`faint`，
AccessKeySecret 是`123`，oss endpoint 是`http://oss-cn-hangzhou.aliyuncs.com`

```
echo my-bucket:faint:123 > /etc/passwd-ossfs
chmod 640 /etc/passwd-ossfs
mkdir /tmp/ossfs
ossfs my-bucket /tmp/ossfs -ourl=http://oss-cn-hangzhou.aliyuncs.com
```

卸载 Bucket:

```bash
umount /tmp/ossfs # root user
fusermount -u /tmp/ossfs # non-root user
```

**常用设置**

- 使用`ossfs --version`来查看当前版本，使用`ossfs -h`来查看可用的参数
- 如果使用 ossfs 的机器是阿里云 ECS，可以使用内网域名来**避免流量收费**和
  **提高速度**：

        ossfs my-bucket /tmp/ossfs -ourl=http://oss-cn-hangzhou-internal.aliyuncs.com

- 在 linux 系统中，[updatedb][updatedb] 会定期地扫描文件系统，如果不想
  ossfs 的挂载目录被扫描，可参考 [FAQ][FAQ-updatedb] 设置跳过挂载目录
- 如果你没有使用 [eCryptFs][ecryptfs] 等需要 [XATTR][xattr] 的文件系统，可
  以通过添加`-o noxattr`参数来提升性能
- ossfs 允许用户指定多组 bucket/access_key_id/access_key_secret 信息。当
  有多组信息，写入 passwd-ossfs 的信息格式为：

        bucket1:access_key_id1:access_key_secret1
        bucket2:access_key_id2:access_key_secret2

- 生产环境中推荐使用 [supervisor][supervisor] 来启动并监控 ossfs 进程，使
  用方法见 [FAQ][faq-supervisor]

**高级设置**

- 可以添加`-f -d`参数来让 ossfs 运行在前台并输出 debug 日志
- 可以使用`-o kernel_cache`参数让 ossfs 能够利用文件系统的 page cache，如
  果你有多台机器挂载到同一个 bucket，并且要求强一致性，请**不要**使用此
  选项

### 3.2.5 常见问题处理

遇到错误不要慌：) 按如下步骤进行排查：

1. 如果有打印错误信息，尝试阅读并理解它
2. 查看`/var/log/syslog`或者`/var/log/messages`中有无相关信息

        grep 's3fs' /var/log/syslog
        grep 'ossfs' /var/log/syslog

3. 重新挂载 ossfs，打开 debug log：

        ossfs ... -o dbglevel=debug -f -d > /tmp/fs.log 2>&1

    然后重复你出错的操作，出错后将`/tmp/fs.log`保留，自己查看或者发给我

[FAQ](https://github.com/aliyun/ossfs/wiki/FAQ)

### 3.2.6 局限性

ossfs 提供的功能和性能和本地文件系统相比，具有一些局限性。具体包括：

* 随机或者追加写文件会导致整个文件的重写。
* 元数据操作，例如 list directory，性能较差，因为需要远程访问 oss 服务器。
* 文件 / 文件夹的 rename 操作不是原子的。
* 多个客户端挂载同一个 oss bucket 时，依赖用户自行协调各个客户端的行为。例如避免多个客户端写同一个文件等等。
* 不支持 hard link。
* 不适合用在高并发读 / 写的场景，这样会让系统的 load 升高


### 3.2.6 相关链接

* [ossfs wiki](https://github.com/aliyun/ossfs/wiki)
* [s3fs](https://github.com/s3fs-fuse/s3fs-fuse) - 通过 fuse 接口，mount s3 bucket 到本地文件系统。


[releases]: https://github.com/aliyun/ossfs/releases
[updatedb]: http://linux.die.net/man/8/updatedb
[faq-updatedb]: https://github.com/aliyun/ossfs/wiki/FAQ
[ecryptfs]: http://ecryptfs.org/
[xattr]: http://man7.org/linux/man-pages/man7/xattr.7.html
[supervisor]: http://supervisord.org/
[faq-supervisor]: https://github.com/aliyun/ossfs/wiki/FAQ#18
