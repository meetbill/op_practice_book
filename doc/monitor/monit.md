## 目录

<!-- vim-markdown-toc GFM -->
* [概述](#概述)
* [常用操作](#常用操作)
    * [支持命令行的选项](#支持命令行的选项)
    * [命令行参数](#命令行参数)
* [配置文件](#配置文件)
    * [日志](#日志)
    * [守护进程模式](#守护进程模式)
    * [Init 支持](#init-支持)
    * [包含文件](#包含文件)
* [管理工具](#管理工具)

<!-- vim-markdown-toc -->

### 概述

**Monit** 是 Unix 系统中用于管理和监控进程、程序、文件、目录和文件系统的工具。使用 Monit 可以检测进程是否正常运行，如果异常可以自动重启服务以及报警，当然，也可以使用 Monit 检查文件和目录是否发生修改，例如时间戳、校验和以及文件大小的改变。

> * 官方网址：http://mmonit.com/monit/
> * 源代码包：http://mmonit.com/monit/dist/
> * 二进制包：http://mmonit.com/monit/dist/binary/

### 常用操作

**Monit** 默认的配置文件是`~/.monitrc`，如果没有该文件，则使用`/etc/monitrc`文件。在启动 Monit 的时候，可以指定使用的配置文件：

    $ monit -c /var/monit/monitrc

在第一次启动 **monit** 的使用，可以使用如下命令测试配置文件（控制文件）是否正确

    $ monit -t
    $ Control file syntax OK

如果配置文件没有问题的话，就可以使用`monit`命令启动 **monit** 了。

    $ monit

> 当启动 **monit** 的时候，可以使用命令行选项控制它的行为，命令行提供的选项优先于配置文件中的配置。

#### 支持命令行的选项

下列是 **monit** 支持的选项

- **-c** 指定要使用的配置文件
- **-d n** 每隔 n 秒以守护进程的方式运行 monit 一次，在配置文件中使用 [`set daemon`] 进行配置
- **-g name** 设置用于`start`, `stop`, `restart`, `monitor`, `unmonitor`动作的组名
- **-l logfile** 指定日志文件，[`set logfile`]
- **-p pidfile** 在守护进程模式使用锁文件，配置文件中使用 [`set pidfile`] 指令
- **-s statefile** 将状态信息写入到该文件，[`set statefile`]
- **-I** 不要以后台模式运行（需要从 init 运行）
- **-i** 打印 monit 的唯一 ID
- **-r** 重置 monit 的唯一 ID
- **-t** 检查配置文件语法是否正确
- **-v** 详细模式，会输出针对信息
- **-vv** 非常详细的模式，会打印出现错误的堆栈信息
- **-H [filename]** 打印文件的 MD5 和 SHA1 哈希值 Print MD5 and SHA1，如果没有提供文件名，则为标准输入
- **-V** 打印版本号
- **-h** 打印帮助信息

#### 命令行参数

当 **Monit** 以守护进程运行的时候，可以使用下列的参数连接它的守护进程（默认是 TCP 的 127.0.0.1:2812）使其执行请求的操作。

- `start all`

    启动配置文件中列出的所有的服务并且监控它们，如果使用`-g`选项提供了组选项，则只对该组有效。

- `start name`

    启动指定名称的服务并对其监控，服务名为配置文件中配置的服务条目名称。

- `stop all`

    与`start all`相对。

- `stop name`

    与`start name`相对。

- `restart all`

    重启所有的 service

- `restart name`

    重启指定 service

- `monitor all`

    允许对配置文件中所有的服务进行监控

- `monitor name`

    允许对指定的 service 监控

- `unmonitor all`

    与`monitor all` 相对

- `unmonitor name`

    与`monitor name`相对

- `status`

    打印每个服务的状态信息

- `reload`

    重新初始化 Monitor 守护进程，守护进程将会重载配置文件以及日志文件

- `quit`

    关闭所有`monitor`进程

- `validate`

    检查所有配置文件中的服务，当 Monitor 以守护进程运行的时候，这是默认的动作

- `procmatch regex`

    对符合指定模式的进程进行简单测试，该命令接受正则表达式作为参数，并且显示出符合该模式的所有进程。

### 配置文件

**Monit** 的配置文件叫做`monitrc`文件。默认为`~/.monitrc`文件，如果该文件不存在，则尝试`/etc/monitrc`文件，然后是`@sysconfdir@/monitrc`，最后是`./monitrc`文件。

> 这里所说的配置文件实际上就是控制文件（control file）

**Monit** 使用它自己的领域语言 (DSL) 进行配置，配置文件包含一系列的服务条目和全局配置项。

在语意上，配置文件包含以下三部分：

- 全局 set 指令

	该指令以`set`开始，后面跟着配置项

- 全局 include 指令

	该指令以`include`开头，后面是 glob 字符串，指定了要包含的配置文件位置

- 一个或多个服务条目指令

	每一个服务条目包含关键字`check`，后面跟着服务类型。每一条后面都需要跟着一个唯一的服务标识名称。monit 使用这个名称来引用服务以及与用户进行交互。

当前支持九种类型的`check`语句：

1. `CHECK PROCESS <unique name> <PIDFILE <path> | MATCHING <regex>>`

	这里的`PIDFILE`是进程的 PID 文件的绝对路径，如果 PID 文件不存在，如果定义了进程的 start 方法的话，会调用该方法。

	`MATCHING`是可选的指定进程的方式，使用名称规则指定进程。

2. `CHECK FILE <unique name> PATH <path>`

	检查文件是否存在，如果指定的文件不存在，则调用 start 方法。

3. `CHECK FIFO <unique name> PATH <path>`
4. `CHECK FILESYSTEM <unique name> PATH <path>`
5. `CHECK DIRECTORY <unique name> PATH <path>`
6. `CHECK HOST <unique name> ADDRESS <host address>`
7. `CHECK SYSTEM <unique name>`
8. `CHECK PROGRAM <unique name> PATH <executable file> [TIMEOUT <number> SECONDS]`
9. `CHECK NETWORK <unique name> <ADDRESS <ipaddress> | INTERFACE <name>>`


#### 日志

**Monit** 将会使用日志文件记录运行状态以及错误消息，在配置文件中使用`set logfile`指令指定日志配置。

如果希望使用自己的日志文件，使用下列指令：

	set logfile /var/log/monit.log

如果要使用系统的 syslog 记录日志，使用下列指令：

	set logfile syslog

如果不想开启日志功能，只需要注释掉该指令即可。

日志文件的格式为：

	[date] priority : message

例如：

	[CET Jan  5 18:49:29] info : 'mymachine' Monit started


#### 守护进程模式

    set daemon n (n 的单位是秒）

指定 Monit 在后台轮询检查进程运行状态的时间。你可以使用命令行参数`-d`选项指定这个时间，当然，建议在配置文件中进行设置。

Monit 应该总是以后台的守护进程模式运行，如果你不指定该选项或者是命令行的`-d`选项，则只会在运行 Monit 的时候对它监控的文件或者进程检查一次然后退出。

#### Init 支持

配置`set init`可以防止 monit 将自身转化为守护进程模式，它可以让前台进程运行。这需要从 init 运行 monit，另一种方式是使用 crontab 定时任务运行，当然这样的话你需要在运行前使用`monit -t`检查一下控制文件是否存在语法错误。

要配置 monit 从 init 运行，可以在 monit 的配置文件中使用`set init`指令或者命令行中使用`-I`选项，以下是需要在`/etc/inittab`文件中增加的配置。

    # Run Monit in standard run-levels
    mo:2345:respawn:/usr/local/bin/monit -Ic /etc/monitrc

> inittab 文件格式：`id:runlevels:action:process`
> 该行配置是为 Monit 指定了 id 为 mo，运行级别 2-5 有效，`respawn`指明了无论进程是否已经运行，都对进程 restart

在修改完 init 配置文件后，可以使用如下命令测试`/etc/inittab`文件并运行 Monit:

	telinit q

> `telinit q` 用于重载守护进程的配置，等价于`systemctl daemon-reload`

对于没有`telinit`的系统，执行如下命令：

	kill -1 1

如果 Monit 已经系统启动的时候运行对服务进行监控，在某些情况下，可能会出现竞争。也就是说如果一个服务启动的比较慢，Monit 会假设该服务没有运行并且可能会尝试启动该服务和报警，但是事实上该服务正在启动中或者已经在启动队列里了。

#### 包含文件

	include globstring

例如`include /etc/monit.d/*.cfg`会将`/etc/monit.d/`目录下所有的`.cfg`文件包含到配置文件中。

### 管理工具

[monit_manager](https://github.com/meetbill/monit_manager)

------

原文：[monit 官方文档 Version](https://mmonit.com/monit/documentation/)
