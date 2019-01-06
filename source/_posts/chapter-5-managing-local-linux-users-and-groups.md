---
title: Chapter 5. Managing Local Linux Users and Groups
url: 295.html
id: 295
categories:
  - RHEL124
date: 2018-04-30 21:59:23
tags:
---

id 命令用来显示当前已登录用户的信息

ls -l 查看文件关联的用户。第三列显示的是用户名，第四列是组

ps 显示当前shell的进程

ps a 显示所有进程

ps au 显示进程关联的用户

#### 用户

/etc/passwd 文件格式（七个冒号分隔字段）

![image.png](1524823773815913.png)

1.  username 是UID到名称的一种映射，使用用户使用

2.  password 以前是以加密格式保存密码的位置，现在密码存储在/etc/shadow的单独文件中

3.  UID 是用户的ID

4.  GID 是用户的主要组ID 编号

5.  GECOS 字段是任意文件，通常包含用户的实际姓名，现在是描述

6.  /home/dir 是用户的家目录

7.  shell 是用户登录时运行的程序。对于普通用户通常是提供用户命令行的shell程序。


#### 组

保存在文件/etc/group 中

每个用户有且只有一个主要组，即passwd中的第三个字段。

通常用户创建的文件归主要组所有，通常用户主要组名和用户名相同，用户可以有0个或多个补充组



#### su 切换命令  

su - <username\>

su username 启动non-login shell    #su 使用当前用户环境变量，不使用username的环境变量

su - username 启动login shell # - 会将用户的环境变量调用，和这个用户正常登陆一样

sudo 以root身份执行命令

sudo 命令可以使用用户根据/etc/sudoers文件中的设置，而被允许以root身份或其他用户身份运行命令，su 要求的是被切换用户的密码，而sudo 是输入自己的密码  

sudo usermod -L username

使用sudo执行的所用命令都会被记录到/var/log/secure 中，在RHEL7中wheel组的成员都可以使用sudo ，早期版本wheel组用户默认没有这个权限（取消wheel组运行命令前的注释就可以了）

##### visudo 编辑/etc/sudoers文件更方便

大多数使用GUI的应用使用policykit提示用户进行身份认证，以及管理root访问权限

* * *

### 管理本地用户账户  

##### useradd 创建用户  

*   不带选项运行时，useradd username 会为/etc/passwd中的所用字段设置合理的默认值，默认情况下useradd 不设置任何有效密码，用户也必须设置密码后才可以登陆

*   useradd --help 将显示可用于覆盖默认值的基本选项。在大多数情况，可以将相同的选项用于usermod命令

*   默认值从/etc/login.defs文件中读取，如有效的UID编号的范围和默认密码过期规则。此文件中的值仅在创建用户是使用，更改文件对现有用户无任何影响    


##### usermod    修改现有用户

usermod --help 将显示可用于修改账户的基本选项，常见选项如下：


|usermod 常见选项 ||
| :--
|-c, --coment COMMENT|向GECOS字段添加值，如全名
|-g, --gid GROUP|为用户账户指定主要组
|-G, --group GROUPS|为用户账户指定个组补充组
|-a, --append|与-G选项搭配使用，将用户附加到所给的补充组，而不将该用户从其他组删除
|-d, --home HOME_DIR|为用户账户指定新的主（家）目录
|-m, --move-home|将用户主目录移到新的位置，必须与-d选项搭配使用
|-s,--shell SHELL|为用户账户指定新的登陆SHELL
|-L, --lock|锁定用户账户
|-U, --unlock|解锁用户账户



##### userdel    删除用户

userdel username 可将用户从/etc/passwd中删除，但默认情况下保留主目录不变。

老用户删除后新用户将使用老用户的UID，原文件将在下次创建同等UID的用户是被授权给新用户。

userdel -r username 同时删除用户和和其主目录。

find / -nouser -o -nogroup 2>/dev/null #查找没有用户或者没有组的文件或目录

id 显示用户信息  

id username 将显示username的用户信息，包括用户的UID编号和组成员资格

passwd 设置密码  

passwd username  #如果不使用username 将代表当前用户，root可以在不需要旧密码的情况下修改其他用户密码。

root 可以将密码设置成任何值，如果密码不符合要求，系统会有提示，但仍可以设置。

普通用户必须选择长度至少为8个字符，并且不以字典词语、用户名为密码基础

UID 范围

特定的UID编号和编号范围供RHEL用于特殊目的。

