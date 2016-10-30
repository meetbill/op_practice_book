# Docker

[返回主目录](../../SUMMARY.md)

## Docker 基础
* Docker 三大核心概念
    - 镜像 Image
    - 容器 Container
    - 仓库 Repository

* 命令
    - `docker inspect` IMAGE-ID
        + 返回JSON 格式信息
    - 导入导出镜像
        + `docker save -o` image.tar image
        + `docker load <` image.tar
    - 导入导出容器
        + `docker export` abc > new_container
        + `docker import`
