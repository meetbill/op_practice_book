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
        * [配置 Linux NFS 客户端](#配置-linux-nfs-客户端)
        * [配置 Windows NFS 客户端](#配置-windows-nfs-客户端)
        * [常见问题](#常见问题)
            * [rpcbind 安装失败](#rpcbind-安装失败)
            * [nfs 客户端挂载失败](#nfs-客户端挂载失败)
            * [nfs 客户端无法 chown](#nfs-客户端无法-chown)
    * [CIFS(UNIX 和 windows 间共享协议）](#cifsunix-和-windows-间共享协议)
        * [给挂载共享文件夹指定 owner 和 group](#给挂载共享文件夹指定-owner-和-group)
        * [给 mount 共享文件夹所在组的写权限](#给-mount-共享文件夹所在组的写权限)
        * [永久挂载 Windows 共享](#永久挂载-windows-共享)

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
| ---- | ---- |
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
    Starting rpcbind:                                   [  OK  ]

    # 查看 rpcbind 状态
    [root@nfs-server ~]# /etc/init.d/rpcbind status
    rpcbind (pid  1826) is running...

    # 查看 rpcbind 默认端口 111
    [root@nfs-server ~]# lsof -i :111
    COMMAND  PID USER   FD   TYPE DEVICE SIZE/OFF NODE NAME
    rpcbind 1826  rpc  6u IPv4 12657  0t0  UDP *:sunrpc
    rpcbind 1826  rpc  8u IPv4 12660  0t0  TCP *:sunrpc (LISTEN)
    rpcbind 1826  rpc  9u IPv6 12662  0t0  UDP *:sunrpc
    rpcbind 1826  rpc 11u IPv6 12665  0t0  TCP *:sunrpc (LISTEN)

    # 查看 rpcbind 服务端口
    [root@nfs-server ~]# netstat -lntup|grep rpcbind
    tcp  0 0 0.0.0.0:111  0.0.0.0:*        LISTEN   1826/rpcbind
    tcp  0 0 :::111       :::*             LISTEN   1826/rpcbind
    udp  0 0 0.0.0.0:729  0.0.0.0:*                 1826/rpcbind
    udp  0 0 0.0.0.0:111  0.0.0.0:*                 1826/rpcbind
    udp  0 0 :::729       :::*                      1826/rpcbind
    udp  0 0 :::111       :::*                      1826/rpcbind

    # 查看 rpcbind 开机是否自启动
    [root@nfs-server ~]# chkconfig --list rpcbind
    rpcbind    0:off   1:off   2:on   3:on  4:on   5:on    6:off

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
    Starting NFS services:                             [  OK  ]
    Starting NFS quotas:                               [  OK  ]
    Starting NFS mountd:                               [  OK  ]
    Starting NFS daemon:                               [  OK  ]
    正在启动 RPC idmapd：                              [确定]

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

NFS 配置文件为 /etc/exports

**配置格式**

    ```
    /etc/exports 配置文件格式
    NFS 共享的目录 NFS 客户端地址 (arg1，arg2...)
    NFS 共享的目录 NFS 客户端地址 1(arg1，arg2...) 客户端地址 2(arg1,arg2...)
    ```
如
    ```
     /home/share 192.168.102.15(rw,sync) *(ro)
    ```

**配置实例**

    ```

    # 创建共享目录
    mkdir /data

    # NFS 配置文件添加共享目录相关信息
    cat >>/etc/exports<< EOF
    ########nfs sync dir by zhangjie at 20150909########
    /data  *(rw,sync,all_squash)
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

### 配置 Linux NFS 客户端
    ```
    # 启动 rpcbind 服务
    [root@lamp01 ~]# /etc/init.d/rpcbind start
    Starting rpcbind:                                   [  OK  ]

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
### 配置 Windows NFS 客户端

    ```
    启动 windos NFS 客户端服务：
    1. 打开控制面板 ->程序 ->打开或关闭 windows 功能 ->NFS 客户端
    勾选 NFS 客户端，即开启 windows NFS 客户端服务。

    2.win+R->cmd
    mount 192.168.1.21:/data X:
    成功挂载，打开我的点脑，你即可在你网络位置看到 X: 盘了

    X: 你挂载的网络文件盘 -- 注意，可能会与你的其他盘冲突，你可以随意更改

    3. 取消挂载
    直接在 我的电脑 里面鼠标点击取消映射网络驱动器 X:
    或者：win+R->cmd
    输入：umount X:
    (umount -a 取消所有网络驱动器）
    ```

### 常见问题
#### rpcbind 安装失败

yum 安装时提示如下

```
error: %pre(rpcbind-0.2.0-12.el6.x86_64) scriptlet failed, exit status 6
Error in PREIN scriptlet in rpm package rpcbind-0.2.0-12.el6.x86_64
error:   install: %pre scriptlet failed (2), skipping rpcbind-0.2.0-12.el6
Verifying  : rpcbind-0.2.0-12.el6.x86_64                     1/1
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
