---
title: Chapter 12. Archiving and copying Files
url: 152.html
id: 152
categories:
  - RHEL124
date: 2018-04-12 21:28:25
tags:
---

##### 压缩命令：tar , gzip ,bzip2, xz

tar 命令参数：c(create) , t (list the contents) ,x (extract)  f (后面要跟filename），v (verbose 详细信息),

使用tar 命令打包文件或者文件夹前检查是否有同名的压缩文件，tar会覆盖原文件不提示。

```bash

tar cf archive.tar file1 file2 file3  #压缩 file1,file2,file3 到archive.tar 
tar cf directory.tar directory1/    #压缩 directory1 目录到directory.tar
tar tf archive.tar           #查看archive.tar 里的内容
tar cf /root/etc.tar  /etc      # 指定压缩包的保存位置， 默认情况下，被压缩的路径前导符 “/”（/etc 在tar包里为etc） 在压缩时会被删除，为了以后解压时出现覆盖情况，

```

  

tar 默认会保存文件的访问权限，如果需要同时保存selinux的上下文和acl权限，需要使用 --xattrs(需要root权限执行),--selinux，--acls 查看tar --help  

```bash

tar cf archive.tar --xattrs --selinux  filename   #创建
tar xfp archive.tar --xattrs --selinux    #解压带权限

```
  

默认情况下，使用root解压文件会保留文件所属权限，使用普通用户解压会修改文件所属为当前用户,在解压时一般会删除umask 权限，如果需要保留使用-p 选项

z for gzip  (filename.tar.gz or filename.tgz)

j for bzip2 (filename.tar.bz2)  

J for xz (filename.tar.xz)  

![图片.png](1523583168668639.png)

==========压缩
```bash
tar   czf    filename.tar.gz
tar   czf    filename.tgz
tar   cjf    filename.bz2
tar   cJf    filename.xz

```

==========解压
```bash
tar   xzf    filename.tar.gz
tar   xzf    filename.tgz
tar   xjf    filename.bz2
tar   xJf    filename.xz

```

  

同时可以使用gzip,bzip2,xz 对tar包进行二次压缩



### 2018-04-13

scp  基于ssh 的安全传输

scp  root@host:/path   
```bash
scp server0:/etc/hostname /home student/    #从远程下载
scp /etc/yum.conf /etc/hosts server0:/home/student/        #上传到远程
scp -r root@server0:/var/log /tmp            #递归复制，针对整个目录
```
sftp 互动型文件传输，同样基于ssh的FTP安全传输,
```bash
sftp server0    #连接后输入对应的用户密码，默认为当前同名用户
sftp root@server0    #使用root用户登录
```
常用ftp 命令: ls ,cd ,mkdir ,rmdir ,pwd ,查看本地lcd ,lls ,lpwd 等，详细可以在ftp 模式下"?"查看，put 上传，get 下载，exit退出

```bash

[student@desktop0 ~]$ sftp server0
student@server0's password: 
Connected to server0.
sftp> pwd
Remote working directory: /home/student
sftp> mkdir hostbackup      
sftp> cd hostbackup/
sftp> put /etc/hosts        #上传
Uploading /etc/hosts to /home/student/hostbackup/hosts
/etc/hosts                                    100%  231     0.2KB/s   00:00    
sftp> get /etc/yum.conf     #下载
Fetching /etc/yum.conf to yum.conf
/etc/yum.conf                                 100%  813     0.8KB/s   00:00    
sftp> exit

```

#### rsync  远程同步

-a    归档模式archive mode ，支持软连接,不支持高级权限如ACL,SELINUX 上下文

-A  -a     启用支持高级权限如ACL

-X  -a     启用Selinux  

-n    测试模式，不做更改  

-r    递归模式

-l    同步符号连接，保存为连接

-p    保留权限

-H    保留硬连接

##### 本地目录及文件同步：  
```bash
#命令    参数    源    目地
rsync  -av  /var/log  /tmp #同步log文件夹及其内容
rsync  -av /var/log/  /tmp    #仅同步文件夹下的内容

#远程目录及文件同步,方式和scp 类似  

rsync  -av /var/log   server0:/tmp
rsync  -av server0:/var/log  /tmp
rsync -av  root@server0:/var/log   /tmp

```
