<!-- vim-markdown-toc GFM -->

* [1 Redis](#1-redis)
    * [1.1 持久化](#11-持久化)
        * [1.1.1 AOF 重写机制](#111-aof-重写机制)
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
        * [2.6.3 使用 Python 获取 Twemproxy 状态](#263-使用-python-获取-twemproxy-状态)
* [3 原理说明](#3-原理说明)
    * [3.1 一致性 hash](#31-一致性-hash)
        * [3.1.1 传统的取模方式](#311-传统的取模方式)
        * [3.1.2 一致性哈希方式](#312-一致性哈希方式)
        * [3.1.3 虚拟节点](#313-虚拟节点)

<!-- vim-markdown-toc -->
## 1 Redis

### 1.1 持久化

#### 1.1.1 AOF 重写机制

AOF 重写触发条件

AOF 重写可以由用户通过调用 BGREWRITEAOF 手动触发。
服务器在 AOF 功能开启的情况下，会维持以下三个变量：

> * 记录当前 AOF 文件大小的变量 aof_current_size。
> * 记录最后一次 AOF 重写之后，AOF 文件大小的变量 aof_rewrite_base_size。
> * 增长百分比变量 aof_rewrite_perc。

每次当 serverCron（服务器周期性操作函数，在 src/redis.c 中）函数执行时，它会检查以下条件是否全部满足，如果全部满足的话，就触发自动的 AOF 重写操作：

> * 没有 BGSAVE 命令（RDB 持久化）/AOF 持久化在执行；
> * 没有 BGREWRITEAOF 在进行；
> * auto-aof-rewrite-percentage 参数不为 0
> * 当前 AOF 文件大小要大于 server.aof_rewrite_min_size（默认为 1MB）
> * 当前 AOF 文件大小和最后一次重写后的大小之间的比率等于或者等于指定的增长百分比（在配置文件设置了 auto-aof-rewrite-percentage 参数，不设置默认为 100%）

如果前面四个条件都满足，并且当前 AOF 文件大小比最后一次 AOF 重写时的大小要大于指定的百分比，那么触发自动 AOF 重写。

源码如下：
```
 /* Trigger an AOF rewrite if needed */
        // 触发 BGREWRITEAOF
         if (server.rdb_child_pid == -1 &&
             server.aof_child_pid == -1 &&
             server.aof_rewrite_perc &&
             // AOF 文件的当前大小大于执行 BGREWRITEAOF 所需的最小大小
             server.aof_current_size > server.aof_rewrite_min_size)
         {
            // 上一次完成 AOF 写入之后，AOF 文件的大小
            long long base = server.aof_rewrite_base_size ?
                            server.aof_rewrite_base_size : 1;

            // AOF 文件当前的体积相对于 base 的体积的百分比
            long long growth = (server.aof_current_size*100/base) - 100;

            // 如果增长体积的百分比超过了 growth ，那么执行 BGREWRITEAOF
            if (growth >= server.aof_rewrite_perc) {
                redisLog(REDIS_NOTICE,"Starting automatic rewriting of AOF on %lld%% growth",growth);
                // 执行 BGREWRITEAOF
                rewriteAppendOnlyFileBackground();
            }
         }
```

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
> * 支持设置 HashTag
>   * 通过 HashTag 可以自己设定将两个 key 哈希到同一个实例上去
> * 减少与 redis 的直接连接数
>   * 保持与 redis 的长连接
>   * 减少了客户端直接与服务器连接的连接数量
> * 自动分片到后端多个 redis 实例上
>   * 多种 hash 算法：md5、crc16、crc32 、crc32a、fnv1_64、fnv1a_64、fnv1_32、fnv1a_32、hsieh、murmur、jenkins
> * 多种分片算法：ketama（一致性 hash 算法的一种实现）、modula、random
>   * 可以设置后端实例的权重
> * 避免单点问题
>   * 可以平行部署多个代理层，通过 HAProxy 做负载均衡，将 redis 的读写分散到多个 twemproxy 上。
> * 支持状态监控
>   * 可设置状态监控 ip 和端口，访问 ip 和端口可以得到一个 json 格式的状态信息串
>   * 可设置监控信息刷新间隔时间
> * 使用 pipelining 处理请求和响应
>   * 连接复用，内存复用
>   * 将多个连接请求，组成 reids pipelining 统一向 redis 请求
> * 并不是支持所有 redis 命令
>   * 不支持 redis 的事务操作
>   * 使用 SIDFF, SDIFFSTORE, SINTER, SINTERSTORE, SMOVE, SUNION and SUNIONSTORE 命令需要保证 key 都在同一个分片上。

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
#### 2.6.3 使用 Python 获取 Twemproxy 状态
使用 curl 获取 Twemproxy 状态时，如果后端的 redis 或者 memcache 过多，将会导致获取状态内容失败，可以进行如下解决方法

```
def fetch_stats(ip, port):
    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    s.connect((ip, port))
    raw = ""
    while True:
        data = s.recv(1024)
        if len(data) == 0:
            break
        raw += data
    s.close()
    stats = json.loads(raw)
    return stats
```
## 3 原理说明

### 3.1 一致性 hash

#### 3.1.1 传统的取模方式
例如 10 条数据，3 个节点，如果按照取模的方式，那就是
> * node a: 0,3,6,9
> * node b: 1,4,7
> * node c: 2,5,8

当增加一个节点的时候，数据分布就变更为

> * node a:0,4,8
> * node b:1,5,9
> * node c: 2,6
> * node d: 3,7

总结：数据 3,4,5,6,7,8,9 在增加节点的时候，都需要做搬迁，成本太高

#### 3.1.2 一致性哈希方式

最关键的区别就是，对节点和数据，都做一次哈希运算，然后比较节点和数据的哈希值，数据取和节点最相近的节点做为存放节点。这样就保证当节点增加或者减少的时候，影响的数据最少。还是拿刚刚的例子，（用简单的字符串的 ascii 码做哈希 key）：

十条数据，算出各自的哈希值

> * 0：192
> * 1：196
> * 2：200
> * 3：204
> * 4：208
> * 5：212
> * 6：216
> * 7：220
> * 8：224
> * 9：228

有三个节点，算出各自的哈希值

> * node a: 203
> * node g: 209
> * node z: 228

这个时候比较两者的哈希值，如果大于 228，就归到前面的 203，相当于整个哈希值就是一个环，对应的映射结果：

> * node a: 0,1,2
> * node g: 3,4
> * node z: 5,6,7,8,9

这个时候加入 node n, 就可以算出 node n 的哈希值：

> * node n: 216

这个时候对应的数据就会做迁移：

> * node a: 0,1,2
> * node g: 3,4
> * node n: 5,6
> * node z: 7,8,9

这个时候只有 5 和 6 需要做迁移

#### 3.1.3 虚拟节点

另外，这个时候如果只算出三个哈希值，那再跟数据的哈希值比较的时候，很容易分得不均衡，因此就引入了虚拟节点的概念，通过把三个节点加上 ID 后缀等方式，每个节点算出 n 个哈希值，均匀的放在哈希环上，这样对于数据算出的哈希值，能够比较散列的分布（详见下面代码中的 replica）

通过这种算法做数据分布，在增减节点的时候，可以大大减少数据的迁移规模。
