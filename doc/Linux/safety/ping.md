## 禁止ping

禁止系统响应任何从外部/内部来的ping请求攻击者一般首先通过ping命令检测此主机或者IP是否处于活动状态
，如果能够ping通某个主机或者IP，那么攻击者就认为此系统处于活动状态，继而进行攻击或破坏。如果没有人能ping通机器并收到响应，那么就可以大大增强服务器的安全
性，linux下可以执行如下设置，禁止ping请求：
```
[root@localhost ~]#echo "1"> /proc/sys/net/ipv4/icmp_echo_ignore_all
```
默认情况下"icmp_echo_ignore_all"的值为"0"，表示响应ping操作。

可以加上面的一行命令到/etc/rc.d/rc.local文件中，以使每次系统重启后自动运行
