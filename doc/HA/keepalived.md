目录


<!-- vim-markdown-toc GFM -->
* [Keepalived 介绍及安装](#keepalived-介绍及安装)
    * [介绍](#介绍)
        * [LVS 和 keepalived 的关系](#lvs-和-keepalived-的关系)
    * [安装](#安装)
    * [使用](#使用)
* [keepalived配置相关](#keepalived配置相关)
    * [global_defs区域](#global_defs区域)
    * [vrrp_script区域](#vrrp_script区域)
    * [VRRPD配置](#vrrpd配置)
        * [VRRP Sync Groups](#vrrp-sync-groups)
        * [VRRP实例(instance)配置](#vrrp实例(instance)配置)
    * [LVS 配置](#lvs-配置)
* [keepalived工作原理](#keepalived工作原理)
    * [VRRP 工作流程](#vrrp-工作流程)
    * [MASTER 和 BACKUP 节点的优先级如何调整?](#master-和-backup-节点的优先级如何调整?)
    * [ARP查询处理](#arp查询处理)
    * [虚拟IP地址和MAC地址](#虚拟ip地址和mac地址)
    * [keepalived 进程](#keepalived-进程)
    * [keepalived 健康检查方式](#keepalived-健康检查方式)
* [keepalived场景应用](#keepalived场景应用)
    * [keepalived主从切换](#keepalived主从切换)
    * [keepalived仅做HA时的配置](#keepalived仅做ha时的配置)
* [其他配置](#其他配置)
    * [重定向keepalived 输出日志](#重定向keepalived-输出日志)
    * [只用 vrrp 模块](#只用-vrrp-模块)

<!-- vim-markdown-toc -->
# Keepalived 介绍及安装

## 介绍

Keepalived 是一个基于 VRRP 协议来实现的 WEB 服务高可用方案，其功能类似于[heartbeat],可以利用其来避免单点故障。一个WEB服务至少会有2台服务器运行 Keepalived，一台为主服务器（MASTER），一台为备份服务器（BACKUP），但是对外表现为一个虚拟 IP，主服务器会发送特定的消息给备份服务器，当备份服务器收不到这个消息的时候，即主服务器宕机的时候，备份服务器就会接管虚拟 IP，继续提供服务，从而保证了高可用性。

	 	+---------VIP(192.168.0.3)----------+
		|                                   |
	    |                                   |
	server(MASTER) <----keepalived----> server(BACKUP)
	(192.168.0.1)                       (192.168.0.2)

### LVS 和 keepalived 的关系

LVS 可以不依赖 keepalived 而进行分发请求,但是想让负载调度器动态监控真实服务器心跳 需要写很复杂的代码。而 keepalived 正是一个通过简单配置就能满足请求分发、心跳检测、集群管理的好工具

## 安装

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

## 使用

	$ /etc/init.d/keepalived start | restart | stop

当启动了 keepalived 之后，通过`ifconfig`是看不到VIP的，但是通过`ip a`命令是可以看到的。 当 MASTER 宕机，BACKUP 升级为 MASTER，这些 VRRP_Instance 状态的切换都可以在`/var/log/message`中进行记录。

# keepalived配置相关

keepalived 只有一个配置文件 /etc/keepalived/keepalived.conf，里面主要包括以下几个配置区域，分别是global\_defs、static\_ipaddress、static\_routes、vrrp_script、vrrp\_instance和virtual\_server。

## global_defs区域

主要是配置故障发生时的通知对象以及机器标识

```
global_defs {
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

* smpt_server 通知邮件的smtp地址。

* smtp_connect_timeout 连接smtp服务器的超时时间。

* enable_traps 开启SNMP陷阱（[Simple Network Management Protocol][snmp]）。

* router_id 标识本节点的字条串，通常为hostname，但不一定非得是hostname。故障发生时，邮件通知会用到。

## vrrp_script区域

用来做健康检查的，当时检查失败时会将`vrrp_instance`的`priority`减少相应的值。

```
vrrp_script chk_http_port {
    script "</dev/tcp/127.0.0.1/80"
    interval 1
    weight -10
}
```

以上意思是如果`script`中的指令执行失败，那么相应的`vrrp_instance`的优先级会减少10个点。

## VRRPD配置

在[VRRP]协议中，有两组重要的概念：

> * VRRP路由器和虚拟路由器
> * 主控路由器和备份路由器

VRRP路由器是指运行VRRP的路由器，是物理实体，虚拟路由器是指VRRP协议创建的，是逻辑概念。一组VRRP路由器协同工作，共同构成一台虚拟路由器。该虚拟路由器对外表现为一个具有唯一固定IP地址和MAC地址的逻辑路由器。处于同一个VRRP组中的路由器具有两种互斥的角色：

主控路由器和备份路由器，一个VRRP组中有且只有一台处于主控角色的路由器，可以有一个或者多个处于备份角色的路由器。VRRP协议使用选择策略从路由器组中选出一台作为主控，负责ARP相应和转发IP数据包，组中的其它路由器作为备份的角色处于待命状态。当由于某种原因主控路由器发生故障时，备份路由器能在几秒钟的时延后升级为主路由器。由于此切换非常迅速而且不用改变IP地址和MAC地址，故对终端使用者系统是透明的。

VRRPD 配置包括两部分

> * VRRP同步组(synchroization group)
> * VRRP实例(VRRP Instance)

### VRRP Sync Groups

vrrp_rsync_group用来定义vrrp_intance组，使得这个组内成员动作一致。举个例子来说明一下其功能：

两个vrrp_instance同属于一个vrrp_rsync_group，那么其中一个vrrp_instance发生故障切换时，另一个vrrp_instance也会跟着切换（即使这个instance没有发生故障）。

eg:机器有两个网段，一个内网一个外网，每个网段开启一个VRRP实例，假设VRRP配置为检查内网，那么当外网出现问题时，VRRPD认为自己仍然健康，那么不会发送Master和Backup的切换，从而导致了问题。Sync group 就是为了解决这个问题。可以将两个实例都放到一个Sync group，这样，group里面任何一个实例出现问题都会发生切换

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
* notify_master/backup/fault 分别表示切换为主/备/出错时所执行的脚本。

* notify 表示任何一状态切换时都会调用该脚本，并且该脚本在以上三个脚本执行完成之后进行调用，keepalived会自动传递三个参数（$1 = "GROUP"|"INSTANCE"，$2 = name of group or instance，$3 = target state of transition(MASTER/BACKUP/FAULT)）。

* smtp_alert 表示是否开启邮件通知（用全局区域的邮件设置来发通知）。

### VRRP实例(instance)配置

vrrp_instance用来定义对外提供服务的VIP区域及其相关属性。

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

* state 可以是MASTER或BACKUP，不过当其他节点keepalived启动时会将priority比较大的节点选举为MASTER，因此该项其实没有实质用途。

* interface 节点固有IP（非VIP）的网卡，用来发VRRP包。

* use_vmac 是否使用VRRP的虚拟MAC地址。

* dont_track_primary 忽略VRRP网卡错误。（默认未设置）

* track_interface 监控以下网卡，如果任何一个不通就会切换到FALT状态。（可选项）

* mcast_src_ip 修改vrrp组播包的源地址，默认源地址为master的IP。（由于是组播，因此即使修改了源地址，该master还是能收到回应的）

* lvs_sync_daemon_interface 绑定lvs syncd的网卡。

* garp_master_delay 当切为主状态后多久更新ARP缓存，默认5秒。

* virtual_router_id 取值在0-255之间，用来区分多个instance的VRRP组播。

注意： 同一网段中virtual_router_id的值不能重复，否则会出错，相关错误信息如下。
```
Keepalived_vrrp[27120]: ip address associated with VRID not present in received packet :
one or more VIP associated with VRID mismatch actual MASTER advert
bogus VRRP packet received on eth1 !!!
receive an invalid ip number count associated with VRID!
VRRP_Instance(xxx) ignoring received advertisment...
```

可以用这条命令来查看该网络中所存在的vrid：`tcpdump -nn -i any net 224.0.0.0/8`

* priority 用来选举master的，要成为master，那么这个选项的值[最好高于其他机器50个点][priority_more_than_50]，该项[取值范围][priority]是1-255（在此范围之外会被识别成默认值100）。

* advert_int 发VRRP包的时间间隔，即多久进行一次master选举（可以认为是健康查检时间间隔）。

* authentication 认证区域，认证类型有PASS和HA（IPSEC），推荐使用PASS（密码只识别前8位）。

* virtual_ipaddress vip，不解释了。

* virtual_routes 虚拟路由，当IP漂过来之后需要添加的路由信息。

* virtual_ipaddress_excluded 发送的VRRP包里不包含的IP地址，为减少回应VRRP包的个数。在网卡上绑定的IP地址比较多的时候用。

* nopreempt 允许一个priority比较低的节点作为master，即使有priority更高的节点启动。

首先nopreemt必须在state为BACKUP的节点上才生效（因为是BACKUP节点决定是否来成为MASTER的），其次要实现类似于关闭auto failback的功能需要将所有节点的state都设置为BACKUP，或者将master节点的priority设置的比BACKUP低。我个人推荐使用将所有节点的state都设置成BACKUP并且都加上nopreempt选项，这样就完成了关于autofailback功能，当想手动将某节点切换为MASTER时只需去掉该节点的nopreempt选项并且将priority改的比其他节点大，然后重新加载配置文件即可（等MASTER切过来之后再将配置文件改回去再reload一下）。

当使用`track_script`时可以不用加`nopreempt`，只需要加上`preempt_delay 5`，这里的间隔时间要大于`vrrp_script`中定义的时长。

* preempt_delay master启动多久之后进行接管资源（VIP/Route信息等），并提是没有`nopreempt`选项。

## LVS 配置

virtual_server_group一般在超大型的LVS中用到，一般LVS用不过这东西，因此不多说。

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

* lb_kind LVS调度类型[NAT][nat]/[DR][dr]/[TUN][tun]。

* virtualhost 用来给HTTP_GET和SSL_GET配置请求header的。

* sorry_server 当所有real server宕掉时，sorry server顶替。

* real_server 真正提供服务的服务器。

* weight 权重。

* notify_up/down 当real server宕掉或启动时执行的脚本。

* 健康检查的方式，N多种方式。

* path 请求real serserver上的路径。

* digest/status_code 分别表示用genhash算出的结果和http状态码。

* connect_port 健康检查，如果端口通则认为服务器正常。

* connect_timeout,nb_get_retry,delay_before_retry分别表示超时时长、重试次数，下次重试的时间延迟。

其他选项暂时不作说明。


# keepalived工作原理

keepalived是以VRRP协议为实现基础的，VRRP全称Virtual Router Redundancy Protocol，即***虚拟路由冗余协议***。

虚拟路由冗余协议，可以认为是实现路由器高可用的协议，即将N台提供相同功能的路由器组成一个路由器组，这个组里面有一个master和多个backup，master上面有一个对外提供服务的vip（该路由器所在局域网内其他机器的默认路由为该vip），master会发组播，当backup收不到vrrp包时就认为master宕掉了，这时就需要根据VRRP的优先级***vrrp_priority***来选举一个backup当master***select_master***。这样的话就可以保证路由器的高可用了。

keepalived主要有三个模块，分别是core、check和vrrp。core模块为keepalived的核心，负责主进程的启动、维护以及全局配置文件的加载和解析。check负责健康检查，包括常见的各种检查方式。vrrp模块是来实现VRRP协议的。
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
   	        	 192.168.0.1主   |  192.168.0.2
	        	+--------------+ | +--------------+
	        	|LVS+Keepalived|---|LVS+Keepalived|
	        	+--------------+   +--------------+
			  +------------------+------------------+
			  | 				 |                  |
		+-------------+    +-------------+    +-------------+
		|   web01     |    |   web02     |    |   web03     |
		+-------------+    +-------------+    +-------------+
```

## VRRP 工作流程

(1).初始化

路由器启动时, 如果路由器的优先级是255(最高优先级, 路由器拥有路由器地址), 要发送 VRRP 通告信息, 并发送广播 ARP 信息通告路由器 IP 地址
对应的 MAC 地址为路由虚拟 MAC, 设置通告信息定时器准备定时发送 VRRP 通告信息, 转为 MASTER 状态; 否则进入 BACKUP 状态, 设置定时器检查
定时检查是否收到 MASTER 的通告信息.

(2).Master

    设置定时通告定时器;

    用 VRRP 虚拟 MAC 地址响应路由器 IP 地址的 ARP 请求;

    转发目的MAC是VRRP虚拟MAC的数据包;

    如果是虚拟路由器IP的拥有者, 将接受目的地址是虚拟路由器IP的数据包, 否则丢弃;

    当收到shutdown的事件时删除定时通告定时器, 发送优先权级为0的通告包, 转初始化状态;

    如果定时通告定时器超时时, 发送VRRP通告信息;

    收到VRRP通告信息时, 如果优先权为0, 发送 VRRP 通告信息; 否则判断数据的优先级是否高于本机, 或相等而且实际 IP 地址大于本地实际 IP, 设置定时通告定时器, 复位主机超时定时器, 转 BACKUP 状态; 否则的话, 丢弃该通告包;

(3).Backup

    设置主机超时定时器;

    不能响应针对虚拟路由器IP的ARP请求信息;

    丢弃所有目的MAC地址是虚拟路由器MAC地址的数据包;

    不接受目的是虚拟路由器IP的所有数据包;

    当收到shutdown的事件时删除主机超时定时器, 转初始化状态;

    主机超时定时器超时的时候, 发送VRRP通告信息, 广播ARP地址信息, 转MASTER状态;

    收到VRRP通告信息时, 如果优先权为0, 表示进入MASTER选举; 否则判断数据的优先级是否高于本机, 如果高的话承认MASTER有效, 复位主机超时定时器; 否则的话, 丢弃该通告包;


## MASTER 和 BACKUP 节点的优先级如何调整?

首先, 每个节点有一个初始优先级, 由配置文件中的 priority 配置项指定, MASTER 节点的 priority 应比 BAKCUP 高.
运行过程中 keepalived 根据 vrrp_script 的 weight 设定, 增加或减小节点优先级. 规则如下:

1. 当 weight > 0 时, vrrp_script script 脚本执行返回0(成功)时优先级为 priority + weight, 否则为 priority.
当 BACKUP 发现自己的优先级大于MASTER通告的优先级时, 进行主从切换.

2. 当 weight < 0 时, vrrp_script script 脚本执行返回非0(失败)时优先级为 priority + weight, 否则为 priority.
当 BACKUP 发现自己的优先级大于 MASTER 通告的优先级时, 进行主从切换.

3. 当两个节点的优先级相同时, 以节点发送 VRRP 通告的 IP 作为比较对象, IP 较大者为 MASTER.

以上文中的配置为例:

    HOST1: 192.168.0.1, priority=91, MASTER(default)
    HOST2: 192.168.0.2, priority=90, BACKUP
    VIP: 192.168.0.3 weight = 2

抓包命令: tcpdump -nn vrrp

## ARP查询处理

当内部主机通过 ARP 查询虚拟路由器 IP 地址对应的 MAC 地址时, MASTER 路由器回复的 MAC 地址为虚拟的 VRRP 的 MAC 地址, 而不是实际网卡的
MAC 地址, 这样在路由器切换时让内网机器觉察不到; 而在路由器重新启动时, 不能主动发送本机网卡的实际 MAC 地址. 如果虚拟路由器开启的 ARP
代理 (proxy_arp)功能, 代理的 ARP 回应也回应VRRP虚拟 MAC 地址;

## 虚拟IP地址和MAC地址

VRRP组(备份组)中的虚拟路由器对外表现为唯一的虚拟MAC地址, 地址格式为00-00-5E-00-01-[VRID], VRID 为 VRRP 组的编号, 范围是0~255.

## keepalived 进程

keepalived主要有三个模块，分别是core、check和vrrp。

> * core 模块为 keepalived 的核心，负责主进程的启动、维护以及全局配置文件的加载和解析。
> * check 负责健康检查，包括常见的各种检查方式。
> * vrrp  模块是来实现VRRP协议的。

## keepalived 健康检查方式

keepalived对后端realserver的健康检查方式主要有以下几种：

***TCP_CHECK***

工作在第4层，keepalived向后端服务器发起一个tcp连接请求，如果后端服务器没有响应或者超时，那么这个后端将从服务器中移除

***HTTP_GET***

工作在第5层,通过向指定的URL执行http请求，将得到的结果比对(经检验此种方法在多个实体服务器只能检测到第一个，故不可行)

***SSL_GET***

与HTTP_GET类似
***MISC_CHECK***

用脚本来检测，脚本如果带有参数，需要将脚本和参数放入到双引号内。脚本的返回值需要为：

> * 0--------------检测成功
> * 1--------------检测失败，将从服务器池中移除
> * 2~255--------检测成功；如果有设置misc_dynamic，权重自动调整为退出码-2，如果退出码为200，权重自动调整为198=200-2

# keepalived场景应用

## keepalived主从切换

主从切换比较让人蛋疼，需要将backup配置文件的priority选项的值调整的比master高50个点，然后reload配置文件就可以切换了。当时你也可以将master的keepalived停止，这样也可以进行主从切换。

## keepalived仅做HA时的配置

请看该文档同级目录下的配置文件示例。

用tcpdump命令来捕获的结果如下：

```
17:20:07.919419 IP 192.168.1.1 > 224.0.0.18: VRRPv2, Advertisement, vrid 1, prio 200, authtype simple, intvl 1s, length 20
```
# 其他配置

## 重定向keepalived 输出日志

(1)修改 /etc/sysconfig/keepalived

把KEEPALIVED_OPTIONS="-D" 修改为KEEPALIVED_OPTIONS="-D -d -S 0"

其中 -S 指定 syslog 的 facility"

同时创建 /var/log/keepalived目录

```
#mkdir /var/log/keepalived
```

(2)在 /etc/rsyslog.conf 中添加
```
# keepalived -S 0
local0.*                    /var/log/keepalived/keepalived.log
```

(3)重启 rsyslog 和 Keepalived 服务
```
#/etc/init.d/rsyslog restart
#/etc/init.d/Keepalived restart
```
## 只用 vrrp 模块

假如不使用 LVS 的话，即无需加载 ip_vs 模块(注;不装 ipvsadm 的话，直接启动 keepalived 的话，会因为没有 ip_vs 模块而一直在日志中输出错误日志)

修改 /etc/sysconfig/keepalived

把KEEPALIVED_OPTIONS="-D" 修改为KEEPALIVED_OPTIONS="-D -P"

