# Ceph 安装
结构图：  

![](../../../images/store/Ceph-install.png)

## ceph-deploy 部署工具的安装
### Debian/Ubuntu
1.添加发布密钥：

    wget -q -O- 'https://ceph.com/git/?p=ceph.git;a=blob_plain;f=keys/release.asc' | sudo apt-key add -  
2.添加 Ceph 软件包源，用稳定版 Ceph（如 cuttlefish 、 dumpling 、 emperor 、 firefly 等等）替换掉 {ceph-stable-release} 。  

    echo deb http://ceph.com/debian-{ceph-stable-release}/ $(lsb_release -sc) main | sudo tee /etc/apt/sources.list.d/ceph.list

3.更新仓库，并安装 ceph-deploy ：  

    sudo apt-get update && sudo apt-get install ceph-deploy

### RedHat/CentOS/Fedora
创建一个 YUM (Yellowdog Updater, Modified) 库文件，其路径为 /etc/yum.repos.d/ceph.repo  
用最新稳定版 Ceph 名字替换 {ceph-stable-release} （如 firefly ）、用你的发行版名字替换 {distro} （如 el6 为 CentOS 6 、 rhel6.5 为 Red Hat 6 .5、 fc19 是 Fedora 19 、 fc20 是 Fedora 20 。

    [ceph-noarch]
    name=Ceph noarch packages
    baseurl=http://ceph.com/rpm-{ceph-release}/{distro}/noarch
    enabled=1
    gpgcheck=1
    type=rpm-md
    gpgkey=https://ceph.com/git/?p=ceph.git;a=blob_plain;f=keys/release.asc

更新软件库并安装 ceph-deploy ：

    sudo yum update && sudo yum install ceph-deploy

## Ceph 节点准备
管理节点能够通过 SSH 无密码地访问各 Ceph 节点。
### 安装 NTP
以免因时钟漂移导致故障。

在 CentOS / RHEL 上可执行：

    sudo yum install ntp ntpdate ntp-doc

在 Debian / Ubuntu 上可执行：

    sudo apt-get install ntp

确保在各 Ceph 节点上启动了 NTP 服务，并且要使用同一个 NTP 服务器。
### 安装 SSH 服务器
在所有 Ceph 节点上执行如下步骤：

    sudo apt-get install openssh-server

或者

    sudo yum install openssh-server

确保所有 Ceph 节点上的 SSH 服务器都在运行。

### 创建 Ceph 用户
ceph-deploy 工具必须以普通用户登录，且此用户拥有无密码使用 sudo 的权限，因为它需要安装软件及配置文件，中途不能输入密码。  

建议在集群内的所有 Ceph 节点上都创建一个 Ceph 用户。

在各 Ceph 节点创建用户。

    ssh user@ceph-server
    sudo useradd -d /home/{username} -m {username}·
    sudo passwd {username}

确保各 Ceph 节点上所创建的用户都有 sudo 权限。

    echo "{username} ALL = (root) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/{username}
    sudo chmod 0440 /etc/sudoers.d/{username}

生成 SSH 密钥对，但不要用 sudo 或 root 用户。口令为空：

    ssh-keygen

    Generating public/private key pair.
    Enter file in which to save the key (/ceph-admin/.ssh/id_rsa):
    Enter passphrase (empty for no passphrase):
    Enter same passphrase again:
    Your identification has been saved in /ceph-admin/.ssh/id_rsa.
    Your public key has been saved in /ceph-admin/.ssh/id_rsa.pub.

把公钥拷贝到各 Ceph 节点。

    ssh-copy-id {username}@node1
    ssh-copy-id {username}@node2
    ssh-copy-id {username}@node3

（推荐做法）修改 ceph-deploy 管理节点上的 ~/.ssh/config 文件，这样 ceph-deploy 就能用你所建的用户名登录 Ceph 节点了，无需每次执行 ceph-deploy 都指定 --username {username} 。这样做同时也简化了 ssh 和 scp 的用法。

    Host node1
       Hostname node1
       User {username}
    Host node2
       Hostname node2
       User {username}
    Host node3
       Hostname node3
       User {username}

### 引导时联网

Ceph 监视器之间默认用 6789 端口通信， OSD 之间默认用 6800:7810 这个范围内的端口通信。 Ceph OSD 能利用多个网络连接与客户端、监视器、其他副本 OSD 、其它心跳 OSD 分别进行通信。

对于 RHEL 7 上的 firewalld ，要对公共域放通 Ceph 监视器所使用的 6789 端口、以及 OSD 所使用的 6800:7100 ，并且要配置为永久规则，这样重启后规则仍有效。例如：

    sudo firewall-cmd --zone=public --add-port=6789/tcp --permanent

若用 iptables 命令，要放通 Ceph 监视器所用的 6789 端口和 OSD 所用的 6800:7100 端口范围，命令如下：

    sudo iptables -A INPUT -i {iface} -p tcp -s {ip-address}/{netmask} --dport 6789 -j ACCEPT

配置好 iptables 之后要保存配置，这样重启之后才依然有效。

    /sbin/service iptables save

>在 CentOS 和 RHEL 上执行 ceph-deploy 命令时，如果你的 Ceph 节点默认设置了 requiretty 那就会遇到报错。可以这样禁用它，执行 sudo visudo ，找到 Defaults requiretty 选项，把它改为 Defaults:ceph !requiretty 或者干脆注释掉，这样 ceph-deploy 就可以用之前创建的用户（ 创建 Ceph 用户 ）连接了。编辑配置文件 /etc/sudoers 时，必须用 sudo visudo 而不是文本编辑器。

### SELinux

为简化安装，把 SELinux 设置为 Permissive 或者完全禁用，也就是在加固系统配置前先确保集群的安装、配置没问题。用下列命令把 SELinux 设置为 Permissive ：

    sudo setenforce 0

## Ceph 安装
登录管理节点，新建一个工作目录ceph，后面所有操作都在此目录下进行，ceph-deploy工具会在此目录产生各个配置文件，并对所有节点进行安装配置。

### 生成监视器啊密钥
生成一个文件系统ID (FSID)

    ceph-deploy purgedata {ceph-node} [{ceph-node}]
    ceph-deploy forgetkeys

### 创建集群

    ceph-deploy new {ceph-node}

### 安装ceph软件

    ceph-deploy install {ceph-node} [{ceph-node}]

### 组建mon集群：

    ceph-deploy mon create {ceph-node}

启动mon进程：

    ceph-deploy mon create-initial

### 收集密钥

    ceph-deploy gatherkeys {ceph-node}

### 安装OSD
准备OSD

    ceph-deploy osd prepare {ceph-node}:/path/to/directory

激活OSD

    ceph-deploy osd activate {ceph-node}:/path/to/directory

### 复制ceph配置文件和key文件到各个节点

    ceph-deploy admin {ceph-node}

### 检查健康情况

    ceph health

返回active + clean 状态。

### 安装MDS

    ceph-deploy mds create {ceph-node}
