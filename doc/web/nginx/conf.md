# Nginx服务器基础配置指令

## nginx.conf文件的结构

+ Global: nginx运行相关
+ events: 与用户的网络连接相关
+ http
    + http Global: 代理，缓存，日志，以及第三方模块的配置
    + server
        + server Global: 虚拟主机相关
        + location: 地址定向，数据缓存，应答控制，以及第三方模块的配置

> 所有的所有的所有的指令，都要以`;`结尾

## 配置运行Nginx服务器用户（组）

user nobody nobody;

## 配置允许生成的worker process数

worker_processes auto;
worker_processes 4;

> 这个数字，跟电脑CPU核数要保持一致

```
# grep ^proces /proc/cpuinfo
processor       : 0
processor       : 1
processor       : 2
processor       : 3
# grep ^proces /proc/cpuinfo | wc -l
4
```

## 配置Nginx进程PID存放路径

pid logs/nginx.pid;

> 这里面保存的就是一个数字，nginx master 进程的进程号

## 配置错误日志的存放路径

error_log logs/error.log;
error_log logs/error.log error;

## 配置文件的引入

include mime.types;
include fastcgi_params;
include ../../conf/*.conf;

## 设置网络连接的序列化

accept_mutex on;

> 对多个nginx进程接收连接进行序列化，防止多个进程对连接的争抢（惊群）

## 设置是否允许同时接收多个网络连接

multi_accept off;

## 事件驱动模型的选择

use select|poll|kqueue|epoll|rtsig|/dev/poll|eventport

> 这个重点，后面再看

## 配置最大连接数

worker_connections 512;

## 定义MIME-Type

include mime.types;
default_type application/octet-stream;

## 自定义服务日志

access_log logs/access.log main;
access_log off;

## 配置允许sendfile方式传输文件

sendfile off;

sendfile on;
sendfile_max_chunk 128k;

> nginx 每个worker process 每次调用 sendfile()传输的数据量的最大值

Refer:

+ [Linux kenel sendfile 如何提升性能](http://www.vpsee.com/2009/07/linux-sendfile-improve-performance/)
+ [nginx sendifle tcp_nopush tcp_nodelay参数解释](http://blog.csdn.net/zmj_88888888/article/details/9169227)

## 配置连接超时时间

> 与用户建立连接后，Nginx可以保持这些连接一段时间, 默认 75s
> 下面的65s可以被Mozilla/Konqueror识别，是发给用户端的头部信息`Keep-Alive`值

keepalive_timeout 75s 65s;

## 单连接请求数上限

> 和用户端建立连接后，用户通过此连接发送请求;这条指令用于设置请求的上限数

keepalive_requests 100;

## 配置网络监听

listen *:80 | *:8000; # 监听所有的80和8000端口

listen 192.168.1.10:8000;
listen 192.168.1.10;
listen 8000; # 等同于 listen *:8000;
listen 192.168.1.10 default_server backlog=511; # 该ip的连接请求默认由此虚拟主机处理;最多允许1024个网络连接同时处于挂起状态

## **基于名称的虚拟主机配置**

server_name myserver.com www.myserver.com;

server_name *.myserver.com www.myserver.* myserver2.*; # 使用通配符

> 不允许的情况： server_name www.ab*d.com; # `*`只允许出现在www和com的位置

server_name ~^www\d+\.myserver\.com$; # 使用正则

> nginx的配置中，可以用正则的地方，都以`~`开头

> from Nginx~0.7.40 开始，server_name 中的正则支持 字符串捕获功能（capture）

server_name ~^www\.(.+)\.com$; # 当请求通过www.myserver.com请求时， myserver就被记录到`$1`中, 在本server的上下文中就可以使用

如果一个名称 被多个虚拟主机的 server_name 匹配成功, 那这个请求到底交给谁处理呢？看优先级：

1. 准确匹配到server_name
2. 通配符在开始时匹配到server_name
3. 通配符在结尾时匹配到server_name
4. 正则表达式匹配server_name
5. 先到先得

## **基于IP的虚拟主机配置**

> 基于IP的虚拟主机，需要将网卡设置为同时能够监听多个IP地址

```
ifconfig
# 查看到本机IP地址为 192.168.1.30
ifconfig eth1:0 192.168.1.31 netmask 255.255.255.0 up
ifconfig eth1:1 192.168.1.32 netmask 255.255.255.0 up
ifconfig
# 这时就看到eth1增加来2个别名， eth1:0 eth1:1

# 如果需要机器重启后仍保持这两个虚拟的IP
echo "ifconfig eth1:0 192.168.1.31 netmask 255.255.255.0 up" >> /etc/rc.local
echo "ifconfig eth1:0 192.168.1.32 netmask 255.255.255.0 up" >> /etc/rc.local
```

再来配置基于IP的虚拟主机

```
http {
    ...
    server {
     listen 80;
     server_name 192.168.1.31;
     ...
    }
    server {
     listen 80;
     server_name 192.168.1.32;
     ...
    }
}
```

## **配置location块**(重中之重)

> location 块的配置，应该是最常用的了

location [ = | ~ | ~* | ^~ ] uri {...}

这里内容分2块，匹配方式和uri， 其中uri又分为 标准uri和正则uri

先不考虑 那4种匹配方式

1. Nginx首先会再server块的多个location中搜索是否有`标准uri`和请求字符串匹配， 如果有，记录匹配度最高的一个；
2. 然后，再用location块中的`正则uri`和请求字符串匹配， 当第一个`正则uri`匹配成功，即停止搜索， 并使用该location块处理请求；
3. 如果，所有的`正则uri`都匹配失败，就使用刚记录下的匹配度最高的一个`标准uri`处理请求
4. 如果都失败了，那就失败喽

再看4种匹配方式：

+ `=`:  用于`标准uri`前，要求请求字符串与其严格匹配，成功则立即处理
+ `^~`: 用于`标准uri`前，并要求一旦匹配到，立即处理，不再去匹配其他的那些个`正则uri`
+ `~`:  用于`正则uri`前，表示uri包含正则表达式， 并区分大小写
+ `~*`: 用于`正则uri`前， 表示uri包含正则表达式， 不区分大小写

> `^~` 也是支持浏览器编码过的URI的匹配的哦， 如 `/html/%20/data` 可以成功匹配 `/html/ /data`

## 配置请求的根目录

Web服务器收到请求后，首先要在服务端指定的目录中寻找请求资源

root /var/www;

## 更改location的URI

除了使用root指明处理请求的根目录，还可以使用alias 改变location收到的URI的请求路径

```
location ~ ^/data/(.+\.(htm|html))$ {
    alias /locatinotest1/other/$1;
}
```

## 设置网站的默认首页

index 指令主要有2个作用：

+ 对请求地址没有指明首页的，指定默认首页
+ 对一个请求，根据请求内容而设置不同的首页，如下：

```
location ~ ^/data/(.+)/web/$ {
    index index.$1.html index.htm;
}
```
## 设置网站的错误页面

error_page 404 /404.html;
error_page 403 /forbidden.html;
error_page 404 =301 /404.html;

```
location /404.html {
    root /myserver/errorpages/;
}
```

## 基于IP配置Nginx的访问权限

```
location / {
    deny 192.168.1.1;
    allow 192.168.1.0/24;
    allow 192.168.1.2/24;
    deny all;
}
```
> 从192.168.1.0的用户时可以访问的，因为解析到allow那一行之后就停止解析了


## 基于密码配置Nginx的访问权限

auth_basic "please login";
auth_basic_user_file /etc/nginx/conf/pass_file;

> 这里的file 必须使用绝对路径，使用相对路径无效

```
# /usr/local/apache2/bin/htpasswd -c -d pass_file user_name
# 回车输入密码，-c 表示生成文件，-d 是以 crypt 加密。

name1:password1
name2:password2:comment
```

> 经过basic auth认证之后没有过期时间，直到该页面关闭；
> 如果需要更多的控制，可以使用 HttpAuthDigestModule http://wiki.nginx.org/HttpAuthDigestModule

# Nginx服务器基础配置实例

```
user nginx nginx;

worker_processes 3;

error_log logs/error.log;
pid myweb/nginx.pid;

events {
    use epoll;
    worker_connections 1024;
}

http {
    include mime.types;
    default_type applicatioin/octet-stream;

    sendfile on;

    keepalive_timeout 65;

    log_format access.log '$remote_addr [$time_local] "$request" "$http_user_agent"';

    server {
        listen 8081;
        server_name myServer1;

        access_log myweb/server1/log/access.log;
        error_page 404 /404.html;

        location /server1/location1 {
            root myweb;
            index index.svr1-loc1.htm;
        }

        location /server1/location2 {
            root myweb;
            index index.svr1-loc2.htm;
        }
    }

    server {
        listen 8082;
        server_name 192.168.0.254;

        auth_basic "please Login:";
        auth_basic_user_file /opt/X_nginx/Nginx/myweb/user_passwd;

        access_log myweb/server2/log/access.log;
        error_page 404 /404.html;

        location /server2/location1 {
            root myweb;
            index index.svr2-loc1.htm;
        }

        location /svr2/loc2 {
            alias myweb/server2/location2/;
            index index.svr2-loc2.htm;
        }

        location = /404.html {
            root myweb/;
            index 404.html;
        }
    }
}
```

```
#./sbin/nginx -c conf/nginx02.conf
nginx: [warn] the "user" directive makes sense only if the master process runs with super-user privileges, ignored in /opt/X_nginx/Nginx/conf/nginx02.conf:1
.
├── 404.html
├── server1
│   ├── location1
│   │   └── index.svr1-loc1.htm
│   ├── location2
│   │   └── index.svr1-loc2.htm
│   └── log
│       └── access.log
└── server2
    ├── location1
        │   └── index.svr2-loc1.htm
            ├── location2
                │   └── index.svr2-loc2.htm
                    └── log
                            └── access.log

                            8 directories, 7 files

```
## 测试myServer1的访问

```
http://myserver1:8081/server1/location1/
this is server1/location1/index.svr1-loc1.htm

http://myserver1:8081/server1/location2/
this is server1/location1/index.svr1-loc2.htm
```

## 测试myServer2的访问
```
http://192.168.0.254:8082/server2/location1/
this is server2/location1/index.svr2-loc1.htm

http://192.168.0.254:8082/svr2/loc2/
this is server2/location1/index.svr2-loc2.htm

http://192.168.0.254:8082/server2/location2/
404 404 404 404
```
