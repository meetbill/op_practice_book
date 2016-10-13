#Amazon_IAM(身份及访问管理)

IAM enables you to control who can do what in your AWS account.

- 
## 存储桶策略示例

创建存储桶后需要创建个IAM用户和关联下权限

### 创建个权限:可以对某个存储桶有所有权限

```
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:ListAllMyBuckets"
            ],
            "Resource": "arn:aws-cn:s3:::*"
        },
        {
            "Effect": "Allow",
            "Action": "s3:*",
            "Resource": [
                "arn:aws-cn:s3:::backet-name/*"
             ]
        }
   ]
}
```
注:Amazon 资源名称 (ARN) 和 AWS 服务命名空间

arn:partition:service:region:account-id:resource

partition: 资源所处的分区。对于标准 AWS 区域，分区是 aws。如果资源位于其他分区，则分区是 aws-partitionname。例如，位于 中国（北京） 区域的资源的分区为 aws-cn。
