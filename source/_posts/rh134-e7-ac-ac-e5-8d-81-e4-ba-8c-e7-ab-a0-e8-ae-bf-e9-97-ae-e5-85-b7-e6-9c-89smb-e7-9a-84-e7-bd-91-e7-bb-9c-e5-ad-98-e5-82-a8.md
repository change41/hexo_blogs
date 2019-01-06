---
title: RH134 第十二章 访问具有SMB的网络存储
tags:
  - samba
url: 443.html
id: 443
categories:
  - RHEL134
date: 2018-10-11 15:12:19
---

RHEL 使用 samba 服务提供 windows 客户端可以使用的服务。samba 实施“服务器消息块（SMB）协议”，而 “常用Internet 文件系统”（CIFS）是SMB的一种方言，这两个名称经常互换使用。  

###### 连接至SMB/CIFS共享

红帽桌面和服务器均可连接到由使得SMB协议的任何服务器所提供的共享

###### 访问SMB 共享的三个基本步骤：

1、识别要访问的远程共享

2、确定挂载点（应该将共享挂载到的位置），并创建挂载点的空目录。

3、挂载网络文件系统（通过适当的命令或配置更改）。

开始之前，必须先安装一上软件包才能挂载 SMB共享：cifs-utils. mount 命令和autofs 自动挂载程序 均依赖此软件包来挂载 CIFS文件系统。第二个软件包 samba-client 具有一些有用的命令行实用程序（如smbclient），因此也经常值得安装

###### 挂载 SMB共享

1、识别： SMB服务器主机管理员可提供共享的详细信息，如用户名和密码、共享名称等。另一种方式是使用可浏览共享的客户端，如smbclient 
```sh
smbclient -L /serverX
```
-L 选项要求 smbclient 列出 serverX 上可用的共享

2、挂载点：使用mkdir 在合适位置中创建挂载点。
```sh
mkdir -p /mountpoint
```
3、挂载： 手动挂载，或并入 /etc/fstab 文件中，为任一操作切换到root 或使用sudo 

###### 手动：使用mount 命令
```sh
sudo mount -t cifs -o guest //serverX/share /mountpoint
```
-t cifs 选项是 SMB共享的文件系统类型； -o guest 选项指示 mount 以guest 账户身份（无需输入密码）尝试并进行身份验证。

/etc/fstab ：使用vim 来编辑 /etc/fstab 文件并将挂载条目添加到文件的底部。将在每次启动时挂载 SMB 共享
```sh
sudo vim /etc/fstab 
……
//serverX/share /mountpoint  cifs  guest  0 0
```
使用umount 和root 特权，手动卸载共享
```sh
sudo umount /mountpoint
```
对SMB 共享执行身份验证。 SMB 共享可以标记为“no-browsable (不可浏览)”，这意味着 smbclient 等客户端将不会显示它们。但是，如果在挂载操作期间明确指定SMB 共享名称，则仍可以访问这些 SMB 共享。 SMB 服务器通常限制 对特定用户或用户组的访问，如果访问受保护的共享，需向 SMB服务器提供合适的凭证。

身份验证的一个常用予以反击用户名和密码对。这些对既可添加至mount 命令（或/etc/fstab 条目），也可存储在挂载操作期间被引用的凭据文件中。如果未提供密码，mount 命令将会提示输入密码，但是使用 /etc/fstab 时必须提供密码。可通过 guest 选项来请求来宾访问权限 。

###### 示例：
```sh
sudo mount -t cifs -o guest //serverX/docs /public/docs
```
在 /public/docs 中挂载 SMB共享 //serverX/docs 并尝试以 guest 执行身份验证
```sh
sudo mount -t cifs -o username=watson //serverX/cases /bakerst/cases
```
在 /bakerst/cases 中挂载 SMB 共享 //serverX/cases 并尝试以 watson 执行身份验证。在此示例中，mount 命令将提示输入密码。

凭据谁的能提供更高的安全性，这是因为密码存储在更为安全的文件中，而/etc/fstab 文件则比较易于检查。
```sh
sudo mount -t cifs -o credentials=/secure/sherlock  //serverX/sherlook /home/sherlock/work
```
在/home/sherlock/work中挂载 SMB共享 //serverX/sherlock 并尝试使用存储于/secure/sherlock 中的凭据执行身份验证。

凭据文件格式为：
```
username=username
password=password
domain=domian
```
应将其放置在仅具有 root 访问权限的某个安全位置（如 chmod 600 ）

在文件操作期间， SMB服务器将根据用于挂载共享的凭据，检查文件的访问权限。客户端将根据从服务器发送来的文件 UID/GID，检查文件的访问权限。这意味着，客户端需要具有与 SMB服务器的文件相同的UID/GID 以及补充组成员资格（如有必要）

处理本地访问检查和备用身份验证方法的挂载选项有很多，例如多用户（和cifscreds）以及基于Kerberos的选项。

###### 使用自动挂载程序挂载 SMB 文件系统  

要使用 mount 命令，需要具有root 特权以连接到 SMB 共享。或者可将条目添加至/etc/fstab,但是此后与SMB服务器的连接需一直保持活动状态。

当某一进程试图访问SMB共享上的文件时，可以将自动挂载程序 （或autofs）服务配置为“按需”挂载 SMB 共享。当共享不再使用并处于不活动状态达一段时间以后，自动挂载程序将会挂载该共享。

使用autofs 在 SMB 共享上设置自动挂载的进程实质与其它自动挂载相同。

添加一个可识别共享基础目录和关联映射文件的auto.master.d 配置文件

创建或编辑映射文件。包括 SMB共享的挂载详细信息

启用并启动 autofs 服务

###### tips :

如果尚未安装此服务，则安装 autofs 软件包，与 mount一样，自动挂载也依赖 cifs-utils软件包来挂载 SMB 共享。

映射文件

指定文件系统类型需要先使用 -fstype=cifs 选项，然后使用一列以逗号分隔的挂载选项（与mount 相同）服务器 URI 地址以冒号“：”为前缀。

###### 示例：

以下示例在路径 /bakerst/cases 为 SMB 共享 //serverX/cases 创建一个自动挂载，并根据凭据文件 /secure/sherlock 进行身份验证。
```
/etc/auto.master.d/bakerst.autofs

/bakerst /etc/auto.bakerst

/etc/auto.bakerst

cases -fstype=cifs,credentials=/secure/sherlock ://serverX/cases

/secure/sherlock 内容（属于root,权限 0600）:

username=sherlock
password=violin2018
domain=BAKERST

autofs 启用并启动

sudo systemctl enable autofs
sudo systemctl start autofs
```
* * *

###### 实验
```sh
sudo yum install cifs-utils autofs -y
sudo vim /etc/auto.master.d/shares.autofs
  /share /etc/auto.shares
sudovim /etc/auto.shares
  work -fstype=cifs,credentials=/etc/me.cred ://server0/student
  docs -fstype=cifs,guest ://server0/public
  cases -fstype=cifs,credentials=/etc/me.cred ://server0/student
sudo vim /etc/my.cred
  username=student
  password=student
  domain=MYGROUP
groups    #查看当前用户所属组
sudo groupadd bakerst -g 10221    #创建组
sudo usermod -aG bakerst student    #附加组
newgrp bakerst    #切换（更新）组
```
