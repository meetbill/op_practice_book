## ZooKeeper
<!-- vim-markdown-toc GFM -->

* [1 ZooKeeper 安装](#1-zookeeper-安装)
    * [2.1 单机模式](#21-单机模式)
    * [2.2 集群模式](#22-集群模式)
* [2 客户端](#2-客户端)
* [3 ZooKeeper 的简单操作](#3-zookeeper-的简单操作)
    * [3.1 ls](#31-ls)
    * [3.2 create](#32-create)
    * [3.3 get](#33-get)
    * [3.4 set](#34-set)
    * [3.5 delete](#35-delete)

<!-- vim-markdown-toc -->

## 1 ZooKeeper 安装
ZooKeeper 的安装模式分为三种，分别为：单机模式（stand-alone）、集群模式和集群伪分布模式。ZooKeeper 单机模式的安装相对比较简单，如果第一次接触 ZooKeeper 的话，建议安装 ZooKeeper 单机模式或者集群伪分布模式。

http://hadoop.apache.org/zookeeper/releases.html
### 2.1 单机模式

```bash
[meetbill@meetbill_dev01 /opt]$ tar xvfz  zookeeper-3.4.10.tar.gz
[meetbill@meetbill_dev01 /opt]$ ZOOKEEPER_HOME=/opt/zookeeper-3.4.10
```
配置：

```bash
# 添加一个 zoo.cfg 配置文件
[meetbill@meetbill_dev01 ~]$ cd $ZOOKEEPER_HOME/conf
[meetbill@meetbill_dev01 conf]$ cp zoo_sample.cfg zoo.cfg

# 修改配置文件（zoo.cfg）
dataDir=/home/hadoop/app/tmp/zk

# 启动 zk
[meetbill@meetbill_dev01 zookeeper]$ bin/zkServer.sh start
```
### 2.2 集群模式

为了获得可靠的 ZooKeeper 服务，用户应该在一个集群上部署 ZooKeeper 。只要集群上大多数的 ZooKeeper 服务启动了，那么总的 ZooKeeper 服务将是可用的。另外，最好使用奇数台机器。 如果 zookeeper 拥有 5 台机器，那么它就能处理 2 台机器的故障了。

之后的操作和单机模式的安装类似，我们同样需要对 JAVA 环境进行设置，下载最新的 ZooKeeper 稳定版本并配置相应的环境变量。不同之处在于每台机器上 conf/zoo.cfg 配置文件的参数设置，参考下面的配置：

```
tickTime=2000
dataDir=/var/zookeeper/
clientPort=2181
initLimit=5
syncLimit=2
server.1=zoo1:2888:3888
server.2=zoo2:2888:3888
server.3=zoo3:2888:3888
```

server.id=host:port:port. 指示了不同的 ZooKeeper 服务器的自身标识，作为集群的一部分的机器应该知道 ensemble 中的其它机器。用户可以从“ server.id=host:port:port. ”中读取相关的信息。 在服务器的 data （ dataDir 参数所指定的目录）目录下创建一个文件名为 myid 的文件，这个文件中仅含有一行的内容，指定的是自身的 id 值。比如，服务器“ 1 ”应该在 myid 文件中写入“ 1 ”。这个 id 值必须是 ensemble 中唯一的，且大小在 1 到 255 之间。这一行配置中，第一个端口（ port ）是从（ follower ）机器连接到主（ leader ）机器的端口，第二个端口是用来进行 leader 选举的端口。在这个例子中，每台机器使用三个端口，分别是： clientPort ， 2181 ； port ， 2888 ； port ， 3888 。

## 2 客户端
```bash
[meetbill@meetbill_dev01 ~]$ zkCli.sh
Connecting to localhost:2181
2018-07-21 01:11:38,350 [myid:] - INFO  [main:Environment@100] - Client
...
[zk: localhost:2181(CONNECTED) 0] ls /
[zookeeper]
```

## 3 ZooKeeper 的简单操作

### 3.1 ls
使用 ls 命令来查看当前 ZooKeeper 中所包含的内容：
```
[zk: 10.77.20.23:2181(CONNECTED) 1] ls /
[zookeeper]
```
### 3.2 create
创建一个新的 znode ，使用 create /zk myData 。这个命令创建了一个新的 znode 节点“ zk ”以及与它关联的字符串：
```
[zk: 10.77.20.23:2181(CONNECTED) 2] create /zk myData
Created /zk
```

再次使用 ls 命令来查看现在 zookeeper 中所包含的内容：
```
[zk: 10.77.20.23:2181(CONNECTED) 3] ls /
[zk, zookeeper]
```

此时看到， zk 节点已经被创建。

### 3.3 get 
我们运行 get 命令来确认第二步中所创建的 znode 是否包含我们所创建的字符串：
```
[zk: 10.77.20.23:2181(CONNECTED) 4] get /zk
myData
Zxid = 0x40000000c
time = Tue Jan 18 18:48:39 CST 2011
Zxid = 0x40000000c
mtime = Tue Jan 18 18:48:39 CST 2011
pZxid = 0x40000000c
cversion = 0
dataVersion = 0
aclVersion = 0
ephemeralOwner = 0x0
dataLength = 6
numChildren = 0
```

### 3.4 set 
我们通过 set 命令来对 zk 所关联的字符串进行设置：
```
[zk: 10.77.20.23:2181(CONNECTED) 5] set /zk shenlan211314
cZxid = 0x40000000c
ctime = Tue Jan 18 18:48:39 CST 2011
mZxid = 0x40000000d
mtime = Tue Jan 18 18:52:11 CST 2011
pZxid = 0x40000000c
cversion = 0
dataVersion = 1
aclVersion = 0
ephemeralOwner = 0x0
dataLength = 13
numChildren = 0
```

### 3.5 delete
下面我们将刚才创建的 znode 删除：
```
[zk: 10.77.20.23:2181(CONNECTED) 6] delete /zk
```

最后再次使用 ls 命令查看 ZooKeeper 所包含的内容：
```
[zk: 10.77.20.23:2181(CONNECTED) 7] ls /
[zookeeper]
```

经过验证， zk 节点已经被删除。
