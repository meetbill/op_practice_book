# 使用 AWS S3

S3 是 Simple Storage Service 的缩写，是 AWS 提供的云存储服务，价格公道、服务稳定，因此被广泛应用在静态文件存储、内容备份、大数据分析领域。


## 基本概念

在使用 S3 前首先需要了解一些基本概念：

- 对象：即文件。
- Bucket：官方翻译为存储桶，是在网络存储服务中广泛使用的一个概念，通常用于区分文件所在区域，可以对比操作系统不同盘符来理解。
- AWS CLI：AWS 提供的控制台工具，aws-cli 是其在 PyPI 上注册的名字，shell 中的命令为 ``aws``。
- [AWS IAM](./aws_IAM.md)：即 Identity and Access Management，是 AWS 的身份认证服务，用于对用户身份及资源进行授权管理，需要配置号已授权的 AWS 认证信息才可以使用其服务。
- S3 资源：S3 资源以 ``s3://bucket-name/`` 开始。


## 基本操作

### 创建以及管理 Bucket

就像你首先需要有硬盘以及挂载盘符才能在本地操作文件一样，正式使用 S3
提供服务前你同样需要准备好 Bucket：

    aws s3 mb s3://bucket-name

Bucket 名称必须唯一，并且应符合 DNS 标准：可以包含小写字母、数字、连字符（-）和点号（.），
只能以字母或数字开头和结尾，连字符或点号后不能跟点号。

想要列出以创建的 Bucket 可以使用 ls 命令：

```
$ aws s3 ls
       CreationTime Bucket
       ------------ ------
2015-11-11 11:11:11 my-bucket
2015-11-11 11:11:11 my-bucket1
```

删除空 Bucket 可以使用 ``aws s3 rb s3://bucket-name``，非空 Bucket 需要加上 ``--force``
命令，这一点对于管理文件对象也是一样。

``mb``、``rb`` 命令分别是 ``MakeBucket`` 和 ``RemoveBucket`` 的缩写。

### 操作文件

S3 的服务基于文件对象，提供了类似 Linux 环境下的文件访问操作：

```
aws s3 ls s3://bucket-name[/folder]/
aws s3 cp s3://bucket-name/file s3://bucket-name[/folder]/
aws s3 mv s3://bucket-name/file s3://bucket-name[/folder]/
aws s3 rm s3://bucket-name/file
aws s3 rm s3://bucket-name[/folder]/ --recursive
```

操作文件的方式基本上和 Linux 环境类似，``--recursive`` 用于递归调用，类似 Linux 命令的
``-r`` 参数。

### 同步本地文件、目录

AWS CLI 还提供了一个本地文件同步命令 ``sync``：

    aws s3 sync local_dir s3://my-bucket/MyFolder

``sync`` 会递归地将本地文件复制到 S3 Bucket 中，如存在重名文件则覆盖处理。
如果需要像同步盘一样删除已不存在的文件可以加上 ``--delete`` 命令。

``sync`` 还可以通过 ``--exclude`` 和 ``--include`` 来指定不同步的目录，以及不同步的目录中的例外。

### 权限控制

默认情况下，所有 Amazon S3 资源都是私有的，包括存储桶、对象和相关子资源（例如，lifecycle 配置和 website 配置）。只有资源拥有者，即***创建该资源的 AWS 账户***可以访问该资源。资源拥有者可以选择通过编写访问策略授予他人访问权限

Amazon S3 提供的访问策略

> * 基于资源的策略-------存储桶策略和访问控制列表 (ACL – 注:每个存储桶和对象都有关联的 ACL)
> * 基于用户策略------使用 IAM 管理, IAM用户必须拥有两种权限：一种权限来自其父账户，另一种权限来自要访问的资源的拥有者AWS 账户。


## 实际应用

### 每天凌晨备份 Postgres 数据库

```sh
pg_dump -Fc --no-owner  bxzz_exercise > /tmp/tmp.pgdump && aws s3 cp tmp.pgdump s3://filebackup/pg/$(date +%Y/%m/%d).pgdump
```

crontab 设置：

```
0 2 * * * pg_dump -Fc --no-owner  bxzz_exercise > /tmp/tmp.pgdump && aws s3 cp tmp.pgdump s3://filebackup/pg/$(date +\%Y/\%m/\%d).pgdump
```

### 将 S3 当作同步盘

检测到文件变动时触发：

    aws s3 sync . s3://my-bucket/MyFolder --exclude '*.txt' --include 'MyFile*.txt' --exclude 'MyFile?.txt'


参考：[AWS S3 官方中文文档](http://docs.aws.amazon.com/zh_cn/cli/latest/userguide/using-s3-commands.html)


