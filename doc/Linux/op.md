# 常用问题处理


<!-- vim-markdown-toc GFM -->
* [Yum 安装安装包时提示证书过期](#yum-安装安装包时提示证书过期)
* [系统日志中的时间不准确](#系统日志中的时间不准确)
* [lvm 变为 inactive 状态](#lvm-变为-inactive-状态)

<!-- vim-markdown-toc -->
## Yum 安装安装包时提示证书过期

yum 安装安装包时提示"Peer's Certificate has expired"

https的证书是有开始时间和失效时间的。因此本地时间要在这个证书的有效时间内。不过最好的方式，还是能够把时间进行同步。

```
# ntpdate pool.ntp.org
```

##  系统日志中的时间不准确

重启下 rsyslog 服务

```
/etc/init.d/rsyslog restart

```
## lvm 变为 inactive 状态

lvscan查看lvm状态
```
[root@DB01 log]# lvscan
ACTIVE       '/dev/OraBack/backupone' [7.00 TB] inherit
ACTIVE       '/dev/OraBack/backuptwo' [7.00 TB] inherit
ACTIVE       '/dev/OraBack/backupthree' [1.00 TB] inherit
inactive     '/dev/OraBack【vg名字】/orcl' [3.00 TB] inherit
```
激活VG
```
[root@DB01 log]# vgchange -ay OraBack
4 logical volume(s) in volume group "OraBack" now active
```
lvscan查看lvm状态
```
[root@DB01 log]# lvscan
ACTIVE            '/dev/OraBack/backupone' [7.00 TB] inherit
ACTIVE            '/dev/OraBack/backuptwo' [7.00 TB] inherit
ACTIVE            '/dev/OraBack/backupthree' [1.00 TB] inherit
ACTIVE            '/dev/OraBack/orcl' [3.00 TB] inherit
```

挂载

mount -a


