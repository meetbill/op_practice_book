## linux基础

* [安装](#安装)
	* [安装准备](#安装准备)
	* [安装centos6.8](#安装centos68)
	* [系统安装后的配置](#系统安装后的配置)
* [Bash基础特性](#bash基础特性)
	* [命令历史](#命令历史)
	* [命令补全](#命令补全)
	* [路径补全](#路径补全)
	* [命令行展开](#命令行展开)
	* [命令的执行状态结果](#命令的执行状态结果)
	* [命令别名](#命令别名)
		* [User specific aliases and functions](#user-specific-aliases-and-functions)
	* [通配符glob](#通配符glob)
	* [bash快捷键](#bash快捷键)
		* [编辑命令：](#编辑命令)
		* [重新执行命令：](#重新执行命令)
		* [控制命令：](#控制命令)
		* [Bang (!) 命令](#bang--命令)
		* [友情提示：](#友情提示)
	* [bash的io重定向及管道](#bash的io重定向及管道)
		* [I/O重定向：改变标准位置；](#io重定向改变标准位置)
* [linux 常用命令](#linux-常用命令)
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
		* [RPM包 \(Fedora,RedHat and alike\)](#rpm包-fedoraredhat-and-alike)
		* [YUM 软件工具 \(Fedora,RedHat and alike\)](#yum-软件工具-fedoraredhat-and-alike)
		* [备份](#备份)
	* [磁盘和分区](#磁盘和分区)
		* [文件系统分析](#文件系统分析)
		* [初始化一个文件系统](#初始化一个文件系统)
		* [SWAP 文件系统](#swap-文件系统)
	* [网络](#网络)
		* [网络 \(LAN / WiFi\)](#网络-lan--wifi)
		* [Microsoft windows 网络 \(samba\)](#microsoft-windows-网络-samba)
		* [IPTABLES \(firewall\)](#iptables-firewall)
* [ssh](#ssh)
	* [ssh登陆原理以及端口转发](#ssh登陆原理以及端口转发)
		* [简介：](#简介)
		* [密钥:](#密钥)
		* [基于口令的安全验证通讯原理：](#基于口令的安全验证通讯原理)
		* [基于密匙的安全验证通讯原理：](#基于密匙的安全验证通讯原理)
		* [SSH forwarding:](#ssh-forwarding)
		* [windows ---xshell](#windows----xshell)
* [用户管理](#用户管理-1)
	* [Linux踢出其他正在SSH登陆用户](#linux踢出其他正在ssh登陆用户)
	* [使用脚本创建用户，同时用户有 sudo 权限](#使用脚本创建用户同时用户有-sudo-权限)
* [其他设置](#其他设置)
	* [时区及时间](#时区及时间)
		* [UTC 和 GMT](#utc-和-gmt)
		* [时间换算](#时间换算)
		* [Linux 下调整时区及更新时间](#linux-下调整时区及更新时间)
* [CentOS 7 vs CentOS 6的不同](#centos-7-vs-centos-6的不同)
	* [运行相关](#运行相关)
	* [服务相关](#服务相关)
	* [网络](#网络-1)

# 安装

centos 6.x

## 安装准备
    1.下载安装镜像文件
    http://www.centos.org   ->downloads->mirrors  
    http://mirrors.aliyun.com/centos/6.8/isos/x86_64/
    http://mirrors.aliyun.com/centos/6.8/isos/i386/
    主要下载Centos-6.8-x86_64-bin-DVD1.iso和Centos-6.8-x86_64-bin-DVD2.iso

## 安装centos6.8

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

    （1）.为系统设置主机名  主机名为：meetbill
    （2）.配置网卡及连接网络（可选）

***系统时钟及时区***

    选择：Asia/Shanghai
    取消：system clock uses UTC  
    然后：next

***设置root口令***

***磁盘分区类型选择与磁盘分区配置过程***

(1)选择系统安装磁盘空间类型
    
    选择：create custom layout

(2)进入 'create custom layout'分区界面
    
    可以create (创建),update(修改) ,delete(删除)等操作。

(3)按企业生产标准定制磁盘分区
    
    选择：standard partition 
    1）.创建引导分区，/boot分区
    mount point:/boot
    file system type:ext4
    size:200 

    2）.创建swap交换分区
    mount point :<not applicable>
    file system type:swap
    size:1024 (物理内存的1-2倍)
    addtion size options : fixed size
    force to be a primary partition

    3).创建( / )根分区
    mount point :/
    file system type : ext4
    size : 剩余
    addtion size options : fill to maximum allowable size  (根分区是最后一个分区，所以把剩余的空间都分配给根分区)
    force to be a primary partition 

    4).格式化警告
    选择： format

***系统安装包的选择与配置***

(1)启动引导设备的配置
    系统默认使用GRUB作为启动加载器，引导程序默认在MBR下：
    ```
    install boot loader on /dev/sda ->change device 
    选择 master boot record -/dev/sda
    [选择的是操作系统所在的那个设备，如/dev/sda]

    Boot Loader operation system list 
    列表中选择的是操作系统根目录/所在的分区，如CentOS /dev/sda4

    ```
(2)系统安装类型选择及自定义额外包组
    系统默认是desktop ，但是这里选择minimal。
    自定义安装包选择：customsize now 
    base system :
        base
    然后：next

***开始安装->安装完成->reboot***

## 系统安装后的配置

***更新系统，打补丁到最新***

    修改更新yum源：
    cp  /etc /yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.ori
    wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirros.163.com/.help/CentOS 6-Base-163.repo
    ll /etc/pki/rpm-gpg/
    rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY*
    yum update -y
    
    ps:一般在首次安装时执行yum update -y ,如果是在实际生产环境中，切记使用，以免导致异常。

***安装额外的软件包***

    yum install tree telnet dos2unix sysstat lrzsz nc nmap -y
    yum grouplist    #查看包组列表
    yum frouplist "development Tools"

# Bash基础特性
## 命令历史
(1)  使用命令：history

(2)  环境变量：

        a) HISTSIZE：命令历史缓冲区中记录的条数，默认为1000；

        b) HISTFILE：记录当前登录用户在logout时历史命令存放文件；

        c) HISTFILESIZE：命令历史文件记录历史的条数，默认为1000；
(3)  操作命令历史：

        a) history –d OFFSET 删除指定行的命令历史；

        b) history –c 清空命令历史缓冲区中的命令；

        c) history # 显示历史中最近的#条命令；

        d) history –a 手动追加当前会话缓冲区中的命令至历史文件中；
(4) 调用历史中的命令：

        a) !# : 重复执行第#条命令；

        b) !! : 重复执行上一条(最近一条命令；)

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

         export 变量名=“VALUE”

         或： VARNAME=“VALUE” export VARNAME
         
## 命令补全

内部命令：直接通过shell补全；
外部命令：bash根据PATH环境变量定义的路径，自左而右地在每个路径搜寻以给定命令命名的文件，第一次找到即为要执行的命令；
- Note: 在第一次通过PATH搜寻到命令后，会将其存入hash缓存中，下次使用不再搜寻PATH，从hash中查找；

~~~shell
[root@sslinux ~]# hash
hits command
 1 /usr/sbin/ifconfig
 1 /usr/bin/vim
 1 /usr/bin/ls
~~~

Tab键补全：
若用户给出的字符在命令搜索路径中有且仅有一条命令与之相匹配，则Tab键直接补全；

若用户输入的字符在命令搜索路径中有多条命令与之相匹配，则再次Tab键可以将这些命令列出；

## 路径补全

以用户输入的字符串作为路径开头，并在其指定路径的上级目录下搜索以指定字符串开头的文件名；       

    如果唯一，则直接补全；     

    否则，再次Tab，列出所有符合条件的路径及文件；  

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

[返回目录](#目录)

## 命令的执行状态结果
表示命令是否成功执行；

bash使用特殊变量$?保存最近一条命令的执行状态结果；

- 环境变量$?的取值：

     0 ： 成功；

     1-255：失败，1,127,255为系统保留；

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
- 通过alias命令实现：

a、alias ： 显示当前shell进程所有可用的命令别名；

b、定义别名，格式为： alias NAME='VALUE'  

	定义别名NAME，其执行相当于执行命令VALUE，VALUE中可包含命令、选项以及参数；仅当前会话有效，不建议使用；

c、通过修改配置文件定义命令别名：

    当前用户：~/.bashrc
    全局用户：/etc/bashrc

- Bash进程重新读取配置文件：
~~~shell
    source /path/to/config_file 

    . /path/to/config_file
~~~
- 撤销别名： unalias
```
    unalias [-a] name [name...]
```
- Note:

    对于定义了别名的命令，要使用原命令，可通过\COMMAND的方式使用；

- Example:

~~~shell
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
~~~

## 通配符glob

Bash中用于文件名"通配"

- 通配符： *,?,[]

    1) * 任意长度的任意字符；

        a * b 
~~~shell
[root@sslinux sslinux]# ls -ld /etc/au*
drwxr-x---. 3 root root 41 Sep 3 22:05 /etc/audisp
drwxr-x---. 3 root root 79 Sep 3 22:09 /etc/audit
~~~

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
- 专用字符结合：(表示一类字符中的单个)

[:digit:] 任意单个数字，相当于[0-9];

[:lower:] 任意单个小写字母；

[:upper:] 任意单个大写字母；

[:alpha:] 任意单个大小写字母；

[:alnum:] 任意单个数字或字母；

[:space:] 任意空白字符；

[:punct:] 任意单个特殊字符；

- Note：

在使用[]应用专用字符集合时，外层也需要嵌套[]。

Example：

```
# ls -d /etc/*[[:digit:]]*[[:lower:]]
```

## bash快捷键

### 编辑命令：
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

### 重新执行命令：
- Ctrl + r：逆向搜索命令历史
- Ctrl + g：从历史搜索模式退出
- Ctrl + p：历史中的上一条命令
- Ctrl + n：历史中的下一条命令
- Alt + .：使用上一条命令的最后一个参数

### 控制命令：
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

### 友情提示：

    以上介绍的大多数 Bash 快捷键仅当在 emacs 编辑模式时有效，

    若你将 Bash 配置为 vi 编辑模式，那将遵循 vi 的按键绑定。

    Bash 默认为 emacs 编辑模式。

    如果你的 Bash 不在 emacs 编辑模式，可通过 set-o emacs 设置。

    ^S、^Q、^C、^Z 是由终端设备处理的，可用 stty 命令设置。

## bash的io重定向及管道
打开的文件都有一个fd：file descriptor(文件描述符)

    标准输入：keyboard，0

    标准输出：monitor，1

    标准错误输出：monitor，2

### I/O重定向：改变标准位置；

- 输出重定向：

     COMMAND > NEW_POS 覆盖重定向，目标文件中的原有内容会被清除；

     COMMAND >> NEW_POS 追加重定向，新内容会被追加到目标文件尾部；

- Note：

    为了在输出重定向时防止覆盖原有文件，建议使用以下设置：

    set –C ： 禁止将内容覆盖输出(>)至已有文件中,追加输出不受影响；

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

     合并标准输出和错误输出为同一个数据流进行重定向；

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

            最后一个命令会在当前shell进程的子shell进程中执行；
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
# linux 常用命令

## 系统

### 系统信息  
| 命令 | 说明 |
|--------|--------|
|\# arch|显示机器的处理器架构|
|\# cal 2016|显示2016年的日历表|
|\# cat /proc/cpuinfo|查看CPU信息|
|\# cat /proc/interrupts|显示中断|
|\# cat /proc/meminfo|校验内存使用|
|\# cat /proc/swaps|显示哪些swap被使用|
|\# cat /proc/version|显示内核版本|
|\# cat /proc/net/dev|显示网络适配器及统计|
|\# cat /proc/mounts|显示已加载的文件系统|
|\# clock \-w|将时间修改保存到BIOS|
|\# date|显示系统日期|
|\# date 072308302016\.00|设置日期和时间 \- 月日时分年\.秒|
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
|\# free \-m|以兆为单位罗列RAM状态|
|\# kill \-9 process\_id|强行关闭进程并结束它|
|\# kill \-1 process\_id|强制一个进程重载其配置|
|\# last reboot|显示重启历史|
|\# lsmod|罗列装载的内核模块|
|\# lsof \-p process\_id|罗列一个由进程打开的文件列表|
|\# lsof /home/user1|罗列所给系统路径中所打开的文件的列表|
|\# ps \-eafw|罗列linux任务|
|\# ps \-e \-o pid,args \-\-forest|以分级的方式罗列linux任务|
|\# pstree|以树状图显示程序|
|\# smartctl \-A /dev/hda|通过启用SMART监控硬盘设备的可靠性|
|\# smartctl \-i /dev/hda|检查一个硬盘设备的 SMART 是否启用|
|\# strace \-c ls >/dev/null|罗列系统 calls made并用一个进程接收|
|\# strace \-f \-e open ls >/dev/null|罗列库调用|
|\# tail /var/log/dmesg|显示内核引导过程中的内部事件|
|\# tail /var/log/messages|显示系统事件|
|\# top|罗列使用CPU资源最多的linux任务|
|\# watch \-n1 'cat /proc/interrupts'|罗列实时中断|

### 公钥私钥  
| 命令 | 说明 |
|--------|--------|
| \# ssh-keygen -t rsa -C "邮箱地址" | 产生公钥私钥对 |
| \# ssh-copy-id -i ~/.ssh/id_rsa.pub root@192.168.0.2  | 将本地机器的公钥复制到远程机器的root用户的authorized_keys文件中 |
| \# ssh-keygen -p -f ~/.ssh/id_rsa | 添加或修改SSH-key的私钥密码 |
| \# ssh-keygen -y -f ~/.ssh/id_rsa > id_rsa.pub | 从私钥中生成公钥 |
  
### 其他  
| 命令 | 说明 |
|--------|--------|
|\# alias hh='history'|为命令history\(历史\)设置一个别名|
|\# gpg \-c file1|用GNU Privacy Guard加密一个文件|
|\# gpg file1\.gpg|用GNU Privacy Guard解密一个文件|
|\# ldd /usr/bin/ssh|显示ssh程序所依赖的共享库|
|\# man ping|罗列在线手册页（例如ping 命令）|
|\# mkbootdisk \-\-device /dev/fd0 \`uname \-r\`|创建一个引导软盘|
|\# wget \-r www\.example\.com|下载一个完整的web站点|
|\# wget \-c www\.example\.com/file\.iso|以支持断点续传的方式下载一个文件|
|\# echo 'wget \-c www\.example\.com/files\.iso' &#124; at 09:00|在任何给定的时间开始一次下载|
|\# whatis \.\.\.keyword|罗列该程序功能的说明|
|\# who \-a|显示谁正登录在线，并打印出：系统最后引导的时间，关机进程，系统登录进程以及由init启动的进程，当前运行级和最后一次系统时钟的变化|

## 资源

### 磁盘空间  
| 命令 | 说明 |
|--------|--------|
|\# df \-h|显示已经挂载的分区列表|
|\# du \-sh dir1|估算目录 'dir1' 已经使用的磁盘空间|
|\# du \-sk \* &#124; sort \-rn|以容量大小为依据依次显示文件和目录的大小|
|\# ls \-lSr &#124; more|以尺寸大小排列文件和目录|
|\# rpm \-q \-a \-\-qf '%10\{SIZE\}t%\{NAME\}n' &#124; sort \-k1,1n|以大小为依据依次显示已安装的rpm包所使用的空间 \(centos, redhat, fedora类系统\)|


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
|\# cp file file1|将file复制为file1|
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
|\# mv dir1 new\_dir|重命名/移动 一个目录|
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
|\# find /usr/bin \-type f \-atime \+100|搜索在过去100天内未被使用过的执行文件|
|\# find /usr/bin \-type f \-mtime \-10|搜索在10天内被创建或者修改过的文件|
|\# find / \-name \*\.rpm \-exec chmod 755 '\{\}' \\;|搜索以 '\.rpm' 结尾的文件并定义其权限|
|\# find / \-xdev \-name \\\*\.rpm|搜索以 '\.rpm' 结尾的文件，忽略光驱、捷盘等可移动设备|
|\# locate \\\*\.ps|寻找以 '\.ps' 结尾的文件 \- 先运行 'updatedb' 命令|
|\# whereis halt|显示一个二进制文件、源码或man的位置|
|\# which halt|显示一个二进制文件或可执行文件的完整路径|
  
### 文件的权限  
| 命令 | 说明 |
|--------|--------|
|\# chgrp group1 file1|改变文件的群组|
|\# chmod ugo\+rwx directory1|设置目录的所有人\(u\)、群组\(g\)以及其他人\(o\)以读\(r\)、写\(w\)和执行\(x\)的权限|
|\# chmod go\-rwx directory1|删除群组\(g\)与其他人\(o\)对目录的读写执行权限|
|\# chmod u\+s /bin/file1|设置一个二进制文件的 SUID 位 \- 运行该文件的用户也被赋予和所有者同样的权限|
|\# chmod u\-s /bin/file1|禁用一个二进制文件的 SUID 位|
|\# chmod g\+s /home/public|设置一个目录的 SGID 位 \- 类似SUID，不过这是针对目录的|
|\# chmod g\-s /home/public|禁用一个目录的 SGID 位|
|\# chmod o\+t /home/public|设置一个文件的 STIKY 位 \- 只允许合法所有人删除文件|
|\# chmod o\-t /home/public|禁用一个目录的 STIKY 位|
|\# chown user1 file1|改变一个文件的所有人属性|
|\# chown \-R user1 directory1|改变一个目录的所有人属性并同时改变改目录下所有文件的属性|
|\# chown user1:group1 file1|改变一个文件的所有人和群组属性|
|\# find / \-perm \-u\+s|罗列一个系统中所有使用了SUID控制的文件|
|\# ls \-lh|显示权限|
|\# ls /tmp &#124; pr \-T5 \-W$COLUMNS|将终端划分成5栏显示|
  
### 文件的特殊属性  
| 命令 | 说明 |
|--------|--------|
|\# chattr \+a file1|只允许以追加方式读写文件|
|\# chattr \+c file1|允许这个文件能被内核自动压缩/解压|
|\# chattr \+d file1|在进行文件系统备份时，dump程序将忽略这个文件|
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
|\# cat example\.txt &#124; awk 'NR%2==1'|删除example\.txt文件中的所有偶数行|
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
|\# sed 's/string1/string2/g' example\.txt|将example\.txt文件中的 "string1" 替换成 "string2"|
|\# sed '/^$/d' example\.txt|从example\.txt文件中删除所有空白行|
|\# sed '/ \*&#124;\#/d; /^$/d' example\.txt|去除文件example\.txt中的注释与空行|
|\# sed \-e '1d' exampe\.txt|从文件example\.txt 中排除第一行|
|\# sed \-n '/string1/p'|查看只包含词汇 "string1"的行|
|\# sed \-e 's/ \*$//' example\.txt|删除每一行最后的空白字符|
|\# sed \-e 's/string1//g' example\.txt|从文档中只删除词汇 "string1" 并保留剩余全部|
|\# sed \-n '1,5p' example\.txt|显示文件1至5行的内容|
|\# sed \-n '5p;5q' example\.txt|显示example\.txt文件的第5行内容|
|\# sed \-e 's/00\*/0/g' example\.txt|用单个零替换多个零|
|\# sort file1 file2|排序两个文件的内容|
|\# sort file1 file2 &#124; uniq|取出两个文件的并集\(重复的行只保留一份\)|
|\# sort file1 file2 &#124; uniq \-u|删除交集，留下其他的行|
|\# sort file1 file2 &#124; uniq \-d|取出两个文件的交集\(只留下同时存在于两个文件中的文件\)|
|\# echo 'word' &#124; tr '\[:lower:\]' '\[:upper:\]'|合并上下单元格内容|
  
### 字符设置和文件格式  
| 命令 | 说明 |
|--------|--------|
|\# dos2unix filedos\.txt fileunix\.txt|将一个文本文件的格式从MSDOS转换成UNIX|
|\# recode \.\.HTML < page\.txt > page\.html|将一个文本文件转换成html|
|\# recode \-l &#124; more|显示所有允许的转换格式|
|\# unix2dos fileunix\.txt filedos\.txt|将一个文本文件的格式从UNIX转换成MSDOS|

## 挂载

### 挂载一个文件系统  
| 命令 | 说明 |
|--------|--------|
|\# fuser \-km /mnt/hda2|当设备繁忙时强制卸载|
|\# mount /dev/hda2 /mnt/hda2|挂载一个叫做hda2的盘 \- 确保目录 '/mnt/hda2' 已经存在|
|\# mount /dev/fd0 /mnt/floppy|挂载一个软盘|
|\# mount /dev/cdrom /mnt/cdrom|挂载一个cdrom或dvdrom|
|\# mount /dev/hdc /mnt/cdrecorder|挂载一个cdrw或dvdrom|
|\# mount /dev/hdb /mnt/cdrecorder|挂载一个cdrw或dvdrom|
|\# mount \-o loop file\.iso /mnt/cdrom|挂载一个文件或ISO镜像文件|
|\# mount \-t vfat /dev/hda5 /mnt/hda5|挂载一个Windows FAT32文件系统|
|\# mount /dev/sda1 /mnt/usbdisk|挂载一个U盘或闪存设备|
|\# mount \-t smbfs \-o username=user,password=pass //WinClient/share /mnt/share|挂载一个windows网络共享|
|\# umount /dev/hda2|卸载一个叫做hda2的盘 \- 先从挂载点 '/mnt/hda2' 退出|
|\# umount \-n /mnt/hda2|运行卸载操作而不写入 /etc/mtab 文件\- 当文件为只读或当磁盘写满时非常有用|

### 光盘  
| 命令 | 说明 |
|--------|--------|
|\# cd\-paranoia \-B|从一个CD光盘转录音轨到 wav 文件中|
|\# cd\-paranoia \-\-|从一个CD光盘转录音轨到 wav 文件中（参数\-3）|
|\# cdrecord \-v gracetime=2 dev=/dev/cdrom \-eject blank=fast \-force|清空一个可复写的光盘内容|
|\# cdrecord \-v dev=/dev/cdrom cd\.iso|刻录一个ISO镜像文件|
|\# gzip \-dc cd\_iso\.gz &#124; cdrecord dev=/dev/cdrom \-|刻录一个压缩了的ISO镜像文件|
|\# cdrecord \-\-scanbus|扫描总线以识别scsi通道|
|\# dd if=/dev/hdc &#124; md5sum|校验一个设备的md5sum编码，例如一张 CD|
|\# mkisofs /dev/cdrom > cd\.iso|在磁盘上创建一个光盘的iso镜像文件|
|\# mkisofs /dev/cdrom &#124; gzip > cd\_iso\.gz|在磁盘上创建一个压缩了的光盘iso镜像文件|
|\# mkisofs \-J \-allow\-leading\-dots \-R \-V|创建一个目录的iso镜像文件|
|\# mount \-o loop cd\.iso /mnt/iso|挂载一个ISO镜像文件|
  
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
|\# passwd user1|修改一个用户的口令 \(只允许root执行\)|
|\# pwck|检查 '/etc/passwd' 的文件格式和语法修正以及存在的用户|
|\# useradd \-c "User Linux" \-g admin \-d /home/user1 \-s /bin/bash user1|创建一个属于 "admin" 用户组的用户|
|\# useradd user1|创建一个新用户|
|\# userdel \-r user1|删除一个用户 \( '\-r' 排除主目录\)|
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
|\# rar x file1\.rar|解压rar包|
|\# tar \-cvf archive\.tar file1|创建一个非压缩的 tarball|
|\# tar \-cvf archive\.tar file1 file2 dir1|创建一个包含了 'file1', 'file2' 以及 'dir1'的档案文件|
|\# tar \-tf archive\.tar|显示一个包中的内容|
|\# tar \-xvf archive\.tar|释放一个包|
|\# tar \-xvf archive\.tar \-C /tmp|将压缩包释放到 /tmp目录下|
|\# tar \-cvfj archive\.tar\.bz2 dir1|创建一个bzip2格式的压缩包|
|\# tar \-xvfj archive\.tar\.bz2|解压一个bzip2格式的压缩包|
|\# tar \-cvfz archive\.tar\.gz dir1|创建一个gzip格式的压缩包|
|\# tar \-xvfz archive\.tar\.gz|解压一个gzip格式的压缩包|
|\# unrar x file1\.rar|解压rar包|
|\# unzip file1\.zip|解压一个zip格式压缩包|
|\# zip file1\.zip file1|创建一个zip格式的压缩包|
|\# zip \-r file1\.zip file1 file2 dir1|将几个文件和目录同时压缩成一个zip格式的压缩包|
  
### RPM包 \(Fedora,RedHat and alike\)  
| 命令 | 说明 |
|--------|--------|
|\# rpm \-ivh \[package\.rpm\]|安装一个rpm包|
|\# rpm \-ivh \-\-nodeeps \[package\.rpm\]|安装一个rpm包而忽略依赖关系警告|
|\# rpm \-U \[package\.rpm\]|更新一个rpm包但不改变其配置文件|
|\# rpm \-F \[package\.rpm\]|更新一个确定已经安装的rpm包|
|\# rpm \-e \[package\]|删除一个rpm包|
|\# rpm \-qa|显示系统中所有已经安装的rpm包|
|\# rpm \-qa &#124; grep httpd|显示所有名称中包含 "httpd" 字样的rpm包|
|\# rpm \-qi \[package\]|获取一个已安装包的特殊信息|
|\# rpm \-qg "System Environment/Daemons"|显示一个组件的rpm包|
|\# rpm \-ql \[package\]|显示一个已经安装的rpm包提供的文件列表|
|\# rpm \-qc \[package\]|显示一个已经安装的rpm包提供的配置文件列表|
|\# rpm \-q \[package\] \-\-whatrequires|显示与一个rpm包存在依赖关系的列表|
|\# rpm \-q \[package\] \-\-whatprovides|显示一个rpm包所占的体积|
|\# rpm \-q \[package\] \-\-scripts|显示在安装/删除期间所执行的脚本l|
|\# rpm \-q \[package\] \-\-changelog|显示一个rpm包的修改历史|
|\# rpm \-qf /etc/httpd/conf/httpd\.conf|确认所给的文件由哪个rpm包所提供|
|\# rpm \-qp \[package\.rpm\] \-l|显示由一个尚未安装的rpm包提供的文件列表|
|\# rpm \-\-import /media/cdrom/RPM\-GPG\-KEY|导入公钥数字证书|
|\# rpm \-\-checksig \[package\.rpm\]|确认一个rpm包的完整性|
|\# rpm \-qa gpg\-pubkey|确认已安装的所有rpm包的完整性|
|\# rpm \-V \[package\]|检查文件尺寸、 许可、类型、所有者、群组、MD5检查以及最后修改时间|
|\# rpm \-Va|检查系统中所有已安装的rpm包\- 小心使用|
|\# rpm \-Vp \[package\.rpm\]|确认一个rpm包还未安装|
|\# rpm \-ivh /usr/src/redhat/RPMS/\`arch\`/\[package\.rpm\]|从一个rpm源码安装一个构建好的包|
|\# rpm2cpio \[package\.rpm\] &#124; cpio \-\-extract \-\-make\-directories \*bin\*|从一个rpm包运行可执行文件|
|\# rpmbuild \-\-rebuild \[package\.src\.rpm\]|从一个rpm源码构建一个 rpm 包|
  
### YUM 软件工具 \(Fedora,RedHat and alike\)  
| 命令 | 说明 |
|--------|--------|
|\# yum \-y install \[package\]|下载并安装一个rpm包|
|\# yum localinstall \[package\.rpm\]|将安装一个rpm包，使用你自己的软件仓库为你解决所有依赖关系|
|\# yum \-y update|更新当前系统中所有安装的rpm包|
|\# yum update \[package\]|更新一个rpm包|
|\# yum remove \[package\]|删除一个rpm包|
|\# yum list|列出当前系统中安装的所有包|
|\# yum repolist|显示可用的仓库|
|\# yum search \[package\]|在rpm仓库中搜寻软件包|
|\# yum clean \[package\]|清理rpm缓存删除下载的包|
|\# yum clean headers|删除所有头文件|
|\# yum clean all|删除所有缓存的包和头文件|
  
  
  
### 备份  
| 命令 | 说明 |
|--------|--------|
|\# find /var/log \-name '\*\.log' &#124; tar cv \-\-files\-from=\- &#124; bzip2 > log\.tar\.bz2|查找所有以 '\.log' 结尾的文件并做成一个bzip包|
|\# find /home/user1 \-name '\*\.txt' &#124; xargs cp \-av \-\-target\-directory=/home/backup/ \-\-parents|从一个目录查找并复制所有以 '\.txt' 结尾的文件到另一个目录|
|\# dd bs=1M if=/dev/hda &#124; gzip &#124; ssh user@ip\_addr 'dd of=hda\.gz'|通过ssh在远程主机上执行一次备份本地磁盘的操作|
|\# dd if=/dev/sda of=/tmp/file1|备份磁盘内容到一个文件|
|\# dd if=/dev/hda of=/dev/fd0 bs=512 count=1|做一个将 MBR \(Master Boot Record\)内容复制到软盘的动作|
|\# dd if=/dev/fd0 of=/dev/hda bs=512 count=1|从已经保存到软盘的备份中恢复MBR内容|
|\# dump \-0aj \-f /tmp/home0\.bak /home|制作一个 '/home' 目录的完整备份|
|\# dump \-1aj \-f /tmp/home0\.bak /home|制作一个 '/home' 目录的交互式备份|
|\# restore \-if /tmp/home0\.bak|还原一个交互式备份|
|\# rsync \-rogpav \-\-delete /home /tmp|同步两边的目录|
|\# rsync \-rogpav \-e ssh \-\-delete /home ip\_address:/tmp|通过SSH通道rsync|
|\# rsync \-az \-e ssh \-\-delete ip\_addr:/home/public /home/local|通过ssh和压缩将一个远程目录同步到本地目录|
|\# rsync \-az \-e ssh \-\-delete /home/local ip\_addr:/home/public|通过ssh和压缩将本地目录同步到远程目录|
|\# tar \-Puf backup\.tar /home/user|执行一次对 '/home/user' 目录的交互式备份操作|
|\# \( cd /tmp/local/ && tar c \. \) &#124; ssh \-C user@ip\_addr 'cd /home/share/ && tar x \-p'|通过ssh在远程目录中复制一个目录内容|
|\# \( tar c /home \) &#124; ssh \-C user@ip\_addr 'cd /home/backup\-home && tar x \-p'|通过ssh在远程目录中复制一个本地目录|
|\# tar cf \- \. &#124; \(cd /tmp/backup ; tar xf \- \)|本地将一个目录复制到另一个地方，保留原有权限及链接|
  

## 磁盘和分区

### 文件系统分析  
| 命令 | 说明 |
|--------|--------|
|\# badblocks \-v /dev/hda1|检查磁盘hda1上的坏磁块|
|\# dosfsck /dev/hda1|修复/检查hda1磁盘上dos文件系统的完整性|
|\# e2fsck /dev/hda1|修复/检查hda1磁盘上ext2文件系统的完整性|
|\# e2fsck \-j /dev/hda1|修复/检查hda1磁盘上ext3文件系统的完整性|
|\# fsck /dev/hda1|修复/检查hda1磁盘上linux文件系统的完整性|
|\# fsck\.ext2 /dev/hda1|修复/检查hda1磁盘上ext2文件系统的完整性|
|\# fsck\.ext3 /dev/hda1|修复/检查hda1磁盘上ext3文件系统的完整性|
|\# fsck\.vfat /dev/hda1|修复/检查hda1磁盘上fat文件系统的完整性|
|\# fsck\.msdos /dev/hda1|修复/检查hda1磁盘上dos文件系统的完整性|
  
### 初始化一个文件系统  
| 命令 | 说明 |
|--------|--------|
|\# fdformat \-n /dev/fd0|格式化一个软盘|
|\# mke2fs /dev/hda1|在hda1分区创建一个linux ext2的文件系统|
|\# mke2fs \-j /dev/hda1|在hda1分区创建一个linux ext3\(日志型\)的文件系统|
|\# mkfs /dev/hda1|在hda1分区创建一个文件系统|
|\# mkfs \-t vfat 32 \-F /dev/hda1|创建一个 FAT32 文件系统|
|\# mkswap /dev/hda3|创建一个swap文件系统|
  
### SWAP 文件系统  
| 命令 | 说明 |
|--------|--------|
|\# mkswap /dev/hda3|创建一个swap文件系统|
|\# swapon /dev/hda3|启用一个新的swap文件系统|
|\# swapon /dev/hda2 /dev/hdb3|启用两个swap分区|
  
## 网络

### 网络 \(LAN / WiFi\)  
| 命令 | 说明 |
|--------|--------|
|\# dhclient eth0|以dhcp模式启用 'eth0' 网络设备|
|\# ethtool eth0|显示网卡 'eth0' 的流量统计|
|\# host www\.example\.com|查找主机名以解析名称与IP地址及镜像|
|\# hostname|显示主机名|
|\# ifconfig eth0|显示一个以太网卡的配置|
|\# ifconfig eth0 192\.168\.1\.1 netmask 255\.255\.255\.0|控制IP地址|
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
|\# nslookup www\.example\.com|查找主机名以解析名称与IP地址及镜像|
|\# route \-n|显示路由表|
|\# route add \-net 0/0 gw IP\_Gateway|控制预设网关|
|\# route add \-net 192\.168\.0\.0 netmask 255\.255\.0\.0 gw 192\.168\.1\.1|控制通向网络 '192\.168\.0\.0/16' 的静态路由|
|\# route del 0/0 gw IP\_gateway|删除静态路由|
|\# echo "1" > /proc/sys/net/ipv4/ip\_forward|激活IP转发|
|\# tcpdump tcp port 80|显示所有 HTTP回环|
|\# whois www\.example\.com|在 Whois 数据库中查找|
  
### Microsoft windows 网络 \(samba\)  
| 命令 | 说明 |
|--------|--------|
|\# mount \-t smbfs \-o username=user,password=pass //WinClient/share /mnt/share|挂载一个windows网络共享|
|\# nbtscan ip\_addr|netbios名解析|
|\# nmblookup \-A ip\_addr|netbios名解析|
|\# smbclient \-L ip\_addr/hostname|显示一台windows主机的远程共享|
|\# smbget \-Rr smb://ip\_addr/share|像wget一样能够通过smb从一台windows主机上下载文件|
  
### IPTABLES \(firewall\)  
| 命令 | 说明 |
|--------|--------|
|\# iptables \-t filter \-L|显示过滤表的所有链路|
|\# iptables \-t nat \-L|显示nat表的所有链路|
|\# iptables \-t filter \-F|以过滤表为依据清理所有规则|
|\# iptables \-t nat \-F|以nat表为依据清理所有规则|
|\# iptables \-t filter \-X|删除所有由用户创建的链路|
|\# iptables \-t filter \-A INPUT \-p tcp \-\-dport telnet \-j ACCEPT|允许telnet接入|
|\# iptables \-t filter \-A OUTPUT \-p tcp \-\-dport http \-j DROP|阻止 HTTP 连出|
|\# iptables \-t filter \-A FORWARD \-p tcp \-\-dport pop3 \-j ACCEPT|允许转发链路上的 POP3 连接|
|\# iptables \-t filter \-A INPUT \-j LOG \-\-log\-prefix|记录所有链路中被查封的包|
|\# iptables \-t nat \-A POSTROUTING \-o eth0 \-j MASQUERADE|设置一个 PAT \(端口地址转换\) 在 eth0 掩盖发出包|
|\# iptables \-t nat \-A PREROUTING \-d 192\.168\.0\.1 \-p tcp \-m tcp \-\-dport 22 \-j DNAT \-\-to\-destination 10\.0\.0\.2:22|将发往一个主机地址的包转向到其他主机|
  

# ssh

## ssh登陆原理以及端口转发

### 简介：
SSH，全名secure shell，其目的是用来从终端与远程机器交互，SSH设计之处初，遵循了如下原则：

  * 机器之间通讯的内容必须经过加密。
  * 加密过程中，通过 public key加密，private 解密。

### 密钥:
SSH通讯的双方各自持有一个公钥私钥对，公钥对对方是可见的，私钥仅持有者可见，你可以通过"ssh-keygen"生成自己的公私钥，默认情况下，公私钥的存放路径如下：    

  * 公钥：$HOME/.ssh/id_rsa.pub
  * 私钥：$HOME/.ssh/id_rsa

### 基于口令的安全验证通讯原理：

  建立通信通道的步骤如下：

```
  1.远程主机将公钥发给用户----远程主机收到用户的登录请求，把自己的公钥发给客户端,客户端检查这个public key是否在自己的$HOME/.ssh/known_hosts中，如果没有，客户端会提示是否要把这个public key加入到known_hosts中.
  2.用户使用公钥加密密码------用户使用这个公钥，将登录密码加密后，发送回来
  3.远程主机使用私钥加密------远程主机用自己的私钥，解密登录密码，如果密码正确，就同意用户登录。
  4.客户端把PUBLIC KEY(client), 发送给服务器。
  5.至此，到此为止双方彼此拥有了对方的公钥，开始双向加密解密。
```

PS：当网络中有另一台冒牌服务器冒充远程主机时，客户端的连接请求被服务器B拦截，服务器B将自己的公钥发送给客户端，客户端就会将密码加密后发送给冒牌服务器，冒牌服务器就可以拿自己的私钥获取到密码，然后为所欲为。因此当第一次链接远程主机时，在上述步骤中，会提示您当前远程主机的”公钥指纹”，以确认远程主机是否是正版的远程主机，如果选择继续后就可以输入密码进行登录了，当远程的主机接受以后，该台服务器的公钥就会保存到 ~/.ssh/known_hosts文件中。

### 基于密匙的安全验证通讯原理：

这种方式你需要在当前用户家目录下为自己创建一对密匙，并把公匙放在需要登录的服务器上。当你要连接到服务器上时，客户端就会向服务器请求使用密匙进行安全验证。服务器收到请求之后，会在该服务器上你所请求登录的用户的家目录下寻找你的公匙，然后与你发送过来的公匙进行比较。如果两个密匙一致，服务器就用该公匙加密“质询”并把它发送给客户端。客户端收到“质询”之后用自己的私匙解密再把它发送给服务器。与第一种级别相比，第二种级别不需要在网络上传送口令。

PS：简单来说，就是将客户端的公钥放到服务器上，那么客户端就可以免密码登录服务器了，那么客户端的公钥应该放到服务器上哪个地方呢？默认为你要登录的用户的家目录下的 .ssh 目录下的 authorized_keys 文件中（即：~/.ssh/authorized_keys）。
我们的目标是: 用户已经在主机A上登录为a用户，现在需要以不输入密码的方式以用户b登录到主机B上。   

可以把密钥理解成一把钥匙, 公钥理解成这把钥匙对应的锁头,
把锁头(公钥)放到想要控制的server上, 锁住server, 只有拥有钥匙(密钥)的人,
才能打开锁头, 进入server并控制
而对于拥有这把钥匙的人, 必需得知道钥匙本身的密码,才能使用这把钥匙(除非这把钥匙没设置密码), 这样就可以防止钥匙被了配了(私钥被人复制)
 
当然, 这种例子只是方便理解罢了,
拥有root密码的人当然是不会被锁住的, 而且不一定只有一把锁(公钥),
但如果任何一把锁, 被人用其对应的钥匙(私钥)打开了, server就可以被那个人控制了
所以说, 只要你曾经知道server的root密码, 并将有root身份的公钥放到上面,
就可以用这个公钥对应的私钥"打开" server, 再以root的身分登录,即使现在root密码已经更改!

步骤如下：

  1. 以用户a登录到主机A上，生成一对公私钥。
  2. 把主机A的公钥复制到主机B的authorized_keys中，可能需要输入b@B的密码。

	    ssh-copy-id -i ~/.ssh/id_dsa.pub b@B
  3. 在a@A上以免密码方式登录到b@B

  		ssh b@B

tips:

   假如B机器修改端口后，将主机A上的公钥复制到B机的操作方法是(下面方法中双引号是必须的)：

   ssh-copy-id "-p 端口号 b@B"

### SSH forwarding:

SSH 端口转发自然需要 SSH 连接，而 SSH 连接是有方向的，从 SSH Client 到 SSH Server 。
而我们所要访问的应用也是有方向的，应用连接的方向也是从应用的 Client端连接到应用的 Server端。
比如需要我们要访问Internet上的Web站点时，Http应用的方向就是从我们自己这台主机(Client)到远处的Web Server。

如果SSH连接和应用的连接这两个连接的方向一致，那我们就说它是本地转发。

本地转发Local Forward
```
ssh -L <local port>:<remote host>:<remote port> <SSH hostname>
```
ssh  -L 1433:target_server:1433 user@ssh_host

**xshell**

```
(1)ssh远程连接到Linux
(2)打开代理设置面板，点击:view -> Tunneling Pane,在弹出的窗口选择Forwarding Rules
(3)在空白处右键：add。
在弹出的Forwarding Rule，
Type选择"Local(Outgoing)";
Source Host使用默认的localhost; Listen Port添上端口8888;
Destination Host使用默认的localhost；Destination Port添上80;

Destination Host设置为localhost为要访问的机器，可以设置为登陆后的机器可以访问到的IP
```

如果SSH连接和应用的连接这两个连接的方向不同，那我们就说它是远程转发。
```
ssh -R <local port>:<remote host>:<remote port> <SSH hostname>
```


### windows ---xshell

  * 私钥,在Xshell里也叫用户密钥
  * 公钥,在Xshell里也叫主机密钥
   利用xshell密钥管理服务器远程登录,
   (1)Xshell自带有用户密钥生成向导,:点击菜单栏的工具->新建用户密钥生成向导 
   (2)添加公钥(Pubic Key)到远程Linux服务器

# 用户管理

## Linux踢出其他正在SSH登陆用户

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
***用pkill 命令剔除对方***

```
[root@Linux ~]# pkill -kill -t pts/2
[root@Linux ~]# w
 20:44:15 up 1 day, 27 min,  3 users,  load average: 0.01, 0.03, 0.01
 USER     TTY      FROM              LOGIN@   IDLE   JCPU   PCPU WHAT
 root     tty1     -                Fri09   10:14m  0.34s  0.34s -bash
 root     pts/3    192.168.31.124   19:55   51.00s  1.43s  1.35s vim base.md
 root     pts/4    192.168.31.124   19:55    0.00s  0.21s  0.00s w
```
如果最后查看还是没有干掉，建议加上-9 强制杀死。
[root@Linux ~]# pkill -9 -t pts/2

## 使用脚本创建用户，同时用户有 sudo 权限

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

# 其他设置


## 时区及时间

时区就是时间区域，主要是为了克服时间上的混乱，统一各地时间。地球上共有 24 个时区，东西各 12 个时区（东12与西12合二为一）。

### UTC 和 GMT

时区通常写成`+0800`，有时也写成`GMT +0800`，其实这两个是相同的概念。

GMT 是格林尼治标准时间（Greenwich Mean Time）。

UTC 是协调世界时间（Universal Time Coordinated），又叫世界标准时间，其实就是`0000`时区的时间。

### 时间换算

通常当有跨区域的会议时，一般大家都用 UTC 来公布，比如某个会议在`UTC 20:00 周三`开始，按照时间换算规则：

计算的区时=已知区时-（已知区时的时区-要计算区时的时区）

中国北京时间是：20:00 - ( 0 - 8 ) = 1天 + 04:00，即北京时间周四早上 04:00 。

### Linux 下调整时区及更新时间

修改系统时间

```
# ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
```
修改/etc/sysconfig/clock文件，修改为：

```
ZONE=”Asia/Shanghai”
UTC=false
ARC=false
```
校对时间
```
#ntpdate cn.ntp.org.cn
```
设置硬件时间和系统时间一致并校准
```
#/sbin/hwclock --systohc
```

***定时同步时间设置***

凌晨 5 点定时同步时间

```
echo "0 5 * * *  /usr/sbin/ntpdate cn.ntp.org.cn" >> /var/spool/cron/root
或者
echo "0 5 * * *  /usr/sbin/ntpdate 133.100.11.8" >> /var/spool/cron/root

```
# CentOS 7 vs CentOS 6的不同

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

    [CentOS6] /bin, /sbin, /lib, and /lib64在/下
    [CentOS7] /bin, /sbin, /lib, and /lib64移到/usr下

**主机名**

    [CentOS6] /etc/sysconfig/network
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

    1)关闭
    [CentOS6]
    $ shutdown -h now 

    [CentOS7]
    $ poweroff
    $ systemctl poweroff

    2)重启
    [CentOS6]
    $ reboot
    $ shutdown -r now

    [CentOS7]
    $ reboot
    $ systemctl reboot

    3)单用户模式
    [CentOS6]
    $ init S

    [CentOS7]
    $ systemctl rescue

    4)启动模式
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
    $ systemctl set-default multi-user.target
    当前
    $ systemctl get-default

## 服务相关

**启动停止**

    [CentOS6]
    $ service service_name start
    $ service service_name stop
    $ service sshd restart/status/reload

    [CentOS7]
    $ systemctl start service_name
    $ systemctl stop service_name
    $ systemctl restart/status/reload sshd

**自启动**

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

**IP地址MAC地址**

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
