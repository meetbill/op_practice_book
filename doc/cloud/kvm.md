
<!-- vim-markdown-toc GFM -->
* [什么是 KVM](#什么是-kvm)
* [安装 KVM](#安装-kvm)
    * [系统要求](#系统要求)
    * [安装 kvm 软件](#安装-kvm-软件)
        * [确保正确加载 KVM 模块](#确保正确加载-kvm-模块)
        * [检查 kvm 是否正确安装](#检查-kvm-是否正确安装)
    * [配置网络](#配置网络)
        * [默认网络 virbro](#默认网络-virbro)
        * [桥接网络](#桥接网络)
    * [配置 VNC](#配置-vnc)
* [创建虚拟机](#创建虚拟机)
    * [上传 ISO](#上传-iso)
    * [创建 kvm 虚拟机的磁盘文件](#创建-kvm-虚拟机的磁盘文件)
    * [启动虚拟机](#启动虚拟机)
    * [连接虚拟机](#连接虚拟机)
* [管理 KVM](#管理-kvm)
    * [管理 kvm 上的虚拟机](#管理-kvm-上的虚拟机)

<!-- vim-markdown-toc -->

# 什么是 KVM

KVM 是指基于 Linux 内核的虚拟机（Kernel-based Virtual Machine）。 2006 年 10 月，由以色列的 Qumranet 组织开发的一种新的“虚拟机”实现方案。 2007 年 2 月发布的 Linux 2.6.20 内核第一次包含了 KVM 。增加 KVM 到 Linux 内核是 Linux 发展的一个重要里程碑，这也是第一个整合到 Linux 主线内核的虚拟化技术。

KVM 在标准的 Linux 内核中增加了虚拟技术，从而我们可以通过优化的内核来使用虚拟技术。在 KVM 模型中，每一个虚拟机都是一个由 Linux 调度程序管理的标准进程，你可以在用户空间启动客户机操作系统。一个普通的 Linux 进程有两种运行模式：内核和用户。 KVM 增加了第三种模式：客户模式（有自己的内核和用户模式）。

一个典型的 KVM 安装包括以下部件：

> * 一个管理虚拟硬件的设备驱动，这个驱动通过一个字符设备 /dev/kvm 导出它的功能。通过 /dev/kvm 每一个客户机拥有其自身的地址空间，这个地址空间与内核的地址空间相分离或与任何一个正运行着的客户机相分离。
* 一个模拟硬件的用户空间部件，它是一个稍微改动过的 QEMU 进程。从客户机操作系统执行 I/O 会拥有 QEMU。QEMU 是一个平台虚拟化方案，它允许整个 PC 环境（包括磁盘、显示卡（图形卡）、网络设备）的虚拟化。任何客户机操作系统所发出的 I/O 请求都被拦截，并被路由到用户模式用以被 QEMU 过程模拟仿真。

# 安装 KVM

## 系统要求

KVM 需要有 CPU 的支持 (Intel VT 或 AMD SVM)，在安装 KVM 之前检查一下 CPU 是否提供了虚拟技术的支持

* 基于`Intel`处理器的系统，运行`grep vmx /proc/cpuinfo`查找 CPU flags 是否包括`vmx`关键词
* 基于`AMD`处理器的系统，运行`grep svm /proc/cpuinfo`查找 CPU flags 是否包括`svm`关键词
* 检查 BIOS，确保 BIOS 里开启`VT`选项

**注：**

* 一些厂商禁止了机器 BIOS 中的 VT 选项 , 这种方式下 VT 不能被重新打开
* /proc/cpuinfo 仅从 Linux 2.6.15(Intel) 和 Linux 2.6.16(AMD) 开始显示虚拟化方面的信息。请使用 uname -r 命令查询您的内核版本。如有疑问，请联系硬件厂商

```
egrep "(vmx|svm)" /proc/cpuinfo
flags           : fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe syscall nx rdtscp lm constant_tsc arch_perfmon pebs bts rep_good xtopology nonstop_tsc aperfmperf pni dtes64 monitor ds_cpl vmx est tm2 ssse3 cx16 xtpr pdcm dca sse4_1 sse4_2 popcnt lahf_lm dts tpr_shadow vnmi flexpriority ept vpid
flags           : fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe syscall nx rdtscp lm constant_tsc arch_perfmon pebs bts rep_good xtopology nonstop_tsc aperfmperf pni dtes64 monitor ds_cpl vmx est tm2 ssse3 cx16 xtpr pdcm dca sse4_1 sse4_2 popcnt lahf_lm dts tpr_shadow vnmi flexpriority ept vpid
flags           : fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe syscall nx rdtscp lm constant_tsc arch_perfmon pebs bts rep_good xtopology nonstop_tsc aperfmperf pni dtes64 monitor ds_cpl vmx est tm2 ssse3 cx16 xtpr pdcm dca sse4_1 sse4_2 popcnt lahf_lm dts tpr_shadow vnmi flexpriority ept vpid
flags           : fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe syscall nx rdtscp lm constant_tsc arch_perfmon pebs bts rep_good xtopology nonstop_tsc aperfmperf pni dtes64 monitor ds_cpl vmx est tm2 ssse3 cx16 xtpr pdcm dca sse4_1 sse4_2 popcnt lahf_lm dts tpr_shadow vnmi flexpriority ept vpid
flags           : fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe syscall nx rdtscp lm constant_tsc arch_perfmon pebs bts rep_good xtopology nonstop_tsc aperfmperf pni dtes64 monitor ds_cpl vmx est tm2 ssse3 cx16 xtpr pdcm dca sse4_1 sse4_2 popcnt lahf_lm dts tpr_shadow vnmi flexpriority ept vpid
flags           : fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe syscall nx rdtscp lm constant_tsc arch_perfmon pebs bts rep_good xtopology nonstop_tsc aperfmperf pni dtes64 monitor ds_cpl vmx est tm2 ssse3 cx16 xtpr pdcm dca sse4_1 sse4_2 popcnt lahf_lm dts tpr_shadow vnmi flexpriority ept vpid
flags           : fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe syscall nx rdtscp lm constant_tsc arch_perfmon pebs bts rep_good xtopology nonstop_tsc aperfmperf pni dtes64 monitor ds_cpl vmx est tm2 ssse3 cx16 xtpr pdcm dca sse4_1 sse4_2 popcnt lahf_lm dts tpr_shadow vnmi flexpriority ept vpid
flags           : fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe syscall nx rdtscp lm constant_tsc arch_perfmon pebs bts rep_good xtopology nonstop_tsc aperfmperf pni dtes64 monitor ds_cpl vmx est tm2 ssse3 cx16 xtpr pdcm dca sse4_1 sse4_2 popcnt lahf_lm dts tpr_shadow vnmi flexpriority ept vpid
```

## 安装 kvm 软件
安装 KVM 模块、管理工具和 libvirt （一个创建虚拟机的工具）
```
yum install -y qemu-kvm libvirt virt-install virt-manager bridge-utils
/etc/init.d/libvirtd start
chkconfig libvirtd on
```

### 确保正确加载 KVM 模块
```
lsmod  | grep kvm
kvm_intel              54285  0 
kvm                   333172  1 kvm_intel
```

### 检查 kvm 是否正确安装
```
virsh -c qemu:///system list
 Id    Name                           State
----------------------------------------------------

```
如果这里是错误信息，说明安装出现问题


## 配置网络
kvm 上网有两种配置，一种是 default，它支持主机和虚拟机的互访，同时也支持虚拟机访问互联网，但不支持外界访问虚拟机，另外一种是 bridge 方式，可以使虚拟机成为网络中具有独立 Ip 的主机。


### 默认网络 virbro
默认的网络连接是 virbr0，它的配置文件在 /var/lib/libvirt/network 目录下，默认配置为
```
cat /var/lib/libvirt/network/default.xml 

  default
  77094b31-b7eb-46ca-930e-e0be9715a5ce

```

### 桥接网络

配置桥接网卡，配置如下

```
more /etc/sysconfig/network-scripts/ifcfg-\*
::::::::::::::
/etc/sysconfig/network-scripts/ifcfg-br0
::::::::::::::
DEVICE=br0
ONBOOT=yes
TYPE=Bridge
BOOTPROTO=static
IPADDR=192.168.39.20
NETMASK=255.255.255.0
GATEWAY=192.168.39.1
DNS1=8.8.8.8
::::::::::::::
/etc/sysconfig/network-scripts/ifcfg-br1
::::::::::::::
DEVICE=br1
ONBOOT=yes
TYPE=Bridge
BOOTPROTO=static
IPADDR=10.10.39.8
NETMASK=255.255.255.0
::::::::::::::
/etc/sysconfig/network-scripts/ifcfg-em1
::::::::::::::
DEVICE=em1
TYPE=Ethernet
ONBOOT=yes
BOOTPROTO=static
BRIDGE=br0
::::::::::::::
/etc/sysconfig/network-scripts/ifcfg-em2
::::::::::::::
DEVICE=em2
TYPE=Ethernet
ONBOOT=yes
BOOTPROTO=static
BRIDGE=br1
```
## 配置 VNC

**(1) 修改 VNC 服务端的配置文件**
```
[root@LINUX ~]# vim /etc/libvirt/qemu.conf  
vnc_listen = "0.0.0.0"   第十二行，把 vnc_listen 前面的#号去掉。
```
**(2) 重启 libvirtd 和 messagebus 服务**
```
[root@LINUX ~]# /etc/init.d/libvirtd restart
Stopping libvirtd daemon:                                  [  OK  ]
Starting libvirtd daemon: libvirtd: initialization failed  [FAILED]
解决办法：
[root@LINUX ~]# echo "export LC_ALL=en_US.UTF-8"  >>  /etc/profile
[root@LINUX ~]# source /etc/profile
[root@LINUX ~]# /etc/init.d/libvirtd restart
[root@LINUX ~]# /etc/init.d/messagebus restart
```
# 创建虚拟机

virt-manager 是基于 libvirt 的图像化虚拟机管理软件，操作类似 vmware，不做详细介绍。

* (1)Virt-manager 图形化模式安装
* (2)Virt-install   命令模式安装【本文使用此方式】
* (3)Virsh        XML 模板安装

## 上传 ISO

```
[root@LINUX ~]# mkdir -p /home/iso
[root@LINUX ~]# mkdir -p /home/kvm
将 iso 拷贝到 /home/iso 目录
```
## 创建 kvm 虚拟机的磁盘文件

本例创建的磁盘文件为 10G，实际使用中应注意下 /home 的空间，可以设置为 100G

```
[root@LINUX ~]# cd /home/kvm/
[root@LINUX ~]# qemu-img create -f qcow2 -o preallocation=metadata kvm_mode.img 10G        
```
## 启动虚拟机

bridge 网络模式（有独立 IP 时使用这种方式）

```
[root@LINUX ~]# chmod -R 777 /etc/libvirt
[root@LINUX ~]# chmod -R 777 /home/kvm
[root@LINUX ~]#virt-install --name=kvm_test --ram 4096 --vcpus=4 \
       -f /home/kvm/kvm_mode.img --cdrom /home/iso/sucunOs_anydisk.iso \
       --graphics vnc,listen=0.0.0.0,port=7788, --network bridge=br0 \
       --force --autostart
```
Net 模式（没有独立 IP 时使用这种方式）

```
[root@LINUX ~]# chmod -R 777 /etc/libvirt
[root@LINUX ~]# chmod -R 777 /home/kvm
[root@LINUX ~]#virt-install --name=kvm_test --ram 4096 --vcpus=4 \
       -f /home/kvm/kvm_mode.img --cdrom /home/iso/sucunOs_anydisk.iso \
       --graphics vnc,listen=0.0.0.0,port=7788,--network network=default \
       --force --autostart
```
## 连接虚拟机

用 VNC 连接，进行创建 kvm 虚拟机（VNC 连上之后，跟安装 linux Centos 6.5 系统一样，重新装一次）

```
点击 continue 是如果出现闪退的情况，请修改 Option->Expert->ColorLevel 的值为 full
```

# 管理 KVM

## 管理 kvm 上的虚拟机

* virsh list           #显示本地活动虚拟机
* virsh list  --all    #显示本地所有的虚拟机（活动的 + 不活动的）
* virsh start x        #启动名字为 x 的非活动虚拟机
* virsh shutdown x     #正常关闭虚拟机
* virsh dominfo x      #显示虚拟机的基本信息
* virsh autostart x    #将 x 虚拟机设置为自动启动
