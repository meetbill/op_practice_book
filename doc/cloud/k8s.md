## K8s

<!-- vim-markdown-toc GFM -->

* [Kubernetes 概述](#kubernetes-概述)
    * [简介](#简介)
    * [特性](#特性)
* [Kubernetes 设计架构](#kubernetes-设计架构)
    * [官网体验教程](#官网体验教程)
* [重要概念](#重要概念)

<!-- vim-markdown-toc -->
## Kubernetes 概述

### 简介
Kubernetes 是一个开源的，用于管理云平台中多个主机上的容器化的应用，Kubernetes 的目标是让部署容器化的应用简单并且高效（powerful）,Kubernetes 提供了应用部署，规划，更新，维护的一种机制。

### 特性

> * 服务发现和负载均衡
> * 自我修复 - 重新启动失败的容器
> * 横向缩放 - 使用简单的命令或 UI，或者根据 CPU 的使用情况自动调整应用程序副本数
> * 自动部署和回滚
> * 密钥和配置管理 - 部署和更新密钥和应用程序配置，不会重新编译镜像，不会暴露
> * 更多

## Kubernetes 设计架构

Kubernetes 集群包含有节点代理 kubelet 和 Master 组件 (APIs, scheduler, etc)，一切都基于分布式的存储系统。下面这张图是 Kubernetes 的架构图。

![Screenshot](../../images/aws/k8s_arch.jpg)

k8s 全景简图

![Screenshot](../../images/aws/k8s_arch_simple.png)

### 官网体验教程

https://kubernetes.io/docs/tutorials/kubernetes-basics/

官网通过如下 6 部分来实践如何玩转 k8s

> * 创建 k8s 集群
> * 部署应用
> * 内部访问应用
> * 外部访问应用
> * Scale 应用
> * 滚动更新

## 重要概念

> * Cluster : 计算，存储和网络资源的集合，K8s 利用这些资源运行各种基于容器的应用
>   * 比如在百度 CCE 上首先需要创建个集群（购买 N 台 BCC 实例时，实际后台是创建了 N+3 实例，其中 3 台用于创建 Master 节点）
> * Master : 主要负责调度，决定应用放在哪里运行
> * Node ：Node 的职责是运行容器应用。
>   * Node 由 Master 管理，Node 负责监控并汇报容器的状态
>   * 根据 Master 的要求管理容器的生命周期
> * Pod ：K8s 的最小工作单元。每个 Pod 包含一个或者多个容器。
>   * Pod 中的容器会作为一个整体被 Master 调度到一个 Node 上运行
> * Controller : K8s 通过 Controller 来管理 Pod，Controller 定义了 Pod 的部署特性：
>   * Deployment
>   * ReplicaSet
>   * DaemonSet
>   * StatefuleSet
>   * Job
> * Service：定义了外界访问一组 Pod 的方式
>   * ClusterIP
>   * NodePort
>   * LoadBalancer
> * Namespace
>   * 多个用于或者项目可以使用同一个 cluster ,然后使用不同的 Namespace
>   * --namespace=name名





