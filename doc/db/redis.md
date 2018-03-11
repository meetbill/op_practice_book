<!-- vim-markdown-toc GFM -->
* [1 Redis](#1-redis)
* [2 Redis twemproxy 集群](#2-redis-twemproxy-集群)
    * [2.1 Twemproxy 特性](#21-twemproxy-特性)
    * [2.2 环境说明](#22-环境说明)
    * [2.2 安装依赖](#22-安装依赖)
    * [2.3 安装 Twemproxy](#23-安装-twemproxy)
    * [2.4 配置 Twemproxy](#24-配置-twemproxy)
    * [2.5 启动 Twemproxy](#25-启动-twemproxy)
        * [2.5.1 启动命令详解](#251-启动命令详解)
        * [2.5.2 启动](#252-启动)
    * [2.6 查看状态](#26-查看状态)
        * [2.6.1 状态参数](#261-状态参数)
        * [2.6.2 状态实例](#262-状态实例)

<!-- vim-markdown-toc -->
## 1 Redis

## 2 Redis twemproxy 集群

> * Nutcracker，又称 Twemproxy（读音："two-em-proxy"）是支持 memcached 和 redis 协议的快速、轻量级代理；
> * 它的建立旨在减少后端缓存服务器上的连接数量；
> * 再结合管道技术（pipelining*）、及分片技术可以横向扩展分布式缓存架构；
>   * Redis pipelining（流式批处理、管道技术）：将一系列请求连续发送到 Server 端，不必每次等待 Server 端的返回，而 Server 端会将请求放进一个有序的管道中，在执行完成后，会一次性将结果返回（解决 Client 端和 Server 端的网络延迟造成的请求延迟）

### 2.1 Twemproxy 特性

twemproxy 的特性：

> * 支持失败节点自动删除
>   * 可以设置重新连接该节点的时间
>   * 可以设置连接多少次之后删除该节点
> * 支持设置HashTag
>   * 通过HashTag可以自己设定将两个key哈希到同一个实例上去
> * 减少与redis的直接连接数
>   * 保持与redis的长连接
>   * 减少了客户端直接与服务器连接的连接数量
> * 自动分片到后端多个redis实例上
>   * 多种hash算法：md5、crc16、crc32 、crc32a、fnv1_64、fnv1a_64、fnv1_32、fnv1a_32、hsieh、murmur、jenkins
> * 多种分片算法：ketama(一致性hash算法的一种实现)、modula、random
>   * 可以设置后端实例的权重
> * 避免单点问题
>   * 可以平行部署多个代理层,通过HAProxy做负载均衡，将redis的读写分散到多个twemproxy上。
> * 支持状态监控
>   * 可设置状态监控ip和端口，访问ip和端口可以得到一个json格式的状态信息串
>   * 可设置监控信息刷新间隔时间
> * 使用 pipelining 处理请求和响应
>   * 连接复用，内存复用
>   * 将多个连接请求，组成reids pipelining统一向redis请求
> * 并不是支持所有redis命令
>   * 不支持redis的事务操作
>   * 使用SIDFF, SDIFFSTORE, SINTER, SINTERSTORE, SMOVE, SUNION and SUNIONSTORE命令需要保证key都在同一个分片上。

### 2.2 环境说明

```
4 台 redis 服务器
10.10.10.4:6379   - 1
10.10.10.5:6379   - 2
```


### 2.2 安装依赖

安装 autoconf
centos 7 yum 安装既可， autoconf 版本必须 2.64 以上版本

```
yum -y install autoconf
```

### 2.3 安装 Twemproxy

```
git clone https://github.com/twitter/twemproxy.git
autoreconf -fvi          #生成 configure 文件
./configure --prefix=/opt/local/twemproxy/ --enable-debug=log
make && make install
mkdir -p /opt/local/twemproxy/{run,conf,logs}
ln -s /opt/local/twemproxy/sbin/nutcracker /usr/bin/
```



### 2.4 配置 Twemproxy

cd /opt/local/twemproxy/conf/

vi nutcracker.yml          #编辑配置文件

```
meetbill:

  listen: 10.10.10.4:6380                         #监听端口
  hash: fnv1a_64                                  #key 值 hash 算法，默认 fnv1a_64
  distribution: ketama                            #分布算法
  #ketama 一致性 hash 算法；modula 非常简单，就是根据 key 值的 hash 值取模；random 随机分布
  auto_eject_hosts: true                          #摘除后端故障节点
  redis: true                                     #是否是 redis 缓存，默认是 false
  timeout: 400                                    #代理与后端超时时间，毫秒
  server_retry_timeout: 200000                    #摘除故障节点后重新连接的时间，毫秒
  server_failure_limit: 1                         #故障多少次摘除
  servers:
   - 10.10.10.4:6379:1 server1
   - 10.10.10.5:6379:1 server2
```

检查配置文件是否正确

```
nutcracker -t -c /opt/local/twemproxy/conf/nutcracker.yml
```

### 2.5 启动 Twemproxy

#### 2.5.1 启动命令详解
```
Usage: nutcracker [-?hVdDt] [-v verbosity level] [-o output file]
[-c conf file] [-s stats port] [-a stats addr]
[-i stats interval] [-p pid file] [-m mbuf size]
参数    释义
-h, –help   查看帮助文档，显示命令选项
-V, –version    查看 nutcracker 版本
-t, –test-conf  测试配置脚本的正确性
-d, –daemonize  以守护进程运行
-D, –describe-stats 打印状态描述
-v, –verbosity=N    设置日志级别 (default: 5, min: 0, max: 11)
-o, –output=S   设置日志输出路径，默认为标准错误输出 (default: stderr)
-c, –conf-file=S    指定配置文件路径 (default: conf/nutcracker.yml)
-s, –stats-port=N   设置状态监控端口，默认 22222 (default: 22222)
-a, –stats-addr=S   设置状态监控 IP，默认 0.0.0.0 (default: 0.0.0.0)
-i, –stats-interval=N   设置状态聚合间隔 (default: 30000 msec)
-p, –pid-file=S 指定进程 pid 文件路径，默认关闭 (default: off)
-m, –mbuf-size=N    设置 mbuf 块大小，以 bytes 单位 (default: 16384 bytes)
```
#### 2.5.2 启动

```
nutcracker -d -c /opt/local/twemproxy/conf/nutcracker.yml -p /opt/local/twemproxy/run/redisproxy.pid -o /opt/local/twemproxy/logs/redisproxy.log
```
### 2.6 查看状态

#### 2.6.1 状态参数

```
nutcracker --describe-stats
This is nutcracker-0.2.4

pool stats:
  client_eof          "# eof on client connections"
  client_err          "# errors on client connections"
  client_connections  "# active client connections"
  server_ejects       "# times backend server was ejected"
  forward_error       "# times we encountered a forwarding error"
  fragments           "# fragments created from a multi-vector request"

server stats:
  server_eof          "# eof on server connections"
  server_err          "# errors on server connections"
  server_timedout     "# timeouts on server connections"
  server_connections  "# active server connections"
  requests            "# requests"
  request_bytes       "total request bytes"
  responses           "# respones"
  response_bytes      "total response bytes"
  in_queue            "# requests in incoming queue"
  in_queue_bytes      "current request bytes in incoming queue"
  out_queue           "# requests in outgoing queue"
  out_queue_bytes     "current request bytes in outgoing queue"
```

#### 2.6.2 状态实例

```
#curl  -s http://127.0.0.1:22222|python -mjson.tool
{
    "meetbill": {                    # 配置名称
        "client_connections": 0,     # 当前活跃的客户端连接数
        "client_eof": 0,
        "client_err": 2,             # 客户端连接错误次数
        "forward_error": 0,          # 转发错误次数
        "fragments": 0,
        "server_ejects": 0           # 后端服务被踢出次数
        "server1": {
            "in_queue": 0,
            "in_queue_bytes": 0,
            "out_queue": 0,
            "out_queue_bytes": 0,
            "request_bytes": 0,      # 已请求字节数
            "requests": 0,           # 已请求次数
            "response_bytes": 0,     # 已相应字节数
            "responses": 0,          # 已响应次数
            "server_connections": 0, # 当前活跃的服务端连接数
            "server_eof": 0,
            "server_err": 0,         # 服务端连接错误次数
            "server_timedout": 0     # 因连接超时的服务端错误次数
        },
        "server2": {
            "in_queue": 0,
            "in_queue_bytes": 0,
            "out_queue": 0,
            "out_queue_bytes": 0,
            "request_bytes": 0,
            "requests": 0,
            "response_bytes": 0,
            "responses": 0,
            "server_connections": 0,
            "server_eof": 0,
            "server_err": 0,
            "server_timedout": 0
        },
    },
    "service": "nutcracker",
    "source": "meetbill",    # 主机名
    "timestamp": 1520780415, # 当前时间戳
    "uptime": 3160,          # 服务已经启动的时间（单位：秒
    "version": "0.2.4"
}
```
