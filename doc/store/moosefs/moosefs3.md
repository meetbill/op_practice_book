# chunk存储选择算法

##前言
如果自己设计一套chunkserver选择算法,我们要达到哪些目标呢?

> 1. 文件打散后尽量平均分布到各台chunkserver上
> 2. 各台chunkserver上的chunk数量尽可能的平均
> 3. 数据分发过程衡量系统负载，尽量把数据放在负载低的chunkserver上
> 4. 数据分发过程是否应该衡量各台chunkserver的可用空间?
> 5. 机架感应?

回到MFS使用过程中会有一个疑问.chunkserver的选择是怎么选择的.怎么才能保证数据保存占用空间平衡甚至平均?这就是数据分布算法.也正是分布式文件系统的核心容.所以在此,转来一篇关于MFS的chunk存储选择算法的文章.

* * *
##核心算法
 还记得matocsserventry结构中的carry字段么,这个字段就是分布算法的核心.每台chunkserver会有自己的carry值,在选择chunkserver会将每台chunkserver按照carry从大到小做快速排序,优先选择carry值大的chunkserver来使用.

在描述具体算法前,先介绍三个概念:
>
> * allcnt:mfs中可用的chunkserver的个数
>
> * availcnt:mfs中当前可以直接存储数据的chunkserver的个数
>
> * demand:当前文件的副本数目

先说allcnt,可用的chunkserver要满足下面几个条件:
> 1. chunkserver是活着的
> 2. chunkserver的总空间大于0
> 3. chunkserver的可用空间(总空间-使用空间)大于1G

availcnt指的是carry值大于1的可用chunkserver的个数.也就是在allcnt的约束条件上加一条carry值大于1.文件1.txt需要存储2个副本,但是mfs中仅仅有1台chunkserver可用,也就是```demand>allcnt```的时候,mfs会自动减少文件的副本个数到allcnt,保证文件可以成功写入系统.

关于carry有下面几个规则:

> 1. 仅carry值大于1的chunkserver可以存储新数据
> 2. 每台chunkserver存储新数据后其carry会减1
> 3. demand>availcnt的时候，会递归的增加每台chunkserver的carry值，直到```demand<=availcnt```为止
> 4. 每台chunkserver每次carry值的增加量等于当前chunkserver总空间除以最大的chunkserver总空间

上面的规则比较复杂.举个例子就更加清晰了.

```
chunkserver 1：totalspace:3.94G carry:0.463254
chunkserver 2：totalspace:7.87G carry:0.885674
```
文件1.txt大小1k,mfs默认一个chunk大小为64M,所以仅仅需要一个chunk就够了.此时 availcnt=0,demand=1,所以需要增加carry值
```
chunkserver 1：carry=0.463254 + (3.94/7.87) = 0.463254 + 0.500005 = 0.963259
chunkserver 2：carry=0.885674 + (7.87/7.87) = 0.885674 + 1.000000 = 1.885674
```
此时 availcnt=1,demand=1,所以不需要增加carry值,对chunkserver按照carry从大到小排序结果为:```chunkserver 2 > chunkserver 1```,文件1.txt的chunk会存储到chunkserver 2上,同时chunkserver 2的carry会减1

如下：
```
chunkserver 1：carry=0.963259
chunkserver 2：carry=1.885674 – 1 = 0.885674
```
文件2.txt大小1k,mfs默认一个chunk大小为64M,所以仅仅需要一个chunk就够了.此时 availcnt=0,demand=1.所以需要增加carry值
```
chunkserver 1：carry=0.963259 + (3.94/7.87) = 0.963259 + 0.500005 = 1.463264
chunkserver 2：carry=0.885674 + (7.87/7.87) = 0.885674 + 1.000000 = 1.885674
```
此时 availcnt=2,demand=1,所以不需要增加carry值,对chunkserver按照carry从大到小排序结果为:```chunkserver 2 > chunkserver 1```,文件2.txt的chunk会存储到chunkserver 2上,同时chunkserver 2的carry会减1

如下：
```
chunkserver 1：carry=1.463264
chunkserver 2：carry=1.885674 – 1 = 0.885674
```
文件3.txt大小1k,mfs默认一个chunk大小为64M,所以仅仅需要一个chunk就够了.此时availcnt=1,demand=1,所以不需要增加carry值.对chunkserver按照carry从大到小排序结果为:```chunkserver 1 > chunkserver 2```,文件3.txt的chunk会存储到chunkserver 1上,同时chunkserver 1的carry会减1

如下:
```
chunkserver 1：carry=1.463264 – 1 = 0.463264
chunkserver 2：carry=0.885674
```
因为两台chunkserver的总空间大小不一致,根据算法总空间大的那台chunkserver会存储更多的新数据.

记住:**仅仅和chunkserver的总空间有关系和可用空间没有任何关系**,也就是说,当各台chunkserver总空间大小差不多的情况下,chunk能更好的平均分布,否则mfs会更倾向于选择总空间大的机器来使用.

* * *
最后一个问题,当mfs刚刚启动的时候,carry值是如果获得的?

答案:随机产生,通过rndu32()这个函数,随机产生一个小于1,大于等于0的数.

测试结果如下：
```
Nov 23 01:01:25 sunwg mfsmaster[13175]: 192.168.0.159,0.594834
Nov 23 01:01:25 sunwg mfsmaster[13175]: 192.168.0.160,0.000000
Nov 23 01:03:58 sunwg mfsmaster[13187]: 192.168.0.159,0.516242
Nov 23 01:03:58 sunwg mfsmaster[13187]: 192.168.0.160,0.826559
Nov 23 01:04:17 sunwg mfsmaster[13192]: 192.168.0.159,0.123765
Nov 23 01:04:17 sunwg mfsmaster[13192]: 192.168.0.160,0.389592
```
