## linux基础

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
* [ssh](#ssh)
	* [ssh登陆原理以及端口转发](#ssh登陆原理以及端口转发)
		* [简介：](#简介)
		* [密钥:](#密钥)
		* [基于口令的安全验证通讯原理：](#基于口令的安全验证通讯原理)
		* [基于密匙的安全验证通讯原理：](#基于密匙的安全验证通讯原理)
		* [SSH forwarding:](#ssh-forwarding)
		* [windows ---xshell](#windows----xshell)
* [用户管理](#用户管理)
	* [Linux踢出其他正在SSH登陆用户](#linux踢出其他正在ssh登陆用户)
		* [查看系统在线用户](#查看系统在线用户)
		* [查看当前自己占用终端](#查看当前自己占用终端)
		* [用pkill 命令剔除对方](#用pkill-命令剔除对方)
	* [使用脚本创建用户，同时用户有 sudo 权限](#使用脚本创建用户同时用户有-sudo-权限)
* [其他设置](#其他设置)
	* [时区及时间](#时区及时间)
		* [UTC 和 GMT](#utc-和-gmt)
		* [时间换算](#时间换算)
		* [Linux 下调整时区及更新时间](#linux-下调整时区及更新时间)

# Bash基础特性
## 命令历史
（1） 使用命令：history

（2） 环境变量：

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



（5） 控制命令历史的记录方式：

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


[返回目录](#目录)

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

### 查看系统在线用户

```
[root@Linux ~]#w
 20:40:18 up 1 day, 23 min,  4 users,  load average: 0.00, 0.00, 0.00
USER     TTY      FROM              LOGIN@   IDLE   JCPU   PCPU WHAT
root     tty1     -                Fri09   10:10m  0.34s  0.34s -bash
root     pts/2    192.168.31.124   10:30    4:39m  0.99s  0.99s -bash
root     pts/3    192.168.31.124   19:55    0.00s  0.07s  0.00s w
root     pts/4    192.168.31.124   19:55    4:52   0.16s  0.16s -bash
```
### 查看当前自己占用终端

```
[root@Linux ~]# who am i             
root     pts/4        2016-10-30 19:55 (192.168.31.124)
```
### 用pkill 命令剔除对方

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
