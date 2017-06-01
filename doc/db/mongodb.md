## Mongodb
<!-- vim-markdown-toc GFM -->
* [Mongodb 备份](#mongodb-备份)

<!-- vim-markdown-toc -->
### Mongodb 备份
Mongodb 用的是可以热备份的 mongodump 和对应恢复的 mongorestore, 在 linux 下面使用 shell 脚本写的定时备份，代码如下

1. 定时备份

```
    #!/bin/bash
    sourcepath='/usr'/bin   #mongodump 命令所在路径
    targetpath='/var/lib/mongo/mongobak'   #备份存放位置
    nowtime=$(date +%Y%m%d)

    start()
    {
      ${sourcepath}/mongodump -u username -p password -d dbname --host 127.0.0.1 --port 27017 --out ${targetpath}/${nowtime}
    }
    execute()
    {
      start
      if [ $? -eq 0 ]
      then
        echo "back successfully!"
      else
        echo "back failure!"
      fi
    }

    if [ ! -d "${targetpath}/${nowtime}/" ]
    then
     mkdir ${targetpath}/${nowtime}
    fi
    execute
    echo "============== back end ${nowtime} =============="
```
<!--more-->
2. 定时清除，保留 7 天的纪录

```
    #!/bin/bash
    targetpath='/var/lib/mongo/mongobak'
    nowtime=$(date -d '-7 days' "+%Y%m%d")
    if [ -d "${targetpath}/${nowtime}/" ]
    then
      rm -rf "${targetpath}/${nowtime}/"
      echo "=======${targetpath}/${nowtime}/=== 删除完毕 =="
    fi
    echo "===$nowtime ==="
```
3. 服务器的时间要同步，同步的方法

```
  微软公司授时主机（美国）     time.windows.com
  台警大授时中心（台湾）        asia.pool.ntp.org
  中科院授时中心（西安）        210.72.145.44
  网通授时中心（北京）           219.158.14.130
  调用同步：  ntpdate asia.pool.ntp.org
```
4. 设置上面脚本权限和定时任务

  权限：chmod +x filename
  定时任务：crontab -e

```
  10 04 * * * /shell/mongobak.sh 1>/var/log/crontab_mongo_back.log &
  10 02 * * * /shell/mongobakdelete.sh 1>/var/log/crontab_mongo_delete.log &
```
每天凌晨 4 点 10 开始进行备份，2 点 10 分删除旧的备份
