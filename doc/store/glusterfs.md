# GlusterFS

<!-- vim-markdown-toc GFM -->
* [说明](#说明)
    * [简介](#简介)
    * [GlusterFS 在企业中的应用场景](#glusterfs-在企业中的应用场景)
* [GlusterFS 安装](#glusterfs-安装)
    * [环境说明](#环境说明)
    * [安装 GlusterFS](#安装-glusterfs)
    * [配置 GlusterFS](#配置-glusterfs)
    * [volume 模式说明](#volume-模式说明)
    * [创建 GlusterFS 磁盘](#创建-glusterfs-磁盘)
    * [GlusterFS 客户端](#glusterfs-客户端)
* [维护](#维护)

<!-- vim-markdown-toc -->

## 说明

### 简介

```
GlusterFS 是 Scale-Out 存储解决方案 Gluster 的核心，它是一个开源的分布式文件系统， 具有强大的横向扩展能力，通过扩展能够支持数 PB 存储容量和处理数千客户端。

GlusterFS 借助 TCP/IP 或 InfiniBand RDMA 网络将物理分布的存储资源聚集在一起，使用单一全局命名空间来管理数据。

GlusterFS 基于可堆叠的用户空间设计，可为各种不同的数据负载提供优异的性能。

GlusterFS 支持运行在任何 IP 网络上的标准应用程序的标准客户端，用户可以在全局统一的命名空间中使用 NFS/CIFS 等标准协议来访问应用数据。

GlusterFS 使得用户可摆脱原有的独立、高成本的封闭存储系统，能够利用普通廉价的存储设备来部署可集中管理、横向扩展、虚拟化的存储池，存储容量可扩展至 TB/PB 级。

目前 GlusterFS 已被 Red Hat 收购，它的官网是：https://www.gluster.org/
```
### GlusterFS 在企业中的应用场景

理论和实践上分析，GlusterFS 目前主要适用于大文件存储场景，对于小文件尤其是海量小文件，存储效率和访问性能都表现不佳。建议存放文件大小大于 1MB

## GlusterFS 安装

### 环境说明

> * CentOS 7
> * GlusterFS

3 台机器安装 GlusterFS 组成一个集群。

```
服务器：
10.1.0.11
10.1.0.12
10.1.0.13

配置 hosts

10.1.0.11 manager
10.1.0.12 node-1
10.1.0.13 node-2

client:
10.1.0.10 client
```

### 安装 GlusterFS

CentOS 安装 GlusterFS 非常的简单

在三个节点都安装 GlusterFS

```
# 安装 GlusterFS yum 源文件
#yum install centos-release-gluster

# 安装 GlusterFS 软件
yum install -y glusterfs glusterfs-server glusterfs-fuse glusterfs-rdma
```

启动 GlusterFS

```
[root@manager ~]#systemctl start glusterd.service
[root@manager ~]#systemctl enable glusterd.service
[root@manager ~]#systemctl status glusterd.service
● glusterd.service - GlusterFS, a clustered file-system server
  Loaded: loaded (/usr/lib/systemd/system/glusterd.service; disabled; vendor preset: disabled)
  Active: active (running) since 一 2017-02-27 17:55:56 CST; 11s ago
 Process: 5476 ExecStart=/usr/sbin/glusterd -p /var/run/glusterd.pid --log-level $LOG_LEVEL $GLUSTERD_OPTIONS (code=exited, status=0/SUCCESS)
Main PID: 5477 (glusterd)
 Memory: 15.0M
 CGroup: /system.slice/glusterd.service
        └─5477 /usr/sbin/glusterd -p /var/run/glusterd.pid --log-level INFO

2 月 27 17:55:56 meetbill systemd[1]: Starting GlusterFS, a clustered file-system server...
2 月 27 17:55:56 meetbill systemd[1]: Started GlusterFS, a clustered file-system server.
```

### 配置 GlusterFS


在 manager 节点上配置，将 节点 加入到 集群中。

```
[root@manager ~]#gluster peer probe manager
peer probe: success. Probe on localhost not needed

[root@manager ~]#gluster peer probe node-1
peer probe: success.

[root@manager ~]#gluster peer probe node-2
peer probe: success.
```


查看集群状态：

```
[root@manager ~]#gluster peer status
Number of Peers: 2

Hostname: node-1
Uuid: 41573e8b-eb00-4802-84f0-f923a2c7be79
State: Peer in Cluster (Connected)

Hostname: node-2
Uuid: da068e0b-eada-4a50-94ff-623f630986d7
State: Peer in Cluster (Connected)
```


创建数据存储目录：

```
[root@manager ~]#mkdir -p /opt/gluster/data
[root@node-1 ~]# mkdir -p /opt/gluster/data
[root@node-2 ~]# mkdir -p /opt/gluster/data
```


查看 volume 状态：

```
[root@manager ~]#gluster volume info
No volumes present
```


### volume 模式说明

一、 默认模式，既 DHT, 也叫 分布卷：将文件已 hash 算法随机分布到 一台服务器节点中存储。
gluster volume create test-volume server1:/exp1 server2:/exp2

二、 复制模式，既 AFR, 创建 volume 时带 replica x 数量：将文件复制到 replica x 个节点中。
gluster volume create test-volume replica 2 transport tcp server1:/exp1 server2:/exp2

三、 条带模式，既 Striped, 创建 volume 时带 stripe x 数量： 将文件切割成数据块，分别存储到 stripe x 个节点中 ( 类似 raid 0 )。
gluster volume create test-volume stripe 2 transport tcp server1:/exp1 server2:/exp2

四、 分布式条带模式（组合型），最少需要 4 台服务器才能创建。 创建 volume 时 stripe 2 server = 4 个节点： 是 DHT 与 Striped 的组合型。
gluster volume create test-volume stripe 2 transport tcp server1:/exp1 server2:/exp2 server3:/exp3 server4:/exp4

五、 分布式复制模式（组合型）, 最少需要 4 台服务器才能创建。 创建 volume 时 replica 2 server = 4 个节点：是 DHT 与 AFR 的组合型。
gluster volume create test-volume replica 2 transport tcp server1:/exp1 server2:/exp2　server3:/exp3 server4:/exp4

六、 条带复制卷模式（组合型）, 最少需要 4 台服务器才能创建。 创建 volume 时 stripe 2 replica 2 server = 4 个节点： 是 Striped 与 AFR 的组合型。
gluster volume create test-volume stripe 2 replica 2 transport tcp server1:/exp1 server2:/exp2 server3:/exp3 server4:/exp4

七、 三种模式混合，至少需要 8 台 服务器才能创建。 stripe 2 replica 2 , 每 4 个节点 组成一个 组。
gluster volume create test-volume stripe 2 replica 2 transport tcp server1:/exp1 server2:/exp2 server3:/exp3 server4:/exp4 server5:/exp5 server6:/exp6 server7:/exp7 server8:/exp8

### 创建 GlusterFS 磁盘

```
[root@manager ~]#gluster volume create models replica 3 manager:/opt/gluster/data node-1:/opt/gluster/data node-2:/opt/gluster/data force
volume create: models: success: please start the volume to access data
```

再查看 volume 状态：

```
[root@manager ~]#gluster volume info

Volume Name: models
Type: Replicate
Volume ID: e539ff3b-2278-4f3f-a594-1f101eabbf1e
Status: Created
Number of Bricks: 1 x 3 = 3
Transport-type: tcp
Bricks:
Brick1: manager:/opt/gluster/data
Brick2: node-1:/opt/gluster/data
Brick3: node-2:/opt/gluster/data
Options Reconfigured:
performance.readdir-ahead: on
```

启动 models

```
[root@manager ~]#gluster volume start models
volume start: models: success
```

### GlusterFS 客户端

部署 GlusterFS 客户端并 mount GlusterFS 文件系统

```
[root@client ~]#yum install -y glusterfs glusterfs-fuse
[root@client ~]#mkdir -p /opt/gfsmnt
[root@client ~]#mount -t glusterfs manager:models /opt/gfsmnt/
```

```
[root@node-94 ~]#df -h
文件系统 容量 已用 可用 已用 % 挂载点
/dev/mapper/vg001-root 98G 1.2G 97G 2% /
devtmpfs 32G 0 32G 0% /dev
tmpfs 32G 0 32G 0% /dev/shm
tmpfs 32G 130M 32G 1% /run
tmpfs 32G 0 32G 0% /sys/fs/cgroup
/dev/mapper/vg001-opt 441G 71G 370G 17% /opt
/dev/sda2 497M 153M 344M 31% /boot
tmpfs 6.3G 0 6.3G 0% /run/user/0
manager:models 441G 18G 424G 4% /opt/gfsmnt
```
## 维护


1. 查看 GlusterFS 中所有的 volume:

```
[root@manager ~]#gluster volume list
```


2. 删除 GlusterFS 磁盘：

```
[root@manager ~]#gluster volume stop models   #停止名字为 models 的磁盘
[root@manager ~]#gluster volume delete models #删除名字为 models 的磁盘
```

注： 删除 磁盘 以后，必须删除 磁盘 ( /opt/gluster/data ) 中的 （ .glusterfs/ .trashcan/ ）目录。
否则创建新 volume 相同的 磁盘 会出现文件 不分布，或者 类型 错乱 的问题。

3. 卸载某个节点 GlusterFS 磁盘

```
[root@manager ~]#gluster peer detach node-2
```

4. 设置访问限制，按照每个 volume 来限制

```
[root@manager ~]#gluster volume set models auth.allow 10.6.0.*,10.7.0.*
```

5. 添加 GlusterFS 节点：

```
[root@manager ~]#gluster peer probe node-3
[root@manager ~]#gluster volume add-brick models node-3:/opt/gluster/data
```

注：如果是复制卷或者条带卷，则每次添加的 Brick 数必须是 replica 或者 stripe 的整数倍

6. 配置卷

```
[root@manager ~]# gluster volume set
```

7. 缩容 volume:

先将数据迁移到其它可用的 Brick，迁移结束后才将该 Brick 移除：

```
[root@manager ~]#gluster volume remove-brick models node-2:/opt/gluster/data node-3:/opt/gluster/data start
```

在执行了 start 之后，可以使用 status 命令查看移除进度：

```
[root@manager ~]#gluster volume remove-brick models node-2:/opt/gluster/data node-3:/opt/gluster/data status
```


不进行数据迁移，直接删除该 Brick：

```
[root@manager ~]#gluster volume remove-brick models node-2:/opt/gluster/data node-3:/opt/gluster/data commit
```

注意，如果是复制卷或者条带卷，则每次移除的 Brick 数必须是 replica 或者 stripe 的整数倍。

扩容：

```
gluster volume add-brick models node-2:/opt/gluster/data
```


8. 修复命令：

```
[root@manager ~]#gluster volume replace-brick models node-2:/opt/gluster/data node-3:/opt/gluster/data commit -force
```

9. 迁移 volume:

```
[root@manager ~]#gluster volume replace-brick models node-2:/opt/gluster/data node-3:/opt/gluster/data start
```

pause 为暂停迁移

```
[root@manager ~]#gluster volume replace-brick models node-2:/opt/gluster/data node-3:/opt/gluster/data pause
```

abort 为终止迁移

```
[root@manager ~]#gluster volume replace-brick models node-2:/opt/gluster/data node-3:/opt/gluster/data abort
```

status 查看迁移状态

```
[root@manager ~]#gluster volume replace-brick models node-2:/opt/gluster/data node-3:/opt/gluster/data status
```

迁移结束后使用 commit 来生效

```
[root@manager ~]#gluster volume replace-brick models node-2:/opt/gluster/data node-3:/opt/gluster/data commit
```

10. 均衡 volume:

```
[root@manager ~]#gluster volume models lay-outstart
[root@manager ~]#gluster volume models start
[root@manager ~]#gluster volume models startforce
[root@manager ~]#gluster volume models status
[root@manager ~]#gluster volume models stop
```
