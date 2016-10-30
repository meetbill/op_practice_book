# Linux 优化

[返回主目录](../../SUMMARY.md)

## ulimit关于系统连接数的优化

linux 默认值 open files 和 max user processes 为 1024

\#ulimit -n

1024

\#ulimit –u

1024

问题描述： 说明 server 只允许同时打开 1024 个文件，处理 1024 个用户进程

使用ulimit -a 可以查看当前系统的所有限制值，使用ulimit -n 可以查看当前的最大打开文件数。

新装的linux 默认只有1024 ，当作负载较大的服务器时，很容易遇到error: too many open files 。因此，需要将其改大。

解决方法：

使用 ulimit –n 65535 可即时修改，但重启后就无效了。（注ulimit -SHn 65535 等效 ulimit -n 65535 ，-S 指soft ，-H 指hard)

### 修改方式

有如下三种修改方式：

1.  在/etc/rc.local 中增加一行 ulimit -SHn 65535

2.  在/etc/profile 中增加一行 ulimit -SHn 65535

3.  在/etc/security/limits.conf 最后增加:

    ```
    * soft nofile 65535
    * hard nofile 65535
    * soft nproc 65535
    * hard nproc 65535
    ```

具体使用哪种，在 CentOS 中使用第1 种方式无效果，使用第3 种方式有效果，而在Debian 中使用第2 种有效果

\# ulimit -n

65535

\# ulimit -u

65535

备注：ulimit 命令本身就有分软硬设置，加-H 就是硬，加-S 就是软默认显示的是软限制

soft 限制指的是当前系统生效的设置值。 hard 限制值可以被普通用户降低。但是不能增加。 soft 限制不能设置的比 hard 限制更高。 只有 root 用户才能够增加 hard 限制值。
