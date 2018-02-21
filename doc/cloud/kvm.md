
<!-- vim-markdown-toc GFM -->
* [1 什么是 KVM](#1-什么是-kvm)
* [2 安装 KVM](#2-安装-kvm)
    * [2.1 系统要求](#21-系统要求)
    * [2.2 安装 KVM 软件](#22-安装-kvm-软件)
        * [2.2.1 确保正确加载 KVM 模块](#221-确保正确加载-kvm-模块)
        * [2.2.2 检查 KVM 是否正确安装](#222-检查-kvm-是否正确安装)
    * [2.3 配置网络](#23-配置网络)
        * [2.3.1 默认网络 virbro](#231-默认网络-virbro)
        * [2.3.2 桥接网络](#232-桥接网络)
    * [2.4 配置 VNC](#24-配置-vnc)
* [3 创建虚拟机](#3-创建虚拟机)
    * [3.1 上传 ISO](#31-上传-iso)
    * [3.2 创建 KVM 虚拟机的磁盘文件](#32-创建-kvm-虚拟机的磁盘文件)
    * [3.3 启动虚拟机](#33-启动虚拟机)
        * [3.3.1 启动虚拟机参数说明](#331-启动虚拟机参数说明)
        * [3.3.2 bridge 网络模式启动虚拟机](#332-bridge-网络模式启动虚拟机)
        * [3.3.3 nat 模式启动虚拟机](#333-nat-模式启动虚拟机)
    * [3.4 连接虚拟机](#34-连接虚拟机)
* [4 管理 KVM](#4-管理-kvm)
    * [4.1 管理 KVM 上的虚拟机](#41-管理-kvm-上的虚拟机)

<!-- vim-markdown-toc -->

# 1 什么是 KVM

KVM 是指基于 Linux 内核的虚拟机（Kernel-based Virtual Machine）。 2006 年 10 月，由以色列的 Qumranet 组织开发的一种新的“虚拟机”实现方案。 2007 年 2 月发布的 Linux 2.6.20 内核第一次包含了 KVM 。增加 KVM 到 Linux 内核是 Linux 发展的一个重要里程碑，这也是第一个整合到 Linux 主线内核的虚拟化技术。

KVM 在标准的 Linux 内核中增加了虚拟技术，从而我们可以通过优化的内核来使用虚拟技术。在 KVM 模型中，每一个虚拟机都是一个由 Linux 调度程序管理的标准进程，你可以在用户空间启动客户机操作系统。一个普通的 Linux 进程有两种运行模式：内核和用户。 KVM 增加了第三种模式：客户模式（有自己的内核和用户模式）。

一个典型的 KVM 安装包括以下部件：

> * 一个管理虚拟硬件的设备驱动，这个驱动通过一个字符设备 /dev/kvm 导出它的功能。通过 /dev/kvm 每一个客户机拥有其自身的地址空间，这个地址空间与内核的地址空间相分离或与任何一个正运行着的客户机相分离。
* 一个模拟硬件的用户空间部件，它是一个稍微改动过的 QEMU 进程。从客户机操作系统执行 I/O 会拥有 QEMU。QEMU 是一个平台虚拟化方案，它允许整个 PC 环境（包括磁盘、显示卡（图形卡）、网络设备）的虚拟化。任何客户机操作系统所发出的 I/O 请求都被拦截，并被路由到用户模式用以被 QEMU 过程模拟仿真。

# 2 安装 KVM

## 2.1 系统要求

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

## 2.2 安装 KVM 软件
安装 KVM 模块、管理工具和 libvirt （一个创建虚拟机的工具）
```
yum install -y qemu-kvm libvirt virt-install virt-manager bridge-utils
/etc/init.d/libvirtd start
chkconfig libvirtd on
```

### 2.2.1 确保正确加载 KVM 模块
```
lsmod  | grep kvm
kvm_intel              54285  0 
kvm                   333172  1 kvm_intel
```

### 2.2.2 检查 KVM 是否正确安装
```
virsh -c qemu:///system list
 Id    Name                           State
----------------------------------------------------

```
如果这里是错误信息，说明安装出现问题


## 2.3 配置网络
KVM 上网有两种配置，一种是 default，它支持主机和虚拟机的互访，同时也支持虚拟机访问互联网，但不支持外界访问虚拟机，另外一种是 bridge 方式，可以使虚拟机成为网络中具有独立 IP 的主机。


### 2.3.1 默认网络 virbro
默认的网络连接是 virbr0，它的配置文件在 /var/lib/libvirt/network 目录下，默认配置为
```
cat /var/lib/libvirt/network/default.xml 

  default
  77094b31-b7eb-46ca-930e-e0be9715a5ce

```

### 2.3.2 桥接网络

配置桥接网卡，配置如下

```
more /etc/sysconfig/network-scripts/ifcfg-\*
:::::::::::::: 新建文件
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
:::::::::::::: 物理网卡
/etc/sysconfig/network-scripts/ifcfg-em1
::::::::::::::
DEVICE=em1
TYPE=Ethernet
ONBOOT=yes
BOOTPROTO=static
BRIDGE=br0
::::::::::::::
```
## 2.4 配置 VNC

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
# 3 创建虚拟机

virt-manager 是基于 libvirt 的图像化虚拟机管理软件，操作类似 vmware，不做详细介绍。

* (1)Virt-manager 图形化模式安装
* (2)Virt-install   命令模式安装【本文使用此方式】
* (3)Virsh        XML 模板安装

## 3.1 上传 ISO

```
[root@LINUX ~]# mkdir -p /home/iso
[root@LINUX ~]# mkdir -p /home/kvm
将 iso 拷贝到 /home/iso 目录
```
## 3.2 创建 KVM 虚拟机的磁盘文件

本例创建的磁盘文件为 10G，实际使用中应注意下 /home 的空间，可以设置为 100G

```
[root@LINUX ~]# cd /home/kvm/
[root@LINUX ~]# qemu-img create -f qcow2 -o preallocation=metadata kvm_mode.img 10G        
```
## 3.3 启动虚拟机

### 3.3.1 启动虚拟机参数说明

virt-install 命令有许多选项，这些选项大体可分为下面几大类，同时对每类中的常用选项也做出简单说明。

一般选项：指定虚拟机的名称、内存大小、VCPU 个数及特性等；

> * -n NAME, --name=NAME：虚拟机名称，需全局惟一；
> * -r MEMORY, --ram=MEMORY：虚拟机内在大小，单位为 MB；
> * --vcpus=VCPUS[,maxvcpus=MAX][,sockets=#][,cores=#][,threads=#]：VCPU 个数及相关配置；
> * --cpu=CPU：CPU 模式及特性，如 coreduo 等；可以使用 qemu-kvm -cpu ? 来获取支持的 CPU 模式；

安装方法：指定安装方法、GuestOS 类型等；

> * -c CDROM, --cdrom=CDROM：光盘安装介质；
> * -l LOCATION, --location=LOCATION：安装源 URL，支持 FTP、HTTP 及 NFS 等，如 ftp://172.16.0.1/pub；
> * --pxe：基于 PXE 完成安装；
> * --livecd: 把光盘当作 LiveCD；
> * --os-type=DISTRO_TYPE：操作系统类型，如 linux、unix 或 windows 等；
> * --os-variant=DISTRO_VARIANT：某类型操作系统的变体，如 rhel5、fedora8 等；
> * -x EXTRA, --extra-args=EXTRA：根据 --location 指定的方式安装 GuestOS 时，用于传递给内核的额外选项，例如指定 kickstart 文件的位置，--extra-args "ks=http://172.16.0.1/class.cfg"
> * --boot=BOOTOPTS：指定安装过程完成后的配置选项，如指定引导设备次序、使用指定的而非安装的 kernel/initrd 来引导系统启动等 ；例如：
> * --boot cdrom,hd,network：指定引导次序；
> * --boot kernel=KERNEL,initrd=INITRD,kernel_args=”console=/dev/ttyS0”：指定启动系统的内核及 initrd 文件；

存储配置：指定存储类型、位置及属性等；

> * --disk=DISKOPTS：指定存储设备及其属性；格式为 --disk /some/storage/path,opt1=val1，opt2=val2 等；常用的选项有：
>   * device：设备类型，如 cdrom、disk 或 floppy 等，默认为 disk；
>   * bus：磁盘总结类型，其值可以为 ide、scsi、usb、virtio 或 xen；
>   * perms：访问权限，如 rw、ro 或 sh（共享的可读写），默认为 rw；
>   * size：新建磁盘映像的大小，单位为 GB；
>   * cache：缓存模型，其值有 none、writethrouth（缓存读）及 writeback（缓存读写）；
>   * format：磁盘映像格式，如 raw、qcow2、vmdk 等；
>   * sparse：磁盘映像使用稀疏格式，即不立即分配指定大小的空间；
> * --nodisks：不使用本地磁盘，在 LiveCD 模式中常用；

网络配置：指定网络接口的网络类型及接口属性如 MAC 地址、驱动模式等；

> *  -w NETWORK, --network=NETWORK,opt1=val1,opt2=val2：将虚拟机连入宿主机的网络中，其中 NETWORK 可以为：
>   * bridge=BRIDGE：连接至名为“BRIDEG”的桥设备；
>   * network=NAME：连接至名为“NAME”的网络；
>   * 其它常用的选项还有：
>     * model：GuestOS 中看到的网络设备型号，如 e1000、rtl8139 或 virtio 等；
>     * mac：固定的 MAC 地址；省略此选项时将使用随机地址，但无论何种方式，对于 KVM 来说，其前三段必须为 52:54:00；
> * --nonetworks：虚拟机不使用网络功能；

图形配置：定义虚拟机显示功能相关的配置，如 VNC 相关配置；

> * --graphics TYPE,opt1=val1,opt2=val2：指定图形显示相关的配置，此选项不会配置任何显示硬件（如显卡），而是仅指定虚拟机启动后对其进行访问的接口；
>   * TYPE：指定显示类型，可以为 vnc、sdl、spice 或 none 等，默认为 vnc；
>   * port：TYPE 为 vnc 或 spice 时其监听的端口；
>   * listen：TYPE 为 vnc 或 spice 时所监听的 IP 地址，默认为 127.0.0.1，可以通过修改 /etc/libvirt/qemu.conf 定义新的默认值；
>   * password：TYPE 为 vnc 或 spice 时，为远程访问监听的服务进指定认证密码；
> * --noautoconsole：禁止自动连接至虚拟机的控制台；

设备选项：指定文本控制台、声音设备、串行接口、并行接口、显示接口等；

> * --serial=CHAROPTS：附加一个串行设备至当前虚拟机，根据设备类型的不同，可以使用不同的选项，格式为“--serial type,opt1=val1,opt2=val2,...”，例如：
> * --serial pty：创建伪终端；
> * --serial dev,path=HOSTPATH：附加主机设备至此虚拟机；
> * --video=VIDEO：指定显卡设备模型，可用取值为 cirrus、vga、qxl 或 vmvga；

### 3.3.2 bridge 网络模式启动虚拟机
有独立 IP 时使用这种方式

```
[root@LINUX ~]# chmod -R 777 /etc/libvirt
[root@LINUX ~]# chmod -R 777 /home/kvm
[root@LINUX ~]#virt-install --name=kvm_test --ram 4096 --vcpus=4 \
       -f /home/kvm/kvm_mode.img --cdrom /home/iso/sucunOs_anydisk.iso \
       --graphics vnc,listen=0.0.0.0,port=7788, --network bridge=br0 \
       --force --autostart
```
### 3.3.3 nat 模式启动虚拟机

没有独立 IP 时使用这种方式

```
[root@LINUX ~]# chmod -R 777 /etc/libvirt
[root@LINUX ~]# chmod -R 777 /home/kvm
[root@LINUX ~]#virt-install --name=kvm_test --ram 4096 --vcpus=4 \
       -f /home/kvm/kvm_mode.img --cdrom /home/iso/sucunOs_anydisk.iso \
       --graphics vnc,listen=0.0.0.0,port=7788,--network network=default \
       --force --autostart
```
## 3.4 连接虚拟机

> * (1) 网上下载 VNC 客户端
> * (2) 用 VNC 客户端连接并安装虚拟机的操作系统（VNC 连上之后，跟安装 Linux CentOS 6.5 系统一样，重新装一次）

```
点击 continue 是如果出现闪退的情况，请修改 Option->Expert->ColorLevel 的值为 full
```

# 4 管理 KVM

## 4.1 管理 KVM 上的虚拟机

* virsh list           #显示本地活动虚拟机
* virsh list  --all    #显示本地所有的虚拟机（活动的 + 不活动的）
* virsh start x        #启动名字为 x 的非活动虚拟机
* virsh shutdown x     #正常关闭虚拟机
* virsh dominfo x      #显示虚拟机的基本信息
* virsh autostart x    #将 x 虚拟机设置为自动启动
