# 什么是 RAID


<!-- vim-markdown-toc GFM -->
* [简介](#简介)
    * [RAID 动画演示](#raid-动画演示)
* [RAID 分类](#raid-分类)
    * [RAID 0(striped)](#raid-0striped)
    * [RAID 1(mirroring)](#raid-1mirroring)
    * [RAID5 分布式奇偶校验的独立磁盘结构](#raid5-分布式奇偶校验的独立磁盘结构)
    * [RAID0+1/1+0](#raid0110)
* [megacli 管理工具](#megacli-管理工具)
* [raid 日常运维](#raid-日常运维)
    * [查看 raid 信息](#查看-raid-信息)
    * [更换硬盘时需要注意地方](#更换硬盘时需要注意地方)
    * [RAID5 单块硬盘故障恢复方法：](#raid5-单块硬盘故障恢复方法)

<!-- vim-markdown-toc -->

# 简介
RAID, Redundant Arrays of Inexpensive Disks, 容错式廉价磁盘阵列.RAID 的基本原理是把多个便宜的小磁盘组合到一起，成为一个磁盘组，使性能达到或超过一个容量巨大、价格昂贵的磁盘。目前 RAID 技术大致分为两种：基于硬件的 RAID 技术和基于软件的 RAID 技术。其中在 Linux 下通过自带的软件就能实现 RAID 功能，这样便可省去购买昂贵的硬件 RAID 控制器和附件就能极大地增强磁盘的 IO 性能和可靠性。由于是用软件去实现的 RAID 功能，所以它配置灵活、管理方便。同时使用软件 RAID，还可以实现将几个物理磁盘合并成一个更大的虚拟设备，从而达到性能改进和数据冗余的目的。当然基于硬件的 RAID 解决方案比基于软件 RAID 技术在使用性能和服务性能上稍胜一筹，具体表现在检测和修复多位错误的能力、错误磁盘自动检测和阵列重建等方面。

## RAID 动画演示

[RAID 动画演示下载](https://raw.githubusercontent.com/BillWang139967/op_practice_code/master/store/RAID/raid.exe)

# RAID 分类

常用的 RAID RAID0/RAID1/RAID5/RAID10

| 级别   |     优点      |     缺点|
|------------|----------|---------|
|RAID 0 | 存取速度最快 | 没有容错 |
|RAID 1 | 完全容错 | 成本高 |
|RAID 5 | 多任务可容错 | 写入时有 overhead |
|RAID 0+1/RAID 10 | 速度快，完全容错，成本高 |


## RAID 0(striped)

![raid-0 图解](../../images/raid/raid-0.png)

Striped 模式，把连续的数据分散懂啊多个磁盘上存取。速度快，但是没有冗余。

## RAID 1(mirroring)

![raid-1 图解](../../images/raid/raid-1.png)

RAID 1 可以用于两个或 2xN 个磁盘，并使用 0 块或更多的备用磁盘，每次写数据时会同时写入镜像盘。这种阵列可靠性很高，但其有效容量减小到总容量的一半，同时这些磁盘的大小应该相等，否则总容量只具有最小磁盘的大小。

## RAID5 分布式奇偶校验的独立磁盘结构

![raid-5 图解](../../images/raid/raid-5.png)

## RAID0+1/1+0

raid0 over raid1

# megacli 管理工具

[megacli_tui](https://github.com/BillWang139967/megacli_tui)

# raid 日常运维
## 查看 raid 信息

    dmesg | grep -i raid

## 更换硬盘时需要注意地方

    (1) 更换损坏硬盘前，必须查看阵列的当前状态，保证除损坏的硬盘外，其他硬盘处于正常的 ONLINE 状态
    (2) 更换硬盘必须及时
    (3) 更换的新硬盘必须是完好的
    (4) 在阵列数据重建完成之前，不能插拔任何硬盘

## RAID5 单块硬盘故障恢复方法：

    单个硬盘失效，我们通过热插拔拔下来再插上去。如热插拔没用在进入 RAID 配置界面，将该硬盘进行 ForceOnLine 操作。还可以通过更换其它硬盘插槽，切记不要打乱磁盘顺序。如果上面操作不能解决问题，尝试将该硬盘格式化后插入，然后使用 ReBuild 操作。在这过程中可能会遇到不能格式化现象，这是因为硬盘物理错误严重，应该更换硬盘后重建数据来解决问题。
