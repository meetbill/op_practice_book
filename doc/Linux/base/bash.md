# Bash基础特性
## 目录
* [01命令历史](#01命令历史)
* [02命令补全](#02命令补全)
* [03路径补全](#03路径补全)
* [04命令行展开](#04命令行展开)
* [05命令的执行状态结果](#05命令的执行状态结果)
* [06命令别名](#06命令别名)
	* [User specific aliases and functions](#user-specific-aliases-and-functions)
* [07通配符glob](#07通配符glob)
* [08bash快捷键](#08bash快捷键)
	* [编辑命令：](#编辑命令)
	* [重新执行命令：](#重新执行命令)
	* [控制命令：](#控制命令)
	* [Bang (!) 命令](#bang--命令)
	* [友情提示：](#友情提示)
* [09bash的io重定向及管道](#09bash的io重定向及管道)
	* [I/O重定向：改变标准位置；](#io重定向改变标准位置)

## 01命令历史
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
         
[返回目录](#目录)

## 02命令补全
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

[返回目录](#目录)

## 03路径补全

以用户输入的字符串作为路径开头，并在其指定路径的上级目录下搜索以指定字符串开头的文件名；       

    如果唯一，则直接补全；     

    否则，再次Tab，列出所有符合条件的路径及文件；  

[返回目录](#目录)


## 04命令行展开
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

## 05命令的执行状态结果
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

[返回目录](#目录)

## 06命令别名
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

[返回目录](#目录)

## 07通配符glob

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

[返回目录](#目录)

## 08bash快捷键

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

## 09bash的io重定向及管道
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

[返回目录](#目录)

