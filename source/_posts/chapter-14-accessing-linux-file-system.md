---
title: Chapter 14. Accessing Linux File System
url: 183.html
id: 183
categories:
  - RHEL124
date: 2018-04-17 16:43:24
tags:
---

在Red Hat Enterprise Linux 中检测到的第一个SCSI、PATA/SATA或USB硬盘驱动器是/dev/sda,第二个/dev/sdb，以此类推。

/dev/sda 的第一个分区为/dev/sda1,第二个分区为/dev/sda2 ，以此类推。

虚拟机中的硬盘驱动器是例外，一般显示了/dev/vd<letter>或/dev/xvd<letter>

LVM(逻辑卷管理)，通过LVM一个或多个块设备可以汇集成一个存储池，称为卷组（VG），对于卷组/dev/目录中有一个名称与该卷组相同的目录。在该目录下，已经创建名称与逻辑卷相同的符号链接。例如：代表myvg卷组的myvg逻辑卷的设备文件是/dev/myvg/mylv。

LVM依赖于设备映射程序(DM)内核驱动程序。以上符号链接/dev/myvg/mylv 指向/dev/dm-number 块设备节点。number 的分配是连续的。从零（0）开始  

。每个逻辑卷在/dev/mapper 目录中有另外一个符号链接，名称为/dev/mapper/myvg-mylv。通常可能使用任一可靠且一致的符号链接名称来访问逻辑卷。因为/dev/dm-number名称在每次启动会有所不同。

df #显示已经挂载的磁盘空间、已用和剩余，所占比。包括本地和远程

tmpfs 和devtmpfs 设备是系统内存中的文件系统，在系统重启后，写入tmpfs或devtmpfs的文件都会消失。
```sh
df -h    #报告单位是KiB(210),MiB(220),GiB(230)
df -H    #报告单位是KB(103),MB(106),GB(109)硬盘驱动器制造商在广告其产品时通常使用SI单位。
du -h dir    #以递归方式查看特定目录空间详细信息，-h 同df
du -H dir    #以递归方式查看特定目录空间详细信息，-H 同df
```
mount 挂载的两种方式:一、驻留在/dev中的设备文件。二、文件系统的通用唯一标识符：UUID。

blkid 命令用来列出其上具体文件系统的现有分区和文件系统的UUID，以后用于格式化该分区的文件系统。  

```sh

[root@server0 Desktop]# blkid
/dev/sda1: UUID="9bf6b9f7-92ad-441b-848e-0257cbb883d1" TYPE="xfs"

#根据分区的设备文件
mount /dev/vdb1 /mnt/mydata
#根据通用唯一标识符UUID
mount UUID="9bf6b9f7-92ad-441b-848e-0257cbb883d1" /mnt/mydata

```
如果将文件挂载到现有的目录且这个目录不为空，则这个目录下的文件在挂载后不可访问

umount 挂载点    #卸载文件系统。

1.当前处理挂载系统下无法卸载，解决办法：退出当前挂载点  

2.有进程在使用当前挂载点，无法卸载。解决办法：结束进程

lsof /mnt/mydata    #命令列出拨给目录中所有打开的文件以及访问他们的进程。识别哪些进程在阻止文件系统被成功卸载非常有用。

图形桌面环境针对USB闪存设备和驱动器等可移动设备会自动挂载，可移动介质的挂载点是/run/media/<user>/<label>

* * *

#### 软链接和硬链接

硬链接：硬链接是新的目录条目，其引用文件系统中的现有文件。指向同一文件内容的硬链接需要在相同的文件系统中。硬链接具有相同的权限 、链接数、用户/组权限、时间戳、以及文件内容。在文件权限后面，所有者前面的数字为硬链接数。  

ln 命令为现在文件创建新的硬链接。该命令需要一个现在文件作为第一参数，后面可以跟一个或多个额外的硬连接。新硬链接创建后无法区别哪一个是现有硬连接的原始链接。使用ls -l 查看时文件类型都是文件。  

```sh

[root@server0 newspace]# echo "Hello" >file1.txt
[root@server0 newspace]# ln file1.txt file2.txt
[root@server0 newspace]# ll
total 8
-rw-r--r--. 2 root root  6 Apr 17 15:00 file1.txt
-rw-r--r--. 2 root root  6 Apr 17 15:00 file2.txt
drwxr-xr-x. 2 root root 20 Apr 17 14:46 newdir
[root@server0 newspace]# cat file2.txt 
Hello
[root@server0 newspace]# echo 'World' >> file1.txt 
[root@server0 newspace]# cat file2.txt 
Hello
World
[root@server0 newspace]# rm -rf file1.txt 
[root@server0 newspace]# cat file2.txt 
Hello
World
[root@server0 newspace]# 
#创建硬连接后，只要一个文件内容改变其它的跟着改变，且删除其中一个硬链接后不会影响其它链接，内容依然可用。

```
ls -s 命令创建软链接，也称为符号链接。软件连接是特殊的文件类型，它指向现在的文件或目录，软链接可以指向其它文件系统中的文件或目录。

