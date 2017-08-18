## ceph

<!-- vim-markdown-toc GFM -->
* [Ceph](#ceph)
    * [Ceph 对象存储](#ceph-对象存储)
    * [Ceph 块设备](#ceph-块设备)
    * [Ceph 文件系统](#ceph-文件系统)
    * [Ceph 架构](#ceph-架构)
    * [Ceph 组件](#ceph-组件)
    * [硬件配置](#硬件配置)
        * [CPU](#cpu)
        * [内存](#内存)
        * [数据存储](#数据存储)
        * [Ceph 网络](#ceph-网络)
        * [最低硬件推荐（小型生产集群及开发集群）](#最低硬件推荐小型生产集群及开发集群)
            * [Ceph-osd](#ceph-osd)
            * [Ceph-mon](#ceph-mon)
            * [Ceph-mds](#ceph-mds)
        * [生产集群](#生产集群)
            * [Dell PowerEdge R510](#dell-poweredge-r510)
            * [Dell PowerEdge R515](#dell-poweredge-r515)
    * [推荐操作系统](#推荐操作系统)
        * [Ceph 依赖](#ceph-依赖)
            * [Linux 内核](#linux-内核)
        * [系统平台 (FIREFLY 0.80)](#系统平台-firefly-080)
    * [数据流向](#数据流向)
    * [数据复制](#数据复制)
    * [数据重分布](#数据重分布)
        * [影响因素](#影响因素)
    * [Ceph 应用](#ceph-应用)
    * [部署工具](#部署工具)
* [Ceph 安装](#ceph-安装)
    * [ceph-deploy 部署工具的安装](#ceph-deploy-部署工具的安装)
        * [Debian/Ubuntu](#debianubuntu)
        * [RedHat/CentOS/Fedora](#redhatcentosfedora)
    * [Ceph 节点准备](#ceph-节点准备)
        * [安装 NTP](#安装-ntp)
        * [安装 SSH 服务器](#安装-ssh-服务器)
        * [创建 Ceph 用户](#创建-ceph-用户)
        * [引导时联网](#引导时联网)
        * [SELinux](#selinux)
    * [Ceph 安装](#ceph-安装-1)
        * [生成监视器啊密钥](#生成监视器啊密钥)
        * [创建集群](#创建集群)
        * [安装 ceph 软件](#安装-ceph-软件)
        * [组建 mon 集群](#组建-mon-集群)
        * [收集密钥](#收集密钥)
        * [安装 OSD](#安装-osd)
        * [复制 ceph 配置文件和 key 文件到各个节点](#复制-ceph-配置文件和-key-文件到各个节点)
        * [检查健康情况](#检查健康情况)
        * [安装 MDS](#安装-mds)

<!-- vim-markdown-toc -->

# Ceph
Ceph 提供了对象、块和文件存储功能。
## Ceph 对象存储
>* REST 风格的接口
>* 与 S3 和 Swift 兼容的 API
>* S3 风格的子域
>* 统一的 S3/Swift 命名空间
>* 用户管理
>* 利用率跟踪
>* 条带化对象
>* 云解决方案集成
>* 多站点部署
>* 灾难恢复

## Ceph 块设备
>* 瘦接口支持
>* 映像尺寸最大 16EB
>* 条带化可定制
>* 内存缓存
>* 快照
>* 写时复制克隆
>* 支持内核级驱动
>* 支持 KVM 和 libvirt
>* 可作为云解决方案的后端
>* 增量备份

## Ceph 文件系统
>* 与 POSIX 兼容的语义
>* 元数据独立于数据
>* 动态重均衡
>* 子目录快照
>* 可配置的条带化
>* 有内核驱动支持
>* 有用户空间驱动支持
>* 可作为 NFS/CIFS 部署
>* 可用于 Hadoop（取代 HDFS)

## Ceph 架构
**Rados**
核心组件，提供高可靠、高可扩展、高性能的分布式对象存储架构，利用本地文件系统存储对象。

**Client**
RBD
Radosgw
Librados
Cephfs

![](../../images/store/ceph.png)

## Ceph 组件
最简的 Ceph 存储集群至少要一个监视器和两个 OSD 守护进程，只有运营 Ceph 文件系统时元数据服务器才是必需的。
**OSD（对象存储守护进程）**
存储数据，处理数据复制、恢复、回填、重均衡，并向监视器提供邻居的心跳信息。
![](../../images/store/ceph-topo.jpg)

**Monitor**
维护着各种集群状态图，包括监视器图、OSD 图、归置组 (PG) 图和 CRUSH 图。
**MDS（元数据服务器）**
存储元数据。缓存和同步元数据，管理名字空间。
## 硬件配置
### CPU
元数据服务器对 CPU 敏感，CPU 性能尽可能高。
OSD 需要一定的处理能力，CPU 性能要求较高。
### 内存
元数据服务器和监视器对内存要求较高。
OSD 对内存要求较低。
恢复期间，占用内存较大。
### 数据存储
建议用容量大于 1TB 的硬盘。
每个 OSD 守护进程占用一个驱动器。
分别在单独的硬盘运行操作系统、OSD 数据和 OSD 日志。
SSD 顺序读写性能很重要。
SSD 可用于存储 OSD 的日志。
### Ceph 网络
建议每台服务器至少两个千兆网卡，分别用于公网（前端）和集群网络（后端）。集群网络用于处理有数据复制产生的额外负载，而且可用防止拒绝服务攻击。考虑部署万兆网络。

![](../../images/store/ceph_network.png)

### 最低硬件推荐（小型生产集群及开发集群）
#### Ceph-osd
**CPU:**
>* 1x 64-bit AMD-64
>* 1x 32-bit ARM dual-core or better
>* 1x i386 dual-core

**RAM:**
~1GB for 1TB of storage per daemon
**Volume Storage:**
1x storage drive per daemon
**Journal:**
1x SSD partition per daemon (optional)
**Network:**
2x 1GB Ethernet NICs

#### Ceph-mon
**CPU:**
>* 1x 64-bit AMD-64/i386
>* 1x 32-bit ARM dual-core or better
>* 1x i386 dual-core

**RAM:**
1GB per daemon
**Disk Space:**
10GB per daemon
**Network:**
2x 1GB Ethernet NICs

#### Ceph-mds
**CPU:**
>* 1x 64-bit AMD-64 quad-core
>* 1x 32-bit ARM quad-core
>* 1x i386 quad-core

**RAM:**
1GB minimum per daemon
**Disk Space:**
1MB per daemon
**Network:**
2x 1GB Ethernet NICs
### 生产集群
#### Dell PowerEdge R510
**CPU：**
2x 64-bit quad-core Xeon CPUs
**RAM:**
16GB
**Volume Storage:**
8x 2TB drives.1 OS,7 Storage
**Client Network:**
2x 1GB Ethernet NICs
**OSD Network:**
2x 1GB Ethernet NICs
**Mgmt. Network:**
2x 1GB Ethernet NICs
#### Dell PowerEdge R515
**CPU：**
1x hex-core Opteron CPU
**RAM:**
16GB
**Volume Storage:**
12x 3TB drives.Storage
**OS Storage:**
1x 500GB drive. Operating System.
**Client Network:**
2x 1GB Ethernet NICs
**OSD Network:**
2x 1GB Ethernet NICs
**Mgmt. Network:**
2x 1GB Ethernet NICs
## 推荐操作系统
### Ceph 依赖
#### Linux 内核
**Ceph 内核态客户端：**
>* v3.16.3 or later (rbd deadlock regression in v3.16.[0-2])
>* NOT v3.15.* (rbd deadlock regression)
>* V3.14.*
>* v3.6.6 or later in the v3.6 stable series
>* v3.4.20 or later in the v3.4 stable series

**btrfs:**
v3.14 或更新
### 系统平台 (FIREFLY 0.80)
| Distro | Release | Code Name | Kernel | Notes | Testing |
|--------|---------|-----------|--------|-------|---------|
| Ubuntu | 12.04 | Precise Pangolin | linux-3.2.0 | 1,2 | B,I,C |
| Ubuntu | 14.04 | Trusty Tahr | linux-3.13.0 |  | B,I,C |
| Debian | 6.0 | Squeeze | linux-2.6.32 | 1,2,3 | B |
| Debian | 7.0 | Wheezy | linux-3.2.0 | 1,2 | B |
| CentOS | 6 | N/A | linux-2.6.32 | 1,2 | B,I |
| RHEL | 6 |  | linux-2.6.32 | 1,2 | B,I,C |
| RHEL | 7 |  | linux-3.10.0 |  | B,I,C |
| Fedora | 19.0 | Schrodinger's Cat | linux-3.10.0 |  | B |
| Fedora | 20.0 | Heisenbug | linux-3.14.0 |  | B |

Note:

>* 1: 默认内核 btrfs 版本较老，不推荐用于 ceph-osd 存储节点；要升级到推荐的内核，或者改用 xfs,ext4
>* 2: 默认内核带的 Ceph 客户端较老，不推荐做内核空间客户端（内核 RBD 或 Ceph 文件系统），请升级到推荐内核。
>* 3: 默认内核或已安装的 glibc 版本若不支持 syncfs(2) 系统调用，同一台机器上使用 xfs 或 ext4 的 ceph-osd 守护进程性能不会如愿。

测试版：

>* B: 我们持续地在这个平台上编译所有分支、做基本单元测试；也为这个平台构建可发布软件包。
>* I: 我们在这个平台上做基本的安装和功能测试。
>* C: 我们在这个平台上持续地做全面的功能、退化、压力测试，包括开发分支、预发布版本、正式发布版本。

## 数据流向
Data-->obj-->PG-->Pool-->OSD

![](../../images/store/Distributed-Object-Store.png)

## 数据复制

![](../../images/store/ceph_write.png)

## 数据重分布
### 影响因素
OSD
OSD weight
OSD crush weight
## Ceph 应用
**RDB**
为 Glance Cinder 提供镜像存储
提供 Qemu/KVM 驱动支持
支持 openstack 的虚拟机迁移

**RGW**
替换 swift
网盘

**Cephfs**
提供共享的文件系统存储
支持 openstack 的虚拟机迁移
## 部署工具
Ceph-deploy


# Ceph 安装
结构图：

![](../../../images/store/Ceph-install.png)

## ceph-deploy 部署工具的安装
### Debian/Ubuntu
1. 添加发布密钥：

    wget -q -O- 'https://ceph.com/git/?p=ceph.git;a=blob_plain;f=keys/release.asc' | sudo apt-key add -
2. 添加 Ceph 软件包源，用稳定版 Ceph（如 cuttlefish 、 dumpling 、 emperor 、 firefly 等等）替换掉 {ceph-stable-release} 。

    echo deb http://ceph.com/debian-{ceph-stable-release}/ $(lsb_release -sc) main | sudo tee /etc/apt/sources.list.d/ceph.list

3. 更新仓库，并安装 ceph-deploy ：

    sudo apt-get update && sudo apt-get install ceph-deploy

### RedHat/CentOS/Fedora
创建一个 YUM (Yellowdog Updater, Modified) 库文件，其路径为 /etc/yum.repos.d/ceph.repo
用最新稳定版 Ceph 名字替换 {ceph-stable-release} （如 firefly ）、用你的发行版名字替换 {distro} （如 el6 为 CentOS 6 、 rhel6.5 为 Red Hat 6 .5、 fc19 是 Fedora 19 、 fc20 是 Fedora 20 。

    [ceph-noarch]
    name=Ceph noarch packages
    baseurl=http://ceph.com/rpm-{ceph-release}/{distro}/noarch
    enabled=1
    gpgcheck=1
    type=rpm-md
    gpgkey=https://ceph.com/git/?p=ceph.git;a=blob_plain;f=keys/release.asc

更新软件库并安装 ceph-deploy ：

    sudo yum update && sudo yum install ceph-deploy

## Ceph 节点准备
管理节点能够通过 SSH 无密码地访问各 Ceph 节点。
### 安装 NTP
以免因时钟漂移导致故障。

在 CentOS / RHEL 上可执行：

    sudo yum install ntp ntpdate ntp-doc

在 Debian / Ubuntu 上可执行：

    sudo apt-get install ntp

确保在各 Ceph 节点上启动了 NTP 服务，并且要使用同一个 NTP 服务器。
### 安装 SSH 服务器
在所有 Ceph 节点上执行如下步骤：

    sudo apt-get install openssh-server

或者

    sudo yum install openssh-server

确保所有 Ceph 节点上的 SSH 服务器都在运行。

### 创建 Ceph 用户
ceph-deploy 工具必须以普通用户登录，且此用户拥有无密码使用 sudo 的权限，因为它需要安装软件及配置文件，中途不能输入密码。

建议在集群内的所有 Ceph 节点上都创建一个 Ceph 用户。

在各 Ceph 节点创建用户。

    ssh user@ceph-server
    sudo useradd -d /home/{username} -m {username}·
    sudo passwd {username}

确保各 Ceph 节点上所创建的用户都有 sudo 权限。

    echo "{username} ALL = (root) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/{username}
    sudo chmod 0440 /etc/sudoers.d/{username}

生成 SSH 密钥对，但不要用 sudo 或 root 用户。口令为空：

    ssh-keygen

    Generating public/private key pair.
    Enter file in which to save the key (/ceph-admin/.ssh/id_rsa):
    Enter passphrase (empty for no passphrase):
    Enter same passphrase again:
    Your identification has been saved in /ceph-admin/.ssh/id_rsa.
    Your public key has been saved in /ceph-admin/.ssh/id_rsa.pub.

把公钥拷贝到各 Ceph 节点。

    ssh-copy-id {username}@node1
    ssh-copy-id {username}@node2
    ssh-copy-id {username}@node3

（推荐做法）修改 ceph-deploy 管理节点上的 ~/.ssh/config 文件，这样 ceph-deploy 就能用你所建的用户名登录 Ceph 节点了，无需每次执行 ceph-deploy 都指定 --username {username} 。这样做同时也简化了 ssh 和 scp 的用法。

    Host node1
       Hostname node1
       User {username}
    Host node2
       Hostname node2
       User {username}
    Host node3
       Hostname node3
       User {username}

### 引导时联网

Ceph 监视器之间默认用 6789 端口通信， OSD 之间默认用 6800:7810 这个范围内的端口通信。 Ceph OSD 能利用多个网络连接与客户端、监视器、其他副本 OSD 、其它心跳 OSD 分别进行通信。

对于 RHEL 7 上的 firewalld ，要对公共域放通 Ceph 监视器所使用的 6789 端口、以及 OSD 所使用的 6800:7100 ，并且要配置为永久规则，这样重启后规则仍有效。例如：

    sudo firewall-cmd --zone=public --add-port=6789/tcp --permanent

若用 iptables 命令，要放通 Ceph 监视器所用的 6789 端口和 OSD 所用的 6800:7100 端口范围，命令如下：

    sudo iptables -A INPUT -i {iface} -p tcp -s {ip-address}/{netmask} --dport 6789 -j ACCEPT

配置好 iptables 之后要保存配置，这样重启之后才依然有效。

    /sbin/service iptables save

>在 CentOS 和 RHEL 上执行 ceph-deploy 命令时，如果你的 Ceph 节点默认设置了 requiretty 那就会遇到报错。可以这样禁用它，执行 sudo visudo ，找到 Defaults requiretty 选项，把它改为 Defaults:ceph !requiretty 或者干脆注释掉，这样 ceph-deploy 就可以用之前创建的用户（ 创建 Ceph 用户 ）连接了。编辑配置文件 /etc/sudoers 时，必须用 sudo visudo 而不是文本编辑器。

### SELinux

为简化安装，把 SELinux 设置为 Permissive 或者完全禁用，也就是在加固系统配置前先确保集群的安装、配置没问题。用下列命令把 SELinux 设置为 Permissive ：

    sudo setenforce 0

## Ceph 安装
登录管理节点，新建一个工作目录 ceph，后面所有操作都在此目录下进行，ceph-deploy 工具会在此目录产生各个配置文件，并对所有节点进行安装配置。

### 生成监视器啊密钥
生成一个文件系统 ID (FSID)

    ceph-deploy purgedata {ceph-node} [{ceph-node}]
    ceph-deploy forgetkeys

### 创建集群

    ceph-deploy new {ceph-node}

### 安装 ceph 软件

    ceph-deploy install {ceph-node} [{ceph-node}]

### 组建 mon 集群

    ceph-deploy mon create {ceph-node}

启动 mon 进程：

    ceph-deploy mon create-initial

### 收集密钥

    ceph-deploy gatherkeys {ceph-node}

### 安装 OSD
准备 OSD

    ceph-deploy osd prepare {ceph-node}:/path/to/directory

激活 OSD

    ceph-deploy osd activate {ceph-node}:/path/to/directory

### 复制 ceph 配置文件和 key 文件到各个节点

    ceph-deploy admin {ceph-node}

### 检查健康情况

    ceph health

返回 active + clean 状态。

### 安装 MDS

    ceph-deploy mds create {ceph-node}
