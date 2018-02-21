## Keepalived 使用

<!-- vim-markdown-toc GFM -->
* [1 Keepalived 介绍及安装](#1-keepalived-介绍及安装)
    * [1.1 介绍](#11-介绍)
        * [1.1.1 LVS 和 Keepalived 的关系](#111-lvs-和-keepalived-的关系)
    * [1.2 安装](#12-安装)
    * [1.3 使用](#13-使用)
* [2 Keepalived 配置相关](#2-keepalived-配置相关)
    * [2.1 global defs 区域](#21-global-defs-区域)
    * [2.2 vrrp script 区域](#22-vrrp-script-区域)
    * [2.3 VRRPD 配置](#23-vrrpd-配置)
        * [2.3.1 VRRP Sync Groups](#231-vrrp-sync-groups)
        * [2.3.2 VRRP 实例配置](#232-vrrp-实例配置)
    * [2.4 LVS 配置](#24-lvs-配置)
* [3 Keepalived 工作原理](#3-keepalived-工作原理)
    * [3.1 VRRP 工作流程](#31-vrrp-工作流程)
    * [3.2 MASTER 和 BACKUP 节点的优先级如何调整？](#32-master-和-backup-节点的优先级如何调整)
    * [3.3 ARP 查询处理](#33-arp-查询处理)
    * [3.4 虚拟 IP 地址和 MAC 地址](#34-虚拟-ip-地址和-mac-地址)
    * [3.5  Keepalived 进程](#35--keepalived-进程)
    * [3.6 Keepalived 健康检查方式](#36-keepalived-健康检查方式)
* [4 Keepalived 场景应用](#4-keepalived-场景应用)
    * [4.1 Keepalived 主从切换](#41-keepalived-主从切换)
    * [4.2 Keepalived 仅做 HA 时的配置](#42-keepalived-仅做-ha-时的配置)
* [5 其他配置](#5-其他配置)
    * [5.1 重定向 Keepalived 输出日志](#51-重定向-keepalived-输出日志)
    * [5.2 只用 VRRP 模块](#52-只用-vrrp-模块)
* [6 常见问题](#6-常见问题)
    * [6.1 virtual_router_id 冲突](#61-virtual_router_id-冲突)
    * [6.2 VIP 无法访问](#62-vip-无法访问)
        * [6.2.1 VIP 被抢占](#621-vip-被抢占)
        * [6.2.2 网关的 ARP 缓存没有刷新](#622-网关的-arp-缓存没有刷新)

<!-- vim-markdown-toc -->
# 1 Keepalived 介绍及安装

## 1.1 介绍

Keepalived 是一个基于 VRRP 协议来实现的 WEB 服务高可用方案，其功能类似于 [heartbeat], 可以利用其来避免单点故障。一个 WEB 服务至少会有 2 台服务器运行 Keepalived，一台为主服务器（MASTER），一台为备份服务器（BACKUP），但是对外表现为一个虚拟 IP，主服务器会发送特定的消息给备份服务器，当备份服务器收不到这个消息的时候，即主服务器宕机的时候，备份服务器就会接管虚拟 IP，继续提供服务，从而保证了高可用性。

	 	+---------VIP(192.168.0.3)----------+
		|                                   |
	    |                                   |
	server(MASTER) <----keepalived----> server(BACKUP)
	(192.168.0.1)                       (192.168.0.2)

### 1.1.1 LVS 和 Keepalived 的关系

LVS 可以不依赖 Keepalived 而进行分发请求，但是想让负载调度器动态监控真实服务器心跳 需要写很复杂的代码。而 Keepalived 正是一个通过简单配置就能满足请求分发、心跳检测、集群管理的好工具

## 1.2 安装

编译安装：

	$ wget http://www.keepalived.org/software/keepalived-1.2.2.tar.gz</a>
	$ tar -zxvf keepalived-1.2.2.tar.gz
	$ cd keepalived-1.2.2
	$ ./configure --prefix=/usr/local/keepalived
	$ make && make install

拷贝需要的文件：

	$ cp /usr/local/keepalived/etc/rc.d/init.d/keepalived /etc/init.d/keepalived
	$ cp /usr/local/keepalived/sbin/keepalived /usr/sbin/
	$ cp /usr/local/keepalived/etc/sysconfig/keepalived /etc/sysconfig/
	$ mkdir -p /etc/keepalived/
	$ cp /usr/local/etc/keepalived/keepalived.conf /etc/keepalived/keepalived.conf

`/etc/keepalived/keepalived.conf`是默认配置文件

## 1.3 使用

	$ /etc/init.d/keepalived start | restart | stop

当启动了 Keepalived 之后，通过`ifconfig`是看不到 VIP 的，但是通过`ip a`命令是可以看到的。 当 MASTER 宕机，BACKUP 升级为 MASTER，这些 VRRP_Instance 状态的切换都可以在`/var/log/message`中进行记录。

# 2 Keepalived 配置相关

Keepalived 只有一个配置文件 /etc/keepalived/keepalived.conf，里面主要包括以下几个配置区域，分别是 global\_defs、static\_ipaddress、static\_routes、vrrp_script、vrrp\_instance 和 virtual\_server。

## 2.1 global defs 区域

主要是配置故障发生时的通知对象以及机器标识

```
global_de_s {
    notification_email {
        a@abc.com
        b@abc.com
        ...
    }
    notification_email_from alert@abc.com
    smtp_server smtp.abc.com
    smtp_connect_timeout 30
    enable_traps
    router_id host163
}
```

* notification_email 故障发生时给谁发邮件通知。

* notification_email_from 通知邮件从哪个地址发出。

* smpt_server 通知邮件的 smtp 地址。

* smtp_connect_timeout 连接 smtp 服务器的超时时间。

* enable_traps 开启 SNMP 陷阱（[Simple Network Management Protocol][snmp]）。

* router_id 标识本节点的字条串，通常为 hostname，但不一定非得是 hostname。故障发生时，邮件通知会用到。

## 2.2 vrrp script 区域

用来做健康检查的，当时检查失败时会将`vrrp_instance`的`priority`减少相应的值。

```
vrrp_script chk_http_port {
    script "</dev/tcp/127.0.0.1/80"
    interval 1
    weight -10
}
```

以上意思是如果`script`中的指令执行失败，那么相应的`vrrp_instance`的优先级会减少 10 个点。

## 2.3 VRRPD 配置

在 [VRRP] 协议中，有两组重要的概念：

> * VRRP 路由器和虚拟路由器
> * 主控路由器和备份路由器

VRRP 路由器是指运行 VRRP 的路由器，是物理实体，虚拟路由器是指 VRRP 协议创建的，是逻辑概念。一组 VRRP 路由器协同工作，共同构成一台虚拟路由器。该虚拟路由器对外表现为一个具有唯一固定 IP 地址和 MAC 地址的逻辑路由器。处于同一个 VRRP 组中的路由器具有两种互斥的角色：

主控路由器和备份路由器，一个 VRRP 组中有且只有一台处于主控角色的路由器，可以有一个或者多个处于备份角色的路由器。VRRP 协议使用选择策略从路由器组中选出一台作为主控，负责 ARP 相应和转发 IP 数据包，组中的其它路由器作为备份的角色处于待命状态。当由于某种原因主控路由器发生故障时，备份路由器能在几秒钟的时延后升级为主路由器。由于此切换非常迅速而且不用改变 IP 地址和 MAC 地址，故对终端使用者系统是透明的。

VRRPD 配置包括两部分

> * VRRP 同步组 (synchroization group)
> * VRRP 实例 (VRRP Instance)

### 2.3.1 VRRP Sync Groups

vrrp_rsync_group 用来定义 vrrp_intance 组，使得这个组内成员动作一致。举个例子来说明一下其功能：

两个 vrrp_instance 同属于一个 vrrp_rsync_group，那么其中一个 vrrp_instance 发生故障切换时，另一个 vrrp_instance 也会跟着切换（即使这个 instance 没有发生故障）。

eg: 机器有两个网段，一个内网一个外网，每个网段开启一个 VRRP 实例，假设 VRRP 配置为检查内网，那么当外网出现问题时，VRRPD 认为自己仍然健康，那么不会发送 Master 和 Backup 的切换，从而导致了问题。Sync group 就是为了解决这个问题。可以将两个实例都放到一个 Sync group，这样，group 里面任何一个实例出现问题都会发生切换

```
vrrp_sync_group VG_1 {
    group {
        inside_network   # name of vrrp_instance (below)
        outside_network  # One for each moveable IP.
        ...
    }
    notify_master /path/to_master.sh
    notify_backup /path/to_backup.sh
    notify_fault "/path/fault.sh VG_1"
    notify /path/notify.sh
    smtp_alert
}
```
* notify_master/backup/fault 分别表示切换为主 / 备 / 出错时所执行的脚本。

* notify 表示任何一状态切换时都会调用该脚本，并且该脚本在以上三个脚本执行完成之后进行调用，Keepalived 会自动传递三个参数（$1 = "GROUP"|"INSTANCE"，$2 = name of group or instance，$3 = target state of transition(MASTER/BACKUP/FAULT)）。

* smtp_alert 表示是否开启邮件通知（用全局区域的邮件设置来发通知）。

### 2.3.2 VRRP 实例配置

vrrp_instance 用来定义对外提供服务的 VIP 区域及其相关属性。

```

vrrp_instance VI_1 {
    state MASTER
    interface eth0
    use_vmac <VMAC_INTERFACE>
    dont_track_primary
    track_interface {
        eth0
        eth1
    }
    mcast_src_ip <IPADDR>
    lvs_sync_daemon_interface eth1
    garp_master_delay 10
    virtual_router_id 1
    priority 100
    advert_int 1
    authentication {
        auth_type PASS
        auth_pass 12345678
    }
    virtual_ipaddress {
        10.210.214.253/24 brd 10.210.214.255 dev eth0
        192.168.1.11/24 brd 192.168.1.255 dev eth1
    }

    virtual_routes {
        172.16.0.0/12 via 10.210.214.1
        192.168.1.0/24 via 192.168.1.1 dev eth1
        default via 202.102.152.1
    }

    track_script {
        chk_http_port
    }

    nopreempt
    preempt_delay 300
    debug
    notify_master <STRING>|<QUOTED-STRING>
    notify_backup <STRING>|<QUOTED-STRING>
    notify_fault <STRING>|<QUOTED-STRING>
    notify <STRING>|<QUOTED-STRING>
    smtp_alert
}
```

* state 可以是 MASTER 或 BACKUP，不过当其他节点 Keepalived 启动时会将 priority 比较大的节点选举为 MASTER，因此该项其实没有实质用途。

* interface 节点固有 IP（非 VIP）的网卡，用来发 VRRP 包。

* use_vmac 是否使用 VRRP 的虚拟 MAC 地址。

* dont_track_primary 忽略 VRRP 网卡错误。（默认未设置）

* track_interface 监控以下网卡，如果任何一个不通就会切换到 FALT 状态。（可选项）

* mcast_src_ip 修改 vrrp 组播包的源地址，默认源地址为 master 的 IP。（由于是组播，因此即使修改了源地址，该 master 还是能收到回应的）

* lvs_sync_daemon_interface 绑定 lvs syncd 的网卡。

* garp_master_delay 当切为主状态后多久更新 ARP 缓存，默认 5 秒。

* virtual_router_id 取值在 0-255 之间，用来区分多个 instance 的 VRRP 组播。

注意： 同一网段中 virtual_router_id 的值不能重复，否则会出错，相关错误信息如下。
```
Keepalived_vrrp[27120]: ip address associated with VRID not present in received packet :
one or more VIP associated with VRID mismatch actual MASTER advert
bogus VRRP packet received on eth1 !!!
receive an invalid ip number count associated with VRID!
VRRP_Instance(xxx) ignoring received advertisment...
```

可以用这条命令来查看该网络中所存在的 vrid：`tcpdump -nn -i any net 224.0.0.0/8`

* priority 用来选举 master 的，要成为 master，那么这个选项的值 [最好高于其他机器 50 个点][priority_more_than_50]，该项 [取值范围][priority] 是 1-255（在此范围之外会被识别成默认值 100）。

* advert_int 发 VRRP 包的时间间隔，即多久进行一次 master 选举（可以认为是健康查检时间间隔）。

* authentication 认证区域，认证类型有 PASS 和 HA（IPSEC），推荐使用 PASS（密码只识别前 8 位）。

* virtual_ipaddress VIP，不解释了。

* virtual_routes 虚拟路由，当 IP 漂过来之后需要添加的路由信息。

* virtual_ipaddress_excluded 发送的 VRRP 包里不包含的 IP 地址，为减少回应 VRRP 包的个数。在网卡上绑定的 IP 地址比较多的时候用。

* nopreempt 允许一个 priority 比较低的节点作为 master，即使有 priority 更高的节点启动。

首先 nopreemt 必须在 state 为 BACKUP 的节点上才生效（因为是 BACKUP 节点决定是否来成为 MASTER 的），其次要实现类似于关闭 auto failback 的功能需要将所有节点的 state 都设置为 BACKUP，或者将 master 节点的 priority 设置的比 BACKUP 低。我个人推荐使用将所有节点的 state 都设置成 BACKUP 并且都加上 nopreempt 选项，这样就完成了关于 autofailback 功能，当想手动将某节点切换为 MASTER 时只需去掉该节点的 nopreempt 选项并且将 priority 改的比其他节点大，然后重新加载配置文件即可（等 MASTER 切过来之后再将配置文件改回去再 reload 一下）。

当使用`track_script`时可以不用加`nopreempt`，只需要加上`preempt_delay 5`，这里的间隔时间要大于`vrrp_script`中定义的时长。

* preempt_delay master 启动多久之后进行接管资源（VIP/Route 信息等），并提是没有`nopreempt`选项。

## 2.4 LVS 配置

virtual_server_group 一般在超大型的 LVS 中用到，一般 LVS 用不过这东西，因此不多说。

```
virtual_server IP Port {
    delay_loop <INT>
    lb_algo rr|wrr|lc|wlc|lblc|sh|dh
    lb_kind NAT|DR|TUN
    persistence_timeout <INT>
    persistence_granularity <NETMASK>
    protocol TCP
    ha_suspend
    virtualhost <STRING>
    alpha
    omega
    quorum <INT>
    hysteresis <INT>
    quorum_up <STRING>|<QUOTED-STRING>
    quorum_down <STRING>|<QUOTED-STRING>
    sorry_server <IPADDR> <PORT>
    real_server <IPADDR> <PORT> {
        weight <INT>
        inhibit_on_failure
        notify_up <STRING>|<QUOTED-STRING>
        notify_down <STRING>|<QUOTED-STRING>
        # HTTP_GET|SSL_GET|TCP_CHECK|SMTP_CHECK|MISC_CHECK
        HTTP_GET|SSL_GET {
            url {
                path <STRING>
                # Digest computed with genhash
                digest <STRING>
                status_code <INT>
            }
            connect_port <PORT>
            connect_timeout <INT>
            nb_get_retry <INT>
            delay_before_retry <INT>
        }
    }
}
```

* delay_loop 延迟轮询时间（单位秒）。

* lb_algo 后端调试算法（load balancing algorithm）。

* lb_kind LVS 调度类型 [NAT][nat]/[DR][dr]/[TUN][tun]。

* virtualhost 用来给 HTTP_GET 和 SSL_GET 配置请求 header 的。

* sorry_server 当所有 real server 宕掉时，sorry server 顶替。

* real_server 真正提供服务的服务器。

* weight 权重。

* notify_up/down 当 real server 宕掉或启动时执行的脚本。

* 健康检查的方式，N 多种方式。

* path 请求 real serserver 上的路径。

* digest/status_code 分别表示用 genhash 算出的结果和 http 状态码。

* connect_port 健康检查，如果端口通则认为服务器正常。

* connect_timeout,nb_get_retry,delay_before_retry 分别表示超时时长、重试次数，下次重试的时间延迟。

其他选项暂时不作说明。


# 3 Keepalived 工作原理

Keepalived 是以 VRRP 协议为实现基础的，VRRP 全称 Virtual Router Redundancy Protocol，即***虚拟路由冗余协议***。

虚拟路由冗余协议，可以认为是实现路由器高可用的协议，即将 N 台提供相同功能的路由器组成一个路由器组，这个组里面有一个 master 和多个 backup，master 上面有一个对外提供服务的 VIP（该路由器所在局域网内其他机器的默认路由为该 VIP），master 会发组播，当 backup 收不到 vrrp 包时就认为 master 宕掉了，这时就需要根据 VRRP 的优先级***vrrp_priority***来选举一个 backup 当 master***select_master***。这样的话就可以保证路由器的高可用了。

Keepalived 主要有三个模块，分别是 core、check 和 vrrp。core 模块为 Keepalived 的核心，负责主进程的启动、维护以及全局配置文件的加载和解析。check 负责健康检查，包括常见的各种检查方式。vrrp 模块是来实现 VRRP 协议的。
```
                           +-------------+
						   |   uplink    |
						   +-------------+
							     |
							     +
		                     keep|alived
                    		 192.168.0.3
                        	+-------------+
                        	| virtualIP   |
                        	+-------------+
   	        	 192.168.0.1 主   |  192.168.0.2
	        	+--------------+ | +--------------+
	        	|LVS+Keepalived|---|LVS+Keepalived|
	        	+--------------+   +--------------+
			  +------------------+------------------+
			  | 				 |                  |
		+-------------+    +-------------+    +-------------+
		|   web01     |    |   web02     |    |   web03     |
		+-------------+    +-------------+    +-------------+
```

## 3.1 VRRP 工作流程

(1). 初始化

路由器启动时，如果路由器的优先级是 255（最高优先级，路由器拥有路由器地址）, 要发送 VRRP 通告信息，并发送广播 ARP 信息通告路由器 IP 地址
对应的 MAC 地址为路由虚拟 MAC, 设置通告信息定时器准备定时发送 VRRP 通告信息，转为 MASTER 状态；否则进入 BACKUP 状态，设置定时器检查
定时检查是否收到 MASTER 的通告信息。

(2).Master

    设置定时通告定时器；

    用 VRRP 虚拟 MAC 地址响应路由器 IP 地址的 ARP 请求；

    转发目的 MAC 是 VRRP 虚拟 MAC 的数据包；

    如果是虚拟路由器 IP 的拥有者，将接受目的地址是虚拟路由器 IP 的数据包，否则丢弃；

    当收到 shutdown 的事件时删除定时通告定时器，发送优先权级为 0 的通告包，转初始化状态；

    如果定时通告定时器超时时，发送 VRRP 通告信息；

    收到 VRRP 通告信息时，如果优先权为 0, 发送 VRRP 通告信息；否则判断数据的优先级是否高于本机，或相等而且实际 IP 地址大于本地实际 IP, 设置定时通告定时器，复位主机超时定时器，转 BACKUP 状态；否则的话，丢弃该通告包；

(3).Backup

    设置主机超时定时器；

    不能响应针对虚拟路由器 IP 的 ARP 请求信息；

    丢弃所有目的 MAC 地址是虚拟路由器 MAC 地址的数据包；

    不接受目的是虚拟路由器 IP 的所有数据包；

    当收到 shutdown 的事件时删除主机超时定时器，转初始化状态；

    主机超时定时器超时的时候，发送 VRRP 通告信息，广播 ARP 地址信息，转 MASTER 状态；

    收到 VRRP 通告信息时，如果优先权为 0, 表示进入 MASTER 选举；否则判断数据的优先级是否高于本机，如果高的话承认 MASTER 有效，复位主机超时定时器；否则的话，丢弃该通告包；


## 3.2 MASTER 和 BACKUP 节点的优先级如何调整？

首先，每个节点有一个初始优先级，由配置文件中的 priority 配置项指定，MASTER 节点的 priority 应比 BAKCUP 高。
运行过程中 Keepalived 根据 vrrp_script 的 weight 设定，增加或减小节点优先级。规则如下：

1. 当 weight > 0 时，vrrp_script script 脚本执行返回 0（成功）时优先级为 priority + weight, 否则为 priority.
当 BACKUP 发现自己的优先级大于 MASTER 通告的优先级时，进行主从切换。

2. 当 weight < 0 时，vrrp_script script 脚本执行返回非 0（失败）时优先级为 priority + weight, 否则为 priority.
当 BACKUP 发现自己的优先级大于 MASTER 通告的优先级时，进行主从切换。

3. 当两个节点的优先级相同时，以节点发送 VRRP 通告的 IP 作为比较对象，IP 较大者为 MASTER.

以上文中的配置为例：

    HOST1: 192.168.0.1, priority=91, MASTER(default)
    HOST2: 192.168.0.2, priority=90, BACKUP
    VIP: 192.168.0.3 weight = 2

抓包命令：tcpdump -nn vrrp

## 3.3 ARP 查询处理

当内部主机通过 ARP 查询虚拟路由器 IP 地址对应的 MAC 地址时，MASTER 路由器回复的 MAC 地址为虚拟的 VRRP 的 MAC 地址，而不是实际网卡的
MAC 地址，这样在路由器切换时让内网机器觉察不到；而在路由器重新启动时，不能主动发送本机网卡的实际 MAC 地址。如果虚拟路由器开启的 ARP
代理 (proxy_arp) 功能，代理的 ARP 回应也回应 VRRP 虚拟 MAC 地址；

## 3.4 虚拟 IP 地址和 MAC 地址

VRRP 组（备份组）中的虚拟路由器对外表现为唯一的虚拟 MAC 地址，地址格式为 00-00-5E-00-01-[VRID], VRID 为 VRRP 组的编号，范围是 0~255.

## 3.5  Keepalived 进程

Keepalived 主要有三个模块，分别是 core、check 和 vrrp。

> * core 模块为 Keepalived 的核心，负责主进程的启动、维护以及全局配置文件的加载和解析。
> * check 负责健康检查，包括常见的各种检查方式。
> * vrrp  模块是来实现 VRRP 协议的。

## 3.6 Keepalived 健康检查方式

Keepalived 对后端 realserver 的健康检查方式主要有以下几种：

***TCP_CHECK***

工作在第 4 层，Keepalived 向后端服务器发起一个 tcp 连接请求，如果后端服务器没有响应或者超时，那么这个后端将从服务器中移除

***HTTP_GET***

工作在第 5 层，通过向指定的 URL 执行 http 请求，将得到的结果比对（经检验此种方法在多个实体服务器只能检测到第一个，故不可行）

***SSL_GET***

与 HTTP_GET 类似
***MISC_CHECK***

用脚本来检测，脚本如果带有参数，需要将脚本和参数放入到双引号内。脚本的返回值需要为：

> * 0-------------- 检测成功
> * 1-------------- 检测失败，将从服务器池中移除
> * 2~255-------- 检测成功；如果有设置 misc_dynamic，权重自动调整为退出码 -2，如果退出码为 200，权重自动调整为 198=200-2

# 4 Keepalived 场景应用

## 4.1 Keepalived 主从切换

主从切换比较让人蛋疼，需要将 backup 配置文件的 priority 选项的值调整的比 master 高 50 个点，然后 reload 配置文件就可以切换了。当时你也可以将 master 的 Keepalived 停止，这样也可以进行主从切换。

## 4.2 Keepalived 仅做 HA 时的配置

请看该文档同级目录下的配置文件示例。

用 tcpdump 命令来捕获的结果如下：

```
17:20:07.919419 IP 192.168.1.1 > 224.0.0.18: VRRPv2, Advertisement, vrid 1, prio 200, authtype simple, intvl 1s, length 20
```
# 5 其他配置

## 5.1 重定向 Keepalived 输出日志

(1) 修改 /etc/sysconfig/keepalived

把 KEEPALIVED_OPTIONS="-D" 修改为 KEEPALIVED_OPTIONS="-D -d -S 0"

其中 -S 指定 syslog 的 facility"

同时创建 /var/log/keepalived 目录

```
#mkdir /var/log/keepalived
```

(2) 在 /etc/rsyslog.conf 中添加
```
# keepalived -S 0
local0.*                    /var/log/keepalived/keepalived.log
```

(3) 重启 Rsyslog 和 Keepalived 服务
```
#/etc/init.d/rsyslog restart
#/etc/init.d/Keepalived restart
```
## 5.2 只用 VRRP 模块

假如不使用 LVS 的话，即无需加载 ip_vs 模块（注；不装 ipvsadm 的话，直接启动 Keepalived 的话，会因为没有 ip_vs 模块而一直在日志中输出错误日志）

修改 /etc/sysconfig/keepalived

把 KEEPALIVED_OPTIONS="-D" 修改为 KEEPALIVED_OPTIONS="-D -P"

# 6 常见问题

## 6.1 virtual_router_id 冲突

Keepalived 日志提示
```
[Time] [Hostname] Keepalived_vrrp: ip address associated with VRID not present in received packet : [VIP]
[Time] [Hostname] Keepalived_vrrp: one or more VIP associated with VRID mismatch actual MASTER advert
[Time] [Hostname] Keepalived_vrrp: bogus VRRP packet received on eth0 !!!
[Time] [Hostname] Keepalived_vrrp: VRRP_Instance(web_1) Dropping received VRRP packet...
```
解决方法
```
同一集群的 Keepalived 的主、备机的 virtual_router_id 必须相同，取值 0-255
但是同一内网中不应有相同 virtual_router_id 的集群
修改 virtual_router_id 就可以了
```

## 6.2 VIP 无法访问

### 6.2.1 VIP 被抢占

```
arping -I eth0 VIP
```
查看是否输出两个不同的 Mac 地址，如果是则地址被占用

### 6.2.2 网关的 ARP 缓存没有刷新

```
arping -I eth0 -c 5 -s VIP GATEWAY
```
