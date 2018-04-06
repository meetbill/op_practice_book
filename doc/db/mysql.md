# Mysql

<!-- vim-markdown-toc GFM -->
* [前言](#前言)
    * [MySQL 引擎](#mysql-引擎)
    * [查看下是否支持 InnoDB](#查看下是否支持-innodb)
* [安装完 MySQL 后必须调整的 10 项配置](#安装完-mysql-后必须调整的-10-项配置)
    * [写在开始前](#写在开始前)
    * [基本配置](#基本配置)
    * [InnoDB 配置](#innodb-配置)
    * [其他设置](#其他设置)
    * [总结](#总结)
* [mysql 日志](#mysql-日志)
    * [慢日志 (5.1.73)](#慢日志-5173)
        * [配置](#配置)
        * [查看变量](#查看变量)
        * [测试](#测试)
        * [日志查询](#日志查询)
    * [清理 MySQL binlog](#清理-mysql-binlog)
        * [概要](#概要)
        * [相关基本参数](#相关基本参数)
        * [清理方法](#清理方法)
            * [手动清理](#手动清理)
            * [自动清理](#自动清理)
* [mysql 管理](#mysql-管理)
    * [用户管理](#用户管理)
        * [创建用户](#创建用户)
        * [为用户授权](#为用户授权)
        * [修改用户密码](#修改用户密码)
    * [mysql 主从](#mysql-主从)
        * [清除主从关系](#清除主从关系)
* [mysql 工具](#mysql-工具)
* [mysql 运维](#mysql-运维)
    * [MySQL 忘记密码](#mysql-忘记密码)
    * [mysql.sock 位置错误](#mysqlsock-位置错误)

<!-- vim-markdown-toc -->

# 前言
## MySQL 引擎

一种存储数据的技术。

***并发控制***

当多个连接对记录进行修改时保证数据的一致性和完整性。
可以理解为同步与互斥，原理和操作系统的那部分知识一致。

***事务处理***

这也是数据库区别于文件系统的一点。保证数据的完整性。

***外键***

保证数据的一致性。

***索引***

对数据表中一列或多列值进行排序的一种结构。是进行快速定位的方法。

***对比***

* MyISAM: 适用于事务处理不多时；
* InnoDB: 适用于事务处理比较多，且需要外键支持时；（锁颗粒为行锁，相对效率低）
* Memory：将所有数据保存在 RAM 中，在需要快速查找引用和其他类似数据的环境下，可提供极快的访问。

修改存储引擎，使用`SHOW CREATE TABLE table_name;`查看存储引擎类型。
* 在配置文件中`-default-storage-engine = engine_name`
* 创建数据表时`CREATE TABLE tbl_name() ENGINE = engine_name;`

| 特点 | MyISAM | BDB | Memory | InnoDB | Archive |
|------|:------:|:---:|:------:|:------:|:-------:|
| 存储限制 | 没有 | 没有 |  有  | 64TB | 没有 |
| 事务安全 |  -   | 支持 |  -   | 支持 |  -   |
| 锁机制   | 表锁 | 页锁 | 表锁 | 行锁 | 行锁 |
| B 树索引  | 支持 | 支持 | 支持 | 支持 |  -   |
| 哈希索引 |  -   |  -   | 支持 | 支持 |  -   |
| 全文索引 | 支持 |  -   |  -   |  -   |  -   |
| 集群索引 |  -   |  -   |  -   | 支持 |  -   |
| 数据缓存 |  -   |  -   | 支持 | 支持 |  -   |
| 索引缓存 | 支持 |  -   | 支持 | 支持 |  -   |
| 数据可压缩 |支持|  -   |  -   |  -   | 支持 |
| 空间使用 |  低  |  低  | N/A  |  高  |非常低|
| 内存使用 |  低  |  低  | 中等 |  高  |  低  |
| 批量插入的速度|高| 高  |  高  |  低  |非常高|
| 支持外键 |  -   |  -   |  -   | 支持 |  -   |

## 查看下是否支持 InnoDB

通过命令行进入 mysql 或者是通过 phpmyadmin 进行操作，执行如下命令：
```
SHOW variables like 'have_%';
显示结果中会有如下 3 种可能的结果：
have_innodb YES
have_innodb NO
have_innodb DISABLED
这 3 种结果分别对应：
已经开启 InnoDB 引擎
未安装 InnoDB 引擎
未启用 InnoDB 引擎
```
针对第二种未安装，只需要安装即可；针对第三种未启用，则打开 MySQL 配置文件，找到 skip-innodb 项，将其改成#skip-innodb，之后重启 mysql 服务即可。

# 安装完 MySQL 后必须调整的 10 项配置

## 写在开始前

即使是经验老道的人也会犯错，会引起很多麻烦。所以在盲目的运用这些推荐之前，请记住下面的内容：

- 一次只改变一个设置！这是测试改变是否有益的唯一方法。
- 大多数配置能在运行时使用 SET GLOBAL 改变。这是非常便捷的方法它能使你在出问题后快速撤销变更。但是，要永久生效你需要在配置文件里做出改动。
- 一个变更即使重启了 MySQL 也没起作用？请确定你使用了正确的配置文件。请确定你把配置放在了正确的区域内（所有这篇文章提到的配置都属于 [mysqld])
- 服务器在改动一个配置后启不来了：请确定你使用了正确的单位。例如，`innodb_buffer_pool_size`的单位是 MB 而`max_connection`是没有单位的。
- 不要在一个配置文件里出现重复的配置项。如果你想追踪改动，请使用版本控制。
- 不要用天真的计算方法，例如”现在我的服务器的内存是之前的 2 倍，所以我得把所有数值都改成之前的 2 倍“。

## 基本配置

你需要经常察看以下 3 个配置项。不然，可能很快就会出问题。

**`innodb_buffer_pool_size`**: 这是你安装完 InnoDB 后第一个应该设置的选项。缓冲池是数据和索引缓存的地方：这个值越大越好，这能保证你在大多数的读取操作时使用的是内存而不是硬盘。典型的值是 5-6GB(8GB 内存），20-25GB(32GB 内存），100-120GB(128GB 内存）。

**`innodb_log_file_size`**：这是 redo 日志的大小。redo 日志被用于确保写操作快速而可靠并且在崩溃时恢复。一直到 MySQL 5.1，它都难于调整，因为一方面你想让它更大来提高性能，另一方面你想让它更小来使得崩溃后更快恢复。幸运的是从 MySQL 5.5 之后，崩溃恢复的性能的到了很大提升，这样你就可以同时拥有较高的写入性能和崩溃恢复性能了。一直到 MySQL 5.5，redo 日志的总尺寸被限定在 4GB（默认可以有 2 个 log 文件）。这在 MySQL 5.6 里被提高。

一开始就把`innodb_log_file_size`设置成 512M（这样有 1GB 的 redo 日志）会使你有充裕的写操作空间。如果你知道你的应用程序需要频繁的写入数据并且你使用的时 MySQL 5.6，你可以一开始就把它这是成 4G。

**`max_connections`**: 如果你经常看到‘Too many connections’错误，是因为`max_connections`的值太低了。这非常常见因为应用程序没有正确的关闭数据库连接，你需要比默认的 151 连接数更大的值。`max_connection`值被设高了（例如 1000 或更高）之后一个主要缺陷是当服务器运行 1000 个或更高的活动事务时会变的没有响应。在应用程序里使用连接池或者在 MySQL 里使用 [进程池](http://www.mysqlperformanceblog.com/2014/01/23/percona-server-improve-scalability-percona-thread-pool/) 有助于解决这一问题。

## InnoDB 配置

从 MySQL 5.5 版本开始，InnoDB 就是默认的存储引擎并且它比任何其他存储引擎的使用都要多得多。那也是为什么它需要小心配置的原因。

**`innodb_file_per_table`**：这项设置告知 InnoDB 是否需要将所有表的数据和索引存放在共享表空间里（`innodb_file_per_table` = OFF） 或者为每张表的数据单独放在一个.ibd 文件（`innodb_file_per_table` = ON）。每张表一个文件允许你在 drop、truncate 或者 rebuild 表时回收磁盘空间。这对于一些高级特性也是有必要的，比如数据压缩。但是它不会带来任何性能收益。你不想让每张表一个文件的主要场景是：有非常多的表（比如 10k+）。

MySQL 5.6 中，这个属性默认值是 ON，因此大部分情况下你什么都不需要做。对于之前的版本你必须在加载数据之前将这个属性设置为 ON，因为它只对新创建的表有影响。

**`innodb_flush_log_at_trx_commit`**：默认值为 1，表示 InnoDB 完全支持 ACID 特性。当你的主要关注点是数据安全的时候这个值是最合适的，比如在一个主节点上。但是对于磁盘（读写）速度较慢的系统，它会带来很巨大的开销，因为每次将改变 flush 到 redo 日志都需要额外的 fsyncs。将它的值设置为 2 会导致不太可靠（unreliable）因为提交的事务仅仅每秒才 flush 一次到 redo 日志，但对于一些场景是可以接受的，比如对于主节点的备份节点这个值是可以接受的。如果值为 0 速度就更快了，但在系统崩溃时可能丢失一些数据：只适用于备份节点。

**`innodb_flush_method`**: 这项配置决定了数据和日志写入硬盘的方式。一般来说，如果你有硬件 RAID 控制器，并且其独立缓存采用 write-back 机制，并有着电池断电保护，那么应该设置配置为 O_DIRECT；否则，大多数情况下应将其设为 fdatasync（默认值）。sysbench 是一个可以帮助你决定这个选项的好工具。

**`innodb_log_buffer_size`**: 这项配置决定了为尚未执行的事务分配的缓存。其默认值（1MB）一般来说已经够用了，但是如果你的事务中包含有二进制大对象或者大文本字段的话，这点缓存很快就会被填满并触发额外的 I/O 操作。看看`Innodb_log_waits`状态变量，如果它不是 0，增加`innodb_log_buffer_size`。


## 其他设置

**`query_cache_size`**: query cache（查询缓存）是一个众所周知的瓶颈，甚至在并发并不多的时候也是如此。 最佳选项是将其从一开始就停用，设置`query_cache_size` = 0（现在 MySQL 5.6 的默认值）并利用其他方法加速查询：优化索引、增加拷贝分散负载或者启用额外的缓存（比如 memcache 或 redis）。如果你已经为你的应用启用了 query cache 并且还没有发现任何问题，query cache 可能对你有用。这是如果你想停用它，那就得小心了。

**`log_bin`**：如果你想让数据库服务器充当主节点的备份节点，那么开启二进制日志是必须的。如果这么做了之后，还别忘了设置`server_id`为一个唯一的值。就算只有一个服务器，如果你想做基于时间点的数据恢复，这（开启二进制日志）也是很有用的：从你最近的备份中恢复（全量备份），并应用二进制日志中的修改（增量备份）。二进制日志一旦创建就将永久保存。所以如果你不想让磁盘空间耗尽，你可以用 [PURGE BINARY LOGS](http://dev.mysql.com/doc/refman/5.6/en/purge-binary-logs.html) 来清除旧文件，或者设置`expire_logs_days`来指定过多少天日志将被自动清除。

记录二进制日志不是没有开销的，所以如果你在一个非主节点的复制节点上不需要它的话，那么建议关闭这个选项。

**`skip_name_resolve`**：当客户端连接数据库服务器时，服务器会进行主机名解析，并且当 DNS 很慢时，建立连接也会很慢。因此建议在启动服务器时关闭`skip_name_resolve`选项而不进行 DNS 查找。唯一的局限是之后`GRANT`语句中只能使用 IP 地址了，因此在添加这项设置到一个已有系统中必须格外小心。

## 总结

当然还有其他的设置可以起作用，取决于你的负载或硬件：在慢内存和快磁盘、高并发和写密集型负载情况下，你将需要特殊的调整。然而这里的目标是使得你可以快速地获得一个稳健的 MySQL 配置，而不用花费太多时间在调整一些无关紧要的 MySQL 设置或读文档找出哪些设置对你来说很重要上。

# mysql 日志

MySQL 服务器上一共有六种日志：错误日志，查询日志，慢查询日志，二进制日志，事务日志，中继日志

## 慢日志 (5.1.73)

慢查询日志，顾名思义就是记录执行比较慢查询的日志

### 配置

两种方法

**修改配置（永久生效）**

修改配置文件：```/etc/my.cnf```

```ini
[mysqld]
slow_query_log = 1
slow_query_log_file = /tmp/mysql_slow_queries.log
long_query_time = 10
```
配置后重启 mysql

**修改变量（重启后失效）**

`mysql> set global slow_query_log=1;`

5.1.73 默认慢查询日志路径为：/var/run/mysqld/mysqld-slow.log

### 查看变量

**慢查询打开状态 (slow_query_log) 和日志位置 (slow_query_log_file)**

`mysql> SHOW VARIABLES LIKE 'slow%';`

```
+---------------------------+----------------------------+
| Variable_name             | Value                      |
+---------------------------+----------------------------+
| slow_launch_time          | 2                          |
| slow_query_log            | ON                         |
| slow_query_log_file       | /tmp/mysql_slow_queries.log|
+---------------------------+----------------------------+
3 rows in set (0.01 sec)
```

**慢查询时间**

`mysql> SHOW VARIABLES LIKE 'long%';`

```
+---------------------------+-----------+
| Variable_name             | Value     |
+---------------------------+-----------+
| long_query_time           | 10.000000 |
+---------------------------+-----------+
```
### 测试

登陆 mysql

`mysql>select sleep(11);`

查看日志

tail -f /tmp/mysql_slow_queries.log

### 日志查询

列出记录次数最多的 10 个 sql 语句

```
mysqldumpslow -s c -t 10 /tmp/mysql_slow_queries.log
```

得到返回记录最多的 10 个 SQL。

```
mysqldumpslow -s r -t 10 /tmp/mysql_slow_queries.log
```

## 清理 MySQL binlog

### 概要
作为 master 的 Mysql 运行久了以后会在根目录中产生大量的 binlog 日志，如果不及时清理，会占用大量的磁盘空间，也会对数据库的正常运行带来隐患

>之所以要开启 binlog 是因为，mysql 的主备复制是建立在 master 产生 binlog 的基础上

### 相关基本参数

**--log-bin[=base_name]**

Item     | Format
-------- | ---
Command-Line Format |--log-bin
Option-File Format|log-bin
System Variable Name|log_bin
Variable Scope|Global
Dynamic Variable|No
Permitted Values Type |file name

> Enable binary logging. The server logs all statements that change data to the binary log, which is used for backup and replication.The option value, if given, is the basename for the log sequence. The server creates binary log files in sequence by adding a numeric suffix to the basename. It is recommended that you specify a basename (see Section C.5.8, “Known Issues in MySQL”, for the reason). Otherwise, MySQL uses host_name-bin as the basename.

这是手册中关于 binlog 作用的两点描述

>* For replication, the binary log on a master replication server provides a record of the data changes to be sent to slave servers. The master server sends the events contained in its binary log to its slaves, which execute those events to make the same data changes that were made on the master.
>* Certain data recovery operations require use of the binary log. After a backup has been restored, the events in the binary log that were recorded after the backup was made are re-executed. These events bring databases up to date from the point of the backup


**max_binlog_size**

Item     | Format
-------- | ---
Command-Line Format |--max_binlog_size=#
Option-File Format|max\_binlog\_size
System Variable Name|max\_binlog\_size
Variable Scope|Global
Dynamic Variable|Yes
Permitted Values Type |numeric
Default|1073741824
Range|4096 .. 1073741824

>If a write to the binary log causes the current log file size to exceed the value of this variable, the server rotates the binary logs (closes the current file and opens the next one). The minimum value is 4096bytes. The maximum and default value is 1GB.

> **Note:** If max\_relay\_log\_size is 0, the value of max\_binlog\_size applies to relay logs as well.


**--log-bin-index[=file_name]**

Item     | Format
-------- | ---
Command-Line Format |--log-bin-index=name
Option-File Format|log-bin-index
System Variable Name|log_bin
Variable Scope|Global
Dynamic Variable|No
Permitted Values Type |file name

>The index file for binary log file names. If you omit the file name,and if you did not specify one with --log-bin, MySQL uses host_name-bin.index as the file name.

**expire_logs_days**

Item     | Format
-------- | ---
Command-Line Format |--expire\_logs\_days=#
Option-File Format|expire\_logs_days
System Variable Name|expire\_logs_days
Variable Scope|Global
Dynamic Variable|Yes
Permitted Values Type |numeric
Default|0
Range|0 .. 99

> The number of days for automatic binary log file removal. The default is 0, which means “no automatic removal.” Possible removals happen at startup and when the binary log is flushed. Log flushing occurs as indicated in Section 5.2, “MySQL Server Logs”.

---

### 清理方法

#### 手动清理

***使用 PURGE BINARY LOGS 进行清理***

~~~
mysql> help purge
Name: 'PURGE BINARY LOGS'
Description:
Syntax:
PURGE { BINARY | MASTER } LOGS
    { TO 'log_name' | BEFORE datetime_expr }

The binary log is a set of files that contain information about data
modifications made by the MySQL server. The log consists of a set of
binary log files, plus an index file (see
http://dev.mysql.com/doc/refman/5.1/en/binary-log.html).

The PURGE BINARY LOGS statement deletes all the binary log files listed
in the log index file prior to the specified log file name or date.
BINARY and MASTER are synonyms. Deleted log files also are removed from
the list recorded in the index file, so that the given log file becomes
the first in the list.

This statement has no effect if the server was not started with the
--log-bin option to enable binary logging.

URL: http://dev.mysql.com/doc/refman/5.1/en/purge-binary-logs.html

Examples:
PURGE BINARY LOGS TO 'mysql-bin.010';
PURGE BINARY LOGS BEFORE '2008-04-02 22:46:26';

mysql>
~~~

当 slave 正在复制时，这条命令也是安全的，如果尝试删除一个正在被读的日志文件，这个语句将什么事情也不做。

但是如果一个 slave 没有连接上 master，而在 master 上删除了它还没读取的日志文件，一旦 salve 连接上 master，slave 将出错，无法正常复制。

尽量遵循下面的流程，以确保安全删除日志文件：

* 1. 在各个 slave 服务器上，使用**SHOW SLAVE STATUS**检查哪一个日志文件正在被读取
* 2. 使用**SHOW BINARY LOGS**在 master 上获取一份日志文件列表
* 3. 根据所有的 slaves 服务器，决定最早的那个日志文件是哪一个，这个就是目标文件，如果所有的 slaves 都更新完所有操作，这个日志文件就是列表中的最后一个
* 4. 对所有即将删除的日志文件进行备份（这不是必要步骤，但是建议这么做）
* 5. 使用**Purge**清理掉到目标日志的所有日志文件


> **Note:** 当**.index**中列出的文件在系统中已经被各种原因移除（比如使用**rm**手动删除了）的情况下使用 **PURGE BINARY LOGS TO** 或 **PURGE BINARY LOGS BEFORE**会报错，解决办法是手动编辑**.index**文件，确保里面列出的文件在系统中真实存在，然后再次使用**PURGE BINARY LOGS**


检查当前系统中的日志文件

~~~
mysql> show binary logs;
+------------------+-----------+
| Log_name         | File_size |
+------------------+-----------+
| mysql-bin.000001 |       125 |
| mysql-bin.000002 |       125 |
| mysql-bin.000003 |       125 |
| mysql-bin.000004 |       125 |
| mysql-bin.000005 |       125 |
| mysql-bin.000006 |       125 |
| mysql-bin.000007 |       125 |
| mysql-bin.000008 |       125 |
| mysql-bin.000009 |       125 |
| mysql-bin.000010 |       125 |
| mysql-bin.000011 |       125 |
| mysql-bin.000012 |       125 |
| mysql-bin.000013 |       125 |
| mysql-bin.000014 |       125 |
| mysql-bin.000015 |       125 |
| mysql-bin.000016 |       106 |
+------------------+-----------+
16 rows in set (0.00 sec)

mysql> \! ls -l /var/lib/mysql
total 20648
-rw-rw----. 1 mysql mysql 10485760 Mar 18 17:32 ibdata1
-rw-rw----. 1 mysql mysql  5242880 Mar 18 17:32 ib_logfile0
-rw-rw----. 1 mysql mysql  5242880 Mar 18 17:32 ib_logfile1
-rw-r-----. 1 mysql root     27513 Mar 19 00:27 localhost.localdomain.err
-rw-r-----. 1 mysql root     36471 Apr  1 17:07 m2.err
-rw-rw----. 1 mysql mysql        5 Apr  1 17:07 m2.pid
-rw-rw----. 1 mysql mysql      125 Mar 31 22:27 m2-relay-bin.000001
-rw-rw----. 1 mysql mysql      106 Apr  1 17:07 m2-relay-bin.000002
-rw-rw----. 1 mysql mysql       44 Apr  1 17:07 m2-relay-bin.index
-rw-rw----. 1 mysql mysql       68 Apr  1 17:07 master.info
drwx------. 2 mysql mysql     4096 Mar 31 19:28 mysql
-rw-rw----. 1 mysql mysql      125 Mar 18 23:42 mysql-bin.000001
-rw-rw----. 1 mysql mysql      125 Mar 19 00:27 mysql-bin.000002
-rw-rw----. 1 mysql mysql      125 Mar 19 11:37 mysql-bin.000003
-rw-rw----. 1 mysql mysql      125 Mar 19 15:03 mysql-bin.000004
-rw-rw----. 1 mysql mysql      125 Mar 19 15:29 mysql-bin.000005
-rw-rw----. 1 mysql mysql      125 Mar 19 15:56 mysql-bin.000006
-rw-rw----. 1 mysql mysql      125 Mar 19 16:45 mysql-bin.000007
-rw-rw----. 1 mysql mysql      125 Mar 19 17:27 mysql-bin.000008
-rw-rw----. 1 mysql mysql      125 Mar 19 17:56 mysql-bin.000009
-rw-rw----. 1 mysql mysql      125 Mar 19 19:06 mysql-bin.000010
-rw-rw----. 1 mysql mysql      125 Mar 19 20:11 mysql-bin.000011
-rw-rw----. 1 mysql mysql      125 Mar 20 02:33 mysql-bin.000012
-rw-rw----. 1 mysql mysql      125 Mar 28 02:36 mysql-bin.000013
-rw-rw----. 1 mysql mysql      125 Mar 28 06:08 mysql-bin.000014
-rw-rw----. 1 mysql mysql      125 Mar 31 22:27 mysql-bin.000015
-rw-rw----. 1 mysql mysql      106 Apr  1 17:07 mysql-bin.000016
-rw-rw----. 1 mysql mysql      304 Apr  1 17:07 mysql-bin.index
srwxrwxrwx. 1 mysql mysql        0 Apr  1 17:07 mysql.sock
-rw-rw----. 1 mysql mysql       60 Apr  1 17:07 relay-log.info
drwx------. 2 mysql mysql     4096 Mar 18 17:32 test
mysql>
~~~

删除掉**mysql-bin.000004**之前的日志

~~~
mysql> purge binary logs to 'mysql-bin.000004';
Query OK, 0 rows affected (0.00 sec)

mysql> show binary logs;
+------------------+-----------+
| Log_name         | File_size |
+------------------+-----------+
| mysql-bin.000004 |       125 |
| mysql-bin.000005 |       125 |
| mysql-bin.000006 |       125 |
| mysql-bin.000007 |       125 |
| mysql-bin.000008 |       125 |
| mysql-bin.000009 |       125 |
| mysql-bin.000010 |       125 |
| mysql-bin.000011 |       125 |
| mysql-bin.000012 |       125 |
| mysql-bin.000013 |       125 |
| mysql-bin.000014 |       125 |
| mysql-bin.000015 |       125 |
| mysql-bin.000016 |       106 |
+------------------+-----------+
13 rows in set (0.00 sec)

mysql> \! ls -l /var/lib/mysql
total 20636
-rw-rw----. 1 mysql mysql 10485760 Mar 18 17:32 ibdata1
-rw-rw----. 1 mysql mysql  5242880 Mar 18 17:32 ib_logfile0
-rw-rw----. 1 mysql mysql  5242880 Mar 18 17:32 ib_logfile1
-rw-r-----. 1 mysql root     27513 Mar 19 00:27 localhost.localdomain.err
-rw-r-----. 1 mysql root     36471 Apr  1 17:07 m2.err
-rw-rw----. 1 mysql mysql        5 Apr  1 17:07 m2.pid
-rw-rw----. 1 mysql mysql      125 Mar 31 22:27 m2-relay-bin.000001
-rw-rw----. 1 mysql mysql      106 Apr  1 17:07 m2-relay-bin.000002
-rw-rw----. 1 mysql mysql       44 Apr  1 17:07 m2-relay-bin.index
-rw-rw----. 1 mysql mysql       68 Apr  1 17:07 master.info
drwx------. 2 mysql mysql     4096 Mar 31 19:28 mysql
-rw-rw----. 1 mysql mysql      125 Mar 19 15:03 mysql-bin.000004
-rw-rw----. 1 mysql mysql      125 Mar 19 15:29 mysql-bin.000005
-rw-rw----. 1 mysql mysql      125 Mar 19 15:56 mysql-bin.000006
-rw-rw----. 1 mysql mysql      125 Mar 19 16:45 mysql-bin.000007
-rw-rw----. 1 mysql mysql      125 Mar 19 17:27 mysql-bin.000008
-rw-rw----. 1 mysql mysql      125 Mar 19 17:56 mysql-bin.000009
-rw-rw----. 1 mysql mysql      125 Mar 19 19:06 mysql-bin.000010
-rw-rw----. 1 mysql mysql      125 Mar 19 20:11 mysql-bin.000011
-rw-rw----. 1 mysql mysql      125 Mar 20 02:33 mysql-bin.000012
-rw-rw----. 1 mysql mysql      125 Mar 28 02:36 mysql-bin.000013
-rw-rw----. 1 mysql mysql      125 Mar 28 06:08 mysql-bin.000014
-rw-rw----. 1 mysql mysql      125 Mar 31 22:27 mysql-bin.000015
-rw-rw----. 1 mysql mysql      106 Apr  1 17:07 mysql-bin.000016
-rw-rw----. 1 mysql mysql      247 Apr  1 19:47 mysql-bin.index
srwxrwxrwx. 1 mysql mysql        0 Apr  1 17:07 mysql.sock
-rw-rw----. 1 mysql mysql       60 Apr  1 17:07 relay-log.info
drwx------. 2 mysql mysql     4096 Mar 18 17:32 test
mysql>
~~~

查看 binlog 事件

~~~
mysql> show binlog events\G
*************************** 1. row ***************************
   Log_name: mysql-bin.000004
        Pos: 4
 Event_type: Format_desc
  Server_id: 2
End_log_pos: 106
       Info: Server ver: 5.1.73-14.12-log, Binlog ver: 4
*************************** 2. row ***************************
   Log_name: mysql-bin.000004
        Pos: 106
 Event_type: Stop
  Server_id: 2
End_log_pos: 125
       Info:
2 rows in set (0.03 sec)

mysql>
~~~

根据时间来清理

~~~
mysql> purge master logs before '2015-03-19 15:56:00'
Query OK, 0 rows affected (0.01 sec)

mysql> show binary logs;
+------------------+-----------+
| Log_name         | File_size |
+------------------+-----------+
| mysql-bin.000006 |       125 |
| mysql-bin.000007 |       125 |
| mysql-bin.000008 |       125 |
| mysql-bin.000009 |       125 |
| mysql-bin.000010 |       125 |
| mysql-bin.000011 |       125 |
| mysql-bin.000012 |       125 |
| mysql-bin.000013 |       125 |
| mysql-bin.000014 |       125 |
| mysql-bin.000015 |       125 |
| mysql-bin.000016 |       106 |
+------------------+-----------+
11 rows in set (0.00 sec)

mysql>
~~~

清理 5 天之前的日志

~~~
mysql> select now();
+---------------------+
| now()               |
+---------------------+
| 2015-04-02 13:52:13 |
+---------------------+
1 row in set (0.00 sec)

mysql> select date_sub(now(),interval 5 day);
+--------------------------------+
| date_sub(now(),interval 5 day) |
+--------------------------------+
| 2015-03-28 13:52:15            |
+--------------------------------+
1 row in set (0.00 sec)

mysql> purge master logs before date_sub(now(),interval 5 day);
Query OK, 0 rows affected (0.01 sec)

mysql> show binary logs;
+------------------+-----------+
| Log_name         | File_size |
+------------------+-----------+
| mysql-bin.000015 |       125 |
| mysql-bin.000016 |       125 |
| mysql-bin.000017 |       106 |
+------------------+-----------+
3 rows in set (0.00 sec)

mysql> \! ls -l *mysql-bin*
-rw-rw----. 1 mysql mysql 125 Mar 31 22:27 mysql-bin.000015
-rw-rw----. 1 mysql mysql 125 Apr  1 22:56 mysql-bin.000016
-rw-rw----. 1 mysql mysql 106 Apr  2 10:35 mysql-bin.000017
-rw-rw----. 1 mysql mysql  57 Apr  2 13:52 mysql-bin.index
mysql> \! cat mysql-bin.index
./mysql-bin.000015
./mysql-bin.000016
./mysql-bin.000017
mysql>
~~~


---

***使用 RESET MASTER 进行清理***

**RESET MASTER**会删除 index 文件中所有的 binary log，重新设置 binary log 为空，创建新的 binary log，这条语句适合在第一次 master 运行启动后，不太适合在生产环境中已经运行了好久的情况下。

> **Note:** **RESET MASTER**和**PURGE BINARY LOGS**有以下两点不同
>
>* 1.**RESET MASTER**会移除掉 index 文件中的所有日志，然后只留下一个空的以**.000001**结尾的日志文件，但是**PURGE BINARY LOGS**不会重设后缀
>* 2.**RESET MASTER**不是设计来用在有任何 slave 正在运行的情况下，但**PURGE BINARY LOGS**是设计来在此种情况下使用的，当 slave 的复制正在运行时使用**PURGE BINARY LOGS**也是安全的

**RESET MASTER**在第一次设置 master 和 slave 的情况下非常有用，可以按照下面的步骤进行检查：

* 1. 运行 master 和 slave, 开启复制
* 2. 在 master 中进行一系列的插入测试
* 3. 在 slave 中检查更新有无按预期同步
* 4. 在 salve 上确认复制可以正常运行后，**RESET SLAVE** 然后 ** STOP SLAVE** ，然后确保所有不想要的数据在 slave 上已经清理
* 5. 在 master 上执行**RESET MASTER**清除掉测试数据
* 6. 在检查所有的不想要的测试数据和日志已经清理掉后，可以在 slave 上重新开启复制

#### 自动清理

可以使用**expire_logs_days**系统变量来设定日志过期时间，自动删除过期日志，如果环境中有复制，注意要设定合适的值，这个值要大于最坏情况下 slave 可能落后于 master 的天数。

>自动清理操作会发生在系统开启和日志刷新的时候


设定 5 天为日志过期时间

~~~
mysql> show variables like "%expire%";
+------------------+-------+
| Variable_name    | Value |
+------------------+-------+
| expire_logs_days | 0     |
+------------------+-------+
1 row in set (0.00 sec)

mysql> set global expire_logs_days=5 ;
Query OK, 0 rows affected (0.00 sec)

mysql> show variables like "%expire%";
+------------------+-------+
| Variable_name    | Value |
+------------------+-------+
| expire_logs_days | 5     |
+------------------+-------+
1 row in set (0.00 sec)

mysql>
~~~



# mysql 管理

## 用户管理

### 创建用户

  CREATE USER 'username'@'host' IDENTIFIED BY 'password';

用户创建之后只能看到`information_schema`数据库，使用`show grants;`看到自己的权限为`GRANT USAGE ON *.* TO 'user'@'localhost'`;

### 为用户授权
使用***GRANT 命令***为用户授予数据库操作的权力，比如增删改查等。

```
> GRANT ALL PRIVILEGES ON *.* TO 'myuser'@'%' IDENTIFIED BY 'mypassword' WITH GRANT OPTION;  
> FLUSH   PRIVILEGES; 
```
其中 `%` 表示对所有主机开放，只对本机开放时可以写 `127.0.0.1`

### 修改用户密码
SET PASSWORD（推荐）,MySQL5.7.6 及以后：

    SET PASSWORD [FOR user] = password_option
    password_option: {
        PASSWORD('auth_string') # 弃用
      | 'auth_string'
    }
    # 修改自己的密码
    SET PASSWORD = '123456';
    # 修改一用户的密码
    SET PASSWORD FOR 'user'@'34.23.44.32' = '123456';

ALTER（推荐）

    ALTER USER 'user'@'localhost' IDENTIFIED BY 'auth_string';

忘记 root 密码

    # 正确关闭 MySQL 服务
    $ mysqld stop
    # 开启不验证登录
    $ mysqld_safe --skip-grant-tables &
    # 用上述其他方法修改密码
    # 退出重启 MySQL

    # 方法二：
    1. 在 /etc/mysql/my.cnf 或者 /etc/my.cnf 中 [mysqld] 加入 `skip-grant-tales` 可以免除密码登陆。
    2. `service mysqld start`启动 mysql 后，直接在终端输入`mysql`可以免密码直接登陆。
    3. > flush privileges;
    4. set password for root@localhost = 'new-pass';

    在 MySQL 5.7 之后，Windows 使用解压缩安装 MySQL, 需要依次执行如下方便初始化：
    mysqld --initialize-insecure # 删除其他所有用户，无密码初始化 MySQL root 用户，如果没有 insecure, 则会创建随机密码
    mysqld -install # 安装服务
    之后再不输入密码登录 root 用户，再设置密码。


mysqladmin（不安全）, 在终端输入：

    $ mysqladmin -u username -p password '123456'

UPDATE user 表

    UPDATE user SET password=password('123456') WHERE user='name' AND host='12.44.33.22';
    FLUSH privileges;

## mysql 主从

### 清除主从关系

一般情况下清除主从关系只需要做以下操作即可

* 登陆 slave 数据库后执行 `stop slave`
* 登陆 slave 数据库后执行 `RESET SLAVE`
* 重启 slave 的 mysql 服务

阅读下方内容了解更多清除主从关系的相关操作

**RESET MASTER**

删除所有 index file 中记录的所有 binlog 文件，将日志索引文件清空，创建一个新的日志文件，这个命令通常仅仅用于第一次用于搭建主从关系的时的主库，

注意

reset master 不同于 purge binary log 的两处地方

> * reset master 将删除日志索引文件中记录的所有 binlog 文件，创建一个新的日志文件 起始值从 000001 开始，然而 purge binary log 命令并不会修改记录 binlog 的顺序的数值
> * reset master 不能用于有任何 slave 正在运行的主从关系的主库。因为在 slave 运行时刻 reset master 命令不被支持，reset master 将 master 的 binlog 从 000001 开始记录，slave 记录的 master log 则是 reset master 时主库的最新的 binlog, 从库会报错无法找的指定的 binlog 文件。

**RESET SLAVE**

```
使用 reset slave 之前必须使用 stop slave 命令将复制进程停止。

reset slave 将使 slave 忘记主从复制关系的位置信息。该语句将被用于干净的启动，它删除 master.info 文件和 relay-log.info 文件以及所有的 relay log 文件并重新启用一个新的 relaylog 文件。

在 5.1.73（后面的版本貌似也是） 的版本中 reset slave 并不会清理存储于内存中的复制信息比如  master host, master port, master user, or master password, 也就是说如果没有使用 change master 命令做重新定向，执行 start slave 还是会指向旧的 master 上面。当从库执行 reset slave 之后，将 mysqld 重启后复制参数将被重置。

注 所有的 relay log 将被删除不管他们是否被 SQL thread 进程完全应用（这种情况发生于备库延迟以及在备库执行了 stop slave 命令）, 存储复制链接信息的 master.info 文件将被立即清除，如果 SQL thread 正在复制临时表的过程中，执行了 stop slave ，并且执行了 reset slave，这些被复制的临时表将被删除。
```

**RESET SLAVE  ALL**(5.6 后支持）

在 5.6.3 版本以及以后 使用使用 RESET SLAVE ALL 来完全的清理复制连接参数信息。
# mysql 工具

* [mysql 日常定时备份](https://github.com/meetbill/mysql_tools)

# mysql 运维

## MySQL 忘记密码

**现象**

```
#mysql -u root -p
#就会出现：ERROR 1045 (28000): Access denied for user ''@'localhost' (using password: NO)
```
**解决方法**

```
l 关闭 mysql
# service mysqld stop

2. 屏蔽权限
# mysqld_safe --skip-grant-table
屏幕出现：
161028 22:30:08 mysqld_safe Logging to '/var/log/mysqld.log'.
161028 22:30:08 mysqld_safe Starting mysqld daemon with databases from /var/lib/mysql'

3. 新开起一个终端输入
#mysql -u root
mysql> UPDATE user SET Password=PASSWORD('newpassword') where USER='root';
mysql> FLUSH PRIVILEGES;// 记得要这句话，否则如果关闭先前的终端，又会出现原来的错误
mysql> \q
#/etc/init.d/mysqld restart
```
## mysql.sock 位置错误

日常迁移完数据库的存储路径后，client 登陆失败

**解决方法**

修改 /etc/my.cnf 配置文件
```
[client]
socket = /tmp/mysql.sock
```
