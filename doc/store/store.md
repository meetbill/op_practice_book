# DAS/SAN/NAS

目前常见的三种存储结构

> * DAS：直连存储
> * SAN：存储区域网
> * NAS：网络附属存储


* [DAS](#das)
* [SAN](#san)
* [NAS](#nas)
	* [nfs(UNIX和UNIX之间共享协议)](#nfsunix和unix之间共享协议)
		* [nfs客户端无法chown](#nfs客户端无法chown)
	* [CIFS(UNIX和windows间共享协议)](#cifsunix和windows间共享协议)
		* [给挂载共享文件夹指定owner和group](#给挂载共享文件夹指定owner和group)
		* [给mount共享文件夹所在组的写权限](#给mount共享文件夹所在组的写权限)
		* [永久挂载 Windows 共享](#永久挂载-windows-共享)
* [查看磁盘信息](#查看磁盘信息)
	* [lsscsi](#lsscsi)
	* [smartctl](#smartctl)
		* [解释下各属性的含义](#解释下各属性的含义)
		* [各个属性的含义](#各个属性的含义)
		* [对于SSD硬盘，需要关注的几个参数](#对于ssd硬盘需要关注的几个参数)
	* [MegaCli](#megacli)
	* [LSIUtil](#lsiutil)
	* [lsblk](#lsblk)
* [磁盘扩展](#磁盘扩展)
	* [Linux下xfs扩展](#linux下xfs扩展)

# DAS

DAS :  Application --> File system --> Disk Storage

DAS：直连式存储依赖服务器主机操作系统进行数据的IO读写和存储维护管理，数据备份和恢复要求占用服务器主机资源(包括CPU、系统IO等)

# SAN

SAN :  Application --> File system --> Networking --> Disk Storage

IPSAN与FCSAN

# NAS

NAS :  Application --> Networking --> File system --> Disk Storage

NAS，网络附加存储，中心词"存储"，是的，它是一个存储设备。

NAS是一个设备。CIFS/NFS是一种协议。可以在NAS上启用CIFS/NFS协议，这样，用户就能使用CIFS/NFS协议进行访问了。

**一句话，CIFS用于UNIX和windows间共享，而NFS用于UNIX和UNIX之间共享**

## nfs(UNIX和UNIX之间共享协议)

### nfs客户端无法chown

nfs常规配置后，客户端可以创建，删除，chmod；但无法修改属主和属组；

解决方法：

挂载时，加上vers=3即可，例：
```
#mount -t nfs -o vers=3 server:/share /mnt
```
## CIFS(UNIX和windows间共享协议)

在 Linux 上连接windows上NAS设备时，需要cifs-utils支持
```
#yum -y install cifs-utils
```

### 给挂载共享文件夹指定owner和group

在服务器部署的时候需要把文件夹设置在windows的共享文件上。在使用mount命令挂载到linux上后。文件路径和文件都是可以访问，但是不能写入，导致系统在上传文件的时候提示“权限不够，没有写权限”。用"ls-l"查看挂载文件的权限设置是drwxr-xr-x,很明显没有写权限。想当然使用chmod来更改文件夹权限，结果提示权限不够。root和当前用户都不能正常修改权限。

可以添加两个参数即可达到我们所要的效果：

```
#mount -t cifs -o username="***",password="***",gid=***,uid=**** //WindowsHost/sharefolder  /home/xxx/shared  
```
gid和uid，可以使用id username来获得

### 给mount共享文件夹所在组的写权限

```
#mount -t cifs -o username="Administrator",password="PasswordForWindows",uid=test_user,gid=test_user,dir_mode=0777 //192.168.1.2/test /mnt/
```
### 永久挂载 Windows 共享

```
#mount -t cifs -o username="***",password="***",gid=500,uid=500 //WindowsHost/sharefolder  /home/xxx/shared  
```
如上挂载时,可写入fstab文件

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
然后可使用以下命令，使 /etc/cred.ceshi 文件仅可供 root 用户(必须以其身份执行 mount 命令的用户)读取：
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

smartctl 可以查看磁盘的SN，WWN等信息。还有是否有磁盘坏道的信息

```
$ smartctl -a -f brief /dev/sdb

# 如果磁盘位于raid下面，比如megaraid，可以使用如下命令
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

> - **ID**    属性ID，1~255
> - **ATTRIBUTE_NAME**    属性名
> - **FLAG**  表示这个属性携带的标记. 使用-f brief可以打印
> - **VALUE**     Normalized value, 取值范围1到254. 越低表示越差. 越高表示越好. (with 1 representing the worst case and 254 representing the best)。注意wiki上说的是1到253. 这个值是硬盘厂商根据RAW_VALUE转换来的, smartmontools工具不负责转换工作.
> - **WORST**     表示SMART开启以来的, 所有Normalized values的最低值. (which represents the lowest recorded normalized value.)
> - **THRESH**    阈值, 当Normalized value小于等于THRESH值时, 表示这项指标已经failed了。注意这里提到, 如果这个属性是pre-failure的, 那么这项如果出现Normalized value<=THRESH, 那么磁盘将马上failed掉
> - **TYPE**      这里存在两种TYPE类型, Pre-failed和Old_age. 
    1. Pre-failed 类型的Normalized value可以用来预先知道磁盘是否要坏了. 例如Normalized value接近THRESH时, 就赶紧换硬盘吧.
    2. Old_age 类型的Normalized value是指正常的使用损耗值, 当Normalized value 接近THRESH时, 也需要注意, 但是比Pre-failed要好一点.
> - **UPDATED**   这个字段表示这个属性的值在什么情况下会被更新. 一种是通常的操作和离线测试都更新(Always), 另一种是只在离线测试的情况下更新(Offline).
> - **WHEN_FAILED**   这字段表示当前这个属性的状态 : failing_now(normalized_value <= THRESH), 或者in_the_past(WORST <= THRESH), 或者 - , 正常(normalized_value以及wrost >= THRESH).
> - **RAW_VALUE** 表示这个属性的未转换前的RAW值, 可能是计数, 也可能是温度, 也可能是其他的.
注意RAW_VALUE转换成Normalized value是由厂商的firmware提供的, smartmontools不提供转换.

注意有个FLAG是KEEP, 如果不带这个FLAG的属性, 值将不会KEEP在磁盘中, 可能出现WORST值被刷新的情况, 例如这里的ID=1的值, 已经89了, 重新执行又变成91了, 但是WORST的值并不是历史以来的最低89。遇到这种情况的解决办法是找个地方存储这些值的历史值。

因此监控磁盘的重点在哪里呢?
严重情况从上到下 : 

> * 1. 最严重的情况WHEN_FAILED = FAILING_NOW 并且 TYPE=Pre-failed, 表示现在这个属性已经出问题了. 并且硬盘也已经failed了.
> * 2. 次严重的情况WHEN_FAILED = in_the_past 并且 TYPE=Pre-failed, 表示这个属性曾经出问题了. 但是现在是正常的.
> * 3. WHEN_FAILED = FAILING_NOW 并且 TYPE=Old_age, 表示现在这个属性已经出问题了. 但是硬盘可能还没有failed.
> * 4. WHEN_FAILED = in_the_past 并且 TYPE=Old_age, 表示现在这个属性曾经出问题了. 但是现在是正常的.

为了避免这4种情况的发生.

> * 1. 对于UPDATE=Offline的属性, 应该让smartd定期进行测试(smartd还可以发邮件). 或者crontab进行测试. 
> * 2. 应该时刻关注磁盘的Normalized value以及WORST的值是否接近THRESH的值了. 当有值要接近THRESH了, 提前更换硬盘.
> * 3. 温度, 有些磁盘对温度比较敏感, 例如PCI-E SSD硬盘. 如果温度过高可能就挂了. 这里读取RAW_VALUE就比较可靠了.

### 各个属性的含义

> * **read error rate** 错误读取率：记录读取数据错误次数（累计），非0值表示硬盘已经或者可能即将发生坏道
> * **throughput performance** 磁盘吞吐量：平均吞吐性能（一般在进行了人工 Offline S.M.A.R.T. 测试以后才会有值。）；
> * **spinup time** 主轴电机到达要求转速时间（毫秒/秒）；
> * **start/stop count** 电机启动/停止次数（可以当作开机/关机次数，或者休眠后恢复，均增加一次计数。全新的硬盘应该小于10）；
> * **reallocated sectors count** 重分配扇区计数：硬盘生产过程中，有一部分扇区是保留的。当一些普通扇区读/写/验证错误，则重新映射到保留扇区，挂起该异常扇区，并增加计数。随着计数增加，io性能骤降。如果数值不为0，就需要密切关注硬盘健康状况；如果持续攀升，则硬盘已经损坏；如果重分配扇区数超过保留扇区数，将不可修复；
> * **seek error rate** 寻道错误率：磁头定位错误一次，则技术增加一次。如果持续攀升，则可能是机械部分即将发生故障；
> * **seek timer performance** 寻道时间：寻道所需要的时间，越短则读取数据越快，但是如果时间增加，则可能机械部分即将发生故障；
> * **power-on time** 累计通电时间：指硬盘通电时间累计值。（单位：天/时/分/秒。休眠/挂起不计入？新购入的硬盘应小于100hrs）；
> * **spinup retry count** 电机启动失败计数：电机启动到指定转速失败的累计数值。如果失败，则可能是动力系统产生故障；
> * **power cycle count** 电源开关计数：每次加电增加一次计数，新硬盘应小于10次；
> * **g-sensor error rate** 坠落计数：异常加速度（例如坠落，抛掷）计数——磁头会立即回到landing zone，并增加一次计数；
> * **power-off retract count** 异常断电次数：磁头在断电前没有完全回到landing zone的次数，每次异常断电则增加一次计数；
> * **load/unload cycle count** 磁头归位次数：指工作时，磁头每次回归landing zone的次数。（ps：流言说某个linux系统——不点名，在使用电池时候，会不断强制磁头归为，而磁头归位次数最大值约为600k次，所以认为linux会损坏硬盘，实际上不是这样的）；
> * **temperature** 温度：没嘛好说的，硬盘温度而已，理论上比工作环境高不了几度。（sudo hddtemp /dev/sda）
> * **reallocetion event count** 重映射扇区操作次数：上边的重映射扇区还记得吧？这个就是操作次数，成功的，失败的都计数。成功好说，也许硬盘有救，失败了，也许硬盘就要报废了；
> * **current pending sector count** 待映射扇区数：出现异常的扇区数量，待被映射的扇区数量。 如果该异常扇区之后成功读写，则计数会减小，扇区也不会重新映射。读错误不会重新映射，只有写错误才会重新映射；
> * **uncorrectable sector count** 不可修复扇区数：所有读/写错误计数，非0就证明有坏道，硬盘报废；

### 对于SSD硬盘，需要关注的几个参数

SSD磨损数据分析：
SLC的SSD可以擦除10万次，MLC的SSD可以擦除1万次

**Media Wearout Indicator**

定义：表示SSD上NAND的擦写次数的程度，初始值为100，随着擦写次数的增加，开始线性递减，递减速度按照擦写次数从0到最大的比例。一旦这个值降低到1，就不再降了，同时表示SSD上面已经有NAND的擦写次数到达了最大次数。这个时候建议需要备份数据，以及更换SSD。

解释：直接反映了SSD的磨损程度，100为初始值，0为需要更换，有点类似游戏中的血点。

结果：磨损1点

**Re-allocated Sector Count**

定义：出厂后产生的坏块个数，如果有坏块，从1开始增加，每4个坏块增加1

解释：坏块的数量间接反映了SSD盘的健康状态。

结果：基本上都为0

**Host Writes Count**

定义：主机系统对SSD的累计写入量，每写入65536个扇区raw value增加1

解释：SSD的累计写入量，写入量越大，SSD磨损情况越严重。每个扇区大小为512bytes，65536个扇区为32MB

结果：单块盘40T

**Timed Workload Media Wear**

定义：表示在一定时间内，盘片的磨损比例，比Media Wearout Indicator更精确。

解释：可以在测试前清零，然后测试某段时间内的磨损数据，这个值的1点相当于Media Wearout Indicator的1/100，测试时间必须大于60分钟。另外两个相关的参数：Timed Workload Timer表示单次测试时间，Timed Workload Host Read/Write Ratio表示读写比例。

**Available_Reservd_Space**

SSD上剩余的保留空间, 初始值为100，表示100%，阀值为10，递减到10表示保留空间已经不能再减少

## MegaCli

查看media error, other error

## LSIUtil

查看磁盘的物理位置，error检测

## lsblk


# 磁盘扩展

## Linux下xfs扩展

XFS是一个开源的（GPL）日志文件系统，最初由硅谷图形（SGI）开发，现在大多数的Linux发行版都支持。事实上，XFS已被最新的CentOS/RHEL 7采用，成为其默认的文件系统。在其众多的特性中，包含了“在线调整大小”这一特性，使得现存的XFS文件系统在已经挂载的情况下可以进行扩展。

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
将磁盘(/dev/sdb)进行扩展后,扩展磁盘的方式比如虚拟机对虚拟磁盘进行扩展或isics对存储进行扩展，磁盘扩展后，我们还需要对文件系统进行扩展(/mnt)

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
大功告成，如果`xfs_growfs` 不加任何参数，则会对指定挂载目录自动扩展XFS文件系统到最大的可用大小。`-D`参数可以设置为指定大小
