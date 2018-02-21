## 物理机常见问题即处理方法

<!-- vim-markdown-toc GFM -->
* [开机无法启动](#开机无法启动)
    * [提示无法找到系统盘](#提示无法找到系统盘)
        * [场景](#场景)
        * [重做引导项方法](#重做引导项方法)

<!-- vim-markdown-toc -->

## 开机无法启动

### 提示无法找到系统盘

#### 场景

**现象**
```
Reboot and select proper boot device or insert boot media in selected boot device and press a key
```
**可能原因**

先排查硬件原因 ---> 再排查软件原因

**硬件原因**

> * RAID 卡（可以开机时查看 RAID 卡 能否识别到硬盘）
> * 硬盘（硬盘状态灯是否正常）

**软件原因**

> * 开机启动项顺序
> * RAID 卡设置的启动盘配置
> * 引导项丢失

#### 重做引导项方法

> * 插入光盘进入救援模式（选择完英文等，选择 continue 进入救援模式）
> * chroot /mnt/sysimage
> * /sbin/grub-install /dev/sda(sda 是系统所在的设备）
> * 多系统加引导项的话可以添加到 /boot/grub/grub.conf
> * 重启服务器
