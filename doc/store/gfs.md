# GFS

* [特殊的应用场景](#特殊的应用场景)
	* [分布式文件系统的要求](#分布式文件系统的要求)
	* [GFS基于的假设](#gfs基于的假设)
* [架构](#架构)
	* [Chunk大小](#chunk大小)
	* [Metadata](#metadata)
	* [Operation Log](#operation-log)
	* [容错机制](#容错机制)
		* [Master 容错](#master-容错)
	* [一致性模型](#一致性模型)
	* [Lease机制](#lease机制)
	* [版本号](#版本号)
	* [负载均衡](#负载均衡)
* [基本操作](#基本操作)
	* [Read](#read)
	* [Overwrite](#overwrite)
	* [Record Append](#record-append)
	* [Snapshot](#snapshot)
	* [Delete](#delete)

## 特殊的应用场景

GFS作为一个分布式的文件系统，
除了要满足一般的文件系统的需求之外，
还根据一些特殊的应用场景（原文反复提到的`application workloads and technological environment`），
来完成整个系统的设计。

### 分布式文件系统的要求

一般的分布式文件系统需要满足以下四个要求：

* Performance：高性能，较低的响应时间，较高的吞吐量
* Scalability: 易于扩展，可以简单地通过增加机器来增大容量
* Reliability: 可靠性，系统尽量不出错误
* Availability: 可用性，系统尽量保持可用

（注：关于reliability和availability的区别，
请参考[这篇](http://unfolding-mirror.blogspot.com/2009/06/reliability-vs-availability.html)）

### GFS基于的假设

基于对实际应用场景的研究，GFS对它的使用场景做出了如下假设：

1. GFS运行在成千上万台便宜的机器上，这意味着节点的故障会经常发生。
必须有一定的容错的机制来应对这些故障。

2. 系统要存储的文件通常都比较大，每个文件大约100MB或者更大，
GB级别的文件也很常见。必须能够有效地处理这样的大文件，
基于这样的大文件进行系统优化。

3. workloads的读操作主要有两种：

    * 大规模的流式读取，通常一次读取数百KB的数据,
    更常见的是一次读取1MB甚至更多的数据。
    来自同一个client的连续操作通常是读取同一个文件中连续的一个区域。

    * 小规模的随机读取，通常是在文件某个随机的位置读取
    几个KB数据。
    对于性能敏感的应用通常把一批随机读任务进行排序然后按照顺序批量读取，
    这样能够避免在通过一个文件来回移动位置。（后面我们将看到，
    这样能够减少获取metadata的次数，也就减少了和master的交互）


4. workloads的写操作主要由大规模的，顺序的append操作构成。
一个文件一旦写好之后，就很少进行改动。因此随机的写操作是很少的，
所以GFS主要针对于append进行优化。

5. 系统必须有合理的机制来处理多个client并发写同一个文件的情况。
文件经常被用于生产者-消费者队列，需要高效地处理多个client的竞争。
正是基于这种特殊的应用场景，GFS实现了一个无锁并发append。

6. 利用高带宽比低延迟更加重要。基于这个假设，
可以把读写的任务分布到各个节点，
尽量保证每个节点的负载均衡，
尽管这样会造成一些请求的延迟。

<!--more-->

## 架构

下面我们来具体看一下GFS的整个架构。

可以看到GFS由三个不同的部分组成，分别是`master`，`client`, `chunkserver`。

> * `master`负责管理整个系统（包括管理metadata，垃圾回收等），一个系统只有一个`master`。
> * `chunkserver`负责保存数据，一个系统有多个`chunkserver`。
> * `client`负责接受应用程序的请求，通过请求`master`和`chunkserver`来完成读写等操作。

由于系统只有一个`master`，`client`对`master`请求只涉及metadata，数据的交互直接与`chunkserver`进行，这样减小了`master`的压力。

一个文件由多个chunk组成，一个chunk会在多个`chunkserver`上存在多个replica。
对于新建文件，目录等操作，只是更改了metadata，
只需要和`master`交互就可以了。注意，与linux的文件系统不同，
目录不再以一个inode的形式保存，也就是它不会作为data被保存在`chunkserver`。
如果要读写文件的文件的内容，就需要`chunkserver`的参与，
`client`根据需要操作文件的偏移量转化为相应的`chunk index`，
向`master`发出请求，`master`根据文件名和`chunk index`，得到一个全局的`chunk handle`，
一个chunk由唯一的一个`chunk handle`所标识，
`master`返回这个`chunk handle`以及拥有这个chunk的`chunkserver`的位置。
（不止一个，一个chunk有多个replica，分布在不同的`chunkserver`。
必要的时候，`master`可能会新建chunk，
并在`chunkserver`准备好了这个chunk的replica之后，才返回）
`client`拿到`chunk handle`和`chunkserver`列表之后，
先把这个信息用文件名和`chunk index`作为key缓存起来，
然后对相应的`chunkserver`发出数据的读写请求。
这只是一个大概的流程，对于具体的操作过程，下面会做分析。

### Chunk大小

Chunk的大小是一个值得考虑的问题。在GFS中，chunk的大小是64MB。
这比普通文件系统的block大小要大很多。
在`chunkserver`上，一个chunk的replica保存成一个文件，
这样，它只占用它所需要的空间，防止空间的浪费。

Chunk拥有较大的大小由如下几个好处:

* 它减少了`client`和`master`交互的次数。
* 减少了网络的开销，由于一个客户端可能对同一个chunk进行操作，
这样可以与`chunkserver`维护一个长TCP连接。
* chunk数目少了，metadata的大小也就小了，这样节省了`master`的内存。

大的chunk size也会带来一个问题，一个小文件可能就只占用一个chunk，
那么如果多个`client`同时操作这个文件的话，就会变成操作同一个chunk，
保存这个chunk的`chunkserver`就会称为一个hotspot。
这样的问题对于小的chunk并不存在，因为如果是小的chunk的话，
一个文件拥有多个chunk，操作同一个文件被分布到多个`chunkserver`.
虽然在实践中，可以通过错开应用的启动的时间来减小同时操作一个文件的可能性。

### Metadata

GFS的`master`保存三种metadata：

1. 文件和chunk的namespace(命名空间) -- 整个文件系统的目录结构以及 chunk 基本信息
2. 文件到chunk的映射
3. 每一个chunk的具体位置

metadata保存在内存中，可以很快地获取。
前面两种metadata会通过operation log来持久化。
第3种信息不用持久化，因为在`master`启动时，
它会问`chunkserver`要chunk的位置信息。
而且chunk的位置也会不断的变化，比如新的`chunkserver`加入。
这些新的位置信息会通过日常的`HeartBeat`消息由`chunkserver`传给`master`。

将metadata保存在内存中能够保证在`master`的日常处理中很快的获取metadata，
为了保证系统的正常运行，`master`必须定时地做一些维护工作，比如清除被删除的chunk，
转移或备份chunk等，这些操作都需要获取metadata。
metadata保存在内存中有一个不好的地方就是能保存的metadata受限于`master`的内存，
不过足够大的chunk size和使用前缀压缩，能够保证metadata占用很少的空间。

对metadata进行修改时，使用锁来控制并发。需要注意的是，对于目录，
获取锁的方式和linux的文件系统有点不太一样。在目录下新建文件，
只获取对这个目录的读锁，而对目录进行snapshot，却对这个目录获取一个写锁。
同时，如果涉及到某个文件，那么要获取所有它的所有上层目录的读锁。
这样的锁有一个好的地方是可以在通过一个目录下同时新建两个文件而不会冲突，
因为它们都是获得对这个目录的读锁。


### Operation Log

Operation log用于持久化存储前两种metadata，这样`master`启动时，
能够根据operation log恢复metadata。同时，可以通过operation log知道metadata修改的顺序，
对于重现并发操作非常有帮助。因此，必须可靠地存储operation log，
只有当operation log已经存储好之后才向`client`返回。
而且，operation log不仅仅只保存在`master`的本地，而且在远程的机器上有备份，
这样，即使`master`出现故障，也可以使用其他的机器做为`master`。

从operation log恢复状态是一个比较耗时的过程，因此，使用checkpoint来减小operation log的大小。
每次恢复时，从checkpoint开始恢复，只处理checkpoint只有的operation log。
在做checkpoint时，新开一个线程进行checkpoint，原来的线程继续处理metadata的修改请求，
此时把operation log保存在另外一个文件里。

### 容错机制

#### Master 容错

通过操作日志加 checkpoint 的方式进行，并且有一台称为 "Shadow Master" 的实时热备。

> * GFS Master 的修改操作总是先记录操作日志，然后修改内存。
> * Master 会定期将内存中的数据以 checkpoint 文件的形式转存到磁盘中
> * 实时热备，所有元数据修改操作都发送到实时热备才算成功。

### 一致性模型

关于一致性，先看几个定义，对于一个file region，存在以下几个状态：

* consistent。如果任何replica, 包含的都是同样的data。
* defined。defined一定是consistent，而且能够看到一次修改造成的结果。
* undefined。undefined一定是consistent，是多个修改混合在一块。举个例子，
修改a想给文件添加A1,A2，修改b想给文件添加B1,B2，如果最后的结果是A1,A2,B1,B2，
那么就是defined，如果是A1,B1,A2,B2，就是undefined。
* inconsitent。对于不同的replica，包含的是不同的data。

在GFS中，不同的修改可能会出现不同的状态。对于文件的append操作（是GFS中的主要写操作），
通过放松一定的一致性，更好地支持并发，在下面的具体操作时再讲述具体的过程。

### Lease机制

`master`通过lease机制把控制权交给`chunkserver`，当写一个chunk时，
`master`指定一个包含这个chunk的replica的`chunkserver`作为`primary replica`，
由它来控制对这个chunk的写操作。一个lease的过期时间是60秒，如果写操作没有完成，
`primary replica`可以延长这个lease。`primary replica`通过一个序列号控制对这个chunk的写的顺序，
这样能够保证所有的replica都是按同样的顺序执行同样的操作，也就保证了一致性。

### 版本号

对于每一个chunk的修改，chunk都会赋予一个新的版本号。
这样，如果有的 replica 没有被正常的修改（比如修改的时候当前的`chunkserver`挂了）,
那么这个replica就被`stale replica`，当`client`请求一个chuck时，`stale replica`会被`master`忽略，
在`master`的定时管理过程中，会把`stale replica`删除。

### 负载均衡

为了尽量保证所有`chunkserver`都承受差不多的负载，
`master`通过以下机制来完成：

* 首先，在新建一个chunk或者是复制一个chunk的replica时，
尽量保证负载均衡。
* 当一个chunk的replica数量低于某个值时，尝试给这个chuck复制replica
* 扫描整个系统的分布情况，如果不够平衡，则通过移动一些replica来达到负责均衡的目的。

注意，`master`不仅考虑了`chunkserver`的负载均衡，也考虑了机架的负载均衡。

## 基本操作

### Read

Read操作其实已经在上面的Figure 1中描述得很明白了，有如下几个过程：

1. `client`根据chunk size的大小，把`(filename,byte offset)`转化为`(filename,chunk index)`,
发送`(filename,chunk index)`给`master`

2. `master` 返回`(chunk handle,所有正常replica的位置)`, 
`client`以`(filename,chunk index)`作为key缓存这个信息

3. `client`发`(chunk handle,byte range)`给其中一个`chunkserver`，通常是最近的一个。

4. `chunkserver`返回chunk data

### Overwrite

直接假设`client`已经知道了要写的chunk，如Figure 2，具体过程如下:

1. `client`向`master`询问拥有这个chunk的lease的`primary replica`，如果当前没有`primary replica`，
`master`把lease给其中的replica
2. `master`把`primary replica`的位置和其他的拥有这个chunk的replica的`chunkserver`（`secondary replica`）的位置返回，
`client`缓存这个信息。
3. `client`把数据以流水线的方式发送到所有的replica，流水线是一种最高效利用的带宽的方法，
每一个replica把数据用LRU buffer保存起来，并向`client`发送接受到的信息。
4. `client`向`primary replica`发送write请求，`primary replica`根据请求的顺序赋予一个序列号
5. `primary replica`根据序列号修改replica和请求其他的`secondary replica`修改replica，
这个统一的序列号保证了所有的replica都是按照统一的顺序来执行修改操作。
6. 当所有的`secondary replica`修改完成之后，返回修改完成的信号给`primary replica`
7. `primary replica`向`client`返回修改完成的信号，如果有任何的`secondary replica`修改失败，
信息也会被发给`client`，`client`然后重新尝试修改，重新执行步骤3-7。

如果一个修改很大或者到了chuck的边界，那么client会把它分成两个写操作，
这样就有可能发生在两个写操作之间有其他的写操作，所以这时会出现undefined的情况。

### Record Append

Record Append的过程相对于Overwrite的不同在于它的错误处理不同，
当写操作没有成功时，`client`会尝试再次操作，由于它不知道offset，
所以只能再次append，这就会导致在一些replica有重复的记录，
而且不同的replica拥有不同的数据。

为了应对这种情况的发生，应用程序必须通过一定的校验手段来确保数据的正确性，
如果对于生产者-消费者队列，消费者可以通过唯一的id过滤掉重复的记录。

### Snapshot

Snapshot是对文件或者一个目录的“快照”操作，快速地复制一个文件或者目录。
GFS使用*Copy-on-Write*实现snapshot，首先`master`revoke所有相关chunk的lease，
这样所有的修改文件的操作都需要和`master`联系，
然后复制相关的metadata，复制的文件跟原来的文件指向同样的chunck，
但是chuck的reference count大于1。

当有`client`需要写某个相关的chunck C时，`master`会发现它的reference count大于1，
`master`推迟回复给`client`，先新建一个`chunk handle`C'，
然后让所有拥有C的replica的`chunkserver`在本地新建一个同样的C‘的replica，
然后赋予C’的一个replica一个lease，把C'返回给`client`用于修改。

### Delete

当`client`请求删除文件时，GFS并不立即回收这个文件的空间。
也就是说，文件相关的metadata还在，
文件相关的chunk也没有从`chunkserver`上删除。
GFS只是简单的把文件删除的operation log记下，
然后把文件重新命名为一个hidden name， 里面包含了它的删除时间。
在`master`的日常维护工作时，
它会把删除时间删除时间超过3天的文件从metadata中删除，
同时删除相应chunk的metadata，
这样这些chunk就变成了orphan chunk，
它们会在`chunkserver`和`master`进行`Heartbeat`交互时从`chunkserver`删除。

这样推迟删除（原文叫垃圾回收）的好处有：

* 对于分布式系统而言，要确保一个动作正确执行是很难的，
所以如果当场要删除一个chunk的所有replica需要复杂的验错，重试。
如果采用这种推迟删除的方法，只要metadata被正确的处理，最后的replica就一定会被删除，
非常简单
* 把这些删除操作放在`master`的日常处理中，可以使用批处理这些操作，
平摊下来的开销就小了
* 可以防止意外删除的可能，类似于回收站

这样推迟删除的不好在于浪费空间，如果空间吃紧的话，`client`可以强制删除，
或者指定某些目录下面的文件直接删除。
