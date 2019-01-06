---
title: RH134 第一章 使用kickstart自动安装
url: 312.html
id: 312
categories:
  - RHEL134
date: 2018-05-05 13:24:56
tags:
  - pxe
---

Kickstart 配置文件以一个命令列表开关，这些命令定义将如何安装目录计算机。以#字符开关的行是安装程序将会忽略的注释。其它部分开头是以%字符打头的行，结尾是包含%end指令的行。

%packages 部分指定要在目标系统上安装的软件，单个软件包可以根据名称（不带版本）指定。

软件包组可以根据名称或ID指定。并以@字符开关。

环境组（软件包组的组）可使用@^ 指定，后面紧跟环境组名或ID。组具有必需、默认和可选组件。通常kickstart 将安装必需组件和默认组件。

以 \- 字符开头的软件包或组名将补排除在安装以外，除非它们为必需，或因其它软件包的RPM依赖关系而安装。

还有两个部分是%pre 和%post 脚本。%post 更为常见。它在所有软件都已安装后对系统进程配置。%pre 脚本在进行任何磁盘分区之前执行。

必需先指定配置命令。%pre 、 %post 和%packages 可以在配置命令之后以任何顺序出现。  

#### kickstart 配置文件命令

##### 安装命令

###### url:指定安装介质位置

url --url="ftp://install server.example.com/pub/RHEL7/dvd"

repo : 此选项告知Anaconda 在何处查找安装软件包。此选项必须指向有效的yum 存储库。

repo --name="Custom Packages" --baseurl="ftp://repo.example.com/custom"

[](http://ftp://repo.example.com/custom")  

text: 强制进行文本模式安装

vnc:允许通过VNC远程查看图形安装。

vnc --password=redhat

askmethod:当CD-ROM 驱动器中检测到安装介质时，不自动使用CD-ROM作为软件包来源。

###### 分区命令：

clearpart:在安装之前清除指定分区

clearpart --all --drives=sda,sdb --initlabel

part: 指定分区大小、格式、名称

part /home --fstype=ext4 --label=homes --size=4096 --maxsize=8192 --grow

ignoredisk: 安装的时候忽略指定盘

ignoredsk --drives=sdc

bootloader :定义安装引导分区

bootloader --location=mbr --boot-drive=sda

volgroup,logvol: 创建LVM卷组和逻辑卷

part pv.01 --size=8192
volgroup myvg pv.01
logvol / --vgname=myvg --fstype=xfs --size=2048 --name=rootvol --grow
logvol /var --vgname=myvg --fstype=xfs --size=4096 --name=varvol



zerombr: 格式未被识别的磁盘将被初始化。

###### 网络命令

network:配置目标系统的网络信息，并激活安装程序环境中的网络设备。

network --device=eth0 --bootproto=dhcp

firewall : 此选项定义在目标系统上如何配置防火墙

firewall --enabled --service=ssh,cups


##### 配置命令：

lang : 此必需命令设置安装时需要使用的语言和已经安装系统的默认语言

lang en_US.UTF-8

keyboard: 此必需命令，设置系统键盘类型。

keyboard --vckeymap=us --xlayouts='us','us'

timezone :定义时区、NTP server及硬件时钟是否使用UTC

timezone --utc --ntpservers=time.example.com Europe/amsterdam

auth: 此必需选项设置系统身份认证选项

auth --useshadow --enablemd5 --passalgo=sha512

rootpw: 定义root初始密码

rootpw --plaintext redhat    #明文
rootpw --iscrypted $6$KUnFfrTzOBjv.PiH$YlBbOtXBkWzoMuRfb0.SpbQ....XDR1UuchoMG1    #加密

selinux : 设置安装系统后selinux状态

selinux --enforcing

services : 修改默认运行级别下将运行的默认服务集合。

services --disabled=network,iptables,ip6tables --enabled=NetworkManager,firewalld

group,user :在系统上创建本地用户和组

group --name=admins --gid=1001
user --name=jode --gecos="john doe" --groups=admins --password=changeme --plaintext

##### 杂项命令：

logging :此命令定义安装期间Anaconda 将如何进行日志记录。

logging --host=loghost.example.com --level=info

firstboot: 确定系统首次启动时firestboot 是否启动

firstboot --disabled

reboot、poweroff 、halt ： 指定安装结束后就发生什么情况。  

pykickstart软件包中的ksverdiff 程序可以识别两个版本间kickstart文件语法中的区别，如ksverdiff -f RHEL6 -t RHEL7 ,将识别RHEL6到RHEL7 的语法更改。可用版本在/usr/lib/python2.7/sit-packages/pykickstart/version.py。yum install pykickstart 。  



* * *

命令部分参考：

![图片.png](1525422261580488.png)

安装软件部分

![图片.png](1525422300234129.png)

配置脚本部分

![图片.png](1525422328135998.png)

![图片.png](1525422388734744.png)

使用system-config-kickstart 创建kickstart文件。或者使用编辑器创建kickstart文件（参考anaconda-ks.cfg 默认在root的家目录下），使用编辑的几种情况：

1、GUI或system-config-kickstart 不可用

2、需要高级磁盘分区配置说明。system-config-kickstart 不支持LVM和RAID

3、需要包含或者忽略单个包（而不仅仅是组）

4、%prc 和%post 需要更高级的脚本。  

ksvalidator 检查配置语法，它将确保关键字和选项的正确使用，无法验证url路径、单个数据包或组，也无法验证%post 和%pre 脚本的任何部分

##### 通过修改系统启动项，指定配置文件。  

##### 启动方式  

###### 指定配置文件方式  

网络服务器,FTP,HTTP,NFS  

ks=[http://server/dir/file](http://server/dir/file)  

ks=[ftp://server/dir/file](http://ftp://server/dir/file)  

ks=nfs:server:/dir/file



###### USB磁盘或CD-ROM  

ks=hd:device:/dir/file

ks=cdrom:/dir/file  

[完整参数介绍](https://access.redhat.com/documentation/zh-cn/red_hat_enterprise_linux/7/html/installation_guide/sect-kickstart-syntax)
