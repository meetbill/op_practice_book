# DAS/SAN/NAS

目前常见的三种存储结构

> * DAS：直连存储
> * SAN：存储区域网
> * NAS：网络附属存储

<!-- vim-markdown-toc GFM -->
* [DAS](#das)
* [SAN](#san)
* [NAS](#nas)
    * [nfs(UNIX 和 UNIX 之间共享协议）](#nfsunix-和-unix-之间共享协议)
        * [NFS 搭建](#nfs-搭建)
        * [启动 NFS 服务端](#启动-nfs-服务端)
        * [配置 NFS 服务端](#配置-nfs-服务端)
        * [配置 NFS 客户端](#配置-nfs-客户端)
        * [常见问题](#常见问题)
            * [rpcbind 安装失败](#rpcbind-安装失败)
            * [nfs 客户端挂载失败](#nfs-客户端挂载失败)
            * [nfs 客户端无法 chown](#nfs-客户端无法-chown)
    * [CIFS(UNIX 和 windows 间共享协议）](#cifsunix-和-windows-间共享协议)
        * [给挂载共享文件夹指定 owner 和 group](#给挂载共享文件夹指定-owner-和-group)
        * [给 mount 共享文件夹所在组的写权限](#给-mount-共享文件夹所在组的写权限)
        * [永久挂载 Windows 共享](#永久挂载-windows-共享)
* [查看磁盘信息](#查看磁盘信息)
    * [lsscsi](#lsscsi)
    * [smartctl](#smartctl)
        * [解释下各属性的含义](#解释下各属性的含义)
        * [各个属性的含义](#各个属性的含义)
        * [对于 SSD 硬盘，需要关注的几个参数](#对于-ssd-硬盘需要关注的几个参数)
    * [MegaCli](#megacli)
    * [LSIUtil](#lsiutil)
    * [lsblk](#lsblk)
* [磁盘扩展](#磁盘扩展)
    * [Linux 下 xfs 扩展](#linux-下-xfs-扩展)

<!-- vim-markdown-toc -->
# DAS

DAS :  Application --> File system --> Disk Storage

DAS：直连式存储依赖服务器主机操作系统进行数据的 IO 读写和存储维护管理，数据备份和恢复要求占用服务器主机资源（包括 CPU、系统 IO 等）

# SAN

SAN :  Application --> File system --> Networking --> Disk Storage

IPSAN 与 FCSAN

# NAS

NAS :  Application --> Networking --> File system --> Disk Storage

NAS，网络附加存储，中心词"存储"，是的，它是一个存储设备。

NAS 是一个设备。CIFS/NFS 是一种协议。可以在 NAS 上启用 CIFS/NFS 协议，这样，用户就能使用 CIFS/NFS 协议进行访问了。

**一句话，CIFS 用于 UNIX 和 windows 间共享，而 NFS 用于 UNIX 和 UNIX 之间共享**

## nfs(UNIX 和 UNIX 之间共享协议）

NFS 的基本原则是“容许不同的客户端及服务端通过一组 RPC 分享相同的文件系统”，它是独立于操作系统，容许不同硬件及操作系统的系统共同进行文件的分享。

### NFS 搭建

-----

> NFS 服务端部署环境准备

服务器系统|角色|IP|
----|----|----|
CentOS6.6 x86_64|NFS 服务端（NFS-SERVER）|192.168.1.21|
CentOS6.6 x86_64|NFS 客户端（NFS-CLIENT1）|192.168.1.22|


服务器版本：6.x

>  NFS 软件列表

`NFS`可以被视为一个`RPC`程序，在启动任何一个`RPC`程序之前，需要做好端口的对应映射作用，这个映射工作就是由`rpcbind`服务来完成的，因此在提供`NFS`之前必须先启动`rpcbind`服务

首先准备以下软件包
* nfs-utils（NFS 服务主程序，包括 rpc.nfsd、rpc.mountd 两个 deamons 和相关文档说明及执行命令文件等）
* rpcbind

>  安装 NFS 软件包

三台机器都需要安装`NFS`软件包，showmount 命令在`NFS`包中，客户端`NFS`服务不配置，不启动

**安装 NFS 软件包**
```
[root@nfs-server ~]$ yum install nfs-utils rpcbind -y
```

>  NFS 服务器配置

* `NFS`的常用目录

	| 目录路径|目录说明|
	|----|----|
	| /etc/exports | NFS 服务的主要配置文件|
	| /usr/sbin/exportfs | NFS 服务的管理命令|
	| /usr/sbin/showmount | 客户端的查看命令|
	| /var/lib/nfs/etab | 记录 NFS 分享出来的目录的完整权限设定值|
	| /var/lib/nfs/rtab | 记录连接的客户端信息|


* `NFS`服务端的权限设置，`/etc/exports`文件配置格式中小括号中的参数

	| 参数名称 (*为重要参数）|参数用途|
	|----|----
	|rw*|Read-write，表示可读写权限|
	|ro|Read-only，表示只读权限|
	|sync*|请求或写入数据时，数据同步写入到 NF SServer 中，（优点：数据安全不会丢，缺点：性能较差）|
	|async*|请求或写入数据时，先返回请求，再将数据写入到 NFSServer 中，异步写入数据|
	|no_root_squash|访问 NFS Server 共享目录的用户如果是 root 的话，它对共享目录具有 root 权限|
	|not_squash|访问 NFS Server 共享目录的用户如果是 root 的话，则它的权限，将被压缩成匿名用户|
	|all_squash*|不管访问 NFS Server 共享目录的身份如何，它的权限都被压缩成一个匿名用户，同事它的 UID、GID 都会变成 nfsnobody 账号身份|
	|anonuid*|匿名用户 ID|
	|anongid*|匿名组 ID|
	|insecure|允许客户端从大于 1024 的 TCP/IP 端口连 NFS 服务器|
	|secure|限制客户端只能从小于 1024 的 TCP/IP 端口连接 NFS 服务器（默认设置）|
	|wdelay|检查是否有相关的写操作，如果有则将这些写操作一起执行，这样可提高效率（默认设置）|
	|no_wdelay|若有写操作则立即执行（应与 sync 配置）|
	|subtree_check|若输出目录是一个子目录，则 NFS 服务器将检查其父目录的权限（默认设置）|
	|no_subtree_check|即使输出目录是一个子目录，NFS 服务器也不检查其父目录的权限，这样做可提高效率|

### 启动 NFS 服务端

```
# 启动 rpcbind 状态
[root@nfs-server ~]# /etc/init.d/rpcbind start
Starting rpcbind:                                          [  OK  ]
# 查看 rpcbind 状态
[root@nfs-server ~]# /etc/init.d/rpcbind status
rpcbind (pid  1826) is running...
# 查看 rpcbind 默认端口 111
[root@nfs-server ~]# lsof -i :111
COMMAND  PID USER   FD   TYPE DEVICE SIZE/OFF NODE NAME
rpcbind 1826  rpc    6u  IPv4  12657      0t0  UDP *:sunrpc
rpcbind 1826  rpc    8u  IPv4  12660      0t0  TCP *:sunrpc (LISTEN)
rpcbind 1826  rpc    9u  IPv6  12662      0t0  UDP *:sunrpc
rpcbind 1826  rpc   11u  IPv6  12665      0t0  TCP *:sunrpc (LISTEN)
# 查看 rpcbind 服务端口
[root@nfs-server ~]# netstat -lntup|grep rpcbind
tcp        0      0 0.0.0.0:111                 0.0.0.0:*                   LISTEN      1826/rpcbind
tcp        0      0 :::111                      :::*                        LISTEN      1826/rpcbind
udp        0      0 0.0.0.0:729                 0.0.0.0:*                               1826/rpcbind
udp        0      0 0.0.0.0:111                 0.0.0.0:*                               1826/rpcbind
udp        0      0 :::729                      :::*                                    1826/rpcbind
udp        0      0 :::111                      :::*                                    1826/rpcbind
# 查看 rpcbind 开机是否自启动
[root@nfs-server ~]# chkconfig --list rpcbind
rpcbind         0:off   1:off   2:on    3:on    4:on    5:on    6:off
# 查看 nfs 端口信息（没有发现）
[root@nfs-server ~]# rpcinfo -p localhost
   program vers proto   port  service
    100000    4   tcp    111  portmapper
    100000    3   tcp    111  portmapper
    100000    2   tcp    111  portmapper
    100000    4   udp    111  portmapper
    100000    3   udp    111  portmapper
    100000    2   udp    111  portmapper
# 启动 NFS 服务
[root@nfs-server ~]# /etc/init.d/nfs start
Starting NFS services:                                     [  OK  ]
Starting NFS quotas:                                       [  OK  ]
Starting NFS mountd:                                       [  OK  ]
Starting NFS daemon:                                       [  OK  ]
正在启动 RPC idmapd：                                      [确定]

# 设置 nfs 开机自启动
[root@nfs-server ~]# chkconfig nfs on
# 查看 nfs 开机是否启动（已打开）

如何确定`rpcbind`服务一定在`NFS`服务之前启动？？？

# 无须调整，默认 rpcbind 开机顺序为 13，nfs 为 30
[root@nfs-server ~]# cat /etc/init.d/rpcbind|grep 'chkconfig'
# chkconfig: 2345 13 87（开机启动顺序 13）
[root@nfs-server ~]# cat /etc/init.d/nfs|grep 'chkconfig'
# chkconfig: - 30 60（开机启动顺序 30）

```

### 配置 NFS 服务端

`NFS`配置文件为`/etc/exports`

```
# 查看 NFS 配置文件
[root@nfs-server ~]# ll /etc/exports
-rw-r--r--. 1 root root 0 1 月  12 2010 /etc/exports

`/etc/exports`配置文件格式
`NFS`共享的目录 `NFS`客户端地址（参 1，参 2...）
`NFS`共享的目录 `NFS`客户端地址 1（参 1，参 2...） 客户端地址 2（参 1，参 2...）

# 创建共享目录
mkdir /data
# NFS 配置文件添加共享目录相关信息
cat >>/etc/exports<< EOF
########nfs sync dir by zhangjie at 20150909########
/data  * (rw,sync,all_squash)
EOF
# NFS 平滑生效
/etc/init.d/nfs reload

# 查看共享记录
[root@nfs-server ~]# showmount -e localhost
Export list for localhost:
/data *
# 本机挂载测试
[root@nfs-server ~]# mount -t nfs 192.168.1.21:/data /mnt
# 查看是否已经挂载成功
[root@nfs-server ~]# df -h
Filesystem          Size  Used Avail Use% Mounted on
/dev/sda3            18G  1.6G   15G  10% /
tmpfs               491M     0  491M   0% /dev/shm
/dev/sda1           190M   61M  120M  34% /boot
192.168.0.1:/data   18G  1.6G   15G  10% /mnt

# 配置例子
/ceshi_test *(rw,sync,no_root_squash,nohide,no_root_squash,no_subtree_check,sync)
```

### 配置 NFS 客户端
```
# 启动 rpcbind 服务
[root@lamp01 ~]# /etc/init.d/rpcbind start
Starting rpcbind:                                          [  OK  ]
# 测试是否可以连接 NFS 服务器
[root@client ~]# showmount -e 192.168.1.21
Export list for 192.168.1.21:
/data *
# 挂载客户端 NFS 服务
[root@lamp01 ~]# mount -t nfs 192.168.1.21:/data /mnt
# 查看是否挂载成功
[root@lamp01 ~]# df -h
Filesystem          Size  Used Avail Use% Mounted on
/dev/sda3            18G  1.6G   15G  10% /
tmpfs               491M     0  491M   0% /dev/shm
/dev/sda1           190M   61M  120M  34% /boot
192.168.1.21:/data   18G  1.6G   15G  10% /mnt

# 查看 NFS 服务器完整参数配置（仔细看默认添加了很多参数，这里的 anonuid 用户、anongid 组）
[root@nfs-server /]# cat /var/lib/nfs/etab
/data   *(rw,sync,wdelay,hide,nocrossmnt,secure,root_squash,no_all_squash,no_subtree_check,secure_locks,acl,anonuid=65534,anongid=65534,sec=sys,rw,root_squash,no_all_squash)
# 查看用户组为 65534 的用户（nfsnobody 用户）
[root@nfs-server /]# grep '65534' /etc/passwd
nfsnobody:x:65534:65534:Anonymous NFS User:/var/lib/nfs:/sbin/nologin
# 更改目录所属用户、所属组
[root@nfs-server /]# chown -R nfsnobody.nfsnobody /data/
# 查看目录所属用户、所属组
[root@nfs-server /]# ls -ld /data/
drwxr-xr-x 2 nfsnobody nfsnobody 4096 9 月   8 07:16 /data/

> NFS 系统安全挂载

一般`NFS`服务器共享的只是普通的静态数据（图片、附件、视频等等），不需要执行 suid、exec 等权限，挂载的这个文件系统，只能作为存取至用，无法执行程序，对于客户端来讲增加了安全性，（如：很多木马篡改站点文件都是由上传入口上传的程序到存储目录，然后执行的）注意：非性能的参数越多，速度可能越慢

# 安全挂载参数（nosuid、noexec、nodev）
mount -t nfs nosuid,noexec,nodev,rw 192.168.1.21:/data /mnt
# 禁止更新目录及文件时间戳挂载（noatime、nodiratime）
mount -t nfs noatime,nodiratime 192.168.1.21:/data /mnt
# 安全加优化的挂载方式（nosuid、noexec、nodev、noatime、nodiratime、intr、rsize、wsize）
mount -t nfs -o nosuid,noexec,nodev,noatime,nodiratime,intr,rsize=131072,wsize=131072 192.168.1.21:/data /mnt
# 默认挂载方式（无）
mount -t nfs 192.168.24.7:/data /mnt
```
### 常见问题
#### rpcbind 安装失败

yum 安装时提示如下

```
error: %pre(rpcbind-0.2.0-12.el6.x86_64) scriptlet failed, exit status 6
Error in PREIN scriptlet in rpm package rpcbind-0.2.0-12.el6.x86_64
error:   install: %pre scriptlet failed (2), skipping rpcbind-0.2.0-12.el6
  Verifying  : rpcbind-0.2.0-12.el6.x86_64                                                                                    1/1
  Failed:
    rpcbind.x86_64 0:0.2.0-12.el6
```

因为通过 chattr +i 把 /etc/passwd /etc/group /etc/shadow /etc/gshadow 锁定了。

chattr -i 解锁后，问题解决。

#### nfs 客户端挂载失败

现象：客户端 mount 失败，同时 rpcbind 服务是停止的，怎么都启不来
mount 时提示如下：
```
mount.nfs: rpc.statd is not running but is required for remote locking.
mount.nfs: Either use '-o nolock' to keep locks local, or start statd.
mount.nfs: an incorrect mount option was specified
```
调试后发现，rpcbind 要求在 /etc/sysconfig/network 文件里写一个 NETWORKING=yes 才行，加上配置后，即可启动 rpcbind 服务

#### nfs 客户端无法 chown

nfs 常规配置后，客户端可以创建，删除，chmod；但无法修改属主和属组；

解决方法：

挂载时，加上 vers=3 即可，例：
```
#mount -t nfs -o vers=3 server:/share /mnt
```
## CIFS(UNIX 和 windows 间共享协议）

在 Linux 上连接 windows 上 NAS 设备时，需要 cifs-utils 支持
```
#yum -y install cifs-utils
```

### 给挂载共享文件夹指定 owner 和 group

在服务器部署的时候需要把文件夹设置在 windows 的共享文件上。在使用 mount 命令挂载到 linux 上后。文件路径和文件都是可以访问，但是不能写入，导致系统在上传文件的时候提示“权限不够，没有写权限”。用"ls-l"查看挂载文件的权限设置是 drwxr-xr-x, 很明显没有写权限。想当然使用 chmod 来更改文件夹权限，结果提示权限不够。root 和当前用户都不能正常修改权限。

可以添加两个参数即可达到我们所要的效果：

```
#mount -t cifs -o username="***",password="***",gid=***,uid=**** //WindowsHost/sharefolder  /home/xxx/shared
```
gid 和 uid，可以使用 id username 来获得

### 给 mount 共享文件夹所在组的写权限

```
#mount -t cifs -o username="Administrator",password="PasswordForWindows",uid=test_user,gid=test_user,dir_mode=0777 //192.168.1.2/test /mnt/
```
### 永久挂载 Windows 共享

```
#mount -t cifs -o username="***",password="***",gid=500,uid=500 //WindowsHost/sharefolder  /home/xxx/shared
```
如上挂载时，可写入 fstab 文件

```
//WindowsHost/sharefolder /home/xxx/shared cifs username=***,password=***,uid=500,gid=500 0 0
```
遗憾的是，此命令具有明显的安全问题，因为您必须在 /etc/fstab 条目中公开密码，而文件 /etc/fstab 通常可供系统上的每个用户读取。要解决此问题，可使用 credentials 挂载选项将用户名和密码放在指定的文本文件中。例如：

```
//WindowsHost/sharefolder /home/xxx/shared cifs credentials=/etc/cred.ceshi,ui500,gid=500 0 0
```
一个 credentials 文件的格式如下所示：
```
username=***
password=MYPASSWORD
```
然后可使用以下命令，使 /etc/cred.ceshi 文件仅可供 root 用户（必须以其身份执行 mount 命令的用户）读取：
```
#chmod 600 /etc/cred.ceshi
```
# 查看磁盘信息

## lsscsi

```
    --classic|-c      alternate output similar to 'cat /proc/scsi/scsi'
    --device|-d       show device node's major + minor numbers
    --generic|-g      show scsi generic device name
    --help|-h         this usage information
    --hosts|-H        lists scsi hosts rather than scsi devices
    --kname|-k        show kernel name instead of device node name
    --list|-L         additional information output one
                      attribute=value per line
    --long|-l         additional information output
    --protection|-p   show data integrity (protection) information
    --sysfsroot=PATH|-y PATH    set sysfs mount point to PATH (def: /sys)
    --transport|-t    transport information for target or, if '--hosts'
                      given, for initiator
    --verbose|-v      output path names where data is found
    --version|-V      output version string and exit
```

查看磁盘运行状态

```
lsscsi -l
[0:0:0:0]    disk    ATA      ST2000LM003 HN-M 0007  -
  state=running queue_depth=64 scsi_level=6 type=0 device_blocked=0 timeout=0
[0:0:1:0]    disk    ATA      ST2000LM003 HN-M 0007  -
  state=running queue_depth=64 scsi_level=6 type=0 device_blocked=0 timeout=0
[0:0:2:0]    disk    ATA      ST2000LM003 HN-M 0007  /dev/sda
  state=running queue_depth=64 scsi_level=6 type=0 device_blocked=0 timeout=30
[0:0:3:0]    disk    ATA      ST2000LM003 HN-M 0007  /dev/sdb
  state=running queue_depth=64 scsi_level=6 type=0 device_blocked=0 timeout=30
[0:0:4:0]    disk    ATA      ST2000LM003 HN-M 0007  /dev/sdc
  state=running queue_depth=64 scsi_level=6 type=0 device_blocked=0 timeout=30
[0:0:5:0]    disk    ATA      ST2000LM003 HN-M 0007  /dev/sdd
  state=running queue_depth=64 scsi_level=6 type=0 device_blocked=0 timeout=30
[0:0:6:0]    disk    ATA      ST2000LM003 HN-M 0007  /dev/sde
  state=running queue_depth=64 scsi_level=6 type=0 device_blocked=0 timeout=30
[0:0:7:0]    disk    ATA      ST2000LM003 HN-M 0006  /dev/sdf
  state=running queue_depth=64 scsi_level=6 type=0 device_blocked=0 timeout=30
[0:1:0:0]    disk    LSILOGIC Logical Volume   3000  /dev/sdg
  state=running queue_depth=64 scsi_level=3 type=0 device_blocked=0 timeout=30
```


## smartctl

smartctl 可以查看磁盘的 SN，WWN 等信息。还有是否有磁盘坏道的信息

```
$ smartctl -a -f brief /dev/sdb

# 如果磁盘位于 raid 下面，比如 megaraid，可以使用如下命令
# smartctl -a -f brief -d megaraid,1 /dev/sdb

smartctl 5.43 2012-06-30 r3573 [x86_64-linux-3.12.21-1.el6.x86_64] (local build)
Copyright (C) 2002-12 by Bruce Allen, http://smartmontools.sourceforge.net

=== START OF INFORMATION SECTION ===
Device Model:     ST2000LM003 HN-M201RAD
Serial Number:    S34RJ9EG109476
LU WWN Device Id: 5 0004cf 20eeefc42
Firmware Version: 2BC10007
User Capacity:    2,000,398,934,016 bytes [2.00 TB]
Sector Sizes:     512 bytes logical, 4096 bytes physical
Device is:        Not in smartctl database [for details use: -P showall]
ATA Version is:   8
ATA Standard is:  ATA-8-ACS revision 6
Local Time is:    Mon Jun 22 07:48:24 2015 UTC
SMART support is: Available - device has SMART capability.
SMART support is: Enabled

Vendor Specific SMART Attributes with Thresholds:
ID# ATTRIBUTE_NAME          FLAGS    VALUE WORST THRESH FAIL RAW_VALUE
  1 Raw_Read_Error_Rate     POSR-K   91   91   051    -    11787
  2 Throughput_Performance  -OS--K   252   252   000    -    0
  3 Spin_Up_Time            PO---K   086   086   025    -    4319
  4 Start_Stop_Count        -O--CK   100   100   000    -    16
  5 Reallocated_Sector_Ct   PO--CK   252   252   010    -    0
  7 Seek_Error_Rate         -OSR-K   252   252   051    -    0
  8 Seek_Time_Performance   --S--K   252   252   015    -    0
  9 Power_On_Hours          -O--CK   100   100   000    -    2277
 10 Spin_Retry_Count        -O--CK   252   252   051    -    0
 12 Power_Cycle_Count       -O--CK   100   100   000    -    34
191 G-Sense_Error_Rate      -O---K   252   252   000    -    0
192 Power-Off_Retract_Count -O---K   252   252   000    -    0
194 Temperature_Celsius     -O----   064   064   000    -    22 (Min/Max 18/28)
195 Hardware_ECC_Recovered  -O-RCK   100   100   000    -    0
196 Reallocated_Event_Count -O--CK   252   252   000    -    0
197 Current_Pending_Sector  -O--CK   100   100   000    -    11
198 Offline_Uncorrectable   ----CK   252   252   000    -    0
199 UDMA_CRC_Error_Count    -OS-CK   200   200   000    -    0
200 Multi_Zone_Error_Rate   -O-R-K   100   100   000    -    3
223 Load_Retry_Count        -O--CK   252   252   000    -    0
225 Load_Cycle_Count        -O--CK   090   090   000    -    108289
                            ||||||_ K auto-keep
                            |||||__ C event count
                            ||||___ R error rate
                            |||____ S speed/performance
                            ||_____ O updated online
                            |______ P prefailure warning

SMART Error Log Version: 1
No Errors Logged
```

### 解释下各属性的含义

    ID# ATTRIBUTE_NAME          FLAG     VALUE WORST THRESH TYPE      UPDATED  WHEN_FAILED RAW_VALUE

> - **ID**    属性 ID，1~255
> - **ATTRIBUTE_NAME**    属性名
> - **FLAG**  表示这个属性携带的标记。使用 -f brief 可以打印
> - **VALUE**     Normalized value, 取值范围 1 到 254. 越低表示越差。越高表示越好。(with 1 representing the worst case and 254 representing the best)。注意 wiki 上说的是 1 到 253. 这个值是硬盘厂商根据 RAW_VALUE 转换来的，smartmontools 工具不负责转换工作。
> - **WORST**     表示 SMART 开启以来的，所有 Normalized values 的最低值。(which represents the lowest recorded normalized value.)
> - **THRESH**    阈值，当 Normalized value 小于等于 THRESH 值时，表示这项指标已经 failed 了。注意这里提到，如果这个属性是 pre-failure 的，那么这项如果出现 Normalized value<=THRESH, 那么磁盘将马上 failed 掉
> - **TYPE**      这里存在两种 TYPE 类型，Pre-failed 和 Old_age.
    1. Pre-failed 类型的 Normalized value 可以用来预先知道磁盘是否要坏了。例如 Normalized value 接近 THRESH 时，就赶紧换硬盘吧。
    2. Old_age 类型的 Normalized value 是指正常的使用损耗值，当 Normalized value 接近 THRESH 时，也需要注意，但是比 Pre-failed 要好一点。
> - **UPDATED**   这个字段表示这个属性的值在什么情况下会被更新。一种是通常的操作和离线测试都更新 (Always), 另一种是只在离线测试的情况下更新 (Offline).
> - **WHEN_FAILED**   这字段表示当前这个属性的状态 : failing_now(normalized_value <= THRESH), 或者 in_the_past(WORST <= THRESH), 或者 - , 正常 (normalized_value 以及 wrost >= THRESH).
> - **RAW_VALUE** 表示这个属性的未转换前的 RAW 值，可能是计数，也可能是温度，也可能是其他的。
注意 RAW_VALUE 转换成 Normalized value 是由厂商的 firmware 提供的，smartmontools 不提供转换。

注意有个 FLAG 是 KEEP, 如果不带这个 FLAG 的属性，值将不会 KEEP 在磁盘中，可能出现 WORST 值被刷新的情况，例如这里的 ID=1 的值，已经 89 了，重新执行又变成 91 了，但是 WORST 的值并不是历史以来的最低 89。遇到这种情况的解决办法是找个地方存储这些值的历史值。

因此监控磁盘的重点在哪里呢？
严重情况从上到下 :

> * 1. 最严重的情况 WHEN_FAILED = FAILING_NOW 并且 TYPE=Pre-failed, 表示现在这个属性已经出问题了。并且硬盘也已经 failed 了。
> * 2. 次严重的情况 WHEN_FAILED = in_the_past 并且 TYPE=Pre-failed, 表示这个属性曾经出问题了。但是现在是正常的。
> * 3. WHEN_FAILED = FAILING_NOW 并且 TYPE=Old_age, 表示现在这个属性已经出问题了。但是硬盘可能还没有 failed.
> * 4. WHEN_FAILED = in_the_past 并且 TYPE=Old_age, 表示现在这个属性曾经出问题了。但是现在是正常的。

为了避免这 4 种情况的发生。

> * 1. 对于 UPDATE=Offline 的属性，应该让 smartd 定期进行测试 (smartd 还可以发邮件）. 或者 crontab 进行测试。
> * 2. 应该时刻关注磁盘的 Normalized value 以及 WORST 的值是否接近 THRESH 的值了。当有值要接近 THRESH 了，提前更换硬盘。
> * 3. 温度，有些磁盘对温度比较敏感，例如 PCI-E SSD 硬盘。如果温度过高可能就挂了。这里读取 RAW_VALUE 就比较可靠了。

### 各个属性的含义

> * **read error rate** 错误读取率：记录读取数据错误次数（累计），非 0 值表示硬盘已经或者可能即将发生坏道
> * **throughput performance** 磁盘吞吐量：平均吞吐性能（一般在进行了人工 Offline S.M.A.R.T. 测试以后才会有值。）；
> * **spinup time** 主轴电机到达要求转速时间（毫秒 / 秒）；
> * **start/stop count** 电机启动 / 停止次数（可以当作开机 / 关机次数，或者休眠后恢复，均增加一次计数。全新的硬盘应该小于 10）；
> * **reallocated sectors count** 重分配扇区计数：硬盘生产过程中，有一部分扇区是保留的。当一些普通扇区读 / 写 / 验证错误，则重新映射到保留扇区，挂起该异常扇区，并增加计数。随着计数增加，io 性能骤降。如果数值不为 0，就需要密切关注硬盘健康状况；如果持续攀升，则硬盘已经损坏；如果重分配扇区数超过保留扇区数，将不可修复；
> * **seek error rate** 寻道错误率：磁头定位错误一次，则技术增加一次。如果持续攀升，则可能是机械部分即将发生故障；
> * **seek timer performance** 寻道时间：寻道所需要的时间，越短则读取数据越快，但是如果时间增加，则可能机械部分即将发生故障；
> * **power-on time** 累计通电时间：指硬盘通电时间累计值。（单位：天 / 时 / 分 / 秒。休眠 / 挂起不计入？新购入的硬盘应小于 100hrs）；
> * **spinup retry count** 电机启动失败计数：电机启动到指定转速失败的累计数值。如果失败，则可能是动力系统产生故障；
> * **power cycle count** 电源开关计数：每次加电增加一次计数，新硬盘应小于 10 次；
> * **g-sensor error rate** 坠落计数：异常加速度（例如坠落，抛掷）计数——磁头会立即回到 landing zone，并增加一次计数；
> * **power-off retract count** 异常断电次数：磁头在断电前没有完全回到 landing zone 的次数，每次异常断电则增加一次计数；
> * **load/unload cycle count** 磁头归位次数：指工作时，磁头每次回归 landing zone 的次数。（ps：流言说某个 linux 系统——不点名，在使用电池时候，会不断强制磁头归为，而磁头归位次数最大值约为 600k 次，所以认为 linux 会损坏硬盘，实际上不是这样的）；
> * **temperature** 温度：没嘛好说的，硬盘温度而已，理论上比工作环境高不了几度。（sudo hddtemp /dev/sda）
> * **reallocetion event count** 重映射扇区操作次数：上边的重映射扇区还记得吧？这个就是操作次数，成功的，失败的都计数。成功好说，也许硬盘有救，失败了，也许硬盘就要报废了；
> * **current pending sector count** 待映射扇区数：出现异常的扇区数量，待被映射的扇区数量。 如果该异常扇区之后成功读写，则计数会减小，扇区也不会重新映射。读错误不会重新映射，只有写错误才会重新映射；
> * **uncorrectable sector count** 不可修复扇区数：所有读 / 写错误计数，非 0 就证明有坏道，硬盘报废；

### 对于 SSD 硬盘，需要关注的几个参数

SSD 磨损数据分析：
SLC 的 SSD 可以擦除 10 万次，MLC 的 SSD 可以擦除 1 万次

**Media Wearout Indicator**

定义：表示 SSD 上 NAND 的擦写次数的程度，初始值为 100，随着擦写次数的增加，开始线性递减，递减速度按照擦写次数从 0 到最大的比例。一旦这个值降低到 1，就不再降了，同时表示 SSD 上面已经有 NAND 的擦写次数到达了最大次数。这个时候建议需要备份数据，以及更换 SSD。

解释：直接反映了 SSD 的磨损程度，100 为初始值，0 为需要更换，有点类似游戏中的血点。

结果：磨损 1 点

**Re-allocated Sector Count**

定义：出厂后产生的坏块个数，如果有坏块，从 1 开始增加，每 4 个坏块增加 1

解释：坏块的数量间接反映了 SSD 盘的健康状态。

结果：基本上都为 0

**Host Writes Count**

定义：主机系统对 SSD 的累计写入量，每写入 65536 个扇区 raw value 增加 1

解释：SSD 的累计写入量，写入量越大，SSD 磨损情况越严重。每个扇区大小为 512bytes，65536 个扇区为 32MB

结果：单块盘 40T

**Timed Workload Media Wear**

定义：表示在一定时间内，盘片的磨损比例，比 Media Wearout Indicator 更精确。

解释：可以在测试前清零，然后测试某段时间内的磨损数据，这个值的 1 点相当于 Media Wearout Indicator 的 1/100，测试时间必须大于 60 分钟。另外两个相关的参数：Timed Workload Timer 表示单次测试时间，Timed Workload Host Read/Write Ratio 表示读写比例。

**Available_Reservd_Space**

SSD 上剩余的保留空间，初始值为 100，表示 100%，阀值为 10，递减到 10 表示保留空间已经不能再减少

## MegaCli

查看 media error, other error

## LSIUtil

查看磁盘的物理位置，error 检测

## lsblk


# 磁盘扩展

## Linux 下 xfs 扩展

XFS 是一个开源的（GPL）日志文件系统，最初由硅谷图形（SGI）开发，现在大多数的 Linux 发行版都支持。事实上，XFS 已被最新的 CentOS/RHEL 7 采用，成为其默认的文件系统。在其众多的特性中，包含了“在线调整大小”这一特性，使得现存的 XFS 文件系统在已经挂载的情况下可以进行扩展。

扩展前
```
[root@meetbill ~]# xfs_info /mnt/
meta-data=/dev/sdb               isize=512    agcount=4, agsize=196608 blks
         =                       sectsz=512   attr=2, projid32bit=1
         =                       crc=1        finobt=0 spinodes=0
data     =                       bsize=4096   blocks=786432, imaxpct=25
         =                       sunit=0      swidth=0 blks
naming   =version 2              bsize=4096   ascii-ci=0 ftype=1
log      =internal               bsize=4096   blocks=2560, version=2
         =                       sectsz=512   sunit=0 blks, lazy-count=1
realtime =none                   extsz=4096   blocks=0, rtextents=0


[root@meetbill ~]# df -h
Filesystem           Size  Used Avail Use% Mounted on
/dev/mapper/cl-root   17G  8.4G  8.7G  49% /
devtmpfs             902M     0  902M   0% /dev
tmpfs                912M     0  912M   0% /dev/shm
tmpfs                912M  8.7M  904M   1% /run
tmpfs                912M     0  912M   0% /sys/fs/cgroup
/dev/sda1           1014M  141M  874M  14% /boot
tmpfs                183M     0  183M   0% /run/user/0
/dev/sdb             3.0G   33M  3.0G   2% /mnt
```
将磁盘 (/dev/sdb) 进行扩展后，扩展磁盘的方式比如虚拟机对虚拟磁盘进行扩展或 isics 对存储进行扩展，磁盘扩展后，我们还需要对文件系统进行扩展 (/mnt)

我们用到的是 `xfs_growfs` 命令
```
[root@meetbill ~]# xfs_growfs /mnt/
meta-data=/dev/sdb               isize=512    agcount=4, agsize=196608 blks
         =                       sectsz=512   attr=2, projid32bit=1
         =                       crc=1        finobt=0 spinodes=0
data     =                       bsize=4096   blocks=786432, imaxpct=25
         =                       sunit=0      swidth=0 blks
naming   =version 2              bsize=4096   ascii-ci=0 ftype=1
log      =internal               bsize=4096   blocks=2560, version=2
         =                       sectsz=512   sunit=0 blks, lazy-count=1
realtime =none                   extsz=4096   blocks=0, rtextents=0
data blocks changed from 786432 to 1310720
```
大功告成，如果`xfs_growfs` 不加任何参数，则会对指定挂载目录自动扩展 XFS 文件系统到最大的可用大小。`-D`参数可以设置为指定大小
