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
    * [3.2 redis 过期数据存储方式以及删除方式](#32-redis-过期数据存储方式以及删除方式)
        * [3.2.1 存储方式](#321-存储方式)
        * [3.2.2 删除方式](#322-删除方式)
            * [惰性删除](#惰性删除)
            * [定期删除](#定期删除)
        * [3.2.3 redis 主从删除过期 key 方式](#323-redis-主从删除过期-key-方式)
        * [3.2.4 总结](#324-总结)
* [4 其他相关](#4-其他相关)
    * [4.1 内核参数 overcommit](#41-内核参数-overcommit)
        * [什么是 Overcommit 和 OOM](#什么是-overcommit-和-oom)

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

### 3.2 redis 过期数据存储方式以及删除方式

当你通过 expire 或者 pexpire 命令，给某个键设置了过期时间，那么它在服务器是怎么存储的呢？到达过期时间后，又是怎么删除的呢？
<!--more-->

#### 3.2.1 存储方式
比如：
```
redis> EXPIRE book 5
(integer) 1
```
首先我们知道，redis 维护了一个存储了所有的设置的 key->value 的字典。但是其实不止一个字典的。
**redis 有一个包含过期事件的字典**
每当有设置过期事件的 key 后，redis 会用当前的事件，加上过期的时间段，得到过期的标准时间，存储在 expires 字典中。
![](./../../images/db/redis/key-expires-dict.png)
从上图可以看出来，比如你给 book 设置过期事件，那么 expires 字典的 key 也为 book，值是当前的时间 +5s 后的 unix time。

#### 3.2.2 删除方式
如果一个键已经过期了，那么 redis 的如果删除它呢？redis 采用了 2 种删除方式；
##### 惰性删除
惰性删除的原理理是：放任键过期不管，但是每次从键空间获取键的时候，如果该键存在，再去 expires 字典判断这个键是不是超时。如果超时则返回空，并删除该键。过程如下：
![](./../../images/db/redis/key-expires-delete.png)
- 优点：惰性删除对 cpu 是友好的。保证在键必须删除的时候才会消耗 cpu
- 缺点：惰性删除对内存特别不友好。虽然键过期，但是没有使用则一直存在内存中。

##### 定期删除
redis 架构中的时间事件，每隔一段时间后，在规定的时间内，会主动去检测 expires 字典中包含的 key 进行检测，发现过期的则删除。在 redis 的源码 redis.c/activeExpireCycle 函数中。
下面分别是这个函数的源码与伪代码：


```
void  activeExpireCycle(int type) {
    // 静态变量，用来累积函数连续执行时的数据
    static  unsigned  int current_db =  0; /* Last DB tested. */
    static  int timelimit_exit =  0; /* Time limit hit in previous call? */
    static  long  long last_fast_cycle =  0; /* When last fast cycle ran. */

    unsigned  int j, iteration =  0;
    // 默认每次处理的数据库数量
    unsigned  int dbs_per_call = REDIS_DBCRON_DBS_PER_CALL;
    // 函数开始的时间
    long  long start =  ustime(), timelimit;

    // 快速模式
    if (type == ACTIVE_EXPIRE_CYCLE_FAST) {
        // 如果上次函数没有触发 timelimit_exit ，那么不执行处理
        if (!timelimit_exit) return;
        // 如果距离上次执行未够一定时间，那么不执行处理
        if (start < last_fast_cycle + ACTIVE_EXPIRE_CYCLE_FAST_DURATION*2) return;
        // 运行到这里，说明执行快速处理，记录当前时间
        last_fast_cycle = start;
    }

    /*
    * 一般情况下，函数只处理 REDIS_DBCRON_DBS_PER_CALL 个数据库，
    * 除非：
    * 当前数据库的数量小于 REDIS_DBCRON_DBS_PER_CALL
    * 如果上次处理遇到了时间上限，那么这次需要对所有数据库进行扫描，
    * 这可以避免过多的过期键占用空间
    */
    if (dbs_per_call > server.dbnum  || timelimit_exit)
    dbs_per_call = server.dbnum;

    // 函数处理的微秒时间上限
    // ACTIVE_EXPIRE_CYCLE_SLOW_TIME_PERC 默认为 25 ，也即是 25 % 的 CPU 时间
    timelimit =  1000000*ACTIVE_EXPIRE_CYCLE_SLOW_TIME_PERC/server.hz/100;
    timelimit_exit =  0;
    if (timelimit <=  0) timelimit =  1;

    // 如果是运行在快速模式之下
    // 那么最多只能运行 FAST_DURATION 微秒
    // 默认值为 1000 （微秒）
    if (type == ACTIVE_EXPIRE_CYCLE_FAST)
    timelimit = ACTIVE_EXPIRE_CYCLE_FAST_DURATION; /* in microseconds. */

    // 遍历数据库
    for (j =  0; j < dbs_per_call; j++) {
        int expired;
        // 指向要处理的数据库
        redisDb *db = server.db+(current_db % server.dbnum);

        // 为 DB 计数器加一，如果进入 do 循环之后因为超时而跳出
        // 那么下次会直接从下个 DB 开始处理
        current_db++;

        do {
            unsigned  long num, slots;
            long  long now, ttl_sum;
            int ttl_samples;

            // 获取数据库中带过期时间的键的数量
            // 如果该数量为 0 ，直接跳过这个数据库
            if ((num =  dictSize(db->expires)) ==  0) {
                db->avg_ttl  =  0;
                break;
            }
            // 获取数据库中键值对的数量
            slots =  dictSlots(db->expires);
            // 当前时间
            now =  mstime();

            // 这个数据库的使用率低于 1% ，扫描起来太费力了（大部分都会 MISS）
            // 跳过，等待字典收缩程序运行
            if (num && slots > DICT_HT_INITIAL_SIZE &&
            (num*100/slots <  1)) break;

            // 已处理过期键计数器
            expired =  0;
            // 键的总 TTL 计数器
            ttl_sum =  0;
            // 总共处理的键计数器
            ttl_samples =  0;

            // 每次最多只能检查 LOOKUPS_PER_LOOP 个键
            if (num > ACTIVE_EXPIRE_CYCLE_LOOKUPS_PER_LOOP)
            num = ACTIVE_EXPIRE_CYCLE_LOOKUPS_PER_LOOP;

            // 开始遍历数据库
            while (num--) {
                dictEntry *de;
                long  long ttl;

                // 从 expires 中随机取出一个带过期时间的键
                if ((de =  dictGetRandomKey(db->expires)) ==  NULL) break;
                // 计算 TTL
                ttl =  dictGetSignedIntegerVal(de)-now;
                // 如果键已经过期，那么删除它，并将 expired 计数器增一
                if (activeExpireCycleTryExpire(db,de,now)) expired++;
                if (ttl <  0) ttl =  0;
                // 累积键的 TTL
                ttl_sum += ttl;
                // 累积处理键的个数
                ttl_samples++;
            }

            // 为这个数据库更新平均 TTL 统计数据
            if (ttl_samples) {
                // 计算当前平均值
                long  long avg_ttl = ttl_sum/ttl_samples;
                // 如果这是第一次设置数据库平均 TTL ，那么进行初始化
                if (db->avg_ttl  ==  0) db->avg_ttl  = avg_ttl;
                /* Smooth the value averaging with the previous one. */
                // 取数据库的上次平均 TTL 和今次平均 TTL 的平均值
                db->avg_ttl  = (db->avg_ttl+avg_ttl)/2;
            }

            // 我们不能用太长时间处理过期键，
            // 所以这个函数执行一定时间之后就要返回

            // 更新遍历次数
            iteration++;

            // 每遍历 16 次执行一次
            if ((iteration &  0xf) ==  0  &&  /* check once every 16 iterations. */
            (ustime()-start) > timelimit)
            {
                // 如果遍历次数正好是 16 的倍数
                // 并且遍历的时间超过了 timelimit
                // 那么断开 timelimit_exit
                timelimit_exit =  1;
            }

            // 已经超时了，返回
            if (timelimit_exit) return;

            // 如果已删除的过期键占当前总数据库带过期时间的键数量的 25 %
            // 那么不再遍历
        } while (expired > ACTIVE_EXPIRE_CYCLE_LOOKUPS_PER_LOOP/4);
    }
}
```
**伪代码是：**
```
# 默认每次检测的数据库数量为 16
DEFAULT_DB_NUMBERS = 16
# 默认每次检测的键的数量最大为 20
DEFAULT_KEY_NUMBERS = 20
# 全局变量，记录当前检测的进度
current_db = 0
def activeExpireCycle():
    # 初始化要检测的数据库数量
    # 如果服务器的数据库数量小于 16，则以服务器的为准
    if server.dbnumbers < DEFAULT_DB_NUMBERS:
        db_numbers = server.dbnumbers
    else
        db_numbers = DEFAULT_DB_NUMBERS

    # 遍历每次数据库
    for i in range(db_numbers):
        # 如果 current_db 的值等于服务器的数量，代表已经遍历全，则重新开始
        if current_db = db_numbers:
            current_db = 0

        # 获取当前要处理的数据库
        redisDb = server.db[current_db]

        # 将数据库索引 +1，指向下一个数据库
        current_db++

        do
            # 检测数据库中的键
            for j in range(DEFAULT_KEY_NUMBERS):
                # 如果数据库中没有过期键则跳过这个库
                if redisDb.expires.size() == 0:break

                # 随机获取一个带有过期事件的键
                key_with_ttl = redisDb.expires.get_random_key()

                # 检测键是不是过期了，如果过期则删除
                if is_expired(key_with_ttl):
                    delete_key(key_with_ttl)
            # 已达到时间上限，则停止处理
            if reach_time_limit(): retrun
        while expired>ACTIVE_EXPIRE_CYCLE_LOOKUPS_PER_LOOP/4
```
对 activeExpireCycle 进行总结：
- redis 默认 1s 调用 10 次，这个是 redis 的配置中的 hz 选项。hz 默认是 10，代表 1s 调用 10 次，每 100ms 调用一次。
- hz 不能太大，太大的话，cpu 会花大量的时间消耗在判断过期的 key 上，对 cpu 不友好。但是如果你的 redis 过期数据过多，可以适当调大。
- hz 不能太小，因为太小的话，一旦过期的 key 太多可能会过滤不完。
- redis 执行定期删除函数，必须在一定时间内，超过该时间就 return。事件定义为`timelimit =  1000000*ACTIVE_EXPIRE_CYCLE_SLOW_TIME_PERC/server.hz/100` 可以看出该时间与 hz 成反比，hz 默认 10，timelimit 就为 25ms；hz 修改为 100，那么 timelimit 就为 2.5ms。
- 抽取 20 个数据进行判断删除为一个轮训，每经过 16 个轮训才会去判断一次时间是不是超时。
- 如果一个数据库，使用率低于 1%，则不去进行定期删除操作。
- 如果对一个数据库，这次删除操作，已经删除了 25% 的过期 key，那么就跳过这个库。

#### 3.2.3 redis 主从删除过期 key 方式
当 redis 主从模型下，从服务器的删除过期 key 的动作是由主服务器控制的。
- 1、主服务器在惰性删除、客户端主动删除、定期删除一个 key 的时候，会向从服务器发送一个 del 的命令，告诉从服务器需要删除这个 key。
![](./../../images/db/redis/key-expires-delete-master.png)

- 2、从服务器在执行客户端读取 key 的时候，如果该 key 已经过期，也不会将该 key 删除，而是返回一个 null
![](./../../images/db/redis/key-expires-delete-slave.png)

- 3、从服务器只有在接收到主服务器的 del 命令才会将一个 key 进行删除。

#### 3.2.4 总结
- 1、expires 字典的 key 指向数据库中的某个 key，而值记录了数据库中该 key 的过期时间，过期时间是一个以毫秒为单位的 unix 时间戳；
- 2、redis 使用惰性删除和定期删除两种策略来删除过期的 key；惰性删除只会在碰到过期 key 才会删除；定期删除则每隔一段时间主动查找并删除过期键；
- 3、当主服务器删除一个过期 key 后，会向所有的从服务器发送一条 del 命令，显式的删除过期 key；
- 4、从服务器即使发现过期 key 也不会自作主张删除它，而是等待主服务器发送 del 命令，这种统一、中心化的过期 key 删除策略可以保证主从服务器的数据一致性。

## 4 其他相关

### 4.1 内核参数 overcommit
它是 内存分配策略,可选值：0、1、2。
> * 0， 表示内核将检查是否有足够的可用内存供应用进程使用；如果有足够的可用内存，内存申请允许；否则，内存申请失败，并把错误返回给应用进程。
> * 1， 表示内核允许分配所有的物理内存，而不管当前的内存状态如何。
> * 2， 表示内核允许分配超过所有物理内存和交换空间总和的内存

#### 什么是 Overcommit 和 OOM

Linux 对大部分申请内存的请求都回复"yes"，以便能跑更多更大的程序。因为申请内存后，并不会马上使用内存。这种技术叫做 Overcommit。当 linux 发现内存不足时，会发生 OOM killer(OOM=out-of-memory)。它会选择杀死一些进程（用户态进程，不是内核线程），以便释放内存。
当 oom-killer 发生时，linux 会选择杀死哪些进程？选择进程的函数是 oom_badness 函数（在 mm/oom_kill.c 中），该函数会计算每个进程的点数 (0~1000)。点数越高，这个进程越有可能被杀死。每个进程的点数跟 oom_score_adj 有关，而且 oom_score_adj 可以被设置 (-1000 最低，1000 最高）。

解决方法：
    很简单，按提示的操作（将 vm.overcommit_memory 设为 1）即可:可以通过 ` cat /proc/sys/vm/overcommit_memory` 和 `sysctl -a | grep overcommit` 查看
    有三种方式修改内核参数，但要有 root 权限：
> * （1）编辑 /etc/sysctl.conf ，改 vm.overcommit_memory=1，然后 sysctl -p 使配置文件生效
> * （2）sysctl vm.overcommit_memory=1
> * （3）echo 1 > /proc/sys/vm/overcommit_memory
