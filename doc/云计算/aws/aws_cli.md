# 目录

* [AWS CLI](#aws-cli)
	* [安装](#安装)
	* [配置](#配置)
		* [配置多用户](#配置多用户)
		* [环境变量](#环境变量)
	* [命令行参数](#命令行参数)
* [saws工具](#saws工具)
	* [s3](#s3)
		* [上传文件](#上传文件)
		* [下载文件](#下载文件)

# AWS CLI

AWS CLI 是 AWS 提供的命令行工具，使用 Python 开发支持 Python 2.6.5 以上绝大多数
Python 版本。


## 安装

在 Unix/Linux 平台安装 AWS CLI 建议使用 pip：

```sh
pip install aws-cli
```

注意这里是"aws-cli"而不是"aws"

个人还推荐一个叫做 saws 的 aws-cli 封装包，提供了强大的命令补全功能：

```sh
pip install saws
```


## 配置

在使用 aws-cli 之前，你首先需要配置好个人身份信息以及偏好区域。
配置个人身份信息前还需要注册 AWS ISM，并为自己的身份授予对应的权限。

AWS 的配置文件分 config 和 credentials，默认存储在 ~/.aws 目录中，格式如下：

```ini
# ~/.aws/credentials
[default]
aws_access_key_id=XXXXXXXXXXXXXXXXXXXX
aws_secret_access_key=XXXXXXXXXXXXXXXXXXXX
[user1]
aws_access_key_id=XXXXXXXXXXXXXXXXXXXX
aws_secret_access_key=XXXXXXXXXXXXXXXXXXXX
```

```ini
# ~/.aws/config
[default]
region=cn-north-1
output=json
[user1]
region=us-west-2
output=text
```

参数解释：

- ``aws_access_key_id``：AWS 访问密钥。
- ``aws_secret_access_key``：AWS 私有密钥。
- ``aws_session_token``：AWS 会话令牌。只有在使用临时安全证书时才需要会话令牌。
- ``region``：AWS 区域。
- ``output``：输出格式（json、text 或 table）


### 配置多用户


### 环境变量

AWS CLI 支持以下变量：

- ``AWS_ACCESS_KEY_ID``：AWS 访问密钥。
- ``AWS_SECRET_ACCESS_KEY``：AWS 私有密钥。访问和私有密钥变量会覆盖证书和 config 文件中存储的证书。
- ``AWS_SESSION_TOKEN``：会话令牌。只有在使用临时安全证书时才需要会话令牌。
- ``AWS_DEFAULT_REGION``：AWS 区域。如果设置，此变量会覆盖正在使用的配置文件的默认区域。
- ``AWS_DEFAULT_PROFILE``：要使用的 CLI 配置文件的名称。可以是存储在证书或 config 文件中的配置文件的名称，也可以是 default，后者使用默认配置文件。
- ``AWS_CONFIG_FILE``：CLI config 文件的路径。


## 命令行参数


参考：[AWS 官方文档](http://docs.aws.amazon.com/zh_cn/cli/latest/userguide/cli-chap-getting-started.html)


# saws工具

## s3

### 上传文件

前提:aws的配置中的访问密钥对s3 的某bucket-name有权限

输入saws后输入

```
saws>aws s3api put-object --body /root/start.sh --bucket bucket-name --key "start.sh"
{
    "ETag": "\"2bdd5dd11b4273cfb0a807539325xxx\""
}

```

### 下载文件

前提:aws的配置中的访问密钥对s3 的某bucket-name有权限

输入saws后输入

```
saws>aws s3api get-object --bucket "saas-kuaipan" --key "start.sh" /root/start.sh2"
{
    "AcceptRanges": "bytes",
    "ContentType": "binary/octet-stream",
    "LastModified": "Thu, 13 Oct 2016 02:55:48 GMT",
    "ContentLength": 241,
    "ETag": "\"2bdd5dd11b4273cfb0a807539325xxx\"",
    "Metadata": {}
}
```
