# zabbix

[返回主目录](../../SUMMARY.md)

## 快速安装
### server端
```
#git clone https://github.com/BillWang139967/zabbix_install.git
#cd zabbix_install/zabbix3.0.4/server
#sh zabbix_server.sh
```
### agent端
```
#curl -o zabbix_agent.sh "https://raw.githubusercontent.com/BillWang139967/zabbix_install/master/zabbix3.0.4/agent/zabbix_agent.sh"
#sh zabbix_agent.sh
```
安装agent时需要输入server端IP

安装zabbix_agent时会自动将iptables关闭，同样也可以如下设置:

```
#vim /etc/sysconfig/iptables  
-A INPUT -m state --state NEW -m tcp -p tcp --dport 10050 -j ACCEPT  
```

