## 双因子认证(安装及配置篇)

海上升明月，天涯共此时！

### 0 环境

server：Centos 6.5


## 1 install

### 1.1 查看系统时间

使用外网机器时，创建的时候有可能不是北京时间

```
[root@centos ~]#date
Sun Aug 14 23:18:41 EDT 2011
[root@centos ~]# rm -rf /etc/localtime 
[root@centos ~]# ln -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
```
### 1.2 安装google_authenticator

安装EPEL源并安装 google_authenticator

```
#curl -o epel-release-6-8.noarch.rpm "https://raw.githubusercontent.com/BillWang139967/BillWang139967.github.io/master/doc/safety/epel-release-6-8.noarch.rpm"
#rpm -ivh epel-release-6-8.noarch.rpm
#yum install google-authenticator
```
### 2 为SSH服务器用Google认证器

#### 2.1 配置/etc/pam.d/sshd
在"auth       include      password-auth"行前添加如下内容
```
auth       required pam_google_authenticator.so
```
即先google方式认证再linux密码认证
#### 2.2 修改SSH服务配置/etc/ssh/sshd_config
ChallengeResponseAuthentication no->yes

```
sed -i 's#^ChallengeResponseAuthentication no#ChallengeResponseAuthentication yes#' /etc/ssh/sshd_config
```
#### 2.3 重启SSH服务

```
#service sshd restart
```
### 3 生成验证密钥
在Linux主机上登陆需要认证的用户运行Google认证器(我这是使用root用户演示的)
```
#google-authenticator
```
直接一路输入yes即可，询问内容如下，想了解的可以看下

```
Do you want me to update your "/root/.google_authenticator" file (y/n):y  
应急码的保存路径

Do you want to disallow multiple uses of the same authentication token? This restricts you to one login about every 30s, but it increases your chances to notice or even prevent man-in-the-middle attacks (y/n)
是否禁止一个口令多用，自然也是答 y

By default, tokens are good for 30 seconds and in order to compensate for possible time-skew between the client and the server, we allow an extra token before and after the current time. If you experience problems with poor time synchronization, you can increase the window from its default size of 1:30min to about 4min. Do you want to do so (y/n)
问是否打开时间容错以防止客户端与服务器时间相差太大导致认证失败。这个可以根据实际情况来。如果一些 Android平板电脑不怎么连网的，可以答 y 以防止时间错误导致认证失败。

If the computer that you are logging into isn't hardened against brute-force login attempts, you can enable rate-limiting for the authentication module. By default, this limits attackers to no more than 3 login attempts every 30s.Do you want to enable rate-limiting (y/n)
选择是否打开尝试次数限制（防止暴力攻击），自然答 y
```
这里需要记住的是

```
#cat /root/.google_authenticator       手机密钥和应急码保存路径
密钥
Your emergency scratch codes are: 一些生成的5个应急码，每个应急码只能使用一次
```
