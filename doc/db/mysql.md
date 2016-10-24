# Mysql

* [概要](#概要)
* [相关基本参数](#相关基本参数)
* [清理方法](#清理方法)
	* [手动清理](#手动清理)
	* [自动清理](#自动清理)

## 概要
作为master的Mysql运行久了以后会在根目录中产生大量的binlog日志，如果不及时清理，会占用大量的磁盘空间，也会对数据库的正常运行带来隐患

>之所以要开启binlog是因为，mysql的主备复制是建立在master产生binlog的基础上

## 相关基本参数

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

这是手册中关于binlog作用的两点描述

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

## 清理方法 


### 手动清理

***使用PURGE BINARY LOGS进行清理***

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

当slave正在复制时，这条命令也是安全的，如果尝试删除一个正在被读的日志文件，这个语句将什么事情也不做。

但是如果一个slave没有连接上master，而在master上删除了它还没读取的日志文件，一旦salve连接上master，slave将出错，无法正常复制。

尽量遵循下面的流程，以确保安全删除日志文件：

* 1.在各个slave服务器上，使用**SHOW SLAVE STATUS**检查哪一个日志文件正在被读取
* 2.使用**SHOW BINARY LOGS**在master上获取一份日志文件列表
* 3.根据所有的slaves服务器，决定最早的那个日志文件是哪一个，这个就是目标文件，如果所有的slaves都更新完所有操作，这个日志文件就是列表中的最后一个
* 4.对所有即将删除的日志文件进行备份(这不是必要步骤，但是建议这么做)
* 5.使用**Purge**清理掉到目标日志的所有日志文件


> **Note:** 当**.index**中列出的文件在系统中已经被各种原因移除(比如使用**rm**手动删除了)的情况下使用 **PURGE BINARY LOGS TO** 或 **PURGE BINARY LOGS BEFORE**会报错，解决办法是手动编辑**.index**文件，确保里面列出的文件在系统中真实存在，然后再次使用**PURGE BINARY LOGS**


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

查看binlog事件

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

清理5天之前的日志

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

***使用RESET MASTER进行清理***

**RESET MASTER**会删除index文件中所有的binary log，重新设置binary log为空，创建新的binary log，这条语句适合在第一次master运行启动后，不太适合在生产环境中已经运行了好久的情况下。

> **Note:** **RESET MASTER**和**PURGE BINARY LOGS**有以下两点不同
>
>* 1.**RESET MASTER**会移除掉index文件中的所有日志，然后只留下一个空的以**.000001**结尾的日志文件，但是**PURGE BINARY LOGS**不会重设后缀
>* 2.**RESET MASTER**不是设计来用在有任何slave正在运行的情况下，但**PURGE BINARY LOGS**是设计来在此种情况下使用的，当slave的复制正在运行时使用**PURGE BINARY LOGS**也是安全的

**RESET MASTER**在第一次设置master和slave的情况下非常有用，可以按照下面的步骤进行检查：

* 1.运行master和slave,开启复制
* 2.在master中进行一系列的插入测试 
* 3.在slave中检查更新有无按预期同步
* 4.在salve上确认复制可以正常运行后，**RESET SLAVE** 然后 ** STOP SLAVE** ，然后确保所有不想要的数据在slave上已经清理
* 5.在master上执行**RESET MASTER**清除掉测试数据
* 6.在检查所有的不想要的测试数据和日志已经清理掉后，可以在slave上重新开启复制





---

### 自动清理

可以使用**expire_logs_days**系统变量来设定日志过期时间，自动删除过期日志，如果环境中有复制，注意要设定合适的值，这个值要大于最坏情况下slave可能落后于master的天数。

>自动清理操作会发生在系统开启和日志刷新的时候


设定5天为日志过期时间

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

