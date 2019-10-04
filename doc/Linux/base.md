## Linux 基础

<!-- vim-markdown-toc GFM -->

* [安装](#安装)
    * [安装准备](#安装准备)
    * [安装 CentOS6.8](#安装-centos68)
    * [系统安装后的配置](#系统安装后的配置)
* [Bash 基础特性](#bash-基础特性)
    * [命令历史](#命令历史)
    * [命令补全](#命令补全)
    * [路径补全](#路径补全)
    * [命令行展开](#命令行展开)
    * [命令的执行状态结果](#命令的执行状态结果)
    * [命令别名](#命令别名)
    * [通配符 glob](#通配符-glob)
    * [bash 快捷键](#bash-快捷键)
        * [编辑命令](#编辑命令)
        * [重新执行命令](#重新执行命令)
        * [控制命令](#控制命令)
        * [Bang (!) 命令](#bang--命令)
        * [友情提示](#友情提示)
    * [bash 的 io 重定向及管道](#bash-的-io-重定向及管道)
        * [I/O 重定向](#io-重定向)
* [Linux 常用命令](#linux-常用命令)
    * [系统](#系统)
        * [系统信息](#系统信息)
        * [关机](#关机)
        * [监视和调试](#监视和调试)
        * [公钥私钥](#公钥私钥)
        * [其他](#其他)
    * [资源](#资源)
        * [磁盘空间](#磁盘空间)
    * [文件及文本处理](#文件及文本处理)
        * [文件和目录](#文件和目录)
        * [文件搜索](#文件搜索)
        * [文件的权限](#文件的权限)
        * [文件的特殊属性](#文件的特殊属性)
        * [查看文件内容](#查看文件内容)
        * [文本处理](#文本处理)
        * [字符设置和文件格式](#字符设置和文件格式)
    * [挂载](#挂载)
        * [挂载一个文件系统](#挂载一个文件系统)
        * [光盘](#光盘)
    * [用户管理](#用户管理)
        * [用户和群组](#用户和群组)
    * [包管理](#包管理)
        * [打包和压缩文件](#打包和压缩文件)
        * [RPM 包 \(Fedora,RedHat and alike\)](#rpm-包-fedoraredhat-and-alike)
        * [YUM 软件工具 \(Fedora,RedHat and alike\)](#yum-软件工具-fedoraredhat-and-alike)
        * [备份](#备份)
    * [磁盘和分区](#磁盘和分区)
        * [文件系统分析](#文件系统分析)
        * [初始化一个文件系统](#初始化一个文件系统)
        * [SWAP 文件系统](#swap-文件系统)
    * [网络](#网络)
        * [网络 \(LAN / WiFi\)](#网络-lan--wifi)
        * [route 设置](#route-设置)
            * [基本使用](#基本使用)
            * [在 linux 下设置永久路由的方法](#在-linux-下设置永久路由的方法)
        * [Microsoft windows 网络 \(samba\)](#microsoft-windows-网络-samba)
        * [IPTABLES \(firewall\)](#iptables-firewall)
* [Linux 简单管理](#linux-简单管理)
    * [ssh](#ssh)
        * [ssh 简介及基本操作](#ssh-简介及基本操作)
            * [简介](#简介)
            * [密钥](#密钥)
            * [基于口令的安全验证通讯原理](#基于口令的安全验证通讯原理)
            * [StrictHostKeyChecking 和 UserKnownHostsFile](#stricthostkeychecking-和-userknownhostsfile)
        * [基于密匙的安全验证通讯原理](#基于密匙的安全验证通讯原理)
        * [SSH 端口转发](#ssh-端口转发)
            * [SSH 正向连接](#ssh-正向连接)
            * [SSH 反向连接](#ssh-反向连接)
            * [SSH 反向连接自动重连](#ssh-反向连接自动重连)
        * [windows 下 xshell 使用](#windows-下-xshell-使用)
    * [用户管理](#用户管理-1)
        * [Linux 踢出其他正在 SSH 登陆用户](#linux-踢出其他正在-ssh-登陆用户)
        * [使用脚本创建有 sudo 权限的用户](#使用脚本创建有-sudo-权限的用户)
        * [无交互式修改用户密码](#无交互式修改用户密码)
    * [网卡 bond](#网卡-bond)
    * [其他设置](#其他设置)
        * [时区及时间](#时区及时间)
            * [UTC 和 GMT](#utc-和-gmt)
            * [Linux 下调整时区及更新时间](#linux-下调整时区及更新时间)
        * [登录提示信息](#登录提示信息)
            * [修改登录前的提示信息](#修改登录前的提示信息)
        * [修改登录成功后的信息](#修改登录成功后的信息)
* [CentOS 7 vs CentOS 6 的不同](#centos-7-vs-centos-6-的不同)
    * [运行相关](#运行相关)
    * [网络](#网络-1)

<!-- vim-markdown-toc -->

# 安装

CentOS 6.x

## 安装准备
    1. 下载安装镜像文件
    http://www.centos.org   ->downloads->mirrors
    http://mirrors.aliyun.com/centos/6.8/isos/x86_64/
    http://mirrors.aliyun.com/centos/6.8/isos/i386/
    主要下载 Centos-6.8-x86_64-bin-DVD1.iso 和 Centos-6.8-x86_64-bin-DVD2.iso

## 安装 CentOS6.8

***选择系统引导方式***

    选择 install or upgrade an existing system

***检查安装光盘介质***

    选择：skip

***选择安装过程语言***

    选择：english

***选择键盘布局***

    选择：U.S.English

***选择合适的物理设备***

    选择：basic storage devices

***初始化硬盘提示***

    选择：yes ,discard and data

***初始化主机名以及网络配置***

    （1）. 为系统设置主机名  主机名为：meetbill
    （2）. 配置网卡及连接网络（可选）

***系统时钟及时区***

    选择：Asia/Shanghai
    取消：system clock uses UTC
    然后：next

***设置 root 口令***

***磁盘分区类型选择与磁盘分区配置过程***

(1) 选择系统安装磁盘空间类型

    选择：create custom layout

(2) 进入 'create custom layout'分区界面

    可以 create （创建）,update（修改） ,delete（删除）等操作。

(3) 按企业生产标准定制磁盘分区

    选择：standard partition
    1）. 创建引导分区，/boot 分区
    mount point:/boot
    file system type:ext4
    size:200

    2）. 创建 swap 交换分区
    mount point :<not applicable>
    file system type:swap
    size:1024 （物理内存的 1-2 倍）
    addtion size options : fixed size
    force to be a primary partition

    3). 创建 ( / ) 根分区
    mount point :/
    file system type : ext4
    size : 剩余
    addtion size options : fill to maximum allowable size  （根分区是最后一个分区，所以把剩余的空间都分配给根分区）
    force to be a primary partition

    4). 格式化警告
    选择： format

***系统安装包的选择与配置***

(1) 启动引导设备的配置
    系统默认使用 GRUB 作为启动加载器，引导程序默认在 MBR 下：
    ```
    install boot loader on /dev/sda ->change device
    选择 master boot record -/dev/sda
    [选择的是操作系统所在的那个设备，如 /dev/sda]

    Boot Loader operation system list
    列表中选择的是操作系统根目录 / 所在的分区，如 CentOS /dev/sda4

    ```
(2) 系统安装类型选择及自定义额外包组
    系统默认是 desktop ，但是这里选择 minimal。
    自定义安装包选择：customsize now
    base system :
        base
    然后：next

***开始安装 ->安装完成 ->reboot***

## 系统安装后的配置

***更新系统，打补丁到最新***

    修改更新 yum 源：
    cp  /etc /yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.ori
    wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirros.163.com/.help/CentOS 6-Base-163.repo
    ll /etc/pki/rpm-gpg/
    rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY*
    yum update -y

    ps: 一般在首次安装时执行 yum update -y , 如果是在实际生产环境中，切记使用，以免导致异常。

***安装额外的软件包***

    yum install tree telnet dos2unix sysstat lrzsz nc nmap -y
    yum grouplist    #查看包组列表
    yum frouplist "development Tools"

# Bash 基础特性
## 命令历史
(1)  使用命令：history

(2)  环境变量：

        a) HISTSIZE：命令历史缓冲区中记录的条数，默认为 1000；

        b) HISTFILE：记录当前登录用户在 logout 时历史命令存放文件；

        c) HISTFILESIZE：命令历史文件记录历史的条数，默认为 1000；
(3)  操作命令历史：

        a) history –d OFFSET 删除指定行的命令历史；

        b) history –c 清空命令历史缓冲区中的命令；

        c) history # 显示历史中最近的#条命令；

        d) history –a 手动追加当前会话缓冲区中的命令至历史文件中；
(4) 调用历史中的命令：

        a) !# : 重复执行第#条命令；

        b) !! : 重复执行上一条（最近一条命令；)

        c) !string : 重复执行最近一次以指定字符串开头的命令；

        d) 调用上一条命令的最后一个参数：

             i. !$

             ii. ESC, ．

(5) 控制命令历史的记录方式：

        环境变量：HISTCONTROL

        三个值：

            ignoredups：忽略重复的命令；所谓重复，一定是连续且完全相同，包括选项和参数；

            ignorespace：忽略所有以空白开头的命令，不记录；

            ignoreboth：忽略上述两项，既忽略重复的命令，也忽略空白开头的命令；

- 修改环境变量的方式：

         export 变量名 =“VALUE”

         或： VARNAME=“VALUE” export VARNAME

## 命令补全

内部命令：直接通过 shell 补全；
外部命令：bash 根据 PATH 环境变量定义的路径，自左而右地在每个路径搜寻以给定命令命名的文件，第一次找到即为要执行的命令；
- Note: 在第一次通过 PATH 搜寻到命令后，会将其存入 hash 缓存中，下次使用不再搜寻 PATH，从 hash 中查找；

```
[root@sslinux ~]# hash
hits command
 1 /usr/sbin/ifconfig
 1 /usr/bin/vim
 1 /usr/bin/ls

```

Tab 键补全：
若用户给出的字符在命令搜索路径中有且仅有一条命令与之相匹配，则 Tab 键直接补全；

若用户输入的字符在命令搜索路径中有多条命令与之相匹配，则再次 Tab 键可以将这些命令列出；

## 路径补全

以用户输入的字符串作为路径开头，并在其指定路径的上级目录下搜索以指定字符串开头的文件名；

    如果唯一，则直接补全；

    否则，再次 Tab，列出所有符合条件的路径及文件；

## 命令行展开

1）~ ：展开为用户的主目录；
~~~shell
[root@sslinux log]# pwd
/var/log
[root@sslinux log]# cd ~
[root@sslinux ~]# pwd
/root
~~~
2）~USERNAME ： 展开为指定用户的主目录；
~~~shell
[root@sslinux ~]# pwd
/root
[root@sslinux ~]# cd ~sslinux
[root@sslinux sslinux]# pwd
/home/sslinux
~~~

3） {} ： 可承载一个以逗号分隔的列表，并将其展开为多个路径；
~~~shell
[root@localhost test]# ls
[root@localhost test]# mkdir -pv ./tmp/{a,b}/shell
mkdir: created directory `./tmp'
mkdir: created directory `./tmp/a'
mkdir: created directory `./tmp/a/shell'
mkdir: created directory `./tmp/b'
mkdir: created directory `./tmp/b/shell'
[root@localhost test]# mkdir -pv ./tmp/{tom,johnson}/hi
[root@localhost test]# tree .

└── tmp
 ├── a
 │ └── shell
 ├── b
 │ └── shell
 ├── johnson
 │ └── hi
 └── tom
 └── hi
9 directories, 0 files
~~~


## 命令的执行状态结果
表示命令是否成功执行；

bash 使用特殊变量 $? 保存最近一条命令的执行状态结果；

- 环境变量 $? 的取值：

     0 ： 成功；

     1-255：失败，1,127,255 为系统保留；

-  程序执行有两类结果：

     程序的返回值；程序自身执行的输出结果；

     程序的执行状态结果；$?

~~~shell
[root@localhost test]# ls /etc/sysconfig/

[root@localhost test]# echo $?

0    #程序的执行状态结果；执行成功；

[root@localhost test]# ls /etc/sysconfig/NNNN

ls: cannot access /etc/sysconfig/NNNN: No such file or directory    #程序自身的执行结果；

[root@localhost test]# echo $?

2    #执行失败；

~~~

## 命令别名
- 通过 alias 命令实现：

a、alias ： 显示当前 shell 进程所有可用的命令别名；

b、定义别名，格式为： alias NAME='VALUE'

	定义别名 NAME，其执行相当于执行命令 VALUE，VALUE 中可包含命令、选项以及参数；仅当前会话有效，不建议使用；

c、通过修改配置文件定义命令别名：

    当前用户：~/.bashrc
    全局用户：/etc/bashrc

- Bash 进程重新读取配置文件：
~~~shell
    source /path/to/config_file

    . /path/to/config_file
~~~
- 撤销别名： unalias
```
    unalias [-a] name [name...]
```
- Note:

    对于定义了别名的命令，要使用原命令，可通过、COMMAND 的方式使用；

- Example:

```
[root@sslinux sslinux]# alias
alias cp='cp -i'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'
alias grep='grep --color=auto'
alias l.='ls -d .* --color=auto'
alias ll='ls -l --color=auto'
alias ls='ls --color=auto'
alias mv='mv -i'
alias rm='rm -i'
alias which='alias | /usr/bin/which --tty-only --read-alias --show-dot --show-tilde'
[root@sslinux sslinux]# grep alias /root/.bashrc
### User specific aliases and functions
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'
```

## 通配符 glob

Bash 中用于文件名"通配"

- 通配符： *,?,[]

    1) * 任意长度的任意字符；

        a * b
        ```
        [root@sslinux sslinux]# ls -ld /etc/au*
        drwxr-x---. 3 root root 41 Sep 3 22:05 /etc/audisp
        drwxr-x---. 3 root root 79 Sep 3 22:09 /etc/audit
        ```

2)  ? 任意单个字符；

       	 	a?b

~~~shell
[root@sslinux sslinux]# ls -ld /etc/*d?t
drwxr-x---. 3 root root 79 Sep 3 22:09 /etc/audit
~~~

3)  []   匹配指定范围内的任意单个字符；

        [0-9]    [a-z]   不区分大小写；
        [admin]    可以是区间形式的，也可以是离散形式的；
~~~shell
[root@sslinux sslinux]# ls -ld /etc/[ab]*
drwxr-xr-x. 2 root root 4096 Sep 3 22:05 /etc/alternatives
drwxr-xr-x. 2 root root 33 Sep 3 22:04 /etc/avahi
drwxr-xr-x. 2 root root 33 Sep 3 22:04 /etc/bash_completion.d
-rw-r--r--. 1 root root 2835 Oct 29 2014 /etc/bashrc
drwxr-xr-x. 2 root root 6 Mar 6 2015 /etc/binfmt.d
~~~

  4)   [^] 匹配指定范围以外的任意单个字符；

```
        [^0-9] : 单个非数字的任意字符；
```
- 专用字符结合：（表示一类字符中的单个）

[:digit:] 任意单个数字，相当于 [0-9];

[:lower:] 任意单个小写字母；

[:upper:] 任意单个大写字母；

[:alpha:] 任意单个大小写字母；

[:alnum:] 任意单个数字或字母；

[:space:] 任意空白字符；

[:punct:] 任意单个特殊字符；

- Note：

在使用 [] 应用专用字符集合时，外层也需要嵌套 []。

Example：

```
# ls -d /etc/*[[:digit:]]*[[:lower:]]
```

## bash 快捷键

### 编辑命令
- Ctrl + a ：移到命令行首
- Ctrl + e ：移到命令行尾
- Ctrl + f ：按字符前移（右向）
- Ctrl + b ：按字符后移（左向）
- Alt + f ：按单词前移（右向）
- Alt + b ：按单词后移（左向）
- Ctrl + xx：在命令行首和光标之间移动
- Ctrl + u ：从光标处删除至命令行首
- Ctrl + k ：从光标处删除至命令行尾
- Ctrl + w ：从光标处删除至字首
- Alt + d ：从光标处删除至字尾
- Ctrl + d ：删除光标处的字符
- Ctrl + h ：删除光标前的字符
- Ctrl + y ：粘贴至光标后
- Alt + c ：从光标处更改为首字母大写的单词
- Alt + u ：从光标处更改为全部大写的单词
- Alt + l ：从光标处更改为全部小写的单词
- Ctrl + t ：交换光标处和之前的字符
- Alt + t ：交换光标处和之前的单词
- Alt + Backspace：与 Ctrl + w 相同类似，分隔符有些差别

### 重新执行命令
- Ctrl + r：逆向搜索命令历史
- Ctrl + g：从历史搜索模式退出
- Ctrl + p：历史中的上一条命令
- Ctrl + n：历史中的下一条命令
- Alt + .：使用上一条命令的最后一个参数

### 控制命令
- Ctrl + l：清屏
- Ctrl + o：执行当前命令，并选择上一条命令
- Ctrl + s：阻止屏幕输出
- Ctrl + q：允许屏幕输出
- Ctrl + c：终止命令
- Ctrl + z：挂起命令

### Bang (!) 命令
- !!：执行上一条命令
- !blah：执行最近的以 blah 开头的命令，如 !ls
- !blah:p：仅打印输出，而不执行
- !$：上一条命令的最后一个参数，与 Alt + . 相同
- !$:p：打印输出 !$ 的内容
- !*：上一条命令的所有参数
- !*:p：打印输出 !* 的内容
- ^blah：删除上一条命令中的 blah
- ^blah^foo：将上一条命令中的 blah 替换为 foo
- ^blah^foo^：将上一条命令中所有的 blah 都替换为 foo

### 友情提示

    以上介绍的大多数 Bash 快捷键仅当在 emacs 编辑模式时有效，

    若你将 Bash 配置为 vi 编辑模式，那将遵循 vi 的按键绑定。

    Bash 默认为 emacs 编辑模式。

    如果你的 Bash 不在 emacs 编辑模式，可通过 set-o emacs 设置。

    ^S、^Q、^C、^Z 是由终端设备处理的，可用 stty 命令设置。

## bash 的 io 重定向及管道
打开的文件都有一个 fd：file descriptor（文件描述符）

    标准输入：keyboard，0

    标准输出：monitor，1

    标准错误输出：monitor，2

### I/O 重定向

- 输出重定向：

     COMMAND > NEW_POS 覆盖重定向，目标文件中的原有内容会被清除；

     COMMAND >> NEW_POS 追加重定向，新内容会被追加到目标文件尾部；

- Note：

    为了在输出重定向时防止覆盖原有文件，建议使用以下设置：

    set –C ： 禁止将内容覆盖输出 (>) 至已有文件中，追加输出不受影响；

    此时，若确定要将重定向的内容覆盖原有文件，可使用 >| 强制覆盖；

- Example:
~~~shell
[root@localhost test1]# echo "It's dangerous" > ./result.txt #输出到文件；
[root@localhost test1]# cat result.txt
It's dangerous
[root@localhost test1]# set –C #禁止将内容覆盖输出到已有文件；
[root@localhost test1]# echo "It's very dangerous" > ./result.txt
-bash: ./result.txt: cannot overwrite existing file #提示不能覆盖已存在文件；
[root@localhost test1]# echo "It's very dangerous" >| ./result.txt #强制覆盖
[root@localhost test1]#
[root@localhost test1]# set +C #取消禁止覆盖输出到已有文件；
[root@localhost test1]# echo "It's very dangerous" > ./result.txt
[root@localhost test1]#
~~~

- 错误输出：

     2> : 覆盖重定向错误输出数据流；

     2>> ：追加重定向错误输出数据流；
~~~shell
[root@localhost test1]# lss -l /etc/ 2> ./error.txt
[root@localhost test1]# cat error.txt
-bash: lss: command not found
[root@localhost test1]# cat /etc/passwd.error 2>> ./error.txt
[root@localhost test1]# cat error.txt
-bash: lss: command not found
cat: /etc/passwd.error: No such file or directory
~~~

将标准输出和标准错误输出各自重定向至不同位置：

     COMMAND > /path/to/file.out 2> /path/to/error.out

- Example:
```
# cat /etc/passwd > ./file.out 2> ./error.out
```
- 合并输出：

     合并标准输出和错误输出为同一个数据流进行重定向；(PS:重定向命令是倒序操作的，如 > file 2>&1 是先执行 2>&1 然后执行 > file)

         &> 合并覆盖重定向；

         &>> 合并追加重定向；

    格式为：

         COMMAND > /path/to/file.out 2> &1

         COMMAND >> /path/to/file.out 2>> &1

    Example:
~~~shell
    [root@localhost test1]# ls -l /etc/ > ./file.out 2>&1
    [root@localhost test1]# ls -l /etc/ &> file.out
    [root@localhost test1]# ls -l /etcc/ &> file.out
    [root@localhost test1]# cat file.out
    ls: cannot access /etcc/: No such file or directory
~~~

- 输入重定向： <
~~~shell
     HERE Documentation：<<

     # cat << EOF

     # cat > /path/to/somefile << EOF
~~~

Example: 输入重定向，输入完成后显示内容到标准输出上；
~~~shell
[root@localhost test1]# cat << EOF
> my name is kalaguiyin.
> I'm a tibetan.
> I come from Sichuan Provence.
> EOF
my name is kalaguiyin.
I'm a tibetan.
I come from Sichuan Provence.
~~~

Example：从标准输入读取输入并重定向到文件。
~~~shell
[root@localhost test1]# cat > hello.txt << EOF
> this is a test file.
> 中华人民共和国。
> EOF
[root@localhost test1]# cat hello.txt
this is a test file.
中华人民共和国。
~~~

- 管道：

     COMMAND1 | COMMAND2 | COMMAND3 | …..

     作用：前一个命令的执行结果将作为后一个命令执行的参数；

     Note:

            最后一个命令会在当前 shell 进程的子 shell 进程中执行；
~~~shell
[root@sslinux]# cat /etc/passwd | sort -t: -k3 -n | cut -d: -f1
root
bin
daemon
adm
lp
polkitd
sslinux
~~~
# Linux 常用命令

## 系统

### 系统信息
| 命令 | 说明 |
|--------|--------|
|\# arch|显示机器的处理器架构|
|\# cal 2016|显示 2016 年的日历表|
|\# cat /proc/cpuinfo|查看 CPU 信息|
|\# cat /proc/interrupts|显示中断|
|\# cat /proc/meminfo|校验内存使用|
|\# cat /proc/swaps|显示哪些 swap 被使用|
|\# cat /proc/version|显示内核版本|
|\# cat /proc/net/dev|显示网络适配器及统计|
|\# cat /proc/mounts|显示已加载的文件系统|
|\# clock \-w|将时间修改保存到 BIOS|
|\# date|显示系统日期|
|\# date 072308302016\.00|设置日期和时间 \- 月日时分年、. 秒|
|\# dmidecode \-q|显示硬件系统部件 \- \(SMBIOS / DMI\)|
|\# hdparm \-i /dev/hda|罗列一个磁盘的架构特性|
|\# hdparm \-tT /dev/sda|在磁盘上执行测试性读取操作|
|\# lspci \-tv|罗列 PCI 设备|
|\# lsusb \-tv|显示 USB 设备|
|\# uname \-m|显示机器的处理器架构|
|\# uname \-r|显示正在使用的内核版本|

### 关机
| 命令 | 说明 |
|--------|--------|
|\# init 0|关闭系统|
|\# logout|注销|
|\# reboot|重启|
|\# shutdown \-h now|关闭系统|
|\# shutdown \-h 16:30 &|按预定时间关闭系统|
|\# shutdown \-c|取消按预定时间关闭系统|
|\# shutdown \-r now|重启|

### 监视和调试
| 命令 | 说明 |
|--------|--------|
|\# free \-m|以兆为单位罗列 RAM 状态|
|\# kill \-9 process\_id|强行关闭进程并结束它|
|\# kill \-1 process\_id|强制一个进程重载其配置|
|\# last reboot|显示重启历史|
|\# lsmod|罗列装载的内核模块|
|\# lsof \-p process\_id|罗列一个由进程打开的文件列表|
|\# lsof /home/user1|罗列所给系统路径中所打开的文件的列表|
|\# ps \-eafw|罗列 linux 任务|
|\# ps \-e \-o pid,args \-\-forest|以分级的方式罗列 linux 任务|
|\# pstree|以树状图显示程序|
|\# smartctl \-A /dev/hda|通过启用 SMART 监控硬盘设备的可靠性|
|\# smartctl \-i /dev/hda|检查一个硬盘设备的 SMART 是否启用|
|\# strace \-c ls >/dev/null|罗列系统 calls made 并用一个进程接收|
|\# strace \-f \-e open ls >/dev/null|罗列库调用|
|\# tail /var/log/dmesg|显示内核引导过程中的内部事件|
|\# tail /var/log/messages|显示系统事件|
|\# top|罗列使用 CPU 资源最多的 linux 任务|
|\# watch \-n1 'cat /proc/interrupts'|罗列实时中断|

### 公钥私钥
| 命令 | 说明 |
|--------|--------|
| \# ssh-keygen -t rsa -C "邮箱地址" | 产生公钥私钥对 |
| \# ssh-copy-id -i ~/.ssh/id_rsa.pub root@192.168.0.2  | 将本地机器的公钥复制到远程机器的 root 用户的 authorized_keys 文件中 |
| \# ssh-keygen -p -f ~/.ssh/id_rsa | 添加或修改 SSH-key 的私钥密码 |
| \# ssh-keygen -y -f ~/.ssh/id_rsa > id_rsa.pub | 从私钥中生成公钥 |

### 其他
| 命令 | 说明 |
|--------|--------|
|\# alias hh='history'|为命令 history\（历史、) 设置一个别名|
|\# gpg \-c file1|用 GNU Privacy Guard 加密一个文件|
|\# gpg file1\.gpg|用 GNU Privacy Guard 解密一个文件|
|\# ldd /usr/bin/ssh|显示 ssh 程序所依赖的共享库|
|\# man ping|罗列在线手册页（例如 ping 命令）|
|\# mkbootdisk \-\-device /dev/fd0 \`uname \-r\`|创建一个引导软盘|
|\# wget \-r www\.example\.com|下载一个完整的 web 站点|
|\# wget \-c www\.example\.com/file\.iso|以支持断点续传的方式下载一个文件|
|\# echo 'wget \-c www\.example\.com/files\.iso' &#124; at 09:00|在任何给定的时间开始一次下载|
|\# whatis \.\.\.keyword|罗列该程序功能的说明|
|\# who \-a|显示谁正登录在线，并打印出：系统最后引导的时间，关机进程，系统登录进程以及由 init 启动的进程，当前运行级和最后一次系统时钟的变化|

## 资源

### 磁盘空间
| 命令 | 说明 |
|--------|--------|
|\# df \-h|显示已经挂载的分区列表|
|\# du \-sh dir1|估算目录 'dir1' 已经使用的磁盘空间|
|\# du \-sk \* &#124; sort \-rn|以容量大小为依据依次显示文件和目录的大小|
|\# ls \-lSr &#124; more|以尺寸大小排列文件和目录|
|\# rpm \-q \-a \-\-qf '%10\{SIZE\}t%\{NAME\}n' &#124; sort \-k1,1n|以大小为依据依次显示已安装的 rpm 包所使用的空间 \(centos, redhat, fedora 类系统、)|


## 文件及文本处理

### 文件和目录
| 命令 | 说明 |
|--------|--------|
|\# cd /home|进入 '/home' 目录|
|\# cd \.\.|返回上一级目录|
|\# cd \.\./\.\.|返回上两级目录|
|\# cd|进入个人的主目录|
|\# cd ~user1|进入个人的主目录|
|\# cd \-|返回上次所在的目录|
|\# cp file1 file2|复制一个文件|
|\# cp dir/\* \.|复制一个目录下的所有文件到当前工作目录|
|\# cp \-a /tmp/dir1 \.|复制一个目录到当前工作目录|
|\# cp \-a dir1 dir2|复制一个目录|
|\# cp file file1|将 file 复制为 file1|
|\# iconv \-l|列出已知的编码|
|\# iconv \-f fromEncoding \-t toEncoding inputFile > outputFile|改变字符的编码|
|\# find \. \-maxdepth 1 \-name \*\.jpg \-print \-exec convert|batch resize files in the current directory and send them to a thumbnails directory (requires convert from Imagemagick)|
|\# ln \-s file1 lnk1|创建一个指向文件或目录的软链接|
|\# ln file1 lnk1|创建一个指向文件或目录的物理链接|
|\# ls|查看目录中的文件|
|\# ls \-F|查看目录中的文件|
|\# ls \-l|显示文件和目录的详细资料|
|\# ls \-a|显示隐藏文件|
|\# ls \*\[0\-9\]\*|显示包含数字的文件名和目录名|
|\# lstree|显示文件和目录由根目录开始的树形结构|
|\# mkdir dir1|创建一个叫做 'dir1' 的目录|
|\# mkdir dir1 dir2|同时创建两个目录|
|\# mkdir \-p /tmp/dir1/dir2|创建一个目录树|
|\# mv dir1 new\_dir|重命名 / 移动 一个目录|
|\# pwd|显示工作路径|
|\# rm \-f file1|删除一个叫做 'file1' 的文件|
|\# rm \-rf dir1|删除一个叫做 'dir1' 的目录并同时删除其内容|
|\# rm \-rf dir1 dir2|同时删除两个目录及它们的内容|
|\# rmdir dir1|删除一个叫做 'dir1' 的目录|
|\# touch \-t 1607230000 file1|修改一个文件或目录的时间戳 \- \(YYMMDDhhmm\)|
|\# tree|显示文件和目录由根目录开始的树形结构|

### 文件搜索
| 命令 | 说明 |
|--------|--------|
|\# find / \-name file1|从 '/' 开始进入根文件系统搜索文件和目录|
|\# find / \-user user1|搜索属于用户 'user1' 的文件和目录|
|\# find /home/user1 \-name \\\*\.bin|在目录 '/ home/user1' 中搜索带有'\.bin' 结尾的文件|
|\# find /usr/bin \-type f \-atime \+100|搜索在过去 100 天内未被使用过的执行文件|
|\# find /usr/bin \-type f \-mtime \-10|搜索在 10 天内被创建或者修改过的文件|
|\# find / \-name \*\.rpm \-exec chmod 755 '\{\}' \\;|搜索以 '\.rpm' 结尾的文件并定义其权限|
|\# find / \-xdev \-name \\\*\.rpm|搜索以 '\.rpm' 结尾的文件，忽略光驱、捷盘等可移动设备|
|\# locate \\\*\.ps|寻找以 '\.ps' 结尾的文件 \- 先运行 'updatedb' 命令|
|\# whereis halt|显示一个二进制文件、源码或 man 的位置|
|\# which halt|显示一个二进制文件或可执行文件的完整路径|

### 文件的权限
| 命令 | 说明 |
|--------|--------|
|\# chgrp group1 file1|改变文件的群组|
|\# chmod ugo\+rwx directory1|设置目录的所有人、(u\)、群组、(g\) 以及其他人、(o\) 以读、(r\)、写、(w\) 和执行、(x\) 的权限|
|\# chmod go\-rwx directory1|删除群组、(g\) 与其他人、(o\) 对目录的读写执行权限|
|\# chmod u\+s /bin/file1|设置一个二进制文件的 SUID 位 \- 运行该文件的用户也被赋予和所有者同样的权限|
|\# chmod u\-s /bin/file1|禁用一个二进制文件的 SUID 位|
|\# chmod g\+s /home/public|设置一个目录的 SGID 位 \- 类似 SUID，不过这是针对目录的|
|\# chmod g\-s /home/public|禁用一个目录的 SGID 位|
|\# chmod o\+t /home/public|设置一个文件的 STIKY 位 \- 只允许合法所有人删除文件|
|\# chmod o\-t /home/public|禁用一个目录的 STIKY 位|
|\# chown user1 file1|改变一个文件的所有人属性|
|\# chown \-R user1 directory1|改变一个目录的所有人属性并同时改变改目录下所有文件的属性|
|\# chown user1:group1 file1|改变一个文件的所有人和群组属性|
|\# find / \-perm \-u\+s|罗列一个系统中所有使用了 SUID 控制的文件|
|\# ls \-lh|显示权限|
|\# ls /tmp &#124; pr \-T5 \-W$COLUMNS|将终端划分成 5 栏显示|

### 文件的特殊属性
| 命令 | 说明 |
|--------|--------|
|\# chattr \+a file1|只允许以追加方式读写文件|
|\# chattr \+c file1|允许这个文件能被内核自动压缩 / 解压|
|\# chattr \+d file1|在进行文件系统备份时，dump 程序将忽略这个文件|
|\# chattr \+i file1|设置成不可变的文件，不能被删除、修改、重命名或者链接|
|\# chattr \+s file1|允许一个文件被安全地删除|
|\# chattr \+S file1|一旦应用程序对这个文件执行了写操作，使系统立刻把修改的结果写到磁盘|
|\# chattr \+u file1|若文件被删除，系统会允许你在以后恢复这个被删除的文件|
|\# lsattr|显示特殊的属性|

### 查看文件内容
| 命令 | 说明 |
|--------|--------|
|\# cat file1|从第一个字节开始正向查看文件的内容|
|\# head \-2 file1|查看一个文件的前两行|
|\# less file1|类似于 'more' 命令，但是它允许在文件中和正向操作一样的反向操作|
|\# more file1|查看一个长文件的内容|
|\# tac file1|从最后一行开始反向查看一个文件的内容|
|\# tail \-2 file1|查看一个文件的最后两行|
|\# tail \-f /var/log/messages|实时查看被添加到一个文件中的内容|

### 文本处理
| 命令 | 说明 |
|--------|--------|
|\# cat example\.txt &#124; awk 'NR%2==1'|删除 example\.txt 文件中的所有偶数行|
|\# echo a b c &#124; awk '\{print $1\}'|查看一行第一栏|
|\# echo a b c &#124; awk '\{print $1,$3\}'|查看一行的第一和第三栏|
|\# cat \-n file1|标示文件的行数|
|\# comm \-1 file1 file2|比较两个文件的内容只删除 'file1' 所包含的内容|
|\# comm \-2 file1 file2|比较两个文件的内容只删除 'file2' 所包含的内容|
|\# comm \-3 file1 file2|比较两个文件的内容只删除两个文件共有的部分|
|\# diff file1 file2|找出两个文件内容的不同处|
|\# grep Aug /var/log/messages|在文件 '/var/log/messages'中查找关键词"Aug"|
|\# grep ^Aug /var/log/messages|在文件 '/var/log/messages'中查找以"Aug"开始的词汇|
|\# grep \[0\-9\] /var/log/messages|选择 '/var/log/messages' 文件中所有包含数字的行|
|\# grep Aug \-R /var/log/\*|在目录 '/var/log' 及随后的目录中搜索字符串"Aug"|
|\# paste file1 file2|合并两个文件或两栏的内容|
|\# paste \-d '\+' file1 file2|合并两个文件或两栏的内容，中间用"\+"区分|
|\# sdiff file1 file2|以对比的方式显示两个文件的不同|
|\# sed 's/string1/string2/g' example\.txt|将 example\.txt 文件中的 "string1" 替换成 "string2"|
|\# sed '/^$/d' example\.txt|从 example\.txt 文件中删除所有空白行|
|\# sed '/ \*&#124;\#/d; /^$/d' example\.txt|去除文件 example\.txt 中的注释与空行|
|\# sed \-e '1d' exampe\.txt|从文件 example\.txt 中排除第一行|
|\# sed \-n '/string1/p'|查看只包含词汇 "string1"的行|
|\# sed \-e 's/ \*$//' example\.txt|删除每一行最后的空白字符|
|\# sed \-e 's/string1//g' example\.txt|从文档中只删除词汇 "string1" 并保留剩余全部|
|\# sed \-n '1,5p' example\.txt|显示文件 1 至 5 行的内容|
|\# sed \-n '5p;5q' example\.txt|显示 example\.txt 文件的第 5 行内容|
|\# sed \-e 's/00\*/0/g' example\.txt|用单个零替换多个零|
|\# sort file1 file2|排序两个文件的内容|
|\# sort file1 file2 &#124; uniq|取出两个文件的并集、（重复的行只保留一份、)|
|\# sort file1 file2 &#124; uniq \-u|删除交集，留下其他的行|
|\# sort file1 file2 &#124; uniq \-d|取出两个文件的交集、（只留下同时存在于两个文件中的文件、)|
|\# echo 'word' &#124; tr '\[:lower:\]' '\[:upper:\]'|合并上下单元格内容|

### 字符设置和文件格式
| 命令 | 说明 |
|--------|--------|
|\# dos2unix filedos\.txt fileunix\.txt|将一个文本文件的格式从 MSDOS 转换成 UNIX|
|\# recode \.\.HTML < page\.txt > page\.html|将一个文本文件转换成 html|
|\# recode \-l &#124; more|显示所有允许的转换格式|
|\# unix2dos fileunix\.txt filedos\.txt|将一个文本文件的格式从 UNIX 转换成 MSDOS|

## 挂载

### 挂载一个文件系统
| 命令 | 说明 |
|--------|--------|
|\# fuser \-km /mnt/hda2|当设备繁忙时强制卸载|
|\# mount /dev/hda2 /mnt/hda2|挂载一个叫做 hda2 的盘 \- 确保目录 '/mnt/hda2' 已经存在|
|\# mount /dev/fd0 /mnt/floppy|挂载一个软盘|
|\# mount /dev/cdrom /mnt/cdrom|挂载一个 cdrom 或 dvdrom|
|\# mount /dev/hdc /mnt/cdrecorder|挂载一个 cdrw 或 dvdrom|
|\# mount /dev/hdb /mnt/cdrecorder|挂载一个 cdrw 或 dvdrom|
|\# mount \-o loop file\.iso /mnt/cdrom|挂载一个文件或 ISO 镜像文件|
|\# mount \-t vfat /dev/hda5 /mnt/hda5|挂载一个 Windows FAT32 文件系统|
|\# mount /dev/sda1 /mnt/usbdisk|挂载一个 U 盘或闪存设备|
|\# mount \-t smbfs \-o username=user,password=pass //WinClient/share /mnt/share|挂载一个 windows 网络共享|
|\# umount /dev/hda2|卸载一个叫做 hda2 的盘 \- 先从挂载点 '/mnt/hda2' 退出|
|\# umount \-n /mnt/hda2|运行卸载操作而不写入 /etc/mtab 文件、- 当文件为只读或当磁盘写满时非常有用|

### 光盘
| 命令 | 说明 |
|--------|--------|
|\# cd\-paranoia \-B|从一个 CD 光盘转录音轨到 wav 文件中|
|\# cd\-paranoia \-\-|从一个 CD 光盘转录音轨到 wav 文件中（参数、-3）|
|\# cdrecord \-v gracetime=2 dev=/dev/cdrom \-eject blank=fast \-force|清空一个可复写的光盘内容|
|\# cdrecord \-v dev=/dev/cdrom cd\.iso|刻录一个 ISO 镜像文件|
|\# gzip \-dc cd\_iso\.gz &#124; cdrecord dev=/dev/cdrom \-|刻录一个压缩了的 ISO 镜像文件|
|\# cdrecord \-\-scanbus|扫描总线以识别 scsi 通道|
|\# dd if=/dev/hdc &#124; md5sum|校验一个设备的 md5sum 编码，例如一张 CD|
|\# mkisofs /dev/cdrom > cd\.iso|在磁盘上创建一个光盘的 iso 镜像文件|
|\# mkisofs /dev/cdrom &#124; gzip > cd\_iso\.gz|在磁盘上创建一个压缩了的光盘 iso 镜像文件|
|\# mkisofs \-J \-allow\-leading\-dots \-R \-V|创建一个目录的 iso 镜像文件|
|\# mount \-o loop cd\.iso /mnt/iso|挂载一个 ISO 镜像文件|

## 用户管理

### 用户和群组
| 命令 | 说明 |
|--------|--------|
|\# chage \-E 2016\-12\-31 user1|设置用户口令的失效期限|
|\# groupadd \[group\]|创建一个新用户组|
|\# groupdel \[group\]|删除一个用户组|
|\# groupmod \-n moon sun|重命名一个用户组|
|\# grpck|检查 '/etc/passwd' 的文件格式和语法修正以及存在的群组|
|\# newgrp \- \[group\]|登陆进一个新的群组以改变新创建文件的预设群组|
|\# passwd|修改口令|
|\# passwd user1|修改一个用户的口令 \（只允许 root 执行、)|
|\# pwck|检查 '/etc/passwd' 的文件格式和语法修正以及存在的用户|
|\# useradd \-c "User Linux" \-g admin \-d /home/user1 \-s /bin/bash user1|创建一个属于 "admin" 用户组的用户|
|\# useradd user1|创建一个新用户|
|\# userdel \-r user1|删除一个用户 \( '\-r' 排除主目录、)|
|\# usermod \-c "User FTP" \-g system \-d /ftp/user1 \-s /bin/nologin user1|修改用户属性|

## 包管理

### 打包和压缩文件
| 命令 | 说明 |
|--------|--------|
|\# bunzip2 file1\.bz2|解压一个叫做 'file1\.bz2'的文件|
|\# bzip2 file1|压缩一个叫做 'file1' 的文件|
|\# gunzip file1\.gz|解压一个叫做 'file1\.gz'的文件|
|\# gzip file1|压缩一个叫做 'file1'的文件|
|\# gzip \-9 file1|最大程度压缩|
|\# rar a file1\.rar test\_file|创建一个叫做 'file1\.rar' 的包|
|\# rar a file1\.rar file1 file2 dir1|同时压缩 'file1', 'file2' 以及目录 'dir1'|
|\# rar x file1\.rar|解压 rar 包|
|\# tar \-cvf archive\.tar file1|创建一个非压缩的 tarball|
|\# tar \-cvf archive\.tar file1 file2 dir1|创建一个包含了 'file1', 'file2' 以及 'dir1'的档案文件|
|\# tar \-tf archive\.tar|显示一个包中的内容|
|\# tar \-xvf archive\.tar|释放一个包|
|\# tar \-xvf archive\.tar \-C /tmp|将压缩包释放到 /tmp 目录下|
|\# tar \-cvfj archive\.tar\.bz2 dir1|创建一个 bzip2 格式的压缩包|
|\# tar \-xvfj archive\.tar\.bz2|解压一个 bzip2 格式的压缩包|
|\# tar \-cvfz archive\.tar\.gz dir1|创建一个 gzip 格式的压缩包|
|\# tar \-xvfz archive\.tar\.gz|解压一个 gzip 格式的压缩包|
|\# unrar x file1\.rar|解压 rar 包|
|\# unzip file1\.zip|解压一个 zip 格式压缩包|
|\# zip file1\.zip file1|创建一个 zip 格式的压缩包|
|\# zip \-r file1\.zip file1 file2 dir1|将几个文件和目录同时压缩成一个 zip 格式的压缩包|

### RPM 包 \(Fedora,RedHat and alike\)
| 命令 | 说明 |
|--------|--------|
|\# rpm \-ivh \[package\.rpm\]|安装一个 rpm 包|
|\# rpm \-ivh \-\-nodeeps \[package\.rpm\]|安装一个 rpm 包而忽略依赖关系警告|
|\# rpm \-U \[package\.rpm\]|更新一个 rpm 包但不改变其配置文件|
|\# rpm \-F \[package\.rpm\]|更新一个确定已经安装的 rpm 包|
|\# rpm \-e \[package\]|删除一个 rpm 包|
|\# rpm \-qa|显示系统中所有已经安装的 rpm 包|
|\# rpm \-qa &#124; grep httpd|显示所有名称中包含 "httpd" 字样的 rpm 包|
|\# rpm \-qi \[package\]|获取一个已安装包的特殊信息|
|\# rpm \-qg "System Environment/Daemons"|显示一个组件的 rpm 包|
|\# rpm \-ql \[package\]|显示一个已经安装的 rpm 包提供的文件列表|
|\# rpm \-qc \[package\]|显示一个已经安装的 rpm 包提供的配置文件列表|
|\# rpm \-q \[package\] \-\-whatrequires|显示与一个 rpm 包存在依赖关系的列表|
|\# rpm \-q \[package\] \-\-whatprovides|显示一个 rpm 包所占的体积|
|\# rpm \-q \[package\] \-\-scripts|显示在安装 / 删除期间所执行的脚本 l|
|\# rpm \-q \[package\] \-\-changelog|显示一个 rpm 包的修改历史|
|\# rpm \-qf /etc/httpd/conf/httpd\.conf|确认所给的文件由哪个 rpm 包所提供|
|\# rpm \-qp \[package\.rpm\] \-l|显示由一个尚未安装的 rpm 包提供的文件列表|
|\# rpm \-\-import /media/cdrom/RPM\-GPG\-KEY|导入公钥数字证书|
|\# rpm \-\-checksig \[package\.rpm\]|确认一个 rpm 包的完整性|
|\# rpm \-qa gpg\-pubkey|确认已安装的所有 rpm 包的完整性|
|\# rpm \-V \[package\]|检查文件尺寸、 许可、类型、所有者、群组、MD5 检查以及最后修改时间|
|\# rpm \-Va|检查系统中所有已安装的 rpm 包、- 小心使用|
|\# rpm \-Vp \[package\.rpm\]|确认一个 rpm 包还未安装|
|\# rpm \-ivh /usr/src/redhat/RPMS/\`arch\`/\[package\.rpm\]|从一个 rpm 源码安装一个构建好的包|
|\# rpm2cpio \[package\.rpm\] &#124; cpio \-\-extract \-\-make\-directories \*bin\*|从一个 rpm 包运行可执行文件|
|\# rpmbuild \-\-rebuild \[package\.src\.rpm\]|从一个 rpm 源码构建一个 rpm 包|

### YUM 软件工具 \(Fedora,RedHat and alike\)
| 命令 | 说明 |
|--------|--------|
|\# yum \-y install \[package\]|下载并安装一个 rpm 包|
|\# yum localinstall \[package\.rpm\]|将安装一个 rpm 包，使用你自己的软件仓库为你解决所有依赖关系|
|\# yum \-y update|更新当前系统中所有安装的 rpm 包|
|\# yum update \[package\]|更新一个 rpm 包|
|\# yum remove \[package\]|删除一个 rpm 包|
|\# yum list|列出当前系统中安装的所有包|
|\# yum repolist|显示可用的仓库|
|\# yum search \[package\]|在 rpm 仓库中搜寻软件包|
|\# yum clean \[package\]|清理 rpm 缓存删除下载的包|
|\# yum clean headers|删除所有头文件|
|\# yum clean all|删除所有缓存的包和头文件|



### 备份
| 命令 | 说明 |
|--------|--------|
|\# find /var/log \-name '\*\.log' &#124; tar cv \-\-files\-from=\- &#124; bzip2 > log\.tar\.bz2|查找所有以 '\.log' 结尾的文件并做成一个 bzip 包|
|\# find /home/user1 \-name '\*\.txt' &#124; xargs cp \-av \-\-target\-directory=/home/backup/ \-\-parents|从一个目录查找并复制所有以 '\.txt' 结尾的文件到另一个目录|
|\# dd bs=1M if=/dev/hda &#124; gzip &#124; ssh user@ip\_addr 'dd of=hda\.gz'|通过 ssh 在远程主机上执行一次备份本地磁盘的操作|
|\# dd if=/dev/sda of=/tmp/file1|备份磁盘内容到一个文件|
|\# dd if=/dev/hda of=/dev/fd0 bs=512 count=1|做一个将 MBR \(Master Boot Record\) 内容复制到软盘的动作|
|\# dd if=/dev/fd0 of=/dev/hda bs=512 count=1|从已经保存到软盘的备份中恢复 MBR 内容|
|\# dump \-0aj \-f /tmp/home0\.bak /home|制作一个 '/home' 目录的完整备份|
|\# dump \-1aj \-f /tmp/home0\.bak /home|制作一个 '/home' 目录的交互式备份|
|\# restore \-if /tmp/home0\.bak|还原一个交互式备份|
|\# rsync \-rogpav \-\-delete /home /tmp|同步两边的目录|
|\# rsync \-rogpav \-e ssh \-\-delete /home ip\_address:/tmp|通过 SSH 通道 rsync|
|\# rsync \-az \-e ssh \-\-delete ip\_addr:/home/public /home/local|通过 ssh 和压缩将一个远程目录同步到本地目录|
|\# rsync \-az \-e ssh \-\-delete /home/local ip\_addr:/home/public|通过 ssh 和压缩将本地目录同步到远程目录|
|\# tar \-Puf backup\.tar /home/user|执行一次对 '/home/user' 目录的交互式备份操作|
|\# \( cd /tmp/local/ && tar c \. \) &#124; ssh \-C user@ip\_addr 'cd /home/share/ && tar x \-p'|通过 ssh 在远程目录中复制一个目录内容|
|\# \( tar c /home \) &#124; ssh \-C user@ip\_addr 'cd /home/backup\-home && tar x \-p'|通过 ssh 在远程目录中复制一个本地目录|
|\# tar cf \- \. &#124; \(cd /tmp/backup ; tar xf \- \)|本地将一个目录复制到另一个地方，保留原有权限及链接|


## 磁盘和分区

### 文件系统分析
| 命令 | 说明 |
|--------|--------|
|\# badblocks \-v /dev/hda1|检查磁盘 hda1 上的坏磁块|
|\# dosfsck /dev/hda1|修复 / 检查 hda1 磁盘上 dos 文件系统的完整性|
|\# e2fsck /dev/hda1|修复 / 检查 hda1 磁盘上 ext2 文件系统的完整性|
|\# e2fsck \-j /dev/hda1|修复 / 检查 hda1 磁盘上 ext3 文件系统的完整性|
|\# fsck /dev/hda1|修复 / 检查 hda1 磁盘上 linux 文件系统的完整性|
|\# fsck\.ext2 /dev/hda1|修复 / 检查 hda1 磁盘上 ext2 文件系统的完整性|
|\# fsck\.ext3 /dev/hda1|修复 / 检查 hda1 磁盘上 ext3 文件系统的完整性|
|\# fsck\.vfat /dev/hda1|修复 / 检查 hda1 磁盘上 fat 文件系统的完整性|
|\# fsck\.msdos /dev/hda1|修复 / 检查 hda1 磁盘上 dos 文件系统的完整性|

### 初始化一个文件系统
| 命令 | 说明 |
|--------|--------|
|\# fdformat \-n /dev/fd0|格式化一个软盘|
|\# mke2fs /dev/hda1|在 hda1 分区创建一个 linux ext2 的文件系统|
|\# mke2fs \-j /dev/hda1|在 hda1 分区创建一个 linux ext3\（日志型、) 的文件系统|
|\# mkfs /dev/hda1|在 hda1 分区创建一个文件系统|
|\# mkfs \-t vfat 32 \-F /dev/hda1|创建一个 FAT32 文件系统|
|\# mkswap /dev/hda3|创建一个 swap 文件系统|

### SWAP 文件系统
| 命令 | 说明 |
|--------|--------|
|\# mkswap /dev/hda3|创建一个 swap 文件系统|
|\# swapon /dev/hda3|启用一个新的 swap 文件系统|
|\# swapon /dev/hda2 /dev/hdb3|启用两个 swap 分区|

## 网络

### 网络 \(LAN / WiFi\)
| 命令 | 说明 |
|--------|--------|
|\# dhclient eth0|以 dhcp 模式启用 'eth0' 网络设备|
|\# ethtool eth0|显示网卡 'eth0' 的流量统计|
|\# host www\.example\.com|查找主机名以解析名称与 IP 地址及镜像|
|\# hostname|显示主机名|
|\# ifconfig eth0|显示一个以太网卡的配置|
|\# ifconfig eth0 192\.168\.1\.1 netmask 255\.255\.255\.0|控制 IP 地址|
|\# ifconfig eth0 promisc|设置 'eth0' 成混杂模式以嗅探数据包 \(sniffing\)|
|\# ifdown eth0|禁用一个 'eth0' 网络设备|
|\# ifup eth0|启用一个 'eth0' 网络设备|
|\# ip link show|显示所有网络设备的连接状态|
|\# iwconfig eth1|显示一个无线网卡的配置|
|\# iwlist scan|显示无线网络|
|\# mii\-tool eth0|显示 'eth0'的连接状态|
|\# netstat \-tup|显示所有启用的网络连接和它们的 PID|
|\# netstat \-tupl|显示系统中所有监听的网络服务和它们的 PID|
|\# netstat \-rn|显示路由表，类似于“route \-n”命令|
|\# nslookup www\.example\.com|查找主机名以解析名称与 IP 地址及镜像|
|\# route \-n|显示路由表|
|\# route add \-net 0/0 gw IP\_Gateway|控制预设网关|
|\# route add \-net 192\.168\.0\.0 netmask 255\.255\.0\.0 gw 192\.168\.1\.1|控制通向网络 '192\.168\.0\.0/16' 的静态路由|
|\# route del 0/0 gw IP\_gateway|删除静态路由|
|\# echo "1" > /proc/sys/net/ipv4/ip\_forward|激活 IP 转发|
|\# tcpdump tcp port 80|显示所有 HTTP 回环|
|\# whois www\.example\.com|在 Whois 数据库中查找|

### route 设置

#### 基本使用

添加到主机的路由（就是一个 IP 一个 IP 添加）

```
 route add -host 146.148.149.202 dev eno16777984
 route add -host 146.148.149.202 gw 146.148.149.193
```

添加到网络的路由（批量）

```
route add -net 146.148.149.0 netmask 255.255.255.0 dev eno16777984
route add -net 146.148.149.0 netmask 255.255.255.0 gw 146.148.149.193
```

简洁写法

```
route add -net 146.148.150.0/24 dev eno16777984
route add -net 146.148.150.0/24 gw 146.148.150.193
```

添加默认网关

```
route add default gw 146.148.149.193
```

删除主机路由：

```
route del -host 146.148.149.202 dev eno16777984
```

删除网络路由：

```
 route del -net 146.148.149.0 netmask 255.255.255.0
 route del -net 146.148.150.0/24
```

删除默认路由

```
route del default gw 146.148.149.193
```
#### 在 linux 下设置永久路由的方法

服务器启动时自动设置路由，第一想到的可能时 `rc.local`

按照 linux 启动的顺序，rc.local 里面的内容是在 linux 所有服务都启动完毕，最后才被执行的，也就是说，这里面的内容是在 NFS 之后才被执行的，那也就是说在 NFS 启动的时候，服务器上的静态路由是没有被添加的，所以 NFS 挂载不能成功。

/etc/sysconfig/static-routes
```
any net 192.168.3.0/24 gw 192.168.3.254
any net 10.250.228.128 netmask 255.255.255.192 gw 10.250.228.129
```
使用 static-routes 的方法是最好的。无论重启系统和 service network restart 都会生效

static-routes 文件又是什么呢，这个是 network 脚本 (/etc/init.d/network) 调用的，大致的程序如下

```
if [ -f /etc/sysconfig/static-routes  ]; then
    grep "^any" /etc/sysconfig/static-routes | while read ignore args ; do
        /sbin/route add -$args
    done
fi
```
从这段脚本可以看到，这个就是添加静态路由的方法，static-routes 的写法是

any net 192.168.0.0/16 gw 网关 ip


### Microsoft windows 网络 \(samba\)
| 命令 | 说明 |
|--------|--------|
|\# mount \-t smbfs \-o username=user,password=pass //WinClient/share /mnt/share|挂载一个 windows 网络共享|
|\# nbtscan ip\_addr|netbios 名解析|
|\# nmblookup \-A ip\_addr|netbios 名解析|
|\# smbclient \-L ip\_addr/hostname|显示一台 windows 主机的远程共享|
|\# smbget \-Rr smb://ip\_addr/share|像 wget 一样能够通过 smb 从一台 windows 主机上下载文件|

### IPTABLES \(firewall\)
| 命令 | 说明 |
|--------|--------|
|\# iptables \-t filter \-L|显示过滤表的所有链路|
|\# iptables \-t nat \-L|显示 nat 表的所有链路|
|\# iptables \-t filter \-F|以过滤表为依据清理所有规则|
|\# iptables \-t nat \-F|以 nat 表为依据清理所有规则|
|\# iptables \-t filter \-X|删除所有由用户创建的链路|
|\# iptables \-t filter \-A INPUT \-p tcp \-\-dport telnet \-j ACCEPT|允许 telnet 接入|
|\# iptables \-t filter \-A OUTPUT \-p tcp \-\-dport http \-j DROP|阻止 HTTP 连出|
|\# iptables \-t filter \-A FORWARD \-p tcp \-\-dport pop3 \-j ACCEPT|允许转发链路上的 POP3 连接|
|\# iptables \-t filter \-A INPUT \-j LOG \-\-log\-prefix|记录所有链路中被查封的包|
|\# iptables \-t nat \-A POSTROUTING \-o eth0 \-j MASQUERADE|设置一个 PAT \（端口地址转换、) 在 eth0 掩盖发出包|
|\# iptables \-t nat \-A PREROUTING \-d 192\.168\.0\.1 \-p tcp \-m tcp \-\-dport 22 \-j DNAT \-\-to\-destination 10\.0\.0\.2:22|将发往一个主机地址的包转向到其他主机|


# Linux 简单管理
##  ssh

### ssh 简介及基本操作

#### 简介
SSH，全名 secure shell，其目的是用来从终端与远程机器交互，SSH 设计之处初，遵循了如下原则：

  * 机器之间通讯的内容必须经过加密。
  * 加密过程中，通过 public key 加密，private 解密。

#### 密钥
SSH 通讯的双方各自持有一个公钥私钥对，公钥对对方是可见的，私钥仅持有者可见，你可以通过"ssh-keygen"生成自己的公私钥，默认情况下，公私钥的存放路径如下：

  * 公钥：$HOME/.ssh/id_rsa.pub
  * 私钥：$HOME/.ssh/id_rsa

#### 基于口令的安全验证通讯原理

  建立通信通道的步骤如下：

```
  1. 远程主机将公钥发给用户 ---- 远程主机收到用户的登录请求，把自己的公钥发给客户端，客户端检查这个 public key 是否在自己的 $HOME/.ssh/known_hosts 中，如果没有，客户端会提示是否要把这个 public key 加入到 known_hosts 中。
  2. 用户使用公钥加密密码 ------ 用户使用这个公钥，将登录密码加密后，发送回来
  3. 远程主机使用私钥加密 ------ 远程主机用自己的私钥，解密登录密码，如果密码正确，就同意用户登录。
  4. 客户端把 PUBLIC KEY(client), 发送给服务器。
  5. 至此，到此为止双方彼此拥有了对方的公钥，开始双向加密解密。
```

PS：当网络中有另一台冒牌服务器冒充远程主机时，客户端的连接请求被服务器 B 拦截，服务器 B 将自己的公钥发送给客户端，客户端就会将密码加密后发送给冒牌服务器，冒牌服务器就可以拿自己的私钥获取到密码，然后为所欲为。因此当第一次链接远程主机时，在上述步骤中，会提示您当前远程主机的”公钥指纹”，以确认远程主机是否是正版的远程主机，如果选择继续后就可以输入密码进行登录了，当远程的主机接受以后，该台服务器的公钥就会保存到 ~/.ssh/known_hosts 文件中。

#### StrictHostKeyChecking 和 UserKnownHostsFile

> * 如何让连接新主机时，不进行公钥确认？
>   * SSH 客户端的 StrictHostKeyChecking 配置指令，可以实现当第一次连接服务器时，自动接受新的公钥。
>   * [例子:] ssh  -o StrictHostKeyChecking=no  192.168.0.110
> * 如何防止远程主机公钥改变导致 SSH 连接失败
>   * 将本地的 known_hosts 指向不同的文件，就不会造成公钥冲突导致的中断了,提示信息由公钥改变中断警告，变成了首次连接的提示。结合自动接收新的公钥
>   * [例子:] ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null 192.168.0.110

### 基于密匙的安全验证通讯原理

这种方式你需要在当前用户家目录下为自己创建一对密匙，并把公匙放在需要登录的服务器上。当你要连接到服务器上时，客户端就会向服务器请求使用密匙进行安全验证。服务器收到请求之后，会在该服务器上你所请求登录的用户的家目录下寻找你的公匙，然后与你发送过来的公匙进行比较。如果两个密匙一致，服务器就用该公匙加密“质询”并把它发送给客户端。客户端收到“质询”之后用自己的私匙解密再把它发送给服务器。与第一种级别相比，第二种级别不需要在网络上传送口令。

PS：简单来说，就是将客户端的公钥放到服务器上，那么客户端就可以免密码登录服务器了，那么客户端的公钥应该放到服务器上哪个地方呢？默认为你要登录的用户的家目录下的 .ssh 目录下的 authorized_keys 文件中（即：~/.ssh/authorized_keys）。
我们的目标是：用户已经在主机 A 上登录为 a 用户，现在需要以不输入密码的方式以用户 b 登录到主机 B 上。

可以把密钥理解成一把钥匙，公钥理解成这把钥匙对应的锁头，
把锁头（公钥）放到想要控制的 server 上，锁住 server, 只有拥有钥匙（密钥）的人，
才能打开锁头，进入 server 并控制
而对于拥有这把钥匙的人，必需得知道钥匙本身的密码，才能使用这把钥匙（除非这把钥匙没设置密码）, 这样就可以防止钥匙被了配了（私钥被人复制）

当然，这种例子只是方便理解罢了，
拥有 root 密码的人当然是不会被锁住的，而且不一定只有一把锁（公钥）,
但如果任何一把锁，被人用其对应的钥匙（私钥）打开了，server 就可以被那个人控制了
所以说，只要你曾经知道 server 的 root 密码，并将有 root 身份的公钥放到上面，
就可以用这个公钥对应的私钥"打开" server, 再以 root 的身分登录，即使现在 root 密码已经更改！

步骤如下：

  1. 以用户 a 登录到主机 A 上，生成一对公私钥。
  2. 把主机 A 的公钥复制到主机 B 的 authorized_keys 中，可能需要输入 b@B 的密码。

	    ssh-copy-id -i ~/.ssh/id_dsa.pub b@B
  3. 在 a@A 上以免密码方式登录到 b@B

  		ssh b@B

tips:

   假如 B 机器修改端口后，将主机 A 上的公钥复制到 B 机的操作方法是（下面方法中双引号是必须的）：

   ssh-copy-id "-p 端口号 b@B"

### SSH 端口转发

SSH 还同时提供了一个非常有用的功能，这就是端口转发。它能够将其他 TCP 端口的网络数据通过 SSH 链接来转发，并且自动提供了相应的加密及解密服务。这一过程有时也被叫做“隧道”(tunneling)，这是因为 SSH 为其他 TCP 链接提供了一个安全的通道来进行传输而得名。

SSH 端口转发自然需要 SSH 连接，而 SSH 连接是有方向的，从 SSH Client 到 SSH Server 。
而我们所要访问的应用也是有方向的，应用连接的方向也是从应用的 Client 端连接到应用的 Server 端。
比如需要我们要访问 Internet 上的 Web 站点时，Http 应用的方向就是从我们自己这台主机 (Client) 到远处的 Web Server。

> * SSH 连接和应用的连接这两个连接的方向一致，那我们就说它是本地转发。
> * SSH 连接和应用的连接这两个连接的方向不同，那我们就说它是远程转发。

#### SSH 正向连接

正向连接就是 client 连上 server，然后把 server 能访问的机器地址和端口（当然也包括 server 自己）镜像到 client 的端口上。

```
何时使用本地 Tunnel？

> * 比如说你在本地访问不了某个网络服务（如 www.google.com)，而有一台机器（如：xx.xx.xx.xx) 可以，那么你就可以通过这台机器的 ssh 服务来转发
```
使用方法
```
ssh -L <local port>:<remote host>:<remote port> <SSH hostname>
ssh -L [客户端 IP 或省略]:[客户端端口]:[服务器能访问的 IP]:[服务器能访问的 IP 的端口] [登陆服务器的用户名 @服务器 IP] -p [服务器 ssh 服务端口（默认 22）]
```
ssh  -L 1433:target_server:1433 user@ssh_host

***windows 下使用本地转发 xshell***

```
(1)ssh 远程连接到 Linux
(2) 打开代理设置面板，点击：view -> Tunneling Pane, 在弹出的窗口选择 Forwarding Rules
(3) 在空白处右键：add。
在弹出的 Forwarding Rule，
Type 选择"Local(Outgoing)";
Source Host 使用默认的 localhost; Listen Port 添上端口 8888;
Destination Host 使用默认的 localhost；Destination Port 添上 80;

Destination Host 设置为 localhost 为要访问的机器，可以设置为登陆后的机器可以访问到的 IP
```

#### SSH 反向连接

反向连接就是 client 连上 server，然后把 client 能访问的机器地址和端口（也包括 client 自己）镜像到 server 的端口上。

```
何时使用反向连接？

比如当你下班回家后就访问不了公司内网的机器了，遇到这种情况可以事先在公司内网的机器上执行远程 Tunnel，连上一台公司外网的机器，等你下班回家后就可以通过公司外网的机器去访问公司内网的机器了。
```
使用方法
```
ssh -R <remote port>:<local host>:<local port> <SSH hostname>
ssh -R [服务器 IP 或省略]:[服务器端口]:[客户端能访问的 IP]:[客户端能访问的 IP 的端口] [登陆服务器的用户名 @服务器 IP] -p [服务器 ssh 服务端口（默认 22）]
```
**外网机器 A 要控制 内网机器 B**

A 主机：外网，ip：122.122.122.122，sshd 端口：2222（默认是 22)

B 主机：内网，sshd 端口：2222（默认是 22)

无论是外网主机 A，还是内网主机 B 都需要跑 ssh daemon

***首先在内网机器 B 上执行***

```
    ssh -NfR 1234:localhost:2222 user1@122.122.122.122 -p 2222
```

这句话的意思是将 A 主机的 1234 端口和 B 主机的 2222 端口绑定，相当于远程端口映射 (Remote Port Forwarding)。

***外网机器 A 会 listen 本地 1234 端口***

```
---- 外网机器 A sshd 会 listen 本地 1234 端口
    #netstat -tanp | grep sshd
    #Proto Recv-Q Send-Q   Local Address   Foreign Address   State       PID/Program name
    #tcp     0      0      127.0.0.1:1234    0.0.0.0:*       LISTEN      4234/sshd

---- 在外网机器 A 登录内网机器 B（非 root 用户的话，直接 user@localhost 即可）
    #ssh user@localhost -p1234
```
#### SSH 反向连接自动重连

上面的反向连接（Reverse Connection）不稳定，可能随时断开，需要内网主机 B 再次向外网 A 发起连接，这时需要个"朋友"帮你在内网 B 主机执行这条命令。可以使用 Autossh 或者 while 进行循环。

(1) 在 B 机器上将 B 机器公钥放到外网机器 A 上（实现 B 机器自动登录到 A 机器）

(2) 用 Autossh 或者 while 循环 保持 ssh 反向隧道一直连接，CentOS 需要使用 epel 源下载

在 CentOS6 和 CentOS7 都可以执行下面的命令安装 epel 仓库

**while**

编写脚本写入如下内容

```
#!/bin/bash
# 远程机器的 IP 和端口
remote_ip=122.122.122.122
remote_port=2222

while [[ 1==1  ]]
do
    ssh  -o ServerAliveInterval=15 -o ServerAliveCountMax=3 -N -R:1234:localhost:22 -p ${remote_port} root@${remote_ip}
    sleep 3
done
```
执行脚本后，即可以通过登陆 122.122.122.122 机器访问本地 1234 端口进行访问此机器

注;可以将此脚本放在后台中运行，并加到系统自启动程序中

**autossh**

```
#yum -y install epel-release
```
安装号 autossh 后使用如下方法进行反向连接
```
#autossh -M 5678 -NfR 1234:localhost:2222 user1@122.122.122.122 -p2222
```
比之前的命令添加的一个 -M 5678 参数，负责通过 5678 端口监视连接状态，连接有问题时就会自动重连

### windows 下 xshell 使用

  * 私钥，在 Xshell 里也叫用户密钥
  * 公钥，在 Xshell 里也叫主机密钥

  利用 xshell 密钥管理服务器远程登录，

  (1)Xshell 自带有用户密钥生成向导：点击菜单栏的工具 ->新建用户密钥生成向导
  (2) 添加公钥 (Pubic Key) 到远程 Linux 服务器

## 用户管理

### Linux 踢出其他正在 SSH 登陆用户

***查看系统在线用户***

```
[root@Linux ~]#w
 20:40:18 up 1 day, 23 min,  4 users,  load average: 0.00, 0.00, 0.00
USER     TTY      FROM              LOGIN@   IDLE   JCPU   PCPU WHAT
root     tty1     -                Fri09   10:10m  0.34s  0.34s -bash
root     pts/2    192.168.31.124   10:30    4:39m  0.99s  0.99s -bash
root     pts/3    192.168.31.124   19:55    0.00s  0.07s  0.00s w
root     pts/4    192.168.31.124   19:55    4:52   0.16s  0.16s -bash
```
***查看当前自己占用终端***

```
[root@Linux ~]# who am i
root     pts/4        2016-10-30 19:55 (192.168.31.124)
```
***用 pkill 命令剔除对方***

```
[root@Linux ~]# pkill -kill -t pts/2
[root@Linux ~]# w
 20:44:15 up 1 day, 27 min,  3 users,  load average: 0.01, 0.03, 0.01
 USER     TTY      FROM              LOGIN@   IDLE   JCPU   PCPU WHAT
 root     tty1     -                Fri09   10:14m  0.34s  0.34s -bash
 root     pts/3    192.168.31.124   19:55   51.00s  1.43s  1.35s vim base.md
 root     pts/4    192.168.31.124   19:55    0.00s  0.21s  0.00s w
```
如果最后查看还是没有干掉，建议加上 -9 强制杀死。
[root@Linux ~]# pkill -9 -t pts/2

### 使用脚本创建有 sudo 权限的用户

```
cat >./create_user.sh <<-'EOF'
#!/bin/bash
arg="ceshi"
if id ${arg}
then
    echo "the username is exsit!"
else
    useradd $arg
    echo "ceshi_password" | passwd --stdin $arg
    echo "${arg} ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/${arg}
fi
EOF
```
以上脚本会创建用户 `ceshi` 同时用户的密码为 `ceshi_password` ，并且此用户有 sudo 权限

### 无交互式修改用户密码

```
echo "123456" | passwd --stdin root
```
## 网卡 bond

Linux 多网卡绑定

网卡绑定 mode 共有七种 (0~6) bond0、bond1、bond2、bond3、bond4、bond5、bond6

常用的有三种

> * mode=0：平衡负载模式，有自动备援，但需要”Switch”支援及设定。
> * mode=1：自动备援模式，其中一条线若断线，其他线路将会自动备援。
> * mode=6：平衡负载模式，有自动备援，不必”Switch”支援及设定。

需要说明的是如果想做成 mode 0 的负载均衡，仅仅设置这里 options bond0 miimon=100 mode=0 是不够的，与网卡相连的交换机必须做特殊配置（这两个端口应该采取聚合方式），因为做 bonding 的这两块网卡是使用同一个 MAC 地址。从原理分析一下（bond 运行在 mode 0 下）：

mode 0 下 bond 所绑定的网卡的 IP 都被修改成相同的 mac 地址，如果这些网卡都被接在同一个交换机，那么交换机的 arp 表里这个 mac 地址对应的端口就有多 个，那么交换机接受到发往这个 mac 地址的包应该往哪个端口转发呢？正常情况下 mac 地址是全球唯一的，一个 mac 地址对应多个端口肯定使交换机迷惑了。所以 mode0 下的 bond 如果连接到交换机，交换机这几个端口应该采取聚合方式（cisco 称为 ethernetchannel，foundry 称为 portgroup），因为交换机做了聚合后，聚合下的几个端口也被捆绑成一个 mac 地址。我们的解 决办法是，两个网卡接入不同的交换机即可。

mode6 模式下无需配置交换机，因为做 bonding 的这两块网卡是使用不同的 MAC 地址。

## 其他设置


### 时区及时间

时区就是时间区域，主要是为了克服时间上的混乱，统一各地时间。地球上共有 24 个时区，东西各 12 个时区（东 12 与西 12 合二为一）。

#### UTC 和 GMT

时区通常写成`+0800`，有时也写成`GMT +0800`，其实这两个是相同的概念。

GMT 是格林尼治标准时间（Greenwich Mean Time）。

UTC 是协调世界时间（Universal Time Coordinated），又叫世界标准时间，其实就是`0000`时区的时间。

#### Linux 下调整时区及更新时间

修改系统时间

```
$ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
```

修改 /etc/sysconfig/clock 文件，修改为：

```
ZONE="Asia/Shanghai"
UTC=false
ARC=false
```
校对时间
```
$ntpdate cn.ntp.org.cn
```
设置硬件时间和系统时间一致并校准
```
$/sbin/hwclock --systohc
```

***定时同步时间设置***

凌晨 5 点定时同步时间

```
echo "0 5 * * *  /usr/sbin/ntpdate cn.ntp.org.cn" >> /var/spool/cron/root
或者
echo "0 5 * * *  /usr/sbin/ntpdate 133.100.11.8" >> /var/spool/cron/root

```
### 登录提示信息

#### 修改登录前的提示信息

**(1) 系统级别的设置方法 /etc/issue**

使用此方法时远程 ssh 连接的时候并不会显示

```
在登录系统输入用户名之前，可以看到上方有 WELCOME...... 之类的信息，这里会显示 LINUX 发行版本名称，内核版本号，日期，机器信息等等信息，

首先打开 /etc/issue 文件，可以看到里面是这样一段"Welcome to <LINUX 发行版本名称》-kernel 后接各项参数、"

参数的各项说明：
\r 显示 KERNEL 内核版本号；
\l 显示虚拟控制台号；
\d 显示当前日期；
\n 显示主机名；
\m 显示机器类型，即 CPU 架构，如 i386 等；

可以显示所有必要的信息：

Welcome to <LINUX 发行版本名称》-kernel \r (\l) \d \n \m.
```

### 修改登录成功后的信息

motd(message of the day)

修改登录成功后的提示信息在此文件中添加内容即可：/etc/motd

如：
```
/////////////////////////////////////
系统初始化配置提示
xxxx

应用联系人：xxxx 联系方式：xxxx
/////////////////////////////////////
```

# CentOS 7 vs CentOS 6 的不同

## 运行相关

**桌面系统**

    [CentOS6] GNOME 2.x
    [CentOS7] GNOME 3.x（GNOME Shell）

**文件系统**

    [CentOS6] ext4
    [CentOS7] xfs

**内核版本**

    [CentOS6] 2.6.x-x
    [CentOS7] 3.10.x-x

**启动加载器**

    [CentOS6] GRUB Legacy (+efibootmgr)
    [CentOS7] GRUB2

**防火墙**

    [CentOS6] iptables
    [CentOS7] firewalld

**默认数据库**

    [CentOS6] MySQL
    [CentOS7] MariaDB

**文件结构**

    [CentOS6] /bin, /sbin, /lib, and /lib64 在 / 下
    [CentOS7] /bin, /sbin, /lib, and /lib64 移到 /usr 下

**主机名**

    [CentOS6] /etc/sysconfig/network  # 修改主机名时，修改此文件，同时在命令行执行 "hostname 新主机名"
    [CentOS7] /etc/hostname

**时间同步**

    [CentOS6]
    $ ntp
    $ ntpq -p

    [CentOS7]
    $ chrony
    $ chronyc sources

**修改时区**

    [CentOS6]
    $ vim /etc/sysconfig/clock
       ZONE="Asia/Shanghai"
       UTC=fales
    $ sudo ln -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

    [CentOS7]
    $ timedatectl set-timezone Asia/Shanghai
    $ timedatectl status

**修改语言**

    [CentOS6]
    $ vim /etc/sysconfig/i18n
       LANG="en_US.utf8"
    $ /etc/sysconfig/i18n
    $ locale

    [CentOS7]
    $ localectl set-locale LANG=en_US.utf8
    $ localectl status

**重启关闭**

    1) 关闭
    [CentOS6]
    $ shutdown -h now

    [CentOS7]
    $ poweroff
    $ systemctl poweroff

    2) 重启
    [CentOS6]
    $ reboot
    $ shutdown -r now

    [CentOS7]
    $ reboot
    $ systemctl reboot

    3) 单用户模式
    [CentOS6]
    $ init S

    [CentOS7]
    $ systemctl rescue

    4) 启动模式
    [CentOS6]
    [GUICUI]
    $ vim /etc/inittab
      id:3:initdefault:
    [CUIGUI]
    $ startx

    [CentOS7]
    [GUICUI]
    $ systemctl isolate multi-user.target
    [CUIGUI]
    $systemctl isolate graphical.target
    默认
    $ systemctl set-default graphical.target

    [CentOS6]
    $ chkconfig service_name on/off

    [CentOS7]
    $ systemctl enable service_name
    $ systemctl disable service_name

**服务一览**

    [CentOS6]
    $ chkconfig --list

    [CentOS7]
    $ systemctl list-unit-files
    $ systemctl --type service

**强制停止**

    [CentOS6]
    $ kill -9 <PID>

    [CentOS7]
    $ systemctl kill --signal=9 sshd

## 网络

**网络信息**

    [CentOS6]
    $ netstat
    $ netstat -I
    $ netstat -n

    [CentOS7]
    $ ip -s l
    $ ss

**IP 地址 MAC 地址**

    [CentOS6]
    $ ifconfig -a

    [CentOS7]
    $ ip address show

**路由**

    [CentOS6]
    $ route -n
    $ route -A inet6 -n

    [CentOS7]
    $ ip route show
    $ ip -6 route show
