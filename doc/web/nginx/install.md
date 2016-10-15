# 安装

安装 Nginx 之前，确保系统已经安装 gcc、openssl-devel、pcre-devel 和 zlib-devel软件库

* gcc、openssl-devel、zlib-devel可以通过光盘直接选择安装
* pcre-devel 安装pcre库是为了使Nginx支持HTTP Rewrite模块

## Install

```
#wget http://nginx.org/download/nginx-1.8.0.tar.gz 
#tar xzvf nginx-1.8.0.tar.gz
#cd nginx-1.8.0
# ./configure --prefix=/opt/X_nginx/nginx
#make && sudo make install
```
