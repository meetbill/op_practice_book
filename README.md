## 目录

* 点击可直接查看-[运维实践手册](SUMMARY.md)
* [需要安装](#需要安装)
* [使用方式](#使用方式)
* [文档规范](#文档规范)
	* [文档章节的划分](#文档章节的划分)
	* [各种信息](#各种信息)
	* [内容相关](#内容相关)
* [参加步骤](#参加步骤)
* [小额捐款](#小额捐款)

# 需要安装
+ git
+ pandoc---将md文件转为html工具
+ python

# 使用方式

1. `git clone https://github.com/BillWang139967/op_practice_book.git`
2. `./run_web.sh`

运行run_web后，可以在本地输入http://IP:8000进行html访问本地书籍

# 文档规范


## 文档章节的划分

1. 原则上，不超过三级标题，如有需要，可以根据需要扩展。
1. 目录结构如下：

  ```
  文档1----第一章--1.1--1.1.1
    |        |      |---1.1.2
    |        |      |---1.2.3
    |        |-----1.2--1.2.1
    |        |      |---1.2.2
    |------第二章--2.1--2.1.1
    |        |      |---2.1.2
    |        |-----2.2--2.2.1
    |        |      |
    |        |-----2.3--2.3.1
  文档2----第一章--1.1--1.1.1
    |        |      |---1.1.2
    |        |-----1.2--1.2.1
    |------第二章--1.1--1.1.1
    |------第三章--1.1--1.1.1
  ```

  其中，每个文档中包含一个 **SUMMARY.md** 文件，将目录写入其中。

1. 按照如上的目录结构，最终以文件形式存在的是二级目录和三级目录。

> **标题约定**:
>
> `# 一级标题`</br>
> `## 二级标题`</br>
> `### 三级标题`</br>
> 以此类推。

## 各种信息

1. 提示信息分为：注意、重要、警告。

  * 注意：对目前任务的提示、捷径或者备选的解决方法。忽略提示不会造成负面后果，但可能会错过一个更省事的诀窍。
  * 重要：重要框中的内容是那些容易错过的事情。配置更改只可用于当前会话，或者在应用更新前要重启的服务。忽略"重要"框中的内容不会造成数据丢失但可能会让您抓狂。
  * 警告：警告是不应被忽略的。忽略警告信息很可能导致数据丢失。

1. 三种提示信息的书写方法：

  ```
  > ###### 注意
  > 注意的内容
  ```
  ```
  > #### 重要
  > 重要的内容
  ```
  ```
  > ## 警告
  > 警告的内容
  ```

  效果如下：

  > ###### 注意
  > 注意的内容

  > #### 重要
  > 重要的内容

  > ## 警告
  > 警告的内容


## 内容相关

1. 需要高亮的内容如下：

  * 所需要修改的配置文件，如：

    修改配置文件 `/etc/nova/nova.conf`。

    * 书写方法如下：

        ```
修改配置文件 `/etc/nova/nova.conf`。
        ```

  * 所需要修改的字段，如：

    修改配置文件中的 `auth_url`。

    * 书写方法如下：

        ```
修改配置文件中的 `auth_url`。
        ```

  * 要执行的命令，如：

    执行命令 `nova list`。

    或

    执行如下命令：

      ```
      # nova list
      ```

    * 书写方法如下：

        ```
      执行命令 `nova list`。

      或

      执行如下命令：

          ```
        # nova list
          ```
        ```

  * 代码，如：

    代码如下：

    ```python
    # @file setup.py
    from setuptools import setup

    setup(
        # Other keywords
        entry_points={
            'foo': [
                'add = add:make',
                'remove = remove:make',
                'update = update:make',
            ],
        }
    )
    ```

    * 书写方法如下：

        ```
        代码如下：

            ```python
            # @file setup.py
            from setuptools import setup

            setup(
                # Other keywords
                entry_points={
                    'foo': [
                        'add = add:make',
                        'remove = remove:make',
                        'update = update:make',
                    ],
                }
            )
            ```
        ```

1. 界面相关

  描述界面选项卡或按键时，使用【】，如：

  ```
  选择【项目】，点击【概况】选项卡，可以查看项目的概况信息。
  ```

1. 加粗或斜体

  * 加粗：某个命令的名称，如：

    可以使用 **nova** 命令进行操作。（注意与上文的**执行命令**区分）

    * 书写方法如下：

      ```
      可以使用 **nova** 命令进行操作。
      ```

  * 斜体：描述某个命令的参数或需要替换的字段时，如：

    **nova** 命令的 *--debug* 参数用于......

    将其中的 *NOVA_PASS* 替换为 nova 用户的密码。

      * 书写方法如下：

        ```
        **nova** 命令的 *--debug* 参数用于......
        ```
        ```
        将其中的 *NOVA_PASS* 替换为 nova 用户的密码。
        ```

  > **注**：其他时候可以根据需要加粗或写为斜体，另：加粗并斜体的书写方法为 `***--debug***`。

1. 参见的书写

  有时需要一些参考内容，书写为：

  **参见**

    [Google](http://www.google.com)

  * 书写方法如下：

    ```
    **参见**

      [Google](http://www.google.com)
    ```

1. 图片的插入

  有时需要插入一些图片进行说明，书写为：

  ```
  ![图片名称](图片链接)

  > **图片名称**

  ```

1. 过程的书写

  需要描述一些过程时，书写如下：

  ```

  > **过程**：过程名称

  1. xxx(第一步)

    1. xxx(第一步的第一个小步骤)

  1. xxx(第二步)

  1. xxx(第三步)

  ```

1. 表格的书写

  使用到表格时，书写如下：

  ```
  > **表格**：表格标题

  |第一列|第二列|第三列|
  |------|------|------|
  | 内容 | 内容 | 内容 |

  ```

  效果如下：

  > **表格**：表格标题

  |第一列|第二列|第三列|
  |------|------|------|
  | 内容 | 内容 | 内容 |

# 参加步骤

* 在 GitHub 上 `fork` 到自己的仓库，然后 `clone` 到本地，并设置用户信息。
```
$ git clone https://github.com/BillWang139967/op_practice_book.git
$ cd op_practice_book
$ git config user.name "yourname"
$ git config user.email "your email"
```
* 修改代码后提交，并推送到自己的仓库。
```
$ #do some change on the content
$ git commit -am "Fix issue #1: change helo to hello"
$ git push
```
* 在 GitHub 网站上提交 pull request。
* 定期使用项目仓库内容更新自己仓库内容。
```
$ git remote add upstream https://github.com/BillWang139967/op_practice_book.git
$ git fetch upstream
$ git checkout master
$ git rebase upstream/master
$ git push -f origin master
```

# 小额捐款

如果你觉得op_practice_book对你有帮助, 可以对作者进行小额捐款(支付宝)

![Screenshot](images/5.jpg)

