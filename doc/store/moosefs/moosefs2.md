## 日常问题及修复方法

## Client操作与修复
客户端强制 `kill -9` 杀掉 `mfsmount` 进程,需要先 `umount` ,然后再 `mount` ,否则会提示:

```
fuse: bad mount point `/mnt/test/': Transport endpoint is not connected
see: /data/jingbo.li/mfs/bin/mfsmount -h for help
```

###关于修复
使用过程中遭遇master断电导致服务停止,可以使用 `mfsmetarestore -a` 修复才能启动,如果无法修复,使用 `metalogger` 上的备份日志进行恢复: `mfsmetarestore -m metadata.mfs.back -o metadata.mfs changelog_ml.*.mfs` ,但是此方法也不是万能的,但凡此过程chunks块出现问题,可以使用 `mfsfilerepair` 进行修复.

`mfsfilerepair` 主要是处理坏文件的(如写操作引起的I/O错误)使文件能够部分可读.作用如下:在丢失块的情况下使用0对丢失文件进行填充;在块的版本号不匹配时设置快的版本号为master上已知的能在chunkerservers找到的最高版本号;

注意:

> 因为在第二种情况的内容不匹配,可能发生在块具有相同的版本,建议进行文件的拷贝(而不是进行不快照!),并删除原始文件再进行文件的修复.恢复后会有文件丢失或损坏.

* * *

## Chunker的空间
查看MooseFS文件的使用情况,请使用 `mfsdirinfo` 命令,相当于 `df`.

* * *

## 快照 `snapshot`
可以快照任何一个文件或目录,语法: `mfsmakesnapshot src dst` ,但是src和dst必须都属于mfs体系,即不能mfs体系中的文件快照到其他文件系统.

* * *

## **mfsappendchunks**
追加chunks到一个文件,追加文件块到另一个文件.如果目标文件不存在,则会创建一个空文件,然后继续将块进行追加.

* * *

## 回收站机制
其实MFS有类似windows的回收站这种机制,当文件不小心删除了,不用担心,去回收站去找.随时可以恢复.当然,我所说的随时随地恢复要看你回收站的数据保存多长时间了(默认24小时).

* 首先挂载辅助系统

单独安装或挂载 **MFSMETA** 文件系统,它包含目录/trash (包含仍然可以被还原的删除文件的信息)和 `/trash/undel` (用于获取文件),用一个 `-m` 或 `-o mfsmeta` 的选项,这样可以挂接一个辅助的文件系统MFSMETA,这么做的目的是对于意外的从MooseFS卷上删除文件或者是为了释放磁盘空间而移动的文件而又此文件又过去了垃圾文件存放期的恢复.
> 例如:

        mfsmount -m /mnt/mfsmeta -H mfs1.com.org
        或者
        mfsmount -o mfsmeta -H mfs1.com.org /mnt/mfsmeta
需要注意的是,如果要挂载mfsmeta,一定要在mfsmaster的mfsexports.cfg文件中加入如下条目:\* . rw

挂载后在/mnt/mfsmeta目录下分reserved和trash两个目录,trash为已删除文件存放目录,删除时间根据mfsgettrashtime设置时间来自动删除.

* 设置文件或目录的删除时间
> 一个删除的文件能够存放在“ 垃圾箱”中的时间称为隔离时间,这个时间可以用 `mfsgettrashtime` 命令来查看:
    默认时间为86400,即时间为24小时

```
[root@linux mnt]# mfsgettrashtime filename(某文件名)
filename: 86400
```
> 用 `mfssettrashtime` 命令来设置上面的这个有效时间,要注意的是,保存时间单位为秒.

```
[root@Linux mnt]# mfssettrashtime 60 filename
filename: 60
```

* 恢复删除的文件

把删除的文件移到/trash/undel下,就可以恢复此文件.在MFSMETA的目录里,除了 `trash` 和 `trash/undel` 两个目录,还有第三个目录 `reserved` ,该目录内有已经删除的文件,但却被其他用户一直打开着.
在用户关闭了这些被打开的文件后, `reserved` 目录中的文件将被删除,文件的数据也将被立即删除.此目录不能进行操作.

