# 简单介绍 AWS

国内云服务参差不齐，国外却是一片欣欣向荣，曾经的 IaaS AWS 已经逐步将它的触手扩展开来，渗透进不同的领域，
在 IaaS、PaaS、SaaS、DaaS 领域均有涉及，现在已经是国外创业者的首选平台。
Hacker News 上有一篇评分非常高的一个 AWS 介绍文章叫做[《Amazon Web Services
in Plain English》](https://www.expeditedssl.com/aws-in-plain-english)，这里简单做一下搬运。


## 基本服务

如果你要使用 AWS，那么基本上是离不开这些服务的。

### EC2

EC2 是 AWS 的虚拟服务器服务，基本上可以对比 Linode 之类的 VPS 服务。

### IAM

IAM 是 AWS 的密钥管理服务，管理的对象包括用户、密钥、证书以及安全策略。

### S3

AWS 的存储服务，使用上略有不同，但是可以简单对比 FTP 服务。

### VPC

### Lambda

AWS 脚本运行器。通常用来运行离线脚本，可以把偶而使用的非常耗费资源的服务在这里运行，可以完全和线上服务隔离开来。

也可以用于 S3 或者 DynamoDB 的触发服务。


## web 服务

对于部署 web 应用非常有用的服务。

### API Gateway

可以理解为 API Proxy。

### RDS

Amazon SQL，云数据库服务。支持 MySQL、Postgres 和 Oracle。

### Route53

DNS 和 域名服务。

### SES

邮件分发服务。通常用于发送一次性的邮件，比如密码重置邮件。

### Cloudfront

CDN 服务。

### CloudSearch

全文搜索服务。可以配合 S3 和 RDS 使用。

### DynamoDB

Amazon 自己的 NoSQL。

### Elasticache

基于 Memcached 或者 Redis 提供 web 缓存服务。

### Elastic Transcoder

云转码服务。提供在线视频转码、压缩等等。

### SQS

消息队列服务。相当于一个在线的 RabbitMQ 服务。

### WAF

防火墙。配合 Cloudfront 阻止恶意请求。


## 移动应用服务

### Cognito

OAuth 服务提供 Google/Facebook 联合登录功能。

### Device Farm

提供 iOS 和 Android 设备云测试的服务。

### Mobile Analytics

记录用户应用行为用于分析。

### SNS

提供通知信息、Email 或者 SMS 短信推送。


## 运维、部署服务

### CodeCommit

版本控制服务。

### Code Deploy

将 CodeCommit 中代码部署到 EC2 中。

### CodePipeline

持续集成服务。自动测试项目，并根据测试结果执行指定任务。

### EC2 Container Service

Docker 服务。

### Elastic Beanstalk

PaaS。


## 企业服务

企业应用相关服务。

### AppStream

远程应用接入，似乎只支持 Windows 程序。



## 大数据服务

大数据分析、处理相关的专用服务。



## AWS 服务管理

使用了众多 AWS 服务后你还需要这些服务来配置和管理它们。


