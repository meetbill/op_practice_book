# shell 基础及实例

<!-- vim-markdown-toc GFM -->
* [01 shell 编程环境](#01-shell-编程环境)
* [02 bash 变量类型](#02-bash-变量类型)
* [03 bash 的配置文件](#03-bash-的配置文件)
* [04 bash 中的算术运算符](#04-bash-中的算术运算符)
* [05 条件测试](#05-条件测试)
    * [Bash 的测试类型](#bash-的测试类型)
    * [文件测试](#文件测试)
* [06 bash 脚本编程之用户交互](#06-bash-脚本编程之用户交互)
* [07 流程控制](#07-流程控制)
    * [if 语句](#if-语句)
    * [for 循环](#for-循环)
        * [Example 判断某路径下所有文件的类型](#example-判断某路径下所有文件的类型)
        * [Example 使用 for 循环统计关于 tcp 端口监听状态](#example-使用-for-循环统计关于-tcp-端口监听状态)
        * [Example 通过 ping 命令探测 192.168.0.1-254 范围内的所有主机的在线状态](#example-通过-ping-命令探测-19216801-254-范围内的所有主机的在线状态)
    * [while 循环](#while-循环)
        * [Example 用 while 求 100 以内所有正整数之和](#example-用-while-求-100-以内所有正整数之和)
        * [Example 用 while 添加 10 个用户](#example-用-while-添加-10-个用户)
        * [Example 使用 while 循环 ping 指定网络内的所有主机](#example-使用-while-循环-ping-指定网络内的所有主机)
        * [Example 利用 RANDOM 生成 10 个随机数字，输出这 10 个数字，并显示其中的最大者和最小者](#example-利用-random-生成-10-个随机数字输出这-10-个数字并显示其中的最大者和最小者)
    * [创建死循环](#创建死循环)
    * [while 循环的特殊用法：（遍历文件的每一行）](#while-循环的特殊用法遍历文件的每一行)
    * [for 循环的特殊格式：](#for-循环的特殊格式)
        * [Example 求 100 以内所有正整数之和](#example-求-100-以内所有正整数之和)
        * [Example 菜单](#example-菜单)
    * [case 语句](#case-语句)
        * [Example 使用 case 语句改写前一个练习：](#example-使用-case-语句改写前一个练习)
* [08 函数](#08-函数)
        * [Example 通过函数，创建 10 个用户](#example-通过函数创建-10-个用户)
        * [Example 编写一个服务启动关闭脚本](#example-编写一个服务启动关闭脚本)
    * [函数返回值](#函数返回值)
        * [Example 求 N 的阶乘](#example-求-n-的阶乘)
* [09 数组](#09-数组)
    * [数组](#数组)
        * [Example 生成 10 个随机数保存于数组中，并找出其最大值和最小值：](#example-生成-10-个随机数保存于数组中并找出其最大值和最小值)
        * [Example 写一个脚本：定义一个数组，数组中的元素是 /var/log 目录下所有以.log 结尾的文件；要统计其下标为偶数的文件中的行数之和；](#example-写一个脚本定义一个数组数组中的元素是-varlog-目录下所有以log-结尾的文件要统计其下标为偶数的文件中的行数之和)
    * [引用数组中的元素：](#引用数组中的元素)
* [10 bash 的字符串处理工具](#10-bash-的字符串处理工具)
    * [字符串切片：](#字符串切片)
    * [基于模式取子串：](#基于模式取子串)
        * [Exampleurl=http://www.google.com:80, 分别取出协议和端口；](#exampleurlhttpwwwgooglecom80-分别取出协议和端口)
    * [查找替换](#查找替换)
    * [查找并删除](#查找并删除)
    * [字符大小写转换：](#字符大小写转换)
    * [变量赋值](#变量赋值)
* [11 脚本的配置文件](#11-脚本的配置文件)
    * [步骤](#步骤)

<!-- vim-markdown-toc -->

## 01 shell 编程环境
- 编程基础知识：

    1、程序编程风格：

        过程式：以指令为中心，数据服务于指令；

        对象式：以数据为中心，指令服务于数据；

    shell 程序，提供了编程能力，解释执行，shell 就是一解释器；

    2、程序的执行方式：

        计算机：运行二进制命令；

        编程语言：

            低级：汇编；

            高级：

                编译型语言：高级语言 -->编译器 --> 目标代码；

                解释型语言：高级语言 -->解释器 --> 机器代码；

    3、过程式编程的三种结构；

        顺序执行；

        循环执行；

        选择执行；

    4、shell 编程：过程式语言，由解释器解释执行；

        编程语言的基本结构：

           数据存储： 变量、数组；

           表达式；

           语句；

    5、shell 脚本：文本文件；

        首行特定格式：

            `#!/bin/bash`

    6、运行脚本的两种方式：

        a、 给予执行权限，通过具体的文件路径指定文件执行；

        b、 直接运行解释器，将脚本作为解释器程序的参数运行；

Example
```
    [root@localhost test1]# vim test.sh
    [root@localhost test1]# bash test.sh
    hello,girl
    [root@localhost test1]# chmod +x test.sh
    [root@localhost test1]# ./test.sh
    hello,girl
```

- Bash 编程：

    bash 是弱类型编程，变量默认为字符型；

    把所有要存储的数据统统当做字符进行存储；

    变量不需要事先声明，可以在调用时直接赋值使用，参与运算会自动进行隐式类型转换；

    不支持浮点数；

- 逻辑运算：

     与：&& 同为 1 则为 1，否则为 0；

     或：|| 同为 0 则为 0，否则为 1；

     非：取反，!0 为 1，!1 为 0；

    短路与运算：双目运算符前面的结果为 0，则结果一定为 0，后面的不执行；

    短路或运算：双目运算符前面的结果为 1，则结果一定为 1，后面的不执行；

## 02 bash 变量类型

变量类型决定了变量的数据存储格式、存储空间大小以及变量能参与的运算种类；

- 强弱类型语言的区别：

    强类型：定义变量时必须执行类型、参与运算必须符合类型要求；调用未声明变量会产生错误；

    弱类型：无需指定类型，默认均为字符型；参与运算会自动进行隐式类型转换；变量无需事先定义即可直接调用；

- Bash 中的变量的种类：

 根据变量的生效范围等标准划分：

 1、本地变量：生效范围为当前 shell 进程；对当前 shell 之外的其他 shell 进程，包括当前 shell 的子 shell 进程均无效；

 2、环境变量：生效范围为当前 shell 进程及其子进程；

 3、局部变量：生效范围为当前 shell 进程中某代码片断（通常指函数）

 4、位置变量：$1, $2, ... 来表示，用于让脚本在脚本代码中调用通过命令行传递给它的参数；

 5、特殊变量：$?, $0, $*, $@, $#

         $? : 上一条命令的执行状态结果；
         $0 : 命令本身
         $* : 传递给脚本的所有参数；
         $@ : 传递给脚本的所有参数；
         $# : 传递给脚本的参数的个数；

**本地变量**
1、变量赋值：name='VALUE'

    a) 在赋值时，VALUE 可以使用以下引用：

       【1】可以是直接字符串；name="username"
       【2】变量引用：name=“$username”
       【3】命令引用：name=`COMMAND`,name=$(COMMAND)

2、 变量引用：${name}, 花括号可省略：$name

    引号引用：

         " " ： 弱引用，其中的变量引用会被替换为变量值；

         ' ' ： 强引用，其中的变量不会被替换为变量值，而保持原字符串；

查看所有已定义的变量： #set

销毁变量： # unset name

**环境变量**
    1、变量声明、赋值：
        export name=VALUE
        declare -x name=VALUE
    2、变量引用：
        $name
        ${name}
    3、显示所有环境变量：
        export
        env
        printenv
    4、销毁环境变量：
        unset name
- Bash 中内建的环境变量：
    PATH，SHELL，UID，HISTSIZE, HOME, PWD, OLD, HISTFILE, PS1

**只读变量**
相当于常量，变量值不可变，不能再进行赋值运算；

声明只读变量的格式：

    readonly name
    declare –r name

**位置变量**
在脚本代码中调用通过命令行传递给脚本的参数；

    $1,$2,…. : 对应调用第 1、第 2 等参数；

    $0: 命令本身；

    $*: 传递给脚本的所有参数；

    $@: 传递给脚本的所有参数；

    $#: 传递给脚本的参数的个数；

## 03 bash 的配置文件
按生效范围划分，存在两类配置文件：

1、全局配置：

    /etc/profile
        /etc/profile.d/*.sh
    /etc/bashrc
2、用户配置：

    ~/.bash_profile
    ~/.bashrc

按功能划分：也存在两类；

1、profile 类：为交互式登录的 shell 提供配置；

    交互式登录 shell：直接通过终端输入账号密码登录；

    使用“su - UserName”或“su -l UserName”切换的用户

    作用于全局：/etc/profile，/etc/profile.d/*.sh

    作用于个人：~/.bash_profile

- 功用：

    （1）用于定义环境变量；

    （2）运行命令或脚本；

- 配置文件加载顺序：（相同参数，后加载的生效）

         /etc/profile -->
         /etc/profile.d/*.sh -->
         ~/.bash_profile -->
         ~/.bashrc -->
         /etc/bashrc

2、bashrc 类：为非交互式登录的 shell 提供配置：

- 非交互式 Shell：

    su UserName
    图形界面下打开的终端
    执行脚本

    作用于全局：/etc/bashrc
    作用于个人：~/.bashrc

- 功用：

    （1）	定义命令别名；

    （2）	定义本地变量；


- 配置文件加载顺序：（相同参数，后加载的生效）

	~/.bashrc --> /etc/bashrc --> /etc/profile.d/*.sh

- 编辑配置文件后让定义的新配置生效的方式：

	(1) 重新启动 shell 进程；

	(2) 使用 source 或点命令 (　．) 进程；


## 04 bash 中的算术运算符
+，-，*，/，%，**

实现算术运算的方式：

    (1) let var= 算术表达式
    (2) var=$[算术表达式]
    (3) var=$(（算术表达式）)
    (4) var=$(expr arg1 arg2 arg3...)
乘法符号在有些场景中需要转义；

- bash 内建随机数生成器：$RANDOM

- 增强型赋值：
    +=，-=，*=，/=，%=

    let varOPERvalue：

        例如：letcount+=1
- 自增，自减：

    let var+=1

        let var++

    let var-=1

        let var--

- Example
```
#!/bin/bash
spaceline1=$(grep "^[[:space:]]*$" $1 | wc -l)
spaceline2=$(grep "^[[:space:]]*$" $2 | wc -l)
echo "The sum of space line:$[$spaceline1+$spaceline2]"
```

## 05 条件测试
判断某需求是否满足，需要有测试机制来实现；

- Note：专用的测试表达式需要由测试命令辅助完成测试过程；

- 测试命令：

 test EXPRESSION

[ EXPRESSION ]

[[ EXPRESSION ]]

    Note: EXPRESSION 前后必须有空白字符，否则报错；

### Bash 的测试类型

- 数值测试：

 -gt : 是否大于； >

 -ge：是否大于等于； >=

 -eq：是否等于 ==

 -ne：是否不能于 !=

 -lt ：是否小于 <

 -le ：是否小于等于； <=

- 字符串测试：


 == : 是否等于；

 >: 是否大于；

 <: 是否小于；

 != ： 是否不等于；

 =~ ：左侧字符串是否能够被右侧的 PATTERN 所匹配；

 - Note：此表达式一般用于 [[ ]] 中；

 -z “STRING” : 测试字符串是否为空，空则为真，不空则为假；

 -n “STRING” ：测试字符串是否不空，不空则为真，空则为假；

Note：在字符串比较时用到的操作数都应该使用引号；

### 文件测试

- (a) 存在性测试：

    -a FILE

    -e FILE：文件存在性测试，存在为真，否则为假；

- (b) 存在性及类别测试

     -b FILE ：是否存在且为块设备文件；

     -c FILE ：是否存在且为字符设备文件；

     -d FILE ：是否存在且为目录文件；

     -f FILE ：是否存在且为普通文件；

     -h FILE 或 –L FILE：是否存在且为符号链接文件；

     -p FILE：是否存在且为命名管道文件；

     -S FILE ：是否存在且为套接字文件；

- (c) 文件权限测试：

     -r FILE：是否存在且可读

     -w FILE: 是否存在且可写

     -x FILE: 是否存在且可执行

- (d) 文件特殊权限测试：

     -g FILE：是否存在且拥有 sgid 权限；

     -u FILE：是否存在且拥有 suid 权限；

     -k FILE：是否存在且拥有 sticky 权限；

-  (e) 文件大小测试：

     -s FILE：是否存在且非空；

- (f) 文件是否打开：

     -t fd：fd 表示文件描述符是否已经打开且与某终端相关

     -N FILE：文件自从上一次被读取之后是否被修改过；

     -O FILE：当前有效用户是否为文件属主；

     -G FILE：当前有效用户是否为文件属组；

- (g) 双目测试：

    FILE1 –ef FILE2 ： FILE1 与 FILE2 是否指向同一个设备上的相同 inode；

    FILE1 –nt FILE2 ：FILE 是否新于 FILE2；

    FILE1 –ot FILE2 ：FILE1 是否旧于 FILE2；

- (h) 组合测试条件：

 完成逻辑运算：

     第一种方式：

             COMMAND1 && COMMAND2

             COMMAND1 || COMMAND2

             !COMMAND

         eg：[ -e FILE ] && [ -r FILE ] 文件是否存在且是否有读权限；


     第二种方式：

             EXPRESSION1 –a EXPRESSION2

             EXPRESSION1 –o EXPRESSION2

             !EXPRESSION

     必须使用测试命令进行；

- Example
```
# [ -z "$hostName" -o "$hostName"=="localhost.localdomain" ] && hostname hostname_w
# -z 判断 hostName 是否为空，-o 表示或者，即：hostName 为空或者值为 localhot.localdomain 的时候，使用 hostname 命令修改主机名；
```

- Example

```
[root@bill ~]# [ -f /bin/cat -a -x /bin/cat ] && cat /etc/fstab
#判断文件 /bin/cat 是否存在且是否有可执行权限，&& 是短路与，如果前面执行结果为真则使用 cat 命令#查看文件；
#
# /etc/fstab
# Created by anaconda on Fri Jul 3 03:08:29 2015
#
# Accessible filesystems, by reference, are maintained under '/dev/disk'
# See man pages fstab(5), findfs(8), mount(8) and/or blkid(8) for more info
#
/dev/mapper/centos-root / xfs defaults 0 0
UUID=3d04d82b-c52b-4184-8d64-1826db6e2eac /boot xfs defaults 0 0
/dev/mapper/centos-home /home xfs defaults 0 0
/dev/mapper/centos-swap swap swap defaults 0 0
```
- 快速查找选项定义的方法：

 man bash --> /^[[:space:]]*-f

```
# [ -f /bin/cat -a -x /bin/cat ] && cat /etc/fstab
#如果文件存在且有执行权限，就用它查看文件内容；
```

## 06 bash 脚本编程之用户交互

- read 命令：

    read [option]… [name….]

         -p “prompt” 提示符；

         -t TIMEOUT 用户输入超时时间；

- 检测脚本中的语法错误：

         bash –n /path/to/some_script

- 调试执行，查看执行流程：

         bash –x /path/to/some_script

- Example

```
#!/bin/bash
#
#Description: Test read command's grammer.
read -t 50 -p "Enter a disk special file:" diskfile #将用户输入的内容赋值给 diskfile 变量
[ -z "$diskfile" ] && echo "Fool" && exit 1
#判断 diskfile 的值是否为空，如果为空则输出，并退出；
if fdisk -l | grep "^Disk $diskfile" &> /dev/null;then
 fdisk -l $diskfile
else
 echo "Wrong disk special file."
 exit 2
fi
```

## 07 流程控制

### if 语句

```
if 语句：
     CONDITION：
     bash 命令：
```

 用命令的执行状态结果：

     成功：true，即执行状态结果值为 0 时；

     失败：false，即执行状态结果为 1-255 时；

 成功或失败的定义：取决于用到的命令；


- 单分支 if：
```
 if CONDITION；then
     if-true（条件为真时的执行语句集合）
 fi
```
- Example
```
#!/bin/bash
#if 单分支语句测试；
if [ $UID -eq 0 ];then
     echo "It's amdinistrator."
fi
```

-  双分支 if：
```
 if CONDITION;then
     if-true
 else
     if-false
 fi
```
- Example

```
#!/bin/bash
#
#if 双分支语句测试；
if [ $UID -eq 0 ];then
 echo "It's administrator."
else
 echo "It's Comman User."
fi
```

- 多分支 if：
```
 if CONDITION1；then
     if-true
 elif CONDITION2;then
     if-true
 elif CONDITION3;then
     if-true
 ….
 else
     all-false
 fi
```
逐条件进行判断，第一次遇为“真”条件时，执行其分支，而后结束；

- Exmaple: 用户键入文件路径，脚本来判断文件类型；

```
#!/bin/bash
#
#if 语句多分支语句；
read -t 20 -p "Enter a file path:" filename

if [ -z "$filename" ];then #判断变量是否为空；
 echo "Usage:Enter a file path."
 exit 2
fi

if [ ! -e $filename ];then #判断用户输入的文件是否存在；
 echo "No such file."
 exit 3
fi

if [ -f $filename ];then #判断是否为普通文件；
 echo "A common file."
elif [ -d $filename ];then #判断是否为目录；
 echo "A directory"
elif [ -L $filename ];then #判断是否为链接文件；
 echo "A symbolic file."
else
 echo "Other type."
fi
```

### for 循环


循环体：要执行的代码，可能要执行 n 遍；

 循环需具备进入循环的条件和退出循环的条件；

- for 循环：
```
 for 变量名 in 列表；do
     循环体
 done
```

- 执行机制：

    依次将列表中的元素赋值给“变量”；每次赋值后即执行一次循环体；直到列表中的元素耗尽，循环结束；

** Example 添加 10 个用户，用户名为：user1-user10：密码同用户名**

```
#!/bin/bash
#
#for 循环，使用列表；
#添加 10 个用户，user1-user10

if [ ! $UID -eq 0 ];then #判断执行脚本的是否为 root 用户，若不是则直接退出；
	echo "Only root can use this script."
	exit 1
fi

for i in {1..10};do
	if id user$i &> /dev/null;then	#判断用户是否已经存在；
		echo "user$i exists"
	else
		useradd user$i
		if [ $? -eq 0 ];then   #判断前一条命令是否执行成功；
			echo "user$i" | passwd --stdin user$i &> /dev/null
			#passwd 命令从标准输入获得命令，即管道前命令的执行结果；
		fi
	fi
done

```

- 列表生成方式：

    (1) 直接给出列表 for i in {bill johnson rechard}

    (2) 整数列表

        (a) {start..end}

        (b) $(seq [start [step]] end)

    (3) 返回列表的命令

        $(COMMAND) --> 如：$(ls /var)

    (4) glob

        /etc/rc.d/rc3.d/K*

    (5) 变量引用

        $@ , $*  -->所有向脚本传递的参数；

#### Example 判断某路径下所有文件的类型

```
#!/bin/bash
#
#for 循环使用命令返回列表；

for file in $(ls /var);do #使用命令生成列表；
 if [ -f /var/$file ];then
     echo "Common file."
 elif [ -L /var/$file ];then
     echo "Symbolic file."
 elif [ -d /var/$file ];then
     echo "Directory."
 else
     echo "Other type"
 fi
done
```

#### Example 使用 for 循环统计关于 tcp 端口监听状态

```
#!/bin/bash
#
#使用 for 循环过滤 netstat 命令中关于 tcp 的信息；
declare -i estab=0
declare -i listen=0
declare -i other=0

for state in $( netstat -tan | grep "^tcp\>" | awk '{print $NF}');do

 if [ "$state" == 'ESTABLISHED' ];then
     let estab++
 elif [ "$state" == 'LISTEN' ];then
     let listen++
 else
     let other++
 fi
done

echo "ESTABLISHED:$estab"
echo "LISTEN:$listen"
echo "Unknow:$other"
```

#### Example 通过 ping 命令探测 192.168.0.1-254 范围内的所有主机的在线状态

```
#!/bin/bash
#
#通过 ping 命令探测 192.168.0.1-254 范围内的所有主机的在线状态
net='192.168.0'
uphosts=0
donwhosts=0

for i in {1..254};do
 ping -c 1 -w 1 ${net}.${i} &> /dev/null
 if [ $? -eq 0 ];then
     echo "${net}.${i} is up."
     let uphosts++
 else
     echo "${net}.${i} is down."
     let downhosts++
 fi
done

echo "Up hosts:$uphosts."
echo "Down hosts:$downhosts."
```

### while 循环
语法：
```
 while CONDITION；do
     循环体
 done
```
```
CONDITION：循环控制条件；进入循环之前，先做一次判断；
每一次循环之后会再次做判断；条件为“true”，则执行一次循环；
直到条件测试状态为“false”终止循环；

因此：CONDTION 一般应该有循环控制变量；
而此变量的值会在循环体不断地被修正，直到最终条件为 false，结束循环。
```

#### Example 用 while 求 100 以内所有正整数之和

```
#!/bin/bash
#使用 while 求 100 以内正整数之和；
declare -i sum=0
declare -i i=1
while [ $i -le 100 ];do
 let sum+=$i
 let i++
done
echo $i
echo "Summary:$sum."
```
#### Example 用 while 添加 10 个用户

```
#!/bin/bash
#
#使用 while 循环添加 10 个用户
declare -i i=1
declare -i users=0

while [ $i -le 10 ];do
 if ! id user$i &> /dev/null;then
     useradd user$i
     echo "Add user: user$i"
     let users++
 fi
 let i++
done
echo "Add $users users."

```

#### Example 使用 while 循环 ping 指定网络内的所有主机

```
#!/bin/bash
#
#使用 while 循环 ping 指定网段内的所有主机；
declare -i i=1
declare -i uphosts=0
declare -i downhosts=0
net='172.16.250'

while [ $i -le 254 ];do
 if ping -c 1 -w 1 ${net}.${i} &> /dev/null;then
     echo "${net}.$i is up."
     let uphosts++
 else
     echo "${net}.$i is down."
     let downhosts++
 fi
 let i++
done

echo "Up hosts:$uphosts."
echo "Down hosts:$downhosts."
```

#### Example 利用 RANDOM 生成 10 个随机数字，输出这 10 个数字，并显示其中的最大者和最小者

```
#!/bin/bash
#
#利用 RANDOM 生成 10 个随机数，输出，并求最大值和最小值；
declare -i max=0
declare -i min=0
declare -i i=1

while [ $i -le 9 ];do
	rand=$RANDOM
	echo $rand

	if [ $i -eq 1 ];then
		max=$rand
		min=$rand
	fi

	if [ $rand -gt $max ];then
		max=$rand
	fi
	if [ $rand -lt $min ];then
		min=$rand
	fi
	let i++
done

echo "MAX:$max."
echo "MIN:$min."

```
### 创建死循环

```
while true;do
	循环体
done
```

```
until false；do
	循环体
done

```

**Example 每隔 3 秒钟到系统上获取已经登录的用户信息；如果用户输入的用户名登录了，则记录于日志中，并退出**

```
#!/bin/bash
#
#用 while 造成死循环，在系统上每隔 3 秒判断一次用户输入的用户名是否登录；
read -p "Enter a user name:" username

while true;do
	if who | grep "^$username" &> /dev/null;then
		break
	fi
	sleep 3
done

echo "$username logggen on." >> /tmp/user.log

```

### while 循环的特殊用法：（遍历文件的每一行）
```
	while read line;do
		循环体
	done < /PATH/FROM/SOMEFILE
```
依次读取 /PATH/FROM/SOMEFILE 文件中的每一行，且将该行赋值给变量 line；

**Example 依次读取 /etc/passwd 文件中的每一行，找出其 ID 号为偶数的所有用户，显示其用户名、ID 号及默认 shell**

```
#!/bin/bash
#while 循环的特殊用法 读取指定文件的每一行并赋值给变量

while read line;do
	if [ $[`echo $line | cut -d: -f3` % 2] -eq 0 ];then
		echo -e -n "username:`echo $line | cut -d: -f1`\t"
		echo -e -n "uid: `echo $line | cut -d: -f3`\t"
		echo "SHELL:`echo $line | cut -d: -f7`"
	fi
done < /etc/passwd

```

### for 循环的特殊格式：
```
	for (（控制变量初始化；条件判断表达式；控制变量的修正表达式）)；do
		循环体
	done
```
此种格式和 C 语言等的格式是一样一样的，只是多了一对括号；

控制变量初始化：仅在运行到循环代码段时执行一次；

控制变量的修正表达式：每轮循环结束会先进行控制变量修正运算，而后再在条件判断；

#### Example 求 100 以内所有正整数之和

```
#!/bin/bash
#
#for 循环，类似 C 语言格式，求 100 以内正整数之和；

declare -i sum=0

for ((i=1;i<=100;i++));do
	let sum+=$i
done

echo "Sum:$sum."

```

#### Example 菜单
(1)	显示一个如下菜单：
```
    cpu) show cpu information;
    mem) show memory information;
    disk) show disk information;
    quit) quit
```
(2)	提示用户选择选项；

(3)	显示用户选择的内容；

```
#!/bin/bash
#
#根据用户的选择，给用户显示相应的硬件信息；

cat << EOF
cpu) show cpu information;
mem) show memory information;
disk) show disk information;
quit) quit
#####################################
EOF

read -p "Enter a option:" option
while [ "$option" != 'cpu' -a "$option" != 'mem' -a "$option" != 'disk' -a "$option" != 'quit' ];do
	read -p "Wrong option,please Enter again:" option
done

if [ "$option" == 'cpu' ];then
	lscpu
elif [ "$option" == 'mem' ];then
	cat /proc/meminfo
elif [ "$option" == 'disk' ];then
	fdisk -l
else
	echo "Quit"
	exit 0
fi

```

### case 语句
```
case 变量引用 in
PAT1)
		分支 1
		；
PAT2）
		分支 2
		；
….
*)
		默认分支
		；
esac
```

case 支持 glob 风格的通配符：

        *: 任意长度任意字符；
        ?: 任意单个字符；
        []：指定范围内的任意单个字符；
	    a|b: a 或 b

#### Example 使用 case 语句改写前一个练习：

```
#!/bin/bash
#
cat << EOF
cpu) show cpu information;
mem) show memory information;
disk) show disk information;
quit) quit
============================
EOF
read -p "Enter a option: " option
while [ "$option" != 'cpu' -a "$option" != 'mem' -a "$option" != 'disk' -a "$option" != 'quit' ]; do
    read -p "Wrong option, Enter again: " option
done

case "$option" in
cpu)
	lscpu
	;;
mem)
	cat /proc/meminfo
	;;
disk)
	fdisk -l
	;;
*)
	echo "Quit..."
	exit 0
	;;
esac

```


## 08 函数
	函数的作用：
	过程式编程：为实现代码重用
	 	模块化编程
	 	结构化编程；

- 语法一：
```
function f_name {
	…函数体…..
}
```

- 语法二：
```
f_name() {
	…函数….
}
```

- 函数调用：函数只有被调用才会执行：

	调用：给定函数名

		函数名出现的地方，会被自动替换为函数代码；

- 函数的生命周期：被调用时创建，返回时终止；

	return 命令返回自定义状态结果；

		0：成功

		1-255：失败

#### Example 通过函数，创建 10 个用户

```
#!/bin/bash
#
#通过调用函数添加 10 个用户

function adduser {
	if id $username &> /dev/null;then
		echo "$username exists."
		return 1
	else
		useradd $username
		[ $? -eq 0 ] && echo "Add $username finished." && return 0
	fi
}

for i in {1..10};do
	username=myuser$i
	adduser
done

```

#### Example 编写一个服务启动关闭脚本

```
#!/bin/bash
# chkconfig: - 88 12
# description: test service script
prog=$(basename $0)
lockfile=/var/lock/subsys/$prog
start() {
	if [ -e $lockfile ];then
		echo "$prog is already running."
		return 0
	else
		touch $lockfile
		[ $? -eq 0 ] && echo "Starting $prog finished."
	fi
}
stop() {
	if [ -e $lockfile ];then
		rm -f $lockfile && echo "Stop $prog ok."
	else
		echo "$prog is stopped yet."
	fi
}
status() {
	if [ -e $lockfile ];then
		echo "$prog is running."
	else
		echo "$prog is stopped."
	fi
}
usage() {
	echo "Usage:$prog {start | stop | restart | status}"
}
if [ $# -lt 1 ];then
	usage
	exit 1
fi

case $1 in
start)
	start
	;;
stop)
	stop
	;;
restart)
	stop
	start
	;;
status)
	status
	;;
*)
	usage
esac
```
### 函数返回值
函数的执行结果返回值：

	(1)	使用 echo 或 print 命令进行输出；

	(2)	函数体中调用命令的执行结果；

函数的退出状态码：

	(1)	默认取决于函数体中执行的最后一条命令的退出状态码；

	(2)	自定义退出状态码；

		使用 return 关键字；

函数可以接受参数：

		传递参数给函数：调用函数时，在函数名后面以空白分隔给定参数列表即可；

例如：“testfunc arg1 arg2 …”

	在函数体当中，可使用 $1,$2,…. 调用这些参数；还可以使用 $@,$*,$#等特殊变量；

```
#!/bin/bash
#
#使用带参数的函数添加 10 个用户

function adduser {			#一个可接受参数的函数
	if [ $# -lt 1 ];then
		return 2   # 2: no arguments
	fi

	if id $1 &> /dev/null;then
		echo "$1 exists."
		return 1;
	else
		useradd $1
		[ $? -eq 0 ] && echo "Add $1 finished." && return 0
	fi
}

while true;do		#死循环，直到输入的值为 quit 是退出；
	read -t 20 -p "Please input your username(quit to cancel):" username
	if [ $username == "quit" ];then
		echo "Quit."
		exit 0
	else
		adduser $username
	fi
done
```

- 变量作用域：

	本地变量：当前 shell 进程，为了执行脚本会启动专用的 shell 进程；因此，本地变量的作用范围是当前 shell 脚本程序文件；

	局部变量：函数的生命周期：函数结束时变量被自动销毁；

		如果函数中有局部变量，其名称同本地变量无关；

在函数中定义局部变量的方法：

		local NAME=VALUE

函数递归：函数直接或间接调用自身；

#### Example 求 N 的阶乘
```
N！=N（N-1）(N-2)….1
	N(N-1)!=N(N-1)(N-2)!
```
```
#!/bin/bash
#
#利用函数递归求 N 的阶乘

fact() {
	if [ $1 -eq 0 -o $1 -eq 1 ];then
		echo 1
	else
		echo $[$1*$(fact $[$1-1])]
	fi
}
fact 5

```

## 09 数组
### 数组

	变量：存储单个元素的内存空间；
```
	数组：存储多个元素的连续的内存空间；
		数组名
		索引：编号从 0 开始，属于数值索引；
			注意：索引页可支持使用自定义的格式，而不仅仅是数值格式；
				bash 的数组支持稀疏格式；
```

- 引用数组中的元素： ${ARRAY_NAME[INDEX]}

- 声明数组：

	declare –a ARRAY_NAME

	declare –A ARRAY_NAME : 关联数组；

- 数组元素的赋值：

	(1)	一次只赋值一个元素；

		ARRAY_NAME[INDEX]=VALUE

```
	例如：
			weekdays[0]="Sunday"
			weekdays[4]="Thursday"
```

	(2)	一次赋值全部元素：

			ARRAY_NAME=("VAL1" "VAL2" "VAL3" ...)

	(3)	只赋值特定元素：

			ARRAY_NAME=([0]="VAL1" [3]="VAL2" ...)

	(4)	read -a ARRAY

- 引用数组元素：${ARRAY_NAME[INDEX]}

	注意：省略 [INDEX] 表示引用下标为 0 的元素；

- 数组的长度（数组中元素的个数）：

	${#ARRAY_NAME[*]}

	${#ARRAY_NAME[@]}

#### Example 生成 10 个随机数保存于数组中，并找出其最大值和最小值：

```
#!/bin/bash
#
#生成 10 个随机数保存于数组中；

declare -a rand
declare -i max=0
declare -i min=0

for i in {0..9};do
	rand[$i]=$RANDOM
	if [ $i -eq 1 ];then
		max=${rand[$i]}
		min=${rand[$i]}
	fi
	echo ${rand[$i]}
	[ ${rand[$i]} -gt $max ] && max=${rand[$i]}
	[ ${rand[$i]} -lt $min ] && min=${rand[$i]}
done

echo "Max:$max"
echo "Min:$min"

```

#### Example 写一个脚本：定义一个数组，数组中的元素是 /var/log 目录下所有以.log 结尾的文件；要统计其下标为偶数的文件中的行数之和；

```
#!/bin/bash
#
#定义一个数组，数组中的元素是 /var/log 目录下所有以.log 结尾的文件；
#要统计其下标为偶数的文件中的行数之和；

declare -a files
files=(/var/log/*.log)
declare -i lines=0

for i in $(seq 0 $[${#files[*]}-1]);do
	if [ $[$i%2] -eq 0 ];then
		let lines+=$(wc -l ${files[$i]} | cut -d' ' -f1)
	fi
done

echo "Lines:$lines."

```

### 引用数组中的元素：

- 所有元素：${ARRAY[@]} , ${ARRAY[*]}

- 数组切片：${ARRAY[@]:offset:number}

		offset: 要跳过的元素个数；

		number：要取出的元素个数，取偏移量之后的所有元素：${ARRAY[@]:offset};

- 向数组中追加元素：ARRAY[${ARRAY[*]}]

- 删除数组中的某元素：unset ARRAY[INDEX]

- 关联数组：
	declare –A ARRAY_NAME
	ARRAY_NAME=([index_name1]=’val1’ [index_name2]=’val2’ ….)

```
[root@bill scripts]# declare -a array
[root@bill scripts]# #声明一个数组，不是必要的
[root@bill scripts]# array=(0 1 2)
[root@bill scripts]# array=([0]=0 [1]=1 [2]=v2)
[root@bill scripts]# array[0]=5
[root@bill scripts]# echo $array
5
[root@bill scripts]#

```

```
[root@bill scripts]# #以空白作为分隔符拆分字符串为数组
[root@bill scripts]# str="1 2 3"
[root@bill scripts]# array=($str)
[root@bill scripts]# echo $array
1
[root@bill scripts]#

```

```
[root@bill scripts]# #使用其他分隔符拆分字符串为数组，需指定 IFS
[root@bill scripts]# IFS=: array=($PATH)
[root@bill scripts]# echo $array
/usr/local/sbin

```

- 引用数组元素：
	$array  ${array}  ${array[0]}  #第 0 个元素

	${array[n]}  #第 n 个元素（n 从 0 开始计算）

- 引用整个数组：
	${array[*]}  ${array[@]}   这两种方式等同，会把数组展开。

	${array[*]}  表示把数组拼接在一起的整个字符串，如果作为参数传递，会把整个字符串作为一个参数。

	${array[@]}  如果作为参数传递，表示把数组中每个元素作为一个参数，数组有多少个元素，就会展开成多少个参数。

- 计算数组元素长度；

	${#array[*]}

	${#array[@]}

		不是 ${#array}，

		因为它等同于 ${#array[0]}

- 遍历数组：
	for i in "${array[@]}";do
		echo $i;
	done



## 10 bash 的字符串处理工具

### 字符串切片：
- ${var:offset:number}

	取字符串最右侧的几个字符：${var: -lengh}

	Note：冒号后面必须有一空白字符；

### 基于模式取子串：
- ${var#*word}：其中 word 可以是指定的任意字符；

	功能：自左而右，查找 var 变量所存储的字符串中，第一次出现的 word, 删除字符串开头至第一次出现 word 字符之间的所有字符；

- ${var##*word}：其中 word 可以是指定的任意字符；

	功能：自左而右，查找 var 变量所存储的字符串中出现的 word，删除字符串开头至最后一次由 word 指定的字符之间的所有内容；

**bash 基于模式取子串**

```
[root@bill scripts]# file="/var/log/messages"
[root@bill scripts]# echo ${file#*/}
var/log/messages
[root@bill scripts]# echo ${file##*/}
messages

```

- ${var%word*}：其中 word 可以是指定的任意字符；

	功能：自右而左，查找 var 变量所存储的字符串中，第一次出现的 word, 删除字符串最后一个字符向左至第一次出现 word 字符之间的所有字符；

- ${var%%word*}：其中 word 可以是指定的任意字符；

	功能：自右而左，查找 var 变量所存储的字符串中出现的 word,，只不过删除字符串最右侧的字符向左至最后一次出现 word 字符之间的所有字符；
```
[root@bill scripts]# file="/var/log/messages" #从右至左，匹配‘/ ’
[root@bill scripts]# echo ${file%/*}
/var/log
[root@bill scripts]# echo ${file%%/*}    # 双 % 匹配并删除后为空；
[root@bill scripts]#
```

#### Exampleurl=http://www.google.com:80, 分别取出协议和端口；

```
[root@bill scripts]# url=http://www.google.com:80
[root@bill scripts]# echo ${url##*:}    #取端口号
80
[root@bill scripts]# echo ${url%%:*}   #取协议
http
[root@bill scripts]#
```

### 查找替换
	${var/pattern/substi}：查找 var 所表示的字符串中，第一次被 pattern 所匹配到的字符串，以 substi 替换之；

	${var//pattern/substi}: 查找 var 所表示的字符串中，所有能被 pattern 所匹配到的字符串，以 substi 替换之；

	${var/#pattern/substi}：查找 var 所表示的字符串中，行首被 pattern 所匹配到的字符串，以 substi 替换之；

	${var/%pattern/substi}：查找 var 所表示的字符串中，行尾被 pattern 所匹配到的字符串，以 substi 替换之；

```
[root@bill scripts]# var=$(head -n 1 /etc/passwd)
[root@bill scripts]# echo $var
root x 0 0 root /root /bin/bash
[root@bill scripts]# echo ${var/root/ROOT}  #替换第一次匹配到的 root 为 ROOT
ROOT x 0 0 root /root /bin/bash
[root@bill scripts]# echo ${var//root/ROOT}  #替换所有匹配到的 root 为 ROOT
ROOT x 0 0 ROOT /ROOT /bin/bash

```
```
[root@bill scripts]# useradd bash -s /bin/bash
[root@bill scripts]# cat /etc/passwd | grep "^bash.*bash$"
bash:x:1029:1029::/home/bash:/bin/bash
[root@bill scripts]# line=$(cat /etc/passwd | grep "^bash.*bash$")
[root@bill scripts]# echo $line
bash x 1029 1029  /home/bash /bin/bash
[root@bill scripts]# echo ${line/#bash/BASH}	#替换行首的 bash 为 BASH
BASH x 1029 1029  /home/bash /bin/bash
[root@bill scripts]# echo ${line/%bash/BASH}	#替换行尾的 bash 为 BASH
bash x 1029 1029  /home/bash /bin/BASH
```

### 查找并删除
	${var/pattern}：查找 var 所表示的字符串中，删除第一次被 pattern 所匹配到的字符串

	${var//pattern}：查找 var 所表示的字符串中，删除所有被 pattern 所匹配到的字符串；

	${var/#pattern}：查找 var 所表示的字符串中，删除行首被 pattern 所匹配到的字符串；

	${var/%pattern}：查找 var 所表示的字符串中，删除行尾被 pattern 所匹配到的字符串；

- Example
```
[root@bill scripts]# line=$(tail -n 1 /etc/passwd)
[root@bill scripts]# echo $line
bash x 1029 1029  /home/bash /bin/bash
[root@bill scripts]# echo ${line/bash}  #查找并删除第一次匹配到的 bash
 x 1029 1029  /home/bash /bin/bash
[root@bill scripts]# echo ${line//bash}	#查找并删除所有匹配到的 bash
 x 1029 1029  /home/ /bin/
[root@bill scripts]# echo ${line/#bash}	#查找并删除匹配到的行首的 bash
 x 1029 1029  /home/bash /bin/bash
[root@bill scripts]# echo ${line/%bash}   #查找并删除匹配到的行尾 bash
bash x 1029 1029  /home/bash /bin/

```

### 字符大小写转换：
	${var^^}：把 var 中的所有小写字母转换为大写；

	${var,,}：把 var 中的所有大写字母转换为小写；

- Example

```
[root@bill scripts]# line=$(tail -n 1 /etc/fstab)		#将文件最后一行的值赋值给变量
[root@bill scripts]# echo ${line^^}		#全部转换为大写后输出
/DEV/MAPPER/CENTOS-SWAP SWAP                    SWAP    DEFAULTS        0 0
[root@bill scripts]# line=`echo ${line^^}`	#将转换为大写后的值在赋值给变量；
[root@bill scripts]# echo $line			#确认目前变量的值全为大写字母；
/DEV/MAPPER/CENTOS-SWAP SWAP                    SWAP    DEFAULTS        0 0
[root@bill scripts]# echo ${line,,}		#全部转换为大写后输出；
/dev/mapper/centos-swap swap                    swap    defaults        0 0

```

### 变量赋值

	${var:-value}：如果 var 为空或未设置，那么返回 value；否则，则返回 var 的值；

	${var:=value}：如果 var 为空或未设置，那么返回 value，并将 value 赋值给 var；否则，则返回 var 的值；

- Example

```
[root@bill scripts]# echo $test		#变量值为空；

[root@bill scripts]# echo ${test:-helloworld}	#  :- 仅返回设定值，不修改；
helloworld
[root@bill scripts]# echo $test      #变量的值依然为空；

[root@bill scripts]# echo ${test:=helloworld}   #  :=  返回设定值，并赋值给变量；
helloworld
[root@bill scripts]# echo $test			# 变量值已修改；
helloworld
```

## 11 脚本的配置文件
###步骤
-	(1) 定义文本文件，每行定义“name=value”
-	(2) 在脚本中 source 此文件即可

```
[root@bill scripts]# touch /tmp/config.test #创建配置文件；
[root@bill scripts]# echo "name=bill" >> /tmp/config.test #在配置文件中定义变量；
[root@bill scripts]# vim script_configureFile.sh		#编写脚本，导入配置文件；如内容所示；
[root@bill scripts]# bash script_configureFile.sh 	#脚本执行结果；
bill
[root@bill scripts]# cat script_configureFile.sh
#!/bin/bash
#
source /tmp/config.test		#导入配置文件，脚本自身并未定义变量；

echo $name				#引用的是配置文件中的变量 name
```
