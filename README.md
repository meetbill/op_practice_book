## 目录

<!-- vim-markdown-toc GFM -->
* [阅读本书](#阅读本书)
* [相关内容](#相关内容)
    * [下载本书](#下载本书)
    * [本书相关wiki](#本书相关wiki)
    * [本书相关程序](#本书相关程序)
    * [其他](#其他)
* [参加步骤](#参加步骤)
* [小额捐款](#小额捐款)

<!-- vim-markdown-toc -->

# 阅读本书

> * [网上阅读(推荐)](https://billwang139967.gitbooks.io/op_practice_book/content/)
> * [本地阅读](#本地阅读)
> * 本地阅读
```
本地阅读操作

需要安装

+ git
+ pandoc---将md文件转为html工具
+ python

1. `git clone https://github.com/BillWang139967/op_practice_book.git`
2. `./run_web.sh`

运行run_web后，可以在本地输入http://IP:8000进行html访问本地书籍
```
# 相关内容

## 下载本书

[下载本书(pdf)](https://www.gitbook.com/download/pdf/book/billwang139967/op_practice_book)

## 本书相关wiki

[wiki](https://github.com/BillWang139967/op_practice_book/wiki)

## 本书相关程序

[相关程序下载](https://github.com/BillWang139967/op_practice_code)

## 其他

> * 中文排版使用的 vim(https://github.com/BillWang139967/Vim) Pangu 插件一键排版
> * 文档目录使用的 vim(https://github.com/BillWang139967/Vim) GenTocGFM 插件一键生成目录，只需第一次生成目录，后续文档在保存时会自动更新目录

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

