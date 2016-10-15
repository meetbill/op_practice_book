# Nginx服务器架构

## 模块化结构

> Nginx 服务器的开发`完全`遵循模块化设计思想

### 什么是模块化开发？

1. 单一职责原则，一个模块只负责一个功能
2. 将程序分解，自顶向下，逐步求精
3. 高内聚，低耦合

### Nginx的模块化结构

+ 核心模块:         Nginx最基本最核心的服务，如进程管理、权限控制、日志记录；
+ 标准HTTP模块:     Nginx服务器的标准HTTP功能；
+ 可选HTTP模块:     处理特殊的HTTP请求
+ 邮件服务模块:     邮件服务
+ 第三方模块:       作为扩展，完成特殊功能


## Nginx的模块清单

+ 核心模块
    - ngx_core
    - ngx_errlog
    - ngx_conf
    - ngx_events
    - ngx_event_core
    - ngx_epll
    - ngx_regex

+ 标准HTTP模块
    - ngx_http
    - ngx_http_core             #配置端口，URI分析，服务器相应错误处理，别名控制(alias)等
    - ngx_http_log              #自定义access日志
    - ngx_http_upstream         #定义一组服务器，可以接受来自proxy, Fastcgi,Memcache的重定向；主要用作负载均衡
    - ngx_http_static
    - ngx_http_autoindex        #自动生成目录列表
    - ngx_http_index            #处理以`/`结尾的请求，如果没有找到index页，则看是否开启了`random_index`；如开启，则用之，否则用autoindex
    - ngx_http_auth_basic       #基于http的身份认证(auth_basic)
    - ngx_http_access           #基于IP地址的访问控制(deny,allow)
    - ngx_http_limit_conn       #限制来自客户端的连接的响应和处理速率
    - ngx_http_limit_req        #限制来自客户端的请求的响应和处理速率
    - ngx_http_geo
    - ngx_http_map              #创建任意的键值对变量
    - ngx_http_split_clients
    - ngx_http_referer          #过滤HTTP头中Referer为空的对象
    - ngx_http_rewrite          #通过正则表达式重定向请求
    - ngx_http_proxy
    - ngx_http_fastcgi          #支持fastcgi
    - ngx_http_uwsgi
    - ngx_http_scgi
    - ngx_http_memcached
    - ngx_http_empty_gif        #从内存创建一个1×1的透明gif图片，可以快速调用
    - ngx_http_browser          #解析http请求头部的User-Agent 值
    - ngx_http_charset          #指定网页编码
    - ngx_http_upstream_ip_hash
    - ngx_http_upstream_least_conn
    - ngx_http_upstream_keepalive
    - ngx_http_write_filter
    - ngx_http_header_filter
    - ngx_http_chunked_filter
    - ngx_http_range_header
    - ngx_http_gzip_filter
    - ngx_http_postpone_filter
    - ngx_http_ssi_filter
    - ngx_http_charset_filter
    - ngx_http_userid_filter
    - ngx_http_headers_filter   #设置http响应头
    - ngx_http_copy_filter
    - ngx_http_range_body_filter
    - ngx_http_not_modified_filter

+ 可选HTTP模块
    - ngx_http_addition         #在响应请求的页面开始或者结尾添加文本信息
    - ngx_http_degradation      #在低内存的情况下允许服务器返回444或者204错误
    - ngx_http_perl
    - ngx_http_flv              #支持将Flash多媒体信息按照流文件传输，可以根据客户端指定的开始位置返回Flash
    - ngx_http_geoip            #支持解析基于GeoIP数据库的客户端请求
    - ngx_google_perftools
    - ngx_http_gzip             #gzip压缩请求的响应
    - ngx_http_gzip_static      #搜索并使用预压缩的以.gz为后缀的文件代替一般文件响应客户端请求
    - ngx_http_image_filter     #支持改变png，jpeg，gif图片的尺寸和旋转方向
    - ngx_http_mp4              #支持.mp4,.m4v,.m4a等多媒体信息按照流文件传输，常与ngx_http_flv一起使用
    - ngx_http_random_index     #当收到/结尾的请求时，在指定目录下随机选择一个文件作为index
    - ngx_http_secure_link      #支持对请求链接的有效性检查
    - ngx_http_ssl              #支持https
    - ngx_http_stub_status
    - ngx_http_sub_module       #使用指定的字符串替换响应中的信息
    - ngx_http_dav              #支持HTTP和WebDAV协议中的PUT/DELETE/MKCOL/COPY/MOVE方法
    - ngx_http_xslt             #将XML响应信息使用XSLT进行转换

+ 邮件服务模块
    - ngx_mail_core
    - ngx_mail_pop3
    - ngx_mail_imap
    - ngx_mail_smtp
    - ngx_mail_auth_http
    - ngx_mail_proxy
    - ngx_mail_ssl

+ 第三方模块
    - echo-nginx-module         #支持在nginx配置文件中使用echo/sleep/time/exec等类Shell命令
    - memc-nginx-module
    - rds-json-nginx-module     #使nginx支持json数据的处理
    - lua-nginx-module

# Nginx的web请求处理机制

作为服务器软件，必须具备并行处理多个客户端的请求的能力， 工作方式主要以下3种：

+ 多进程(Apache)
    - 优点: 设计和实现简单；子进程独立
    - 缺点: 生成一个子进程要内存复制, 在资源和时间上造成额外开销
+ 多线程(IIS)
    - 优点: 开销小
    - 缺点: 开发者自己要对内存进行管理;线程之间会相互影响
+ 异步方式(Nginx)

经常说道异步非阻塞这个概念， 包含两层含义：

通信模式：
    + 同步: 发送方发送完请求后，等待并接受对方的回应后，再发送下个请求
    + 异步: 发送方发送完请求后，不必等待，直接发送下个请求

# Nginx的事件驱动模型

