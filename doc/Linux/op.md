# 常用问题处理及运维工具


<!-- vim-markdown-toc GFM -->
* [Yum 安装安装包时提示证书过期](#yum-安装安装包时提示证书过期)
* [系统日志中的时间不准确](#系统日志中的时间不准确)
* [lvm 变为 inactive 状态](#lvm-变为-inactive-状态)
* [排查 java CPU 性能问题](#排查-java-cpu-性能问题)
    * [用法](#用法)
    * [示例](#示例)
    * [贡献者](#贡献者)

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


## 排查 java CPU 性能问题

[show-busy-java-threads.sh](https://github.com/BillWang139967/op_practice_code/blob/master/Linux/op/show-busy-java-threads.sh)
```
curl -o show-busy-Java-threads.sh https://raw.githubusercontent.com/BillWang139967/op_practice_code/master/Linux/op/show-busy-java-threads.sh
```

用于快速排查`Java`的`CPU`性能问题(`top us`值过高)，自动查出运行的`Java`进程中消耗`CPU`多的线程，并打印出其线程栈，从而确定导致性能问题的方法调用。

PS，如何操作可以参见[@bluedavy](http://weibo.com/bluedavy)的《分布式Java应用》的【5.1.1 cpu消耗分析】一节，说得很详细：

1. `top`命令找出有问题`Java`进程及线程`id`：
    1. 开启线程显示模式
    1. 按`CPU`使用率排序
    1. 记下`Java`进程`id`及其`CPU`高的线程`id`
1. 用进程`id`作为参数，`jstack`有问题的`Java`进程
1. 手动转换线程`id`成十六进制（可以用`printf %x 1234`）
1. 查找十六进制的线程`id`（可以用`grep`）
1. 查看对应的线程栈

查问题时，会要多次这样操作以确定问题，上面过程**太繁琐太慢了**。

### 用法

```bash
show-busy-java-threads.sh
# 从 所有的 Java进程中找出最消耗CPU的线程（缺省5个），打印出其线程栈。

show-busy-java-threads.sh -c <要显示的线程栈数>

show-busy-java-threads.sh -c <要显示的线程栈数> -p <指定的Java Process>

##############################
# 注意：
##############################
# 如果Java进程的用户 与 执行脚本的当前用户 不同，则jstack不了这个Java进程。
# 为了能切换到Java进程的用户，需要加sudo来执行，即可以解决：
sudo show-busy-java-threads.sh
```

### 示例

```bash
$ show-busy-java-threads.sh
[1] Busy(57.0%) thread(23355/0x5b3b) stack of java process(23269) under user(admin):
"pool-1-thread-1" prio=10 tid=0x000000005b5c5000 nid=0x5b3b runnable [0x000000004062c000]
   java.lang.Thread.State: RUNNABLE
    at java.text.DateFormat.format(DateFormat.java:316)
    at com.xxx.foo.services.common.DateFormatUtil.format(DateFormatUtil.java:41)
    at com.xxx.foo.shared.monitor.schedule.AppMonitorDataAvgScheduler.run(AppMonitorDataAvgScheduler.java:127)
    at com.xxx.foo.services.common.utils.AliTimer$2.run(AliTimer.java:128)
    at java.util.concurrent.ThreadPoolExecutor$Worker.runTask(ThreadPoolExecutor.java:886)
    at java.util.concurrent.ThreadPoolExecutor$Worker.run(ThreadPoolExecutor.java:908)
    at java.lang.Thread.run(Thread.java:662)

[2] Busy(26.1%) thread(24018/0x5dd2) stack of java process(23269) under user(admin):
"pool-1-thread-2" prio=10 tid=0x000000005a968800 nid=0x5dd2 runnable [0x00000000420e9000]
   java.lang.Thread.State: RUNNABLE
    at java.util.Arrays.copyOf(Arrays.java:2882)
    at java.lang.AbstractStringBuilder.expandCapacity(AbstractStringBuilder.java:100)
    at java.lang.AbstractStringBuilder.append(AbstractStringBuilder.java:572)
    at java.lang.StringBuffer.append(StringBuffer.java:320)
    - locked <0x00000007908d0030> (a java.lang.StringBuffer)
    at java.text.SimpleDateFormat.format(SimpleDateFormat.java:890)
    at java.text.SimpleDateFormat.format(SimpleDateFormat.java:869)
    at java.text.DateFormat.format(DateFormat.java:316)
    at com.xxx.foo.services.common.DateFormatUtil.format(DateFormatUtil.java:41)
    at com.xxx.foo.shared.monitor.schedule.AppMonitorDataAvgScheduler.run(AppMonitorDataAvgScheduler.java:126)
    at com.xxx.foo.services.common.utils.AliTimer$2.run(AliTimer.java:128)
    at java.util.concurrent.ThreadPoolExecutor$Worker.runTask(ThreadPoolExecutor.java:886)
    at java.util.concurrent.ThreadPoolExecutor$Worker.run(ThreadPoolExecutor.java:908)
...
```

上面的线程栈可以看出，`CPU`消耗最高的2个线程都在执行`java.text.DateFormat.format`，业务代码对应的方法是`shared.monitor.schedule.AppMonitorDataAvgScheduler.run`。可以基本确定：

- `AppMonitorDataAvgScheduler.run`调用`DateFormat.format`次数比较频繁。
- `DateFormat.format`比较慢。（这个可以由`DateFormat.format`的实现确定。）

多个执行几次`show-busy-java-threads.sh`，如果上面情况高概率出现，则可以确定上面的判定。  
\# 因为调用越少代码执行越快，则出现在线程栈的概率就越低。

分析`shared.monitor.schedule.AppMonitorDataAvgScheduler.run`实现逻辑和调用方式，以优化实现解决问题。

### 贡献者

- [oldratlee](https://github.com/oldratlee)
- [silentforce](https://github.com/silentforce)改进此脚本，增加对环境变量`JAVA_HOME`的判断。 #15
- [liuyangc3](https://github.com/liuyangc3)
    - 优化性能，通过`read -a`简化反复的`awk`操作 #51
    - 发现并解决`jstack`非当前用户`Java`进程的问题 #50
