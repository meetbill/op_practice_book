## 架设简单文件服务器

将 /data/public/ 目录下的文件通过 nginx 提供给外部访问
```
#mkdir /data/public/
#chmod 777 /data/public/
```
```
worker_processes 1;
error_log logs/error.log info;
events {
    use epoll;
}
http {
     
    server {
            # 监听 8080 端口
            listen 8080;
            location /share/ {
                        # 打开自动列表功能，通常关闭
                        autoindex on;
                        # 将 /share/ 路径映射至 /data/public/，请保证 nginx 进程有权限访问 /data/public/
                        alias /data/public/;
                    }
       }
}
```
