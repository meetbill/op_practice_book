## 双因子认证(使用篇)

海上升明月，天涯共此时！

### 0 环境

> * 密钥(一次性输入即可)
> * 安卓手机
> * linux or windows

### 1 在安卓设备上运行Google认证器

#### 1.1 安装google 身份验证器

我的方法是在UC中搜索的 google身份验证器进行的安装

#### 1.2 输入密钥

选择"Enter provided key"选项，使用键盘输入账户名称和验证密钥

### 2 终端设置google 二次身份验证登陆

#### 2.1 windows xshell

打开xshell(其他终端类似)，选择登陆主机的属性。设置登陆方法为Keyboard Interactive

登陆时输入用户名后，接着输入手机设备上的数字，然后输入密码

#### 2.2 linux

linux下直接输入

```
#ssh 用户名@IP
```
连接比较慢时可以修改本机的客户端配置文件ssh_config，注意，不是sshd_config

GSSAPIAuthentication yes -->no

```
#sed -i 's#GSSAPIAuthentication yes#GSSAPIAuthentication no#' /etc/ssh/ssh_config

```

### 3 应急处理
