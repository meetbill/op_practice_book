# MFS集群的维护

## 启动和停止MFS集群

***启动*** 

最安全的启动MooseFS 集群(避免任何读或写的错误数据或类似的问题)的方式是按照以下命令步骤：
```
(1)启动mfsmaster 进程
(2)启动所有的mfschunkserver 进程
(3)启动mfsmetalogger 进程（如果配置了mfsmetalogger）
(4)当所有的chunkservers 连接到MooseFS master 后，任何数目的客户端可以利用mfsmount 去挂接被export 的文件系统。（可以通过检查master 的日志或是CGI 监视器来查看是否所有的chunkserver被连接）。
```
***停止*** 

```
(1)在所有的客户端卸载MooseFS 文件系统（用umount 命令或者是其它等效的命令）
(2)用mfschunkserver stop 命令停止chunkserver 进程
(3)用mfsmetalogger stop 命令停止metalogger 进程
(4)用mfsmaster stop 命令停止master 进程
```
## MFS chunkservers 的维护
若每个文件的goal(目标)都不小于2，并且没有under-goal 文件(这些可以用mfsgetgoal -r和mfsdirinfo 命令来检查)，那么一个单一的chunkserver 在任何时刻都可能做停止或者是重新启动。以后每当需要做停止或者是重新启动另一个chunkserver 的时候，要确定之前的chunkserver 被连接，而且要没有under-goal chunks。

## MFS元数据备份

通常元数据有两部分的数据：
> + 主要元数据文件metadata.mfs，当mfsmaster 运行的时候会被命名为metadata.mfs.back
> + 元数据改变日志changelog.*.mfs，存储了过去的N 小时的文件改变（N 的数值是由BACK_LOGS参数设置的，参数的设置在mfschunkserver.cfg 配置文件中）。
主要的元数据文件需要定期备份，备份的频率取决于取决于多少小时changelogs 储存。元数据changelogs 实时的自动复制。

## MFS Master的恢复

一旦mfsmaster 崩溃（例如因为主机或电源失败），需要最后一个元数据日志changelog 并入主要的metadata 中。这个操作时通过mfsmetarestore 工具做的，最简单的方法是：

$/usr/local/mfs/bin/mfsmetarestore -a

如果master 数据被存储在MooseFS 编译指定地点外的路径，则要利用-d 参数指定使用，如：

$/usr/local/mfs/bin/mfsmetarestore -a -d /opt/mfsmaster

## 从MetaLogger中恢复Master

有些童鞋提到：如果mfsmetarestore -a无法修复，则使用metalogger也可能无法修复，暂时没遇到过这种情况，这里不暂不考虑。
找回metadata.mfs.back 文件，可以从备份中找，也可以中metalogger 主机中找（如果启动了metalogger 服务），然后把metadata.mfs.back 放入data 目录，一般为{prefix}/var/mfs
从在master 宕掉之前的任何运行metalogger 服务的服务器上拷贝最后metadata 文件，然后放入mfsmaster 的数据目录。
利用mfsmetarestore 命令合并元数据changelogs，可以用自动恢复模式mfsmetarestore –a，也可以利用非自动化恢复模式
$mfsmetarestore -m metadata.mfs.back -o metadata.mfs changelog_ml.*.mfs
或：强制使用metadata.mfs.back创建metadata.mfs，可以启动master，但丢失的数据暂无法确定。