UID 0 始终分配给超级用户root

UID 1-200 是一系列“系统用户”，静态分配给红帽系统进程

UID 201-999 是一系列“系统用户”，供文件系统中没有自己的文件的系统进程使用，通常在安装需要他们的软件时，从可用池中动态分配它们。程序以这些“无特权”系统用户身份运行，以便限制它们访问正常运行所需的资源。

UID 1000+ 是可供分配给普通用户的范围。

RHEL7 以前的版本是UID 1-499 为系统用户，500+ 为普通用户。默认范围可以在/etc/login.defs中修改

```sh  
useradd juliet    #添加新用户
tail -2 /etc/passwd     #查看最后两个用户
passwd juliet    #修改juliet的密码
```
#### 管理本地组账户  

##### groupadd 创建组

groupadd groupname 如果不带选项，则使用/etc/login.defs文件的指定范围内的下一个可用GID

-g GID 选项用来指定具体的DIG
```sh
groupadd -g 500 ateam     #创建组
```
用户专用组（GID 1000以上）是系统自动创建的，因此通常预备一系列GID编号待用于补充组，较高的范围可以避免与系统中GID（0-999）冲突  

-r 选项将使用/etc/login.defs中系统用户的GID编号分配
```sh
groupadd -r appusers
```
groupmod 修改现有的组  

-n 选项用于指定新的名称
```sh
groupmod -n javaapp appusers    #修改javaapp组为appusers
```
-g 选项用于指定新的GID  
```sh
groupmod -g 6000 ateam    #修改ateam组的GID为6000
```
groupdel 删除组  
```sh
groupdel javaapp
```
如果该组是当前某一用户的主要组，则他不能被删除，与userdel 一样检查文件系统，确保不会遗留该组拥有的任何文件

usermod 变更组成员资格
```sh
usermod -g groupname  username   #更改用户主要组
usermod -aG wheel elvis     #将用户elvis添加进wheel补充组，如果不使用-a选项，用户将删除其他补充组
```
##### 管理用户密码  

$6$4Sme7FVt$kIMTvWnXbLGVgpVz2xHuWWAY6AxLEG4rtUm/2NvXyocJe0uT/7rIxD.52GvFJR/txTihH8VatnZ.R65YnmZzL0
#以$符为分隔，共三段
* 1. 哈希算法，数字1表示MD5哈希，数字6为SHA-512哈希算法
* 2. "4Sme7FVt" 用于加密哈希的salt，这原先是随机选取的，salt和未加密的密码组合并加密。创建加密的哈希值，使用salt可以防止两个或多个相同密码的用户出现相同的条目
* 3. "kIMTvWnXbLGVgpVz2xHuWWAY6AxLEG4rtUm/2NvXyocJe0uT/7rIxD.52GvFJR/txTihH8VatnZ.R65YnmZzL0" 以加密的哈希值

RHEL7 支持新密码哈希算法：SHA-256(算法5)，SHA-512（算法6）,root 用户通过使用authconfig --passslgo 命令，并从md5,sha-256和sha-512中选择一个适当的参数，7默认使用sha-512
```sh
[change@rhel ~]$ sudo authconfig --help | grep passalgo
  --passalgo=<descrypt|bigcrypt|md5|sha256|sha512>
```
/etc/shadow 格式（九个冒号分隔的字段）

![blob.png](1525166687554964.png)

登陆名称。这必须是系统中的有效账户名

以加密的密码。密码开通为！时表示该密码已被锁定。

最近一次更改密码的日期，以距离1970年1月1日的天数表示

可以更改密码前的最少天数，如果0表示“无最短期限要求”

必须修改密码前的最多天数。

密码即将到期的警告期，以天数表示。0表示不警告。

账户在密码过期后保持活动的天数，在此期限内，用户依然可以登录系统并修改密码。在指定天数过后，账户被锁定，变为不活动。

账户到期日期，以距离1970年1月1日的天数表示

这一blank 字段为预留字段，供未来使用

![blob.png](1525167668913001.png)
```sh
chage -d 0 username    #强制用户在下次登录是修改密码
chage -l user    #列出当前用户的设置
chage -E YYYY-MM-DD    #将在指定日期是账户到期
date -d "+45 days"    #计算未来的日期
usermod -L romeo     #锁定用户romeo
usermod -U romeo     #解除锁定
chage -M 90 romeo    #设置用户romeo 每90天创建新密码
```
