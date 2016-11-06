
* [什么是KVM](#什么是kvm)
* [安装KVM](#安装kvm)
	* [系统要求](#系统要求)
	* [安装 kvm 软件](#安装-kvm-软件)
		* [确保正确加载 KVM 模块](#确保正确加载-kvm-模块)
		* [检查 kvm 是否正确安装](#检查-kvm-是否正确安装)
	* [配置网络](#配置网络)
		* [默认网络 virbro](#默认网络-virbro)
		* [桥接网络](#桥接网络)
	* [使用 virt-manager 安装建立虚拟机](#使用-virt-manager-安装建立虚拟机)

# 什么是KVM 

KVM 是指基于 Linux 内核的虚拟机（Kernel-based Virtual Machine）。 2006 年 10 月，由以色列的Qumranet 组织开发的一种新的“虚拟机”实现方案。 2007 年 2 月发布的 Linux 2.6.20 内核第一次包含了 KVM 。增加 KVM 到 Linux 内核是 Linux 发展的一个重要里程碑，这也是第一个整合到 Linux 主线内核的虚拟化技术。

KVM 在标准的 Linux 内核中增加了虚拟技术，从而我们可以通过优化的内核来使用虚拟技术。在 KVM 模型中，每一个虚拟机都是一个由 Linux 调度程序管理的标准进程，你可以在用户空间启动客户机操作系统。一个普通的 Linux 进程有两种运行模式：内核和用户。 KVM 增加了第三种模式：客户模式（有自己的内核和用户模式）。

一个典型的 KVM 安装包括以下部件：

> * 一个管理虚拟硬件的设备驱动，这个驱动通过一个字符设备 /dev/kvm 导出它的功能。通过 /dev/kvm每一个客户机拥有其自身的地址空间，这个地址空间与内核的地址空间相分离或与任何一个正运行着的客户机相分离。
* 一个模拟硬件的用户空间部件，它是一个稍微改动过的 QEMU 进程。从客户机操作系统执行 I/O 会拥有QEMU。QEMU 是一个平台虚拟化方案，它允许整个 PC 环境（包括磁盘、显示卡（图形卡）、网络设备）的虚拟化。任何客户机操作系统所发出的 I/O 请求都被拦截，并被路由到用户模式用以被 QEMU 过程模拟仿真。

# 安装KVM

## 系统要求

KVM 需要有CPU的支持(Intel VT 或 AMD SVM)，在安装 KVM 之前检查一下 CPU 是否提供了虚拟技术的支持

* 基于`Intel`处理器的系统，运行`grep vmx /proc/cpuinfo`查找 CPU flags 是否包括`vmx`关键词
* 基于`AMD`处理器的系统，运行`grep svm /proc/cpuinfo`查找 CPU flags 是否包括`svm`关键词
* 检查BIOS，确保BIOS里开启`VT`选项

**注:**

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
安装KVM模块、管理工具和libvirt (一个创建虚拟机的工具)
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
kvm上网有两种配置，一种是default，它支持主机和虚拟机的互访，同时也支持虚拟机访问互联网，但不支持外界访问虚拟机，另外一种是bridge方式，可以使虚拟机成为网络中具有独立Ip的主机。


### 默认网络 virbro
默认的网络连接是virbr0，它的配置文件在/var/lib/libvirt/network目录下，默认配置为
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

## 使用 virt-manager 安装建立虚拟机
virt-manager 是基于 libvirt 的图像化虚拟机管理软件，操作类似vmware，不做详细介绍。
