# 常用问题处理


<!-- vim-markdown-toc GFM -->

* [1 系统配置](#1-系统配置)
    * [1.1 Yum 安装安装包时提示证书过期](#11-yum-安装安装包时提示证书过期)
    * [1.2 系统日志中的时间不准确](#12-系统日志中的时间不准确)
    * [1.3  Linux 系统日志出现 hung_task_timeout_secs 和 blocked for more than 120 seconds](#13--linux-系统日志出现-hung_task_timeout_secs-和-blocked-for-more-than-120-seconds)
        * [问题现象](#问题现象)
        * [问题原因](#问题原因)
        * [处理方法](#处理方法)
        * [内核参数解释](#内核参数解释)
* [2 磁盘](#2-磁盘)
    * [2.1 lvm 变为 inactive 状态](#21-lvm-变为-inactive-状态)

<!-- vim-markdown-toc -->

## 1 系统配置
### 1.1 Yum 安装安装包时提示证书过期

yum 安装安装包时提示"Peer's Certificate has expired"

https 的证书是有开始时间和失效时间的。因此本地时间要在这个证书的有效时间内。不过最好的方式，还是能够把时间进行同步。

```
# ntpdate pool.ntp.org
```

###  1.2 系统日志中的时间不准确

重启下 rsyslog 服务

```
/etc/init.d/rsyslog restart

```
### 1.3  Linux 系统日志出现 hung_task_timeout_secs 和 blocked for more than 120 seconds
#### 问题现象

Linux 系统出现系统没有响应。 在 /var/log/message 日志中出现大量的类似如下错误信息：
```
echo 0 > /proc/sys/kernel/hung_task_timeout_secs disables this message.
blocked for more than 120 seconds
```
同时看监控时发现，服务器异常期间磁盘 io 比较高，cpu load 比较高

#### 问题原因
默认情况下， Linux 会最多使用 40% 的可用内存作为文件系统缓存。当超过这个阈值后，文件系统会把将缓存中的内存全部写入磁盘， 导致后续的 IO 请求都是同步的。
将缓存写入磁盘时，有一个默认 120 秒的超时时间。 出现上面的问题的原因是  IO 子系统的处理速度不够快，不能在 120 秒将缓存中的数据全部写入磁盘。
IO 系统响应缓慢，导致越来越多的请求堆积，最终系统内存全部被占用，导致系统失去响应。

#### 处理方法
根据应用程序情况，对 vm.dirty_ratio，vm.dirty_background_ratio 两个参数进行调优设置。 例如，推荐如下设置：
```
# sysctl -w vm.dirty_ratio=10
# sysctl -w vm.dirty_background_ratio=5
# sysctl -p
```
 如果系统永久生效，修改 /etc/sysctl.conf  文件。加入如下两行：
```
#vi /etc/sysctl.conf
vm.dirty_background_ratio = 5
vm.dirty_ratio = 10
```
重启系统生效。
#### 内核参数解释

> * vm.dirty_background_ratio: 这个参数指定了当文件系统缓存脏页数量达到系统内存百分之多少时（如 5%）就会触发 pdflush/flush/kdmflush 等后台回写进程运行，将一定缓存的脏页异步地刷入外存；
> * vm.dirty_ratio: 而这个参数则指定了当文件系统缓存脏页数量达到系统内存百分之多少时（如 10%），系统不得不开始处理缓存脏页（因为此时脏页数量已经比较多，为了避免数据丢失需要将一定脏页刷入外存）；在此过程中很多应用进程可能会因为系统转而处理文件 IO 而阻塞。

一般情况下，dirty_ratio 的触发条件不会达到，因为每次会先达到 vm.dirty_background_ratio 的条件，然后触发 flush 进程进行异步的回写操作，但是这一过程中应用进程仍然可以进行写操作，如果应用进程写入的量大于 flush 进程刷出的量，就会达到 vm.dirty_ratio 这个参数所设定的坎，此时操作系统会转入同步地处理脏页的过程，阻塞应用进程。


## 2 磁盘
### 2.1 lvm 变为 inactive 状态

lvscan 查看 lvm 状态
```
[root@DB01 log]# lvscan
ACTIVE       '/dev/OraBack/backupone' [7.00 TB] inherit
ACTIVE       '/dev/OraBack/backuptwo' [7.00 TB] inherit
ACTIVE       '/dev/OraBack/backupthree' [1.00 TB] inherit
inactive     '/dev/OraBack【vg 名字】/orcl' [3.00 TB] inherit
```
激活 VG
```
[root@DB01 log]# vgchange -ay OraBack
4 logical volume(s) in volume group "OraBack" now active
```
lvscan 查看 lvm 状态
```
[root@DB01 log]# lvscan
ACTIVE            '/dev/OraBack/backupone' [7.00 TB] inherit
ACTIVE            '/dev/OraBack/backuptwo' [7.00 TB] inherit
ACTIVE            '/dev/OraBack/backupthree' [1.00 TB] inherit
ACTIVE            '/dev/OraBack/orcl' [3.00 TB] inherit
```

挂载

mount -a


