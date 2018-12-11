## Linux 安全

<!-- vim-markdown-toc GFM -->

* [1 禁止 ping](#1-禁止-ping)
* [2 禁止密码登陆](#2-禁止密码登陆)
* [3 ssh 防暴力破解及提高 ssh 安全](#3-ssh-防暴力破解及提高-ssh-安全)
* [4 运维操作审计](#4-运维操作审计)
* [5 双因子认证](#5-双因子认证)
    * [5.1  安装及配置篇](#51--安装及配置篇)
        * [5.1.1 环境](#511-环境)
        * [5.1.2 查看系统时间](#512-查看系统时间)
        * [5.1.3 安装 google authenticator](#513-安装-google-authenticator)
        * [5.1.4 为 SSH 服务器用 Google 认证器](#514-为-ssh-服务器用-google-认证器)
        * [5.1.5 生成验证密钥](#515-生成验证密钥)
    * [5.2 使用](#52-使用)
        * [5.2.1 在安卓设备上运行 Google 认证器](#521-在安卓设备上运行-google-认证器)
        * [5.2.2 终端使用二次身份验证登陆](#522-终端使用二次身份验证登陆)
    * [5.3 常见问题及注意点](#53-常见问题及注意点)
        * [5.3.1 登陆失败](#531-登陆失败)
        * [5.3.2 是否可以不同的用户使用不用密钥](#532-是否可以不同的用户使用不用密钥)
        * [5.3.3 是否可以使用 ssh 密钥直接登陆](#533-是否可以使用-ssh-密钥直接登陆)
    * [5.4 原理](#54-原理)
        * [5.4.1 前世今生](#541-前世今生)
        * [5.4.2 TOTP 中的特殊问题](#542-totp-中的特殊问题)
* [6 iptables 命令](#6-iptables-命令)
    * [6.1 iptables 是什么](#61-iptables-是什么)
    * [6.2 iptables 示例](#62-iptables-示例)
        * [6.2.1 filter 表 INPUT 链](#621-filter-表-input-链)
        * [6.2.2 filter 表 OUTPUT 链](#622-filter-表-output-链)
        * [6.2.3 filter 表的 FORWARD 链](#623-filter-表的-forward-链)
    * [6.3 nat 表](#63-nat-表)
        * [6.3.1 nat 表 PREROUTING 链](#631-nat-表-prerouting-链)
        * [6.3.2 nat 表 POSTROUTING 链](#632-nat-表-postrouting-链)
        * [6.3.3 nat 表做 HA 的实例](#633-nat-表做-ha-的实例)
        * [6.3.4 nat 表为虚拟机做内外网联通](#634-nat-表为虚拟机做内外网联通)
    * [6.4 iptables 管理命令](#64-iptables-管理命令)
        * [6.4.1 查看 iptables 规则](#641-查看-iptables-规则)
        * [6.4.2 清除 iptables 规则](#642-清除-iptables-规则)
        * [6.4.3 保存 iptables 规则](#643-保存-iptables-规则)
    * [6.5 常用操作](#65-常用操作)
        * [6.5.1 使用 ip6tables 禁用 ipv6](#651-使用-ip6tables-禁用-ipv6)
        * [6.5.2 配置 iptables 允许部分端口同行，其他全部阻止](#652-配置-iptables-允许部分端口同行其他全部阻止)

<!-- vim-markdown-toc -->

## 1 禁止 ping

禁止系统响应任何从外部 / 内部来的 ping 请求攻击者一般首先通过 ping 命令检测此主机或者 IP 是否处于活动状态 ，如果能够 ping 通某个主机或者 IP，那么攻击者就认为此系统处于活动状态，继而进行攻击或破坏。如果没有人能 ping 通机器并收到响应，那么就可以大大增强服务器的安全性，linux 下可以执行如下设置，禁止 ping 请求：
```
[root@localhost ~]#echo "1"> /proc/sys/net/ipv4/icmp_echo_ignore_all
```
默认情况下"icmp_echo_ignore_all"的值为"0"，表示响应 ping 操作。

可以加上面的一行命令到 /etc/rc.d/rc.local 文件中，以使每次系统重启后自动运行

## 2 禁止密码登陆

## 3 ssh 防暴力破解及提高 ssh 安全

## 4 运维操作审计

[添加运维操作审计工具](https://github.com/meetbill/shell_menu)

## 5 双因子认证

海上生明月，天涯共此时！

### 5.1  安装及配置篇

#### 5.1.1 环境

server：CentOS 6.5/CentOS 7.3

#### 5.1.2 查看系统时间

使用外网机器时，创建的时候有可能不是北京时间

```
[root@centos ~]#date
Sun Aug 14 23:18:41 EDT 2011
[root@centos ~]# rm -rf /etc/localtime
[root@centos ~]# ln -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
```
#### 5.1.3 安装 google authenticator

安装 EPEL 源并安装 google_authenticator

```
#yum -y install epel-release
#yum -y install google-authenticator
```
#### 5.1.4 为 SSH 服务器用 Google 认证器

**配置 /etc/pam.d/sshd**

```
# CentOS 6.5 在"auth       include      password-auth"行前添加如下内容
# CentOS 7 在"auth       substack     password-auth"行前添加如下内容
auth       required pam_google_authenticator.so
```
即先 google 方式认证再 linux 密码认证

**修改 SSH 服务配置 /etc/ssh/sshd_config**

ChallengeResponseAuthentication no->yes

```
sed -i 's#^ChallengeResponseAuthentication no#ChallengeResponseAuthentication yes#' /etc/ssh/sshd_config
```
**重启 SSH 服务**

```
# CentOS6
#service sshd restart

# CentOS7
# systemctl restart sshd
```
**关掉 selinux**

```
# setenforce 0
# 修改 /etc/selinux/config 文件 将 SELINUX=enforcing 改为 SELINUX=disabled
```

#### 5.1.5 生成验证密钥
在 Linux 主机上登陆需要认证的用户运行 Google 认证器（我这是使用 root 用户演示的）
```
$google-authenticator
```
直接一路输入 yes 即可，询问内容如下，想了解的可以看下

```
Do you want me to update your "~/.google_authenticator" file (y/n):y
应急码的保存路径

Do you want to disallow multiple uses of the same authentication token?
This restricts you to one login about every 30s,
but it increases your chances to notice or even prevent man-in-the-middle attacks (y/n)
是否禁止一个口令多用，自然也是答 y

By default, tokens are good for 30 seconds and in order to compensate for possible time-skew between the client and the server,
we allow an extra token before and after the current time. If you experience problems with poor time synchronization, you can increase the window from its default size of 1:30min to about 4min. Do you want to do so (y/n)
问是否打开时间容错以防止客户端与服务器时间相差太大导致认证失败。
这个可以根据实际情况来。如果一些 Android 平板电脑不怎么连网的，可以答 y 以防止时间错误导致认证失败。

If the computer that you are logging into isn't hardened against brute-force login attempts,
you can enable rate-limiting for the authentication module.
By default, this limits attackers to no more than 3 login attempts every 30s.Do you want to enable rate-limiting (y/n)
选择是否打开尝试次数限制（防止暴力攻击），自然答 y
```
这里需要记住的是

```
$cat ~/.google_authenticator       手机密钥和应急码保存路径
密钥
Your emergency scratch codes are: 一些生成的 5 个应急码，每个应急码只能使用一次
```
### 5.2 使用

#### 5.2.1 在安卓设备上运行 Google 认证器

***安装 google 身份验证器***

我的方法是在 UC 中搜索的 google 身份验证器进行的安装

***输入密钥***

选择"Enter provided key"选项，使用键盘输入账户名称和验证密钥

#### 5.2.2 终端使用二次身份验证登陆

***windows xshell***

打开 xshell（其他终端类似），选择登陆主机的属性。设置登陆方法为 Keyboard Interactive

登陆时输入用户名后，接着输入手机设备上的数字，然后输入密码

***linux***

linux 下直接输入

```
#ssh 用户名 @IP
```
连接比较慢时可以修改本机的客户端配置文件 ssh_config，注意，不是 sshd_config

GSSAPIAuthentication yes -->no

```
#sed -i 's#GSSAPIAuthentication yes#GSSAPIAuthentication no#' /etc/ssh/ssh_config

```
### 5.3 常见问题及注意点

#### 5.3.1 登陆失败

如果 SELinux 是打开状态，则会登陆失败，日志 /var/log/secret 中会有如下日志

```
Jan  3 23:42:50 hostname sshd(pam_google_authenticator)[1654]: Failed to update secret file "/home/username/.google_authenticator"
Jan  3 23:42:50 hostname  sshd[1652]: error: PAM: Cannot make/remove an entry for the specified session for username from 192.168.0.5
```
#### 5.3.2 是否可以不同的用户使用不用密钥

可以，只需要在不同的用户执行`google-authenticator`即可

#### 5.3.3 是否可以使用 ssh 密钥直接登陆

可以，根据以上方法操作，只限制密码登陆时需要二次认证

### 5.4 原理

 基于时间的一次性密码（Time-based One-time Password，简称 TOTP），只需要在手机上安装密码生成应用程序，就可以生成一个随着时间变化的一次性密码，用于帐户验证，而且这个应用程序不需要连接网络即可工作。仔细看了看这个方案的实现原理，发现挺有意思的。

#### 5.4.1 前世今生

***HOTP***

 Google 的两步验证算法源自另一种名为 HMAC-Based One-Time Password 的算法，简称 HOTP。HOTP 的工作原理如下：

 客户端和服务器事先协商好一个密钥 K，用于一次性密码的生成过程，此密钥不被任何第三方所知道。此外，客户端和服务器各有一个计数器 C，并且事先将计数值同步。
进行验证时，客户端对密钥和计数器的组合 (K,C) 使用 HMAC（Hash-based Message Authentication Code）算法计算一次性密码，公式如下：

> HOTP(K,C) = Truncate(HMAC-SHA-1(K,C))

上面采用了 HMAC-SHA-1，当然也可以使用 HMAC-MD5 等。HMAC 算法得出的值位数比较多，不方便用户输入，因此需要截断（Truncate）成为一组不太长十进制数（例如 6 位）。计算完成之后客户端计数器 C 计数值加 1。用户将这一组十进制数输入并且提交之后，服务器端同样的计算，并且与用户提交的数值比较，如果相同，则验证通过，服务器端将计数值 C 增加 1。如果不相同，则验证失败。

这里的一个比较有趣的问题是，如果验证失败或者客户端不小心多进行了一次生成密码操作，那么服务器和客户端之间的计数器 C 将不再同步，因此需要有一个重新同步（Resynchronization）的机制。

***TOTP***

介绍完了 HOTP，Time-based One-time Password（TOTP）也就容易理解了。TOTP 将 HOTP 中的计数器 C 用当前时间 T 来替代，于是就得到了随着时间变化的一次性密码。非常有趣吧！

一句话概括就是

> 海上升明月，天涯共此时！

#### 5.4.2 TOTP 中的特殊问题

***时间 T 的选取 (30 秒作为时间片）***

首先，时间 T 的值怎么选取？因为时间每时每刻都在变化，如果选择一个变化太快的 T（例如从某一时间点开始的秒数），那么用户来不及输入密码。如果选择一个变化太慢的 T（例如从某一时间点开始的小时数），那么第三方攻击者就有充足的时间去尝试所有可能的一次性密码（试想 6 位数字的一次性密码仅仅有 10^6 种组合），降低了密码的安全性。除此之外，变化太慢的 T 还会导致另一个问题。如果用户需要在短时间内两次登录账户，由于密码是一次性的不可重用，用户必须等到下一个一次性密码被生成时才能登录，这意味着最多需要等待 59 分 59 秒！这显然不可接受。综合以上考虑，

Google 选择了 30 秒作为时间片，T 的数值为从 Unix epoch（1970 年 1 月 1 日 00:00:00）来经历的 30 秒的个数。

***网络延时处理***

第二个问题是，由于网络延时，用户输入延迟等因素，可能当服务器端接收到一次性密码时，T 的数值已经改变，这样就会导致服务器计算的一次性密码值与用户输入的不同，验证失败。解决这个问题个一个方法是，服务器计算当前时间片以及前面的 n 个时间片内的一次性密码值，只要其中有一个与用户输入的密码相同，则验证通过。当然，n 不能太大，否则会降低安全性。
事实上，这个方法还有一个另外的功能。我们知道如果客户端和服务器的时钟有偏差，会造成与上面类似的问题，也就是客户端生成的密码和服务端生成的密码不一致。但是，如果服务器通过计算前 n 个时间片的密码并且成功验证之后，服务器就知道了客户端的时钟偏差。因此，下一次验证时，服务器就可以直接将偏差考虑在内进行计算，而不需要进行 n 次计算。

以上就是 Google 两步验证的工作原理，推荐大家使用，这确实是保护帐户安全的利器。

## 6 iptables 命令

### 6.1 iptables 是什么
iptables 是与 Linux 内核集成的 IP 信息包过滤系统，该系统有利于在 Linux 系统上更好地控制 IP 信息包过滤和防火墙配置。

### 6.2 iptables 示例
#### 6.2.1 filter 表 INPUT 链
怎么处理发往本机的包。

```
# iptables {-A|-D|-I} INPUT rule-specification
# iptables -A INPUT -s 10.1.2.11 -p tcp --dport 80 -j DROP
# iptables -A INPUT -s 10.1.2.11 -p tcp --dport 80 -j REJECT --reject-with tcp-reset
# iptables -A INPUT -s 10.1.2.11 -p tcp --dport 80 -j ACCEPT
```

以上表示将从源地址 10.1.2.11 访问本机 80 端口的包丢弃（以 tcp-reset 方式拒绝和接受）。

> * -s 表示源地址（--src,--source），其后面可以是一个 IP 地址（10.1.2.11）、一个 IP 网段（10.0.0.0/8）、几个 IP 或网段（192.168.1.11/32,10.0.0.0/8，添加完成之后其实是两条规则）。
> * -d 表示目的地址（--dst,--destination），其后面可以是一个 IP 地址（10.1.2.11）、一个 IP 网段（10.0.0.0/8）、几个 IP 或网段（10.1.2.11/32,10.1.3.0/24，添加完成之后其实是两条规则）。
> * -p 表示协议类型（--protocol），后面可以是 tcp, udp, udplite, icmp, esp, ah, sctp, all，其中 all 表示所有的协议。
> * --sport 表示源端口（--source-port），后面可以是一个端口（80）、一系列端口（80:90，从 80 到 90 之间的所有端口），一般在 OUTPUT 链使用。
> * --dport 表示目的端口（--destination-port），后面可以是一个端口（80）、一系列端口（80:90，从 80 到 90 之间的所有端口）。
> * -j 表示 iptables 规则的目标（--jump），即一个符合目标的数据包来了之后怎么去处理它。常用的有 ACCEPT, DROP, REJECT, REDIRECT, LOG, DNAT, SNAT。
>   * (“就好象骗子给你打电话，ACCEPT 是接收，drop 就是直接拒收，reject 的话，相当于你还给骗子回个电话。”)

```
# iptables -A INPUT -p tcp --dport 80 -j DROP
# iptables -A INPUT -p tcp --dport 80:90 -j DROP
# iptables -A INPUT -m multiport -p tcp --dports 80,8080 -j DROP
```

以上表示将所有访问本机 80 端口（80 和 90 之间的所有端口，80 和 8080 端口）的包丢弃。

> * -m 匹配更多规则（--match），可以指定更多的 iptables 匹配扩展。可以是 tcp, udp, multiport, cpu, time, ttl 等，即你可以指定一个或多个端口，或者本机的一个 CPU 核心，或者某个时间段内的包。

#### 6.2.2 filter 表 OUTPUT 链
怎么处理本机向外发的包。

```
# iptables -A OUTPUT -p tcp --sport 80 -j DROP
```

以上这条规则意思是不允许访问本机 80 端口的包出去。即你可以向本机 80 端口发送请求包，但是本机回应给你的包会被该条规则丢弃。

INPUT 链与 OUTPUT 链用法一样，但是表示的意思不同。

#### 6.2.3 filter 表的 FORWARD 链
For packets being routed through the box（不知道怎么解释）。

其用法与 INPUT 链和 OUTPUT 链类似。

### 6.3 nat 表
nat 表有三条链，分别是 PREROUTING, OUTPUT, POSTROUTING。

#### 6.3.1 nat 表 PREROUTING 链
修改发往本机的包。

```
# iptables -t nat -A PREROUTING -p tcp -d 202.102.152.23 --dport 80 -j DNAT --to-destination 10.67.15.23:8080
# iptables -t nat -A PREROUTING -p tcp -d 202.102.152.23 -j DNAT --to-destination 10.67.15.23
```

以上这两条规则的意思是将发往 IP 地址 202.102.152.23 和端口 80 的包的目的地址修改为 10.67.15.23，目的端口修改为 8080。将发往 202.102.152.23 的其他非 80 端口的包目的地址修改为 10.67.15.23。第二条规则中的 -p tcp 是可选的，也可以指定其他协议。

其实类似这样的规则一般在路由器上做，路由器上有个公网 IP（202.102.152.23），其中有个用户的内网 IP（10.67.15.23）想提供外网的 web 服务，而路由器又不想将公网 IP 地址绑定到用户机器上，因此就出来了以上的蛋疼规则。

#### 6.3.2 nat 表 POSTROUTING 链
修改本机向外发的包。

```
# iptables -t nat -A POSTROUTING -p tcp -s 10.67.15.23 --sport 8080 -j SNAT --to-source 202.102.152.23:80
# iptables -t nat -A POSTROUTING -p tcp -s 10.67.15.23 -j SNAT --to-source 202.102.152.23
```

以上两条规则的意思是将从 IP 地址 10.67.15.23 和端口 8080 发出的包的源地址修改为 202.102.152.23，源端口修改为 80。将从 10.67.15.23 发出的非 80 端口的包的源地址修改为 202.102.152.23。

这两条正好与以上两条 PREROUTING 共同完成了内网用户想提供外网服务的功能。

其中的 --to-destination 和 --to-source 都可以缩写成 --to，在 DNAT 和 SNAT 中会分别被理解成 --to-destination 和 --to-source。

注： 之所以将内网服务的端口和外网服务的端口写的不一致是因为二者其实真的可以不一致。另外，是否将 PREROUTNG 中的 -d 改为域名就可以使用一个公网 IP 为不同用户提供服务了呢？这个需要哥哥我稍后验证。

#### 6.3.3 nat 表做 HA 的实例
有两台服务器和三个 IP 地址，分别是 10.1.2.21, 10.1.2.22, 10.1.5.11。假设他们提供的是相同的 WEB 服务，现在想让他们做 HA，而 10.1.5.11 是他们的 VIP。

* 10.1.2.21 这台的 NAT 规则如下：

```
# iptables -t nat -A PREROUTING -p tcp -d 10.1.2.11 --dport 80 -j DNAT --to-destination 10.1.2.21:80
# iptables -t nat -A POSTROUTING -p tcp -s 10.1.2.21 --sport 80 -j SNAT --to-source 10.1.2.11:80
```

* 10.1.2.22 这台的 NAT 规则如下：

```
# iptables -t nat -A PREROUTING -p tcp -d 10.1.2.11 --dport 80 -j DNAT --to-destination 10.1.2.22:80
# iptables -t nat -A POSTROUTING -p tcp -s 10.1.2.22 --sport 80 -j SNAT --to-source 10.1.2.11:80
```

默认可以认为 VIP 在 10.1.2.21 上挂着，那么当这台机器发生故障不能提供服务时，我们可以及时将 VIP 挂到 10.1.2.22 上，这样就可以保证服务不中断了。当然我们可以写一个简单的 SHELL 脚本来完成 VIP 的检测及挂载，方法非常简单。

注： LVS 的实现中貌似有这么一项，还没有深入去研究 LVS。

#### 6.3.4 nat 表为虚拟机做内外网联通

宿主机内网 IP 是 10.67.15.183(eth1)，外网 IP 是 202.102.152.183(eth0)，内网网关是 10.67.15.1，其上面的虚拟机 IP 是 10.67.15.250(eth1)。

目前虚拟机只能连接内网，其路由信息如下：

```
# ip r s
10.67.15.0/24 dev eth1  proto kernel  scope link  src 10.67.15.250
169.254.0.0/16 dev eth1  scope link  metric 1003
192.168.0.0/16 via 10.67.15.1 dev eth1
172.16.0.0/12 via 10.67.15.1 dev eth1
10.0.0.0/8 via 10.67.15.1 dev eth1
default via 10.67.15.1 dev eth1
```

若要以 NAT 方式实现该虚拟机即能连接公网又能连接内网，则该虚拟机路由需要改成以下：

```
# ip r s
10.67.15.0/24 dev eth1  proto kernel  scope link  src 10.67.15.250
169.254.0.0/16 dev eth1  scope link  metric 1003
192.168.0.0/16 via 10.67.15.1 dev eth1
172.16.0.0/12 via 10.67.15.1 dev eth1
10.0.0.0/8 via 10.67.15.1 dev eth1
default via 10.67.15.183 dev eth1
```
虚拟机连接内网的网关地址也可以写成宿主机内网 IP 地址。

宿主机上面添加如下 NAT 规则：

```
# iptables -t nat -A POSTROUTING -s 10.67.15.250/32 -d 10.0.0.0/8 -j SNAT --to-source 10.67.15.250
# iptables -t nat -A POSTROUTING -s 10.67.15.250/32 -d 172.16.0.0/12 -j SNAT --to-source 10.67.15.250
# iptables -t nat -A POSTROUTING -s 10.67.15.250/32 -d 192.168.0.0/16 -j SNAT --to-source 10.67.15.250
# iptables -t nat -A POSTROUTING -s 10.67.15.250/32 -j SNAT --to-source 202.102.152.183
```

以上四条规则的意思是将从源地址 10.67.15.250 发往内网机器上的数据包的源地址改为 10.67.15.250。将从源地址 10.67.15.250 发往公网机器上的数据包的源地址修改为 202.102.152.183。

### 6.4 iptables 管理命令
#### 6.4.1 查看 iptables 规则

```
# iptables -nL
# iptables -n -L
# iptables --numeric --list
# iptables -S
# iptables --list-rules
# iptables -t nat -nL
# iptables-save
```
> * -n 代表 --numeric，意思是 IP 和端口都以数字形式打印出来。否则会将 127.0.0.1:80 输出成 localhost:http。端口与服务的对应关系可以在 /etc/services 中查看。
> * -L 代表 --list，列出 iptables 规则，默认列出 filter 链中的规则，可以用 -t 来指定列出哪个表中的规则。
> * -t 代表 --tables，指定一个表。
> * -S 代表 --list-rules，以原命令格式列出规则。

iptables-save 命令是以原命令格式列出所有规则，可以 -t 指定某个表。

#### 6.4.2 清除 iptables 规则

```
# iptables -F
# iptables --flush
# iptables -F OUTPUT
# iptables -t nat -F
# iptables -t nat -F PREROUTING
```

> * -F 代表 --flush，清除规则，其后面可以跟着链名，默认是将指定表里所有的链规则都清除。
>   * （警告：如果已经配置过默认规则为 deny 的环境，即 iptables -P INPUT DROP ，直接命令行执行 iptables -F 将使系统的所有网络访问中断，此坑已踩过）

#### 6.4.3 保存 iptables 规则

```
# /etc/init.d/iptables save
```

该命令会将 iptables 规则保存到 /etc/sysconfig/iptables 文件里面，如果 iptable 有开机启动的话，开机时会自动将这些规则添加到机器上。

### 6.5 常用操作
iptables 命令中的很多选项前面都可以加"!"，意思是“非”。如"! -s 10.0.0.0/8"表示除这个网段以外的源地址，"! --dport 80"表示除 80 以外的其他端口。

#### 6.5.1 使用 ip6tables 禁用 ipv6

目前 ipv6 不禁用会存在安全隐患，那我们就可以通过 ip6tables 禁用 ipv6，我们只要在 ip6tables 的 filter 表上的出入口以及转发做限定就行了。

```
[root@meetbill ~]# vim /etc/sysconfig/ip6tables
*filter
:INPUT ACCEPT [0:0]
:FORWARD ACCEPT [0:0]
:OUTPUT ACCEPT [0:0]

# 添加这 3 条规则

-A INPUT -j REJECT --reject-with icmp6-adm-prohibited
-A FORWARD -j REJECT --reject-with icmp6-adm-prohibited
-A OUTPUT -j REJECT --reject-with icmp6-adm-prohibited
COMMIT
[root@meetbill ~]# /etc/init.d/ip6tables restart
```
可以通过 ifconfig 查看 ipv6 的地址
```
[root@meetbill ~]# ping6 -I eth0 fe80::20c:29ff:febc:8aab

```
#### 6.5.2 配置 iptables 允许部分端口同行，其他全部阻止

将下列内容放到脚本中，然后执行脚本即可，此脚本可以重复执行
```
#!/bin/bash
iptables -F /* 清除所有规则 */
iptables -A INPUT -p tcp --dport 22 -j ACCEPT /*允许包从 22 端口进入*/
iptables -A OUTPUT -p tcp --sport 22 -m state --state ESTABLISHED -j ACCEPT /*允许从 22 端口进入的包返回*/
iptables -A INPUT -s 127.0.0.1 -d 127.0.0.1 -j ACCEPT /*允许本机访问本机*/
iptables -A OUTPUT -s 127.0.0.1 -d 127.0.0.1 -j ACCEPT
iptables -A INPUT -p tcp -s 0/0 --dport 80 -j ACCEPT /*允许所有 IP 访问 80 端口*/
iptables -A OUTPUT -p tcp --sport 80 -m state --state ESTABLISHED -j ACCEPT
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT DROP
#iptables-save > /etc/sysconfig/iptables /*保存配置*/
iptables -L /* 显示 iptables 列表 */
```
（警告：如果已经配置过默认规则为 deny 的环境，即 iptables -P INPUT DROP ，直接命令行执行 iptables -F 将使系统的所有网络访问中断，此坑已踩过）

如何清除配置尼（-P 为默认规则）
```
#!/bin/bash
iptables -P INPUT ACCEPT
iptables -P FORWARD ACCEPT
iptables -P OUTPUT ACCEPT
iptables -F
#iptables-save > /etc/sysconfig/iptables
iptables -L
```