![图片.png](1523949252627674.png)

当原始文件被删除后，软链接依然会指向该文件，但目标已经消失。指向缺失的文件的软链接称为：“悬挂的软链接”，查看时会提示文件或目录不存在。

![图片.png](1523949409259777.png)  

软链接指向目录时，可通过cd dir 进入到newdir/目录下。

* * *

#### find and locate 查找文件  

locate 命令根据locate 数据库中的文件名和路径返回搜索结果。该数据库存储文件名和路径信息。

调用locate搜索的用户必须对包含匹配元素的目录树具有读取权限才会有返回结果。

```sh

locate passwd    #查找文件名和路径包含passwd文件和目录
locate -i messages    #不区分大小写查找包含messages的文件和目录
locate -n 5 snow.png    #查找前5个匹配的文件或目录
updatedb    #更新locate数据库，默认每天自动更新。root用户可以updatedb手动更新。

```
find 命令实时搜索，查找符合命令行参数条件的文件。调用find搜索的用户必须对包含匹配元素的目录树具有读取权限才会有返回结果。find 的第一个参数为目录，如果缺省则默认为当前目录，并在当前目录树下搜索。find 可以根据文件名、文件大小、最近修改时间戳和其他文件特性的任意组合进行搜索。

```sh

find / -name sshd_config    #在/根目录和所有子目录中搜索名为sshd\_config的文件
find / -name '*.txt'    #在/根目录和所有子目录中搜索以‘.txt’结尾的文件
find /etc -name '*pass*'    #在/etc目录和所有子目录中搜索名称中包含pass的文件
find / -iname '*messages*'    #-iname 不区分大小写，在/根目录和所有子目录中搜索名称中包含‘messages’的文件  

find -user student    #在当前目录查找student用户拥有的文件
find -group student    #在当前目录查找student组拥有的文件
find -uid 1000    #在当前目录查找uid为1000拥有的文件
find -gid 1000    #在当前目录查找gid为1000拥有的文件
find / -user root -group mail    #在/根目录下搜索root用户和mail组拥有的文件（同时）

find /home -perm 764    #在home目录下查找文件完全匹配权限为764的文件，777不满足
find /home -perm -324    #在home目录下查找文件对应权限至少包含324的文件，三个权限位置对应满足。
find /home -perm /442    #在home目录下查找文件中三个权限任何一位有4或2权限的文件
find /home -perm -004    #在home目录下查找其它人至少具有读权限的文件
find /home -perm -002    #在home目录下查找其它人至少具有写权限的文件

#-perm 选项用于查找具体特定权限集的文件，权限可以描述为八进制值，包含代表读取、写入和执行的4、2和1的某些组合，权限前面可以加上/或-符号。
#前面带有/的数字权限将匹配文件用户、组、其它人权限集中的至少一位。权限为r--r--r--的文件并不匹配/222，rw-r--r--的文件才匹配。即大于或等于其它中一位即为匹配。
#前面带有-的数字权限表示所有三个权限都必须存在。-222 只有rw-rw-rw才能匹配。默认值。
# 与 / 或 - 一起使用时 0 值类似于通配符。因为其表示至少无任何内容权限。

find /home -size 10M    #查找文件大小等于10M的文件，单位有k(小),M,G，+10M表示大于，-10M表示小于。
find /home -size +10M    #-size 单位修饰符将所有内容向上取整为一个单位，find -size 1M 将显示
find /home -size -10M    #小于1M的文件。向上取整为1M，尽量使用小单位。如查找1M文件使用或1024k

find / -mmin 120    #查找正好在前120分钟修改的所有文件
find / -mmin +200    #查找200分钟外修改的所有文件,同时也是200分钟内没有修改过的
find / -mmin -150    #查找在150分内修改的所有文件

find / -type    #f:普通文件，d:目录，l：软链接，b:块设备
find /etc -type d    #查找etc/目录下的文件夹
find / -type l    #查找/根目录下的所有软链接
find / -type f -links +1    #查找/目录下类型为文件，硬链接大于1个的文件。+：大于，-：小于

```
