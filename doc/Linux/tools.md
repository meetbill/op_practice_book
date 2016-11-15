# Linux 工具篇

* [vim](#vim)
	* [快捷键](#快捷键)
		* [Movement](#movement)
		* [Search](#search)
		* [Deletion](#deletion)
		* [Yank & Put](#yank--put)
		* [Insert Mode ###](#insert-mode-)
		* [Visual Mode](#visual-mode)
		* [Other](#other)
	* [技巧](#技巧)
		* [shell 多行注释](#shell-多行注释)
		* [自动补全](#自动补全)
		* [左右分割打开 help 文档](#左右分割打开-help-文档)
		* [逐个替换](#逐个替换)
		* [关于 search/replace 中的换行符](#关于-searchreplace-中的换行符)
	* [vim IDE工具](#vim-ide工具)
* [sed](#sed)
* [awk](#awk)
	* [历史](#历史)
	* [基础知识](#基础知识)
		* [分隔符	](#分隔符)
		* [内建变量](#内建变量)
		* [转义](#转义)
		* [模式](#模式)
		* [单引号](#单引号)
	* [脚本](#脚本)
	* [运算与编程](#运算与编程)
	* [Example](#example)
		* [统计](#统计)
* [Git-分布式管理系统](#git-分布式管理系统)
	* [Git基础](#git基础)
		* [环境配置](#环境配置)
		* [基本操作](#基本操作)
		* [分支](#分支)
		* [标签](#标签)
		* [Git shortcuts/aliases](#git-shortcutsaliases)
	* [知识点](#知识点)
		* [文件的几种状态](#文件的几种状态)
		* [快照和差异](#快照和差异)
		* [Git数据结构](#git数据结构)
	* [其他操作](#其他操作)
		* [解决GitHub commit次数过多.git文件过大](#解决github-commit次数过多git文件过大)
* [curl](#curl)
	* [curl 基础](#curl-基础)
		* [直接获取（GET）一个url](#直接获取get一个url)
		* [post，put等](#postput等)
		* [form表单提交](#form表单提交)
	* [curl 深入](#curl-深入)
		* [显示头信息](#显示头信息)
		* [详细显示通信过程](#详细显示通信过程)
		* [设置头信息](#设置头信息)
		* [Referer字段](#referer字段)
		* [包含cookie](#包含cookie)
		* [自动跳转](#自动跳转)
		* [http认证](#http认证)
* [screen](#screen)
	* [新建一个Screen Session](#新建一个screen-session)
	* [将当前Screen Session放到后台](#将当前screen-session放到后台)
	* [唤起一个Screen Session](#唤起一个screen-session)
	* [分享一个Screen Session](#分享一个screen-session)
	* [终止一个Screen Session](#终止一个screen-session)
	* [查看一个screen里的输出](#查看一个screen里的输出)

# vim
## 快捷键

### Movement
* `h`  - Move *left*
* `j`  - Move *down*
* `k`  - Move *up*
* `l`  - Move *right*
* `0`  - Move to *beginging* of line, 也可以使用 `Home`.
* `^`  - 在有 tab 或 space 的代码行里, `0` 是移到最行首, 而 `^` 是移到代码行首
* `$`  - Move to *end* of line
* `gg` - Move to *first* line of file
* `G`  - Move to *last* line of file
* `ngg`- 移动到指定的第 n 行, 也可以用 `nG`
* `w`  - Move *forward* to next word
* `b`  - Move *backward* to next word
* `%`  - 在匹配的括号、块的首尾移动
* `C-o`- 返回到上次移动前的位置, 也可以用两个单引号 `'`
* `C-i`- 前进到后一次移动的位置
* `f`  - 后接字符，移动到当前行的下一个指定字符，然后按 `;` 继续搜索下一个
* `F`  - 同上，移动到上一个
* `|`  - 竖线，前接数字，移动到当前行的指定列，如 `30|` ，移动到当前行的第30列

### Search
* `*`     - Search *forward* for word under cursor
* `#`     - Search *backward* for word under curor
* `/word` - Search *forward* for *word*. Support *RE*
* `?word` - Search *backward* for *word*. Support *RE*
* `n`     - Repeat the last `/` or `?` command  
* `N`     - Repeat the last `/` or `?` command in opposite direction

在搜索后, 被搜索的单词都会高亮, 一般想取消那些高亮的单词, 可以再次搜索随便输入一些字母, 搜索不到自然就取消了. 另外也可以使用 `nohl` 取消这些被高亮的词.

### Deletion
* `x`  - Delete character *forward*(under cursor), and remain in normal mode
* `X`  - Delete character *backward*(before cursor), and remain in normal mode
* `r`  - Replace single character under cursor, and remain in normal mode
* `s`  - Delete single character under cursor, and *switch* to insert mode
* `shift+~` - 这个可以把光标下的单词转换为大写 / 小写, 并自动移到下一个字符
* `dw` - Delete a *word* forward
* `daw`- 上面的 `dw` 是删除一个单词的前向部分, 而这个是删除整个单词, 不论 cursor 是否在单词中间
* `db` - Delete a *word* backward
* `dd` - Delete *entire* current line
* `D`  - Delete until end of line


### Yank & Put
* `y`   - Yank(copy)
* `yy`  - Yank current line
* `nyy` - Yank `n` lines form current line
* `p`   - Put(paste) yanked text *below* current line
* `P`   - Put(paste) yanked text *above* current line

### Insert Mode ###
* `i` - Enter insert mode to the *left* of the cursor
* `a` - Enter insert mode to the *right* of the cursor
* `o` - Enter insert mode to the line *below* the current line
* `O` - Enter insert mode to the line *above* the current line

### Visual Mode
* `v`   - Enter visual mode, highlight characters
* `V`   - Enter visual mode, highlight lines
* `C-v` - Enter visual mode, highlight block

### Other
* `u`   - Undo
* `U`   - Undo all changes on current line
* `C-r` - Redo

## 技巧

### shell 多行注释

命令行模式下，注释掉 line1 与 line2 之间的行

    line1,line2s/^/#/g


### 自动补全

    Ctrl+n Ctrl+p
    Ctrl+x Ctrl+?{....}

### 左右分割打开 help 文档

默认是上下分割来打开文档，但是对于宽屏，左右分割反而更加方便

    :vert help xxx


### 逐个替换

全文直接替换:

    :%s/old_str/new_str/g

加上参数c可以逐个替换，这样可以对每一个再确认:

    :%s/old_str/new_str/gc


### 关于 search/replace 中的换行符

Search:

`\n` is `newline`, `\r` is `CR`(carriage return = Ctrl-M = ^M)

Replace:

`\r` is newline, `\n` is a null byte(0x00)

比如字符串 test1,test2,test3 把逗号换成换行：

    %s/,/\r/g

## vim IDE工具

* [VIM一键IDE](https://github.com/BillWang139967/Vim)


# sed

# awk
## 历史

AWK是贝尔实验室1977年搞出来的文本处理工具。

之所以叫AWK是因为其取了三位创始人 Alfred Aho，Peter Weinberger, 和 Brian Kernighan 的Family Name的首字符

## 基础知识
### 分隔符	

默认情况下， awk 使用空格当作分隔符。分割后的字符串可以使用$1, $2等访问。

上面提到过，我们可以使用 -F 来指定分隔符。
fs 如果是一个字符，可以直接跟在-F 后面，比如使用冒号当作分隔符就是 -F: .
如果分隔符比较复杂，就需要使用正则表达式来表示这个分隔符了。
正则表达式需要使用引号引起来。
比如使用‘ab’  当作分隔符，就是 -F 'ab' 了。
使用a或b作为分隔符，就是 -F '\[ab]' 了。
关于正则表达式这里不多说了。

### 内建变量

```text
$0	当前记录（这个变量中存放着整个行的内容）
$1~$n	当前记录的第n个字段，字段间由FS分隔
FS	输入字段分隔符 默认是空格或Tab
NF	当前记录中的字段个数，就是有多少列
NR	已经读出的记录数，就是行号，从1开始，如果有多个文件话，这个值也是不断累加中。
FNR	当前记录数，与NR不同的是，这个值会是各个文件自己的行号
RS	输入的记录分隔符， 默认为换行符
OFS	输出字段分隔符， 默认也是空格
ORS	输出的记录分隔符，默认为换行符
FILENAME	当前输入文件的名字
```

### 转义

一般字符在双引号之内就可以直接原样输出了.  
但是有部分转义字符, 需要使用反斜杠转义才能正常输出.  

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
### 模式

```text
~ 表示模式开始
/ /中是模式
!模式取反
```

### 单引号

当需要输出单引号时, 直接转义发现会报错.  
由于awk脚本并不是直接执行, 而是会先进行预处理, 所以需要两次转义.  
awk支持递归引号. 单引号内可以输出转义的单引号, 双引号内可以输出转义的双引号.  

比如需要输出单引号, 则需要下面这样:  

```
> awk 'BEGIN{print "\""}'
"
>  awk 'BEGIN{print "'\''"}'
'
```

当然, 更简单的方式是使用十六进制来输出.  

```
awk 'BEGIN{print "\x27"}'
```

## 脚本

```text
BEGIN{ 这里面放的是执行前的语句 }
END {这里面放的是处理完所有的行后要执行的语句 }
{这里面放的是处理每一行时要执行的语句}
```

## 运算与编程

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
		
## Example
	
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

### 统计

```bash
awk '{sum+=$5} END {print sum}'
```

# Git-分布式管理系统

## Git基础

### 环境配置

+ `git config user.name your_name` : 设置你的用户名, 提交会显示
+ `git config user.email your_email` : 设置你的邮箱
+ `git config core.quotepath false` : 解决中文文件名显示为数字问题

### 基本操作

+ `git init` : 初始化一个 git 仓库
+ `git add <filename>` : 添加一个文件到 git 仓库中
+ `git commit -m "commit message"`: 提交到本地
+ `git push [remote-name] [branch-name]` : 把本地的提交记录推送到远端分支
+ `git pull`: 更新仓库 `git pull` = `git fetch` + `git merge`
+ `git checkout -- <file>` : 还原未暂存(staged)的文件
+ `git reset HEAD <file>...` : 取消暂存，那么还原一个暂存文件，应该是先 `reset` 后 `checkout`
+ `git stash` : 隐藏本地提交记录, 恢复的时候 `git stash pop`。这样可以在本地和远程有冲突的情况下，更新其他文件

### 分支

+ `git branch <branch-name>` : 基于当前 commit 新建一个分支，但是不切换到新分支
+ `git checkout -b <branch-name>` : 新建并切换分支
+ `git checkout <branch-name>` : 切换分支
+ `git branch -d <branch-name>` : 删除分支
+ `git push origin <branch-name>` : 推送本地分支
+ `git checkout -b <local-branch-name> origin/<origin-branch-name>` : 基于某个远程分支新建一个分支开发
+ `git checkout --track origin/<origin-branch-name>` : 跟踪远程分支(创建跟踪远程分支，Git 在 `git push` 的时候不需要指定 `origin` 和 `branch-name` ，其实当我们 `clone` 一个 repo 到本地的时候，`master` 分支就是 origin/master 的跟踪分支，所以提交的时候直接 `git push`)。
+ `git push origin :<origin-branch-name>` : 删除远程分支

### 标签

+ `git tag -a <tagname> -m <message>` : 创建一个标签
+ `git tag` : 显示已有的标签
+ `git show tagname`: 显示某个标签的详细信息
+ `git checkout -b <tag-name>` : 基于某个 tag 创建一个新的分支

### Git shortcuts/aliases

    git config --global alias.co checkout
    git config --global alias.br branch
    git config --global alias.ci commit
    git config --global alias.st status

## 知识点

基本命令让你快速的上手使用Git，知识点能让你更好的理解Git。

### 文件的几种状态

+ untracked: 未被跟踪的，没有纳入 Git 版本控制，使用 `git add <filename>` 纳入版本控制
+ unmodified: 未修改的，已经纳入版本控制，但是没有修改过的文件
+ modified: 对纳入版本控制的文件做了修改，git 将标记为 modified
+ staged: 暂存的文件，简单理解: 暂存文件就是 add 之后，commit 之前的文件状态

理解这几种文件状态对于理解 Git 是非常关键的(至少可以看懂一些错误提示了)。

### 快照和差异

详细可看：[Pro Git: Git基础](http://iissnan.com/progit/html/zh/ch1_3.html)中有讲到 *直接记录快照，而非差异比较*，这里只讲我个人的理解。

Git 关心的是文件数据整体的变化，其他版本管理系统(以svn为例)关心的某个具体文件的*差异*。这个差异是好理解的，也就是两个版本具体文件的不同点，比如某一行的某个字符发生了改变。

Git 不保存文件提交前后的差异，不变的文件不会发生任何改变，对于变化的文件，前后两次提交则保存两个文件。举个例子：

SVN:

1. 新建3个文件a, b, c，做第一次提交 ->  `version1 : file_a file_b file_c`
2. 修改文件 b， 做第二次提交(真正提交的是 修改后的文件 b 和修改前的 `file_b` 的 diff) -> `version2: diff_b_2_1`
3. 当我要 checkout version2 的时候，实际上得到的是 `file_a file_b+diff_b_2_1 file_c`

Git:

1. 新建3个文件a, b, c，做第一次提交 ->  `version1 : file_a file_b file_c`
2. 修改文件 b (得到`file_b1`), 做第二次提交 -> `version2: file_a file_b1 file_c` 
3. 当我要用 version2 的时候，实际上得到的是 `file_a file_b1 file_c` 

上面的 `file_a file_b1 file_c` 就是 version2 的 *快照*。

### Git数据结构

Git的核心数是很简单的，就是一个链表(或者一棵树更准确一些？无所谓了)，一旦你理解了它的基本数据结构，再去看Git，相信你有不同的感受。继续用上面的例子(所有的物理文件都对应一个 SHA-1 的值)

当我们做第一次提交时，数据结构是这样的:


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

当修改了 `file_b`, 再提交一次时，数据结构应该是这样的:

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
            commit_content: "更新文件b"
        file_list:
            [1]: 28415f07ca9281d0ed86cdc766629fb4ea35ea38
            [2]: 39015ba6f80eb9e7fdad3602ef2b1af0521eba89
            [3]: 1b5ca12a6cf11a9b89dbeee2e5431a1a98ea5e39
        pre_commit: null
        next_commit: commit_26b985d269d3a617af4064489199c3e0d4791bb5

当提交完第二次的时候，执行 `git log`，实际上就是从 `commit_a08a57561b5c30b9c0bf33829349e14fad1f5cff` 开始遍历然后打印 `base_info` 而已。

实际的 git 实际肯定要比上面的结构((的信息)的)要复杂的多，但是它的核心思想应该是就是，每一次提交就是一个新的结点。通过这个结点，我可以找到所有的快照文件。再思考一下，什么是分支？什么是 Tags，其实他们可能只是某次提交的引用而已(一个 `tag_head_node` 指向了某一次提交的node)。再思考怎么回退一个版本呢？指针偏移！依次类推，上面的基本命令都可以得到一个合理的解释。

**理解git fetch 和 git pull的差异**

上面我们说过 `git pull` 等价于 `git fetch` 和 `git merge` 两条命令。当我们 `clone` 一个 repo 到本地时，就有了本地分支和远端分支的概念(假定我们只有一个主分支)，本地分支是 `master`，远端分支是 `origin/master`。通过上面我们对 Git 数据结构的理解，`master` 和 `origin/master` 可以想成是指向最新 commit 结点的两个指针。刚 `clone` 下来的 repo，`master` 和 `origin/master` 指针指向同一个结点，我们在本地提交一次，`origin` 结点就更新一次，此时 `master` 和 `orgin/master` 就不再相同了。很有可能别人已经 commit 改 repo 很多次了，并且进行了提交。那么我们的本地的 `origin/master` 就不再是远程服务器上的最新的位置了。 `git fetch` 干的就是从服务器上同步服务器上最新的 `origin/master` 和一些服务器上新的记录/文件到本地。而 `git merge` 就是合并操作了(解决文件冲突)。`git push` 是把本地的 `origin/master` 和 `master` 指向相同的位置，并且推送到远程的服务器。

## 其他操作

### 解决GitHub commit次数过多.git文件过大

完全重建版本库

```
# rm -rf .git
# git init
# git add .
# git cm "first commit"
# git remote add origin <your_github_repo_url>
# git push -f -u origin master
```

# curl 
## curl 基础
在介绍前，我需要先做两点说明：

1. 下面的例子中会使用 [httpbin.org](http://httpbin.org/) ，httpbin提供客户端测试http请求的服务，非常好用，具体可以查看他的网站。
2. 大部分没有使用缩写形式的参数，例如我使用 `--request` 而不是 `-X` ，这是为了好记忆。

下面开始简单介绍几个命令：

### 直接获取（GET）一个url

直接以个GET方式请求一个url，输出返回内容：

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

<!--more-->

### post，put等

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

这个返回值是httpbin输出的，可以清晰的看出我们发送了什么数据，非常实用。

### form表单提交

form表单提交使用 `--form`，使用 `@` 指定本地文件，例如我们提交一个表单，有字段name和文件f：

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

## curl 深入
### 显示头信息

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

### 详细显示通信过程

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

### 设置头信息

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

### Referer字段

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

### 包含cookie

使用 `--cookie` 来设置请求的cookie，例如：

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

### 自动跳转

使用 `--location` 参数会跟随链接的跳转，例如：

``` sh
curl httpbin.org/redirect/1 --location
```

httpbin.org/redirect/1会302跳转，所以返回：

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

### http认证

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


# screen

现在很多时候我们的开发环境都已经部署到云端了，直接通过SSH来登录到云端服务器进行开发测试以及运行各种命令，一旦网络中断，通过SSH运行的命令也会退出，这个发让人发疯的。

好在有screen命令，它可以解决这些问题。我使用screen命令已经有三年多的时间了，感觉还不错。

## 新建一个Screen Session

```
$ screen -S screen_session_name
```

## 将当前Screen Session放到后台

```
$ CTRL + A + D
```

## 唤起一个Screen Session

```
$ screen -r screen_session_name
```

## 分享一个Screen Session

```
$ screen -x screen_session_name
```

通常你想和别人分享你在终端里的操作时可以用此命令。

## 终止一个Screen Session

```
$ exit
$ CTRL + D
```

## 查看一个screen里的输出

当你进入一个screen时你只能看到一屏内容，如果想看之前的内容可以如下：

```
$ Ctrl + a ESC
```

以上意思是进入Copy mode，拷贝模式，然后你就可以像操作VIM一样查看screen session里的内容了。

可以 Page Up 也可以 Page Down。
