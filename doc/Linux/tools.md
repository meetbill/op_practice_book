# Linux 工具篇

<!-- vim-markdown-toc GFM -->
* [编程相关](#编程相关)
    * [vim IDE 工具](#vim-ide-工具)
    * [Git 分布式管理系统](#git-分布式管理系统)
        * [Git 基础](#git-基础)
        * [知识点](#知识点)
        * [其他操作](#其他操作)
* [运维相关](#运维相关)
    * [sed](#sed)
    * [awk](#awk)
        * [历史](#历史)
        * [基础知识](#基础知识)
        * [脚本](#脚本)
        * [运算与编程](#运算与编程)
    * [排查 java CPU 性能问题](#排查-java-cpu-性能问题)
        * [用法](#用法)
        * [示例](#示例)
* [系统相关](#系统相关)
    * [screen](#screen)
        * [screen 使用](#screen-使用)
        * [开启 screen 状态栏](#开启-screen-状态栏)
* [网络相关](#网络相关)
    * [curl](#curl)
        * [curl 基础](#curl-基础)
        * [curl 深入](#curl-深入)
    * [tcpdump](#tcpdump)
        * [tcp 三次握手和四次挥手](#tcp-三次握手和四次挥手)
        * [tcpdump 使用](#tcpdump-使用)
    * [nc](#nc)
        * [语法](#语法)
        * [TCP 端口扫描](#tcp-端口扫描)
        * [扫描 UDP 端口](#扫描-udp-端口)

<!-- vim-markdown-toc -->

# 编程相关
## vim IDE 工具

* [VIM 一键 IDE](https://github.com/BillWang139967/Vim)

## Git 分布式管理系统

### Git 基础

**环境配置**

+ `git config user.name your_name` : 设置你的用户名，提交会显示
+ `git config user.email your_email` : 设置你的邮箱
+ `git config core.quotepath false` : 解决中文文件名显示为数字问题

**基本操作**

+ `git init` : 初始化一个 git 仓库
+ `git add <filename>` : 添加一个文件到 git 仓库中
+ `git commit -m "commit message"`: 提交到本地
+ `git push [remote-name] [branch-name]` : 把本地的提交记录推送到远端分支
+ `git pull`: 更新仓库 `git pull` = `git fetch` + `git merge`
+ `git checkout -- <file>` : 还原未暂存 (staged) 的文件
+ `git reset HEAD <file>...` : 取消暂存，那么还原一个暂存文件，应该是先 `reset` 后 `checkout`
+ `git stash` : 隐藏本地提交记录，恢复的时候 `git stash pop`。这样可以在本地和远程有冲突的情况下，更新其他文件

**分支**

+ `git branch <branch-name>` : 基于当前 commit 新建一个分支，但是不切换到新分支
+ `git checkout -b <branch-name>` : 新建并切换分支
+ `git checkout <branch-name>` : 切换分支
+ `git branch -d <branch-name>` : 删除分支
+ `git push origin <branch-name>` : 推送本地分支
+ `git checkout -b <local-branch-name> origin/<origin-branch-name>` : 基于某个远程分支新建一个分支开发
+ `git checkout --track origin/<origin-branch-name>` : 跟踪远程分支（创建跟踪远程分支，Git 在 `git push` 的时候不需要指定 `origin` 和 `branch-name` ，其实当我们 `clone` 一个 repo 到本地的时候，`master` 分支就是 origin/master 的跟踪分支，所以提交的时候直接 `git push`)。
+ `git push origin :<origin-branch-name>` : 删除远程分支

**标签**

+ `git tag -a <tagname> -m <message>` : 创建一个标签
+ `git tag` : 显示已有的标签
+ `git show tagname`: 显示某个标签的详细信息
+ `git checkout -b <tag-name>` : 基于某个 tag 创建一个新的分支

**Git shortcuts/aliases**

    git config --global alias.co checkout
    git config --global alias.br branch
    git config --global alias.ci commit
    git config --global alias.st status

### 知识点

基本命令让你快速的上手使用 Git，知识点能让你更好的理解 Git。

**文件的几种状态**

+ untracked: 未被跟踪的，没有纳入 Git 版本控制，使用 `git add <filename>` 纳入版本控制
+ unmodified: 未修改的，已经纳入版本控制，但是没有修改过的文件
+ modified: 对纳入版本控制的文件做了修改，git 将标记为 modified
+ staged: 暂存的文件，简单理解：暂存文件就是 add 之后，commit 之前的文件状态

理解这几种文件状态对于理解 Git 是非常关键的（至少可以看懂一些错误提示了）。

**快照和差异**

详细可看：[Pro Git: Git 基础](http://iissnan.com/progit/html/zh/ch1_3.html) 中有讲到 *直接记录快照，而非差异比较*，这里只讲我个人的理解。

Git 关心的是文件数据整体的变化，其他版本管理系统（以 svn 为例）关心的某个具体文件的*差异*。这个差异是好理解的，也就是两个版本具体文件的不同点，比如某一行的某个字符发生了改变。

Git 不保存文件提交前后的差异，不变的文件不会发生任何改变，对于变化的文件，前后两次提交则保存两个文件。举个例子：

SVN:

1. 新建 3 个文件 a, b, c，做第一次提交 ->  `version1 : file_a file_b file_c`
2. 修改文件 b， 做第二次提交（真正提交的是 修改后的文件 b 和修改前的 `file_b` 的 diff) -> `version2: diff_b_2_1`
3. 当我要 checkout version2 的时候，实际上得到的是 `file_a file_b+diff_b_2_1 file_c`

Git:

1. 新建 3 个文件 a, b, c，做第一次提交 ->  `version1 : file_a file_b file_c`
2. 修改文件 b （得到`file_b1`), 做第二次提交 -> `version2: file_a file_b1 file_c`
3. 当我要用 version2 的时候，实际上得到的是 `file_a file_b1 file_c`

上面的 `file_a file_b1 file_c` 就是 version2 的 *快照*。

**Git 数据结构**

Git 的核心数是很简单的，就是一个链表（或者一棵树更准确一些？无所谓了），一旦你理解了它的基本数据结构，再去看 Git，相信你有不同的感受。继续用上面的例子（所有的物理文件都对应一个 SHA-1 的值）

当我们做第一次提交时，数据结构是这样的：


    sha1_2_file_map:
        28415f07ca9281d0ed86cdc766629fb4ea35ea38 => file_a
        ed5cfa40b80da97b56698466d03ab126c5eec5a9 => file_b
        1b5ca12a6cf11a9b89dbeee2e5431a1a98ea5e39 => file_c

    commit_26b985d269d3a617af4064489199c3e0d4791bb5:
        base_info:
            Auther: "JerryZhang(chinajiezhang@gmail.com)"
            Date: "Tue Jul 15 19:19:22 2014 +0800"
            commit_content: "第一次提交"
        file_list:
            [1]: 28415f07ca9281d0ed86cdc766629fb4ea35ea38
            [2]: ed5cfa40b80da97b56698466d03ab126c5eec5a9
            [3]: 1b5ca12a6cf11a9b89dbeee2e5431a1a98ea5e39
            pre_commit: null
        next_commit: null

当修改了 `file_b`, 再提交一次时，数据结构应该是这样的：

    sha1_2_file_map:
        28415f07ca9281d0ed86cdc766629fb4ea35ea38 => file_a
        ed5cfa40b80da97b56698466d03ab126c5eec5a9 => file_b
        1b5ca12a6cf11a9b89dbeee2e5431a1a98ea5e39 => file_c
        39015ba6f80eb9e7fdad3602ef2b1af0521eba89 => file_b1

    commit_26b985d269d3a617af4064489199c3e0d4791bb5:
        base_info:
            Auther: "JerryZhang(chinajiezhang@gmail.com)"
            Date: "Tue Jul 15 19:19:22 2014 +0800"
            commit_content: "第一次提交"
        file_list:
            [1]: 28415f07ca9281d0ed86cdc766629fb4ea35ea38
            [2]: ed5cfa40b80da97b56698466d03ab126c5eec5a9
            [3]: 1b5ca12a6cf11a9b89dbeee2e5431a1a98ea5e39
        pre_commit: commit_a08a57561b5c30b9c0bf33829349e14fad1f5cff
        next_commit: null

    commit_a08a57561b5c30b9c0bf33829349e14fad1f5cff:
        base_info:
            Auther: "JerryZhang(chinajiezhang@gmail.com)"
            Date: "Tue Jul 15 22:19:22 2014 +0800"
            commit_content: "更新文件 b"
        file_list:
            [1]: 28415f07ca9281d0ed86cdc766629fb4ea35ea38
            [2]: 39015ba6f80eb9e7fdad3602ef2b1af0521eba89
            [3]: 1b5ca12a6cf11a9b89dbeee2e5431a1a98ea5e39
        pre_commit: null
        next_commit: commit_26b985d269d3a617af4064489199c3e0d4791bb5

当提交完第二次的时候，执行 `git log`，实际上就是从 `commit_a08a57561b5c30b9c0bf33829349e14fad1f5cff` 开始遍历然后打印 `base_info` 而已。

实际的 git 实际肯定要比上面的结构 (（的信息）的）要复杂的多，但是它的核心思想应该是就是，每一次提交就是一个新的结点。通过这个结点，我可以找到所有的快照文件。再思考一下，什么是分支？什么是 Tags，其实他们可能只是某次提交的引用而已（一个 `tag_head_node` 指向了某一次提交的 node)。再思考怎么回退一个版本呢？指针偏移！依次类推，上面的基本命令都可以得到一个合理的解释。

**理解 git fetch 和 git pull 的差异**

上面我们说过 `git pull` 等价于 `git fetch` 和 `git merge` 两条命令。当我们 `clone` 一个 repo 到本地时，就有了本地分支和远端分支的概念（假定我们只有一个主分支），本地分支是 `master`，远端分支是 `origin/master`。通过上面我们对 Git 数据结构的理解，`master` 和 `origin/master` 可以想成是指向最新 commit 结点的两个指针。刚 `clone` 下来的 repo，`master` 和 `origin/master` 指针指向同一个结点，我们在本地提交一次，`origin` 结点就更新一次，此时 `master` 和 `orgin/master` 就不再相同了。很有可能别人已经 commit 改 repo 很多次了，并且进行了提交。那么我们的本地的 `origin/master` 就不再是远程服务器上的最新的位置了。 `git fetch` 干的就是从服务器上同步服务器上最新的 `origin/master` 和一些服务器上新的记录 / 文件到本地。而 `git merge` 就是合并操作了（解决文件冲突）。`git push` 是把本地的 `origin/master` 和 `master` 指向相同的位置，并且推送到远程的服务器。

### 其他操作

**解决 GitHub commit 次数过多.git 文件过大**

完全重建版本库

```
# rm -rf .git
# git init
# git add .
# git cm "first commit"
# git remote add origin <your_github_repo_url>
# git push -f -u origin master
```
**HTTP request failed**


使用 git clone 失败

```
[root@localhost ~]# git clone https://github.com/BillWang139967/Vim.git
Initialized empty Git repository in /root/Vim/.git/
error:  while accessing https://github.com/BillWang139967/Vim.git/info/refs

fatal: HTTP request failed
```
解决方法
```
#git config --global http.sslVerify false

```
# 运维相关
## sed

## awk
### 历史

AWK 是贝尔实验室 1977 年搞出来的文本处理工具。

之所以叫 AWK 是因为其取了三位创始人 Alfred Aho，Peter Weinberger, 和 Brian Kernighan 的 Family Name 的首字符

### 基础知识
**分隔符**

默认情况下， awk 使用空格当作分隔符。分割后的字符串可以使用 $1, $2 等访问。

上面提到过，我们可以使用 -F 来指定分隔符。
fs 如果是一个字符，可以直接跟在 -F 后面，比如使用冒号当作分隔符就是 -F: .
如果分隔符比较复杂，就需要使用正则表达式来表示这个分隔符了。
正则表达式需要使用引号引起来。
比如使用‘ab’  当作分隔符，就是 -F 'ab' 了。
使用 a 或 b 作为分隔符，就是 -F '\[ab]' 了。
关于正则表达式这里不多说了。

**内建变量**

```text
$0	当前记录（这个变量中存放着整个行的内容）
$1~$n	当前记录的第 n 个字段，字段间由 FS 分隔
FS	输入字段分隔符 默认是空格或 Tab
NF	当前记录中的字段个数，就是有多少列
NR	已经读出的记录数，就是行号，从 1 开始，如果有多个文件话，这个值也是不断累加中。
FNR	当前记录数，与 NR 不同的是，这个值会是各个文件自己的行号
RS	输入的记录分隔符， 默认为换行符
OFS	输出字段分隔符， 默认也是空格
ORS	输出的记录分隔符，默认为换行符
FILENAME	当前输入文件的名字
```

**转义**

一般字符在双引号之内就可以直接原样输出了。
但是有部分转义字符，需要使用反斜杠转义才能正常输出。

```
\\   A literal backslash.
\a   The “alert” character; usually the ASCII BEL character.
\b   backspace.
\f   form-feed.
\n   newline.
\r   carriage return.
\t   horizontal tab.
\v   vertical tab.
\xhex digits
\c   The literal character c.
```
**模式**

```text
~ 表示模式开始
/ / 中是模式
! 模式取反
```

**单引号**

当需要输出单引号时，直接转义发现会报错。
由于 awk 脚本并不是直接执行，而是会先进行预处理，所以需要两次转义。
awk 支持递归引号。单引号内可以输出转义的单引号，双引号内可以输出转义的双引号。

比如需要输出单引号，则需要下面这样：

```
> awk 'BEGIN{print "\""}'
"
>  awk 'BEGIN{print "'\''"}'
'
```

当然，更简单的方式是使用十六进制来输出。

```
awk 'BEGIN{print "\x27"}'
```

### 脚本

```text
BEGIN{ 这里面放的是执行前的语句 }
END {这里面放的是处理完所有的行后要执行的语句 }
{这里面放的是处理每一行时要执行的语句}
```

### 运算与编程

awk 是弱类型语言，变量可以是串，也可以是数字，这依赖于实际情况。
所有的数字都是浮点型。

例如

```bash
//9
echo 5 4 | awk '{ print $1 + $2 }'

//54
echo 5 4 | awk '{ print $1 $2 }'

//"5 4"
echo 5 4 | awk '{ print $1, $2 }'

0-1-2-3-4-5-6
echo 6 | awk '{ for (i=0; i<=$0; i++){ printf (i==0?i:"-"i); }printf "\n";}'
```

**Example**

假设我们有一个日期 2014/03/27, 我们想处理为 2014-03-27.
我们可以使用下面的代码实现。

```bash
echo "2014/03/27" | awk -F/  '{print $1"-"$2"-"$3}'
```

假设 处理的日期都在 date 文件里。
我们可以导入文件来操作

文件名 date

```text
2014/03/27
2014/03/28
2014/03/29
```

命令
```bash
awk -F/ '{printf "%s-%s-%s\n",$1,$2,$3}'  date
```

输出
```text
2014-03-27
2014-03-28
2014-03-29
```

**统计**

```bash
awk '{sum+=$5} END {print sum}'
```
## 排查 java CPU 性能问题

[show-busy-java-threads.sh](https://github.com/BillWang139967/op_practice_code/blob/master/Linux/op/show-busy-java-threads.sh)
```
curl -o show-busy-Java-threads.sh https://raw.githubusercontent.com/BillWang139967/op_practice_code/master/Linux/op/show-busy-java-threads.sh
```

用于快速排查`Java`的`CPU`性能问题 (`top us`值过高），自动查出运行的`Java`进程中消耗`CPU`多的线程，并打印出其线程栈，从而确定导致性能问题的方法调用。

PS，如何操作可以参见 [@bluedavy](http://weibo.com/bluedavy) 的《分布式 Java 应用》的【5.1.1 cpu 消耗分析】一节，说得很详细：

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
# 从 所有的 Java 进程中找出最消耗 CPU 的线程（缺省 5 个），打印出其线程栈。

show-busy-java-threads.sh -c 《要显示的线程栈数》

show-busy-java-threads.sh -c 《要显示的线程栈数》 -p 《指定的 Java Process>

##############################
# 注意：
##############################
# 如果 Java 进程的用户 与 执行脚本的当前用户 不同，则 jstack 不了这个 Java 进程。
# 为了能切换到 Java 进程的用户，需要加 sudo 来执行，即可以解决：
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

上面的线程栈可以看出，`CPU`消耗最高的 2 个线程都在执行`java.text.DateFormat.format`，业务代码对应的方法是`shared.monitor.schedule.AppMonitorDataAvgScheduler.run`。可以基本确定：

- `AppMonitorDataAvgScheduler.run`调用`DateFormat.format`次数比较频繁。
- `DateFormat.format`比较慢。（这个可以由`DateFormat.format`的实现确定。）

多个执行几次`show-busy-java-threads.sh`，如果上面情况高概率出现，则可以确定上面的判定。
\# 因为调用越少代码执行越快，则出现在线程栈的概率就越低。

分析`shared.monitor.schedule.AppMonitorDataAvgScheduler.run`实现逻辑和调用方式，以优化实现解决问题。

- [oldratlee](https://github.com/oldratlee)
- [silentforce](https://github.com/silentforce) 改进此脚本，增加对环境变量`JAVA_HOME`的判断。 #15
- [liuyangc3](https://github.com/liuyangc3)
    - 优化性能，通过`read -a`简化反复的`awk`操作 #51
    - 发现并解决`jstack`非当前用户`Java`进程的问题 #50

# 系统相关
## screen

现在很多时候我们的开发环境都已经部署到云端了，直接通过 SSH 来登录到云端服务器进行开发测试以及运行各种命令，一旦网络中断，通过 SSH 运行的命令也会退出，这个发让人发疯的。

好在有 screen 命令，它可以解决这些问题。我使用 screen 命令已经有三年多的时间了，感觉还不错。

### screen 使用

**新建一个 Screen Session**

```
$ screen -S screen_session_name
```

**将当前 Screen Session 放到后台**

```
$ CTRL + A + D
```

**唤起一个 Screen Session**

```
$ screen -r screen_session_name
```

**分享一个 Screen Session**

```
$ screen -x screen_session_name
```

通常你想和别人分享你在终端里的操作时可以用此命令。

**终止一个 Screen Session**

```
$ exit
$ CTRL + D
```

**查看一个 screen 里的输出**

当你进入一个 screen 时你只能看到一屏内容，如果想看之前的内容可以如下：

```
$ Ctrl + a ESC
```

以上意思是进入 Copy mode，拷贝模式，然后你就可以像操作 VIM 一样查看 screen session 里的内容了。

可以 Page Up 也可以 Page Down。

### 开启 screen 状态栏

```
#curl -o screen.sh https://raw.githubusercontent.com/BillWang139967/op_practice_code/master/Linux/tools/screen.sh
#sh screen.sh
```
# 网络相关
## curl
### curl 基础
在介绍前，我需要先做两点说明：

1. 下面的例子中会使用 [httpbin.org](http://httpbin.org/) ，httpbin 提供客户端测试 http 请求的服务，非常好用，具体可以查看他的网站。
2. 大部分没有使用缩写形式的参数，例如我使用 `--request` 而不是 `-X` ，这是为了好记忆。

下面开始简单介绍几个命令：

**get**

直接以个 GET 方式请求一个 url，输出返回内容：

``` sh
curl httpbin.org
```

返回
``` html
<!DOCTYPE html>
<html>
<head>
  <meta http-equiv='content-type' value='text/html;charset=utf8'>
  <meta name='generator' value='Ronn/v0.7.3 (http://github.com/rtomayko/ronn/tree/0.7.3)'>
  <title>httpbin(1): HTTP Client Testing Service</title>
  <style type='text/css' media='all'>
  /* style: man */
  body#manpage {margin:0}
  .mp {max-width:100ex;padding:0 9ex 1ex 4ex}
  .mp p,.mp pre,.mp ul,.mp ol,.mp dl {margin:0 0 20px 0}
  .mp h2 {margin:10px 0 0 0}
......
```

**post**

使用 `--request` 指定请求类型， `--data` 指定数据，例如：

``` sh
curl httpbin.org/post --request POST --data "name=keenwon&website=http://keenwon.com"
```

返回：

``` html
{
  "args": {},
  "data": "",
  "files": {},
  "form": {
    "name": "tomshine",
    "website": "http://tomshine.xyz"
  },
  "headers": {
    "Accept": "*/*",
    "Content-Length": "41",
    "Content-Type": "application/x-www-form-urlencoded",
    "Host": "httpbin.org",
    "User-Agent": "curl/7.43.0"
  },
  "json": null,
  "origin": "121.35.209.62",
  "url": "http://httpbin.org/post"
}
```

这个返回值是 httpbin 输出的，可以清晰的看出我们发送了什么数据，非常实用。

**form 表单提交**

form 表单提交使用 `--form`，使用 `@` 指定本地文件，例如我们提交一个表单，有字段 name 和文件 f：

``` sh
curl httpbin.org/post --form "name=tomshine" --form "f=@/Users/tomshine/test.txt"
```

返回：

``` json
{
  "args": {},
  "data": "",
  "files": {
    "f": "Hello Curl!\n"
  },
  "form": {
    "name": "tomshine"
  },
  "headers": {
    "Accept": "*/*",
    "Content-Length": "296",
    "Content-Type": "multipart/form-data; boundary=------------------------3bd3dc24dca6daf2",
    "Host": "httpbin.org",
    "User-Agent": "curl/7.43.0"
  },
  "json": null,
  "origin": "112.95.153.98",
  "url": "http://httpbin.org/post"
}
```

### curl 深入
**显示头信息**

使用 `--include` 在输出中包含头信息，使用 `--head` 只返回头信息，例如：

``` sh
curl httpbin.org/post --include --request POST --data "name=tomshine"
```

返回：

``` html
HTTP/1.1 200 OK
Server: nginx
Date: Sun, 18 Sep 2016 01:23:28 GMT
Content-Type: application/json
Content-Length: 363
Connection: keep-alive
Access-Control-Allow-Origin: *
Access-Control-Allow-Credentials: true

{
  "args": {},
  "data": "",
  "files": {},
  "form": {
    "name": "tomshine"
  },
  "headers": {
    "Accept": "*/*",
    "Content-Length": "13",
    "Content-Type": "application/x-www-form-urlencoded",
    "Host": "httpbin.org",
    "User-Agent": "curl/7.43.0"
  },
  "json": null,
  "origin": "121.35.209.62",
  "url": "http://httpbin.org/post"
}
```

再例如，只显示头信息的话：

``` sh
curl httpbin.org --head
```

返回：

``` html
HTTP/1.1 200 OK
Server: nginx
Date: Sun, 18 Sep 2016 01:24:29 GMT
Content-Type: text/html; charset=utf-8
Content-Length: 12150
Connection: keep-alive
Access-Control-Allow-Origin: *
Access-Control-Allow-Credentials: true
```

**详细显示通信过程**

使用 `--verbose` 显示通信过程，例如：

``` sh
curl httpbin.org/post --verbose --request POST --data "name=tomshine"
```

返回：

``` html
*   Trying 54.175.219.8...
* Connected to httpbin.org (54.175.219.8) port 80 (#0)
> POST /post HTTP/1.1
> Host: httpbin.org
> User-Agent: curl/7.43.0
> Accept: */*
> Content-Length: 13
> Content-Type: application/x-www-form-urlencoded
>
* upload completely sent off: 13 out of 13 bytes
< HTTP/1.1 200 OK
< Server: nginx
< Date: Sun, 18 Sep 2016 01:25:03 GMT
< Content-Type: application/json
< Content-Length: 363
< Connection: keep-alive
< Access-Control-Allow-Origin: *
< Access-Control-Allow-Credentials: true
<
{
  "args": {},
  "data": "",
  "files": {},
  "form": {
    "name": "tomshine"
  },
  "headers": {
    "Accept": "*/*",
    "Content-Length": "13",
    "Content-Type": "application/x-www-form-urlencoded",
    "Host": "httpbin.org",
    "User-Agent": "curl/7.43.0"
  },
  "json": null,
  "origin": "121.35.209.62",
  "url": "http://httpbin.org/post"
}
* Connection #0 to host httpbin.org left intact
```

**设置头信息**

使用 `--header` 设置头信息，`httpbin.org/headers` 会显示请求的头信息，我们测试下：

``` sh
curl httpbin.org/headers --header "a:1"
```

返回：

``` html
{
  "headers": {
    "A": "1",
    "Accept": "*/*",
    "Host": "httpbin.org",
    "User-Agent": "curl/7.43.0"
  }
}
```

同样的，可以使用 `--header` 设置 `User-Agent` 等。

**Referer 字段**

设置 `Referer` 字段很简单，使用 `--referer` ，例如：

``` sh
curl httpbin.org/headers --referer http://tomshine.xyz
```

返回：

``` html
{
  "headers": {
    "Accept": "*/*",
    "Host": "httpbin.org",
    "Referer": "http://tomshine.xyz",
    "User-Agent": "curl/7.43.0"
  }
}
```

**包含 cookie**

使用 `--cookie` 来设置请求的 cookie，例如：

``` sh
curl httpbin.org/headers --cookie "name=tomshine;website=http://tomshine.xyz"
```

返回：

``` html
{
  "headers": {
    "Accept": "*/*",
    "Cookie": "name=tomshine;website=http://tomshine.xyz",
    "Host": "httpbin.org",
    "User-Agent": "curl/7.43.0"
  }
}
```

**自动跳转**

使用 `--location` 参数会跟随链接的跳转，例如：

``` sh
curl httpbin.org/redirect/1 --location
```

httpbin.org/redirect/1 会 302 跳转，所以返回：

``` html
{
  "args": {},
  "headers": {
    "Accept": "*/*",
    "Host": "httpbin.org",
    "User-Agent": "curl/7.43.0"
  },
  "origin": "121.35.209.62",
  "url": "http://httpbin.org/get"
}
```

**http 认证**

当页面需要认证时，可以使用 `--user` ，例如：

``` sh
curl httpbin.org/basic-auth/tomshine/123456 --user tomshine:123456
```

返回：

``` html
{
  "authenticated": true,
  "user": "tomshine"
}
```



## tcpdump


### tcp 三次握手和四次挥手

**三次握手**

A 主动打开连接，B 被动打开连接

```
(1) 第一次握手：建立连接时，客户端 A 发送 SYN 包 (SYN=x) 到服务器 B，并进入 SYN_SEND 状态，等待服务器 B 确认。
(2) 第二次握手：服务器 B 收到 SYN 包，必须确认客户 A 的 SYN(ACK=x+1)，同时自己也发送一个 SYN 包 (SYN=y)，即 SYN+ACK 包，此时服务器 B 进入 SYN_RECV 状态。
(3) 第三次握手：客户端 A 收到服务器 B 的 SYN＋ACK 包，向服务器 B 发送确认包 ACK(ACK=y+1)，此包发送完毕，客户端 A 和服务器 B 进入 ESTABLISHED 状态，完成三次握手。
完成三次握手，客户端与服务器开始传送数据。
```

为什么 A 还要发送一次确认呢？

主要是为了防止已失效的连接请求报文段突然有传送到 B，因而产生错误。

***正常情况***

A 发出连接请求，但是因为连接请求报文丢失为未收到确认。于是 A 在重传一次连接请求，后来收到了确认，建立了连接。数据传输完毕后，就释放了连接。A 共发送两个连接请求报文段，其中第一个丢失第二个到达了 B。

***异常情况***
A 发出的第一个连接请求报文段并没有丢失，而是在某些网络节点长时间滞留，导致延误到连接释放之后才到达了 B，本来这是一个早已经失效的报文段，但是 B 收到此失效的连接请求报文段之后，误以为是 A 又发出一次新的连接请求，于是就向 A 发送确认报段，同意建立连接。假如不采用三次握手，那么只要 B 发出确认，新的连接就建立了。由于现在 A 并没有发出建立连接的请求，因此不会理睬 B 的确认，也不会向 B 发送数据，但 B 却以为新的运输连接已经建立了，并且一直等待 A 发来数据。B 的资源就这样白白的浪费了，
采用三次握手的办法可以防止上述现象的发生。例如刚才的情况，A 不会向 B 的确认发出确认。B 由于接收不到确认，就知道 A 并没有要求建立连接。

使用 tcpdump 来验证 TCP 的三次握手

使用 ssh localhost 来连接主机，使用使用 tcpdump 来验证 TCP 的三次握手


    [root@localhost apue]# tcpdump -i lo tcp -S
    tcpdump: verbose output suppressed, use -v or -vv for full protocol decode
    listening on lo, link-type EN10MB (Ethernet), capture size 65535 bytes
    1 15:08:03.039511 IP6 localhost.44910 > localhost.ssh: Flags [S], seq 3120401438, win 32752, options [mss 16376,sackOK,TS val 1319756 ecr 0,nop,wscale 7], length 0
    2 15:08:03.039546 IP6 localhost.ssh > localhost.44910: Flags [S.], seq 404185237, ack 3120401439, win 32728, options [mss 16376,sackOK,TS val 1319756 ecr 1319756,nop,wscale 7], length 0
    3 15:08:03.039576 IP6 localhost.44910 > localhost.ssh: Flags [.], ack 404185238, win 256, options [nop,nop,TS val 1319756 ecr 1319756], length 0
    4 15:08:03.064809 IP6 localhost.ssh > localhost.44910: Flags [P.], seq 404185238:404185259, ack 3120401439, win 256, options [nop,nop,TS val 1319781 ecr 1319756], length 21
    15:08:03.064944 IP6 localhost.44910 > localhost.ssh: Flags [.], ack 404185259, win 256, options [nop,nop,TS val 1319781 ecr 1319781], length 0


第一行就是第一次握手，客户端向服务器发送 SYN 标志 (Flags [S])，其中 seq = 3120401438；
第二行就是第二次握手，服务器向客户端进行 SYN+ACK 响应 (Flags [S.]), 其中 seq 404185237, ack 3120401439（是客户端的 seq+1 的值）
第三行就是第三次握手，客户端向服务器进行 ACK 响应 (Flags [.]), 其中 ack 404185238（就是服务器的 seq+1 的值）。

**四次挥手**

通信传输结束后，通信的双方都可以释放连接，现在 A 和 B 都处于 ESTABLISHED 状态。

由于 TCP 连接是全双工的，因此每个方向都必须单独进行关闭。这个原则是当一方完成它的数据发送任务后就能发送一个 FIN 来终止这个方向的连接。收到一个 FIN 只意味着这一方向上没有数据流动，一个 TCP 连接在收到一个 FIN 后仍能发送数据。首先进行关闭的一方将执行主动关闭，而另一方执行被动关闭。

(1) 客户端 A 发送一个 FIN 包，用来关闭客户 A 到服务器 B 的数据传送。序列号 seq = u，它等于前面已传送过的数据的最后一个字节的序号加 1. 这时 A 进入 FIN-WAIT-1（终止等待 1) 状态，等待 B 的确认。

(2) 服务器 B 收到这个 FIN，它发回一个 ACK，确认序号是 ack = u +1。和 SYN 一样，一个 FIN 将占用一个序号。这个报文段自己的序号是 v，等于 B 前面已经传送过的数据的最后一个字节的序号加 1。然后 B 进程进入 CLOSE-WAIT（关闭等待）状态。TCP 服务器进程这时应通知高层应用进程，因而从 A 到 B 的这个方向的连接就释放了，这时的 TCP 连接处于半关闭 (half-close) 状态， 即 A 已经没有数据要发送了，但是 B 若发送数据，A 仍要接收，也就是说从 B 到 A 这个方向的连接并没有关闭，这个状态可能会持续一些时间。A 收到来到 B 的确认后就进入 FIN-WAIT-2（终止等待 2) 状态，等待 B 发出的连接释放报文段。

(3) 若 B 已经没有要向 A 发送的数据，其应用进程就会通知 TCP 释放连接，这时 B 发出的连接释放报文段必须使 FIN = 1。现假定 B 的序号为 w（在半关闭状态 B 可能要发送一些数据）。B 还必须重复上次发送过的确认号 ack = u +1。这时 B 就进入了 LAST-ACK（最后确认）状态，等待 A 的确认。

(4)A 在收到 B 的连接释放报文段后，必须对此发出确认。在确认报文段中把 ACK 置 1，确认号 ack = w + 1，而自己的序号是 seq = u + 1（根据 TCP 标准，前面发送过的 FIN 报文段要消耗一个序号），然后进入到 TIME-WAIT（时间等待）状态。

***此时的 TCP 还没有完全的释放掉。必须经过时间等待计时器 (TIME-WAIT timer) 设置的时间 2MSL 后，A 才进入到 CLOSED 状态。***

> MSL 叫做最长报文段寿命，它是任何报文段被丢弃前在网络内的最长时间。

2MSL 也就是这个时间的两倍，RFC 建议设置为 2 分钟，但是 2 分钟可能太长了，因此 TCP 允许不同的实现使用更小的 MSL 值。

因此从 A 进入到 TIME-WAIT 状态后，要经过 4 分钟才能进入 CLOSED 状态，此案开始建立下一个新的连接。当 A 撤销相应的传输控制块 TCP 后，就结束了 TCP 连接。

使用 tcpdump 来验证 TCP 的四次挥手

退出 ssh 连接的主机，使用使用 tcpdump 来验证 TCP 的四次挥手


    15:14:58.836149 IP6 localhost.44911 > localhost.ssh: Flags [P.], seq 1823848744:1823848808, ack 3857143125, win 305, options [nop,nop,TS val 1735551 ecr 1735551], length 64
    15:14:58.836201 IP6 localhost.44911 > localhost.ssh: Flags [F.], seq 1823848808, ack 3857143125, win 305, options [nop,nop,TS val 1735551 ecr 1735551], length 0
    15:14:58.837850 IP6 localhost.ssh > localhost.44911: Flags [.], ack 1823848809, win 318, options [nop,nop,TS val 1735554 ecr 1735551], length 0
    15:14:58.842130 IP6 localhost.ssh > localhost.44911: Flags [F.], seq 3857143125, ack 1823848809, win 318, options [nop,nop,TS val 1735559 ecr 1735551], length 0
    15:14:58.842150 IP6 localhost.44911 > localhost.ssh: Flags [.], ack 3857143126, win 305, options [nop,nop,TS val 1735559 ecr 1735559], length 0

***seq start:end 意思是初始序列号：结束序列号，end = start + length, 但是接受包的结束序号应该是 end - 1。***

比如 start = 1，length = 3，那么真正的结束序号是 1+3-1 = 3, 因为开始序号也算在内的！

seq 1823848744:1823848808 意思是初始序列号：结束序列号，其实后面那个就是前面那个加上包长度 length = 64，实际上结束序列号是没有使用的，真正使用的序号是开始序号到结束序号 -1，也就是 1823848807

第一次挥手中客户端发送 FIN 即 [F.] seq u = 1823848808，也就是上次发送的数据的最后一个字节的序号加 1

第二次挥手中服务器发送 ACK 即 [.] ack 1823848809 = u + 1

第三次挥手中服务器发送 FIN 即 [F.] seq v = 3857143125， ack 1823848809 = u + 1

第四次挥手中客户端发送 ACK 即 [.] ack 3857143126 = v + 1


1. 默认情况下（不改变 socket 选项），当你调用 close 函数时，如果发送缓冲中还有数据，TCP 会继续把数据发送完。

2. 发送了`FIN 只是表示这端不能继续发送数据（应用层不能再调用 send 发送）`，但是还可以接收数据。

3. 应用层如何知道对方关闭？

在最简单的阻塞模型中，当调用 recv 时，如果返回 0，则表示对方关闭，

在这个时候通常的做法就是也调用 close，那么 TCP 层就发送 FIN，继续完成四次握手；

***如果不调用 close，那么对方就会处于 FIN_WAIT_2 状态，而本端则会处于 CLOSE_WAIT 状态；***

4. 在很多时候，TCP 连接的断开都会由 TCP 层自动进行，例如你 CTRL+C 终止你的程序，TCP 连接依然会正常关闭。

### tcpdump 使用

**针对特定网口抓包 (-i 选项）**

> tcpdump -i eth0

**指定抓包端口**

> tcpdump -i eth0 port 22

**抓取特定目标 ip 和端口的包**

> tcpdump -i eth0 dst 10.70.121.92 and port 22

**增加抓包时间戳 (-tttt 选项）**

> tcpdump -n -tttt -i eth0

## nc

nc 检测端口更方便，同时批量进行检测端口的话是非常好的工具

### 语法

nc [-hlnruz][-g《网关...>][-G《指向器数目》][-i《延迟秒数》][-o《输出文件》][-p《通信端口》][-s《来源位址》][-v...][-w《超时秒数》][主机名称][通信端口...]
    ```
    参数说明：
    -g《网关》 设置路由器跃程通信网关，最丢哦可设置 8 个。
    -G《指向器数目》 设置来源路由指向器，其数值为 4 的倍数。
    -h 在线帮助。
    -i《延迟秒数》 设置时间间隔，以便传送信息及扫描通信端口。
    -l 使用监听模式，管控传入的资料。
    -n 直接使用 IP 地址，而不通过域名服务器。
    -o《输出文件》 指定文件名称，把往来传输的数据以 16 进制字码倾倒成该文件保存。
    -p《通信端口》 设置本地主机使用的通信端口。
    -r 乱数指定本地与远端主机的通信端口。
    -s《来源位址》 设置本地主机送出数据包的 IP 地址。
    -u 使用 UDP 传输协议。
    -v 显示指令执行过程。
    -w《超时秒数》 设置等待连线的时间。
    -z 使用 0 输入 / 输出模式，只在扫描通信端口时使用。

    ```
### TCP 端口扫描
    ```
    # nc -v -z -w2 10.20.144.145 1-100
    Connection to 10.20.144.145 22 port [tcp/ssh] succeeded!
    nc: connect to 10.20.144.145 port 23 (tcp) failed: Connection refused
    nc: connect to 10.20.144.145 port 24 (tcp) failed: Connection refused
    nc: connect to 10.20.144.145 port 25 (tcp) failed: Connection refused
    ...
    Connection to 10.20.144.145 80 port [tcp/http] succeeded!
    ...
    扫描 10.20.144.145 的端口 范围是 1-100
    ```
    不加 -v 时仅输出 succeeded 的结果

### 扫描 UDP 端口
    ```
    # nc -u -z -w2 10.20.144.145 1-1000 // 扫描 10.20.144.145 的端口 范围是 1-1000
    扫描指定端口
    ```
