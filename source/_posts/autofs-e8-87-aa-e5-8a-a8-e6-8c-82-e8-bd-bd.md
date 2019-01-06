---
title: autofs 自动挂载
url: 497.html
id: 497
categories:
  - 未分类
date: 2018-10-12 21:10:31
tags:
---

Autofs
======

#### 安装  
```bash
yum install autofs -y
```
#### 配置

##### 配置文件默认目录  
```bash
/etc
```
##### 主配置模板auto.master 
```bash
/etc/auto.master
#/media /etc/auto.media
#目录/media  配置文件/etc/auto.media
/etc/auto.master 
/media/misc     /etc/auto.misc     --timeout=5
/media/net      /etc/auto.net      --timeout=60
#第一列是基础主目录，第二列是对接的配置文件，第三列是自动超时时间，timeout 为可选参数，单位为秒
#最好保证模板文件末尾有一个空行。
```
如果您的系统上不存在基目录，则将创建该目录。将挂载基目录以加载动态加载的媒体，这意味着在启用autofs时将无法访问基目录中的任何内容。但是，此过程是非破坏性的，因此如果您不小心自动挂载到实时目录中，只需更改位置auto.master并重新启动AutoFS即可重新获得原始内容。

如果您仍想自动挂载到目标非空目录并且希望即使在挂载动态加载目录后也可以使用原始文件，则可以使用autofs将它们挂载到另一个目录（例如/var/autofs/net）和创建软链接。
```bash
#ln -s /var/autofs/net/share\_name /media/share\_name
```
或者，您可以让autofs将媒体安装到特定文件夹，而不是在公共文件夹中。
```bash
/etc/auto.master
/  -  /etc/auto.template
#不指定基础目录
/etc/auto.template
/path/to/folder -options:/device/path
/home/user/usbstick -fstype = auto，async，nodev，nosuid，umask = 000:/dev/sdb1
```
##### 可移动媒体

打开/etc/auto.misc以添加，删除或编辑其他设备。例如：
```bash
/etc/auto.misc
#kernel -ro 
ftp.kernel.org:/pub/linux #boot -fstype = ext2:/dev/hda1 
usbstick -fstype = auto，async，nodev，nosuid，umask = 000:/dev/sdb1 
cdrom -fstype = iso9660 ，ro:/dev/cdrom 
#floppy -fstype = auto:/dev/fd0
```
如果您有CD / DVD组合驱动器，则可以更改该cdrom行以-fstype=auto自动检测介质类型。

##### NFS 检查挂载  
```bash
showmount <servername> -e
```
##### 手动NFS配置

要将名为/srv/shared\_dir的server\_name上的NFS共享挂载到位于/mnt/foo的另一台名为client\_pc的计算机，请编辑nfs.autofs并为该共享创建配置文件（auto.nfsserver\_name）：
```bash 

/etc/auto.master.d/auto.nfsserver_name
foo -rw,soft,intr,rsize=8192,wsize=8192 server\_name/srv/shared\_dir
```
##### samba 的配置方法

###### samba 检查方法
```bash
smbclient  -L  //servername 

/etc/auto.master.d/auto.smb
smb -fstype=cifs,\[other\_options\]   :// \[remote\_server\]/\[remote\_share\_name\]
#\[any\_name\] -fstype=cifs,username=\[username\],password=\[password\],\[other\_options\] ://\[remote\_server\]/\[remote\_share_name\]
```
##### ftp

安装 curlftpfs (未完待续)
```bash
yum install curlftpfs -y
modprobe fuse
```
