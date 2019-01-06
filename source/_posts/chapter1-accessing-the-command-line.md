---
title: Chapter 1 . Accessing The Command line
url: 250.html
id: 250
categories:
  - RHEL124
date: 2018-04-20 10:10:20
tags:
---
```sh
[root@client ~]#     #root管理员提示符  
[client@client ~]$     #普通用户提示符
```
    如果提供图形环境，它将在Red Hat Enterprise Linux 7 的第一个虚拟控制台中运行。而另外五个文件登录提示符在控制台（tty）二到六（如果图形环境关闭，则为控制台一到五）中可用。在图形环境运行时，通过按住Ctrl+Alt 并按功能键（F2到F6）,来访问虚拟控制台上的文本登录提示符。按Ctrl+Alt+F1返回第一个虚拟控制台和图形桌面。（RHEL5 及之前版本图形运行在第七个虚拟控制台Ctrl+Alt+F7 切换）

参数提示符用法：

*   \[\]    方括号\[\]括起来的是可选项目

*   ...    前面的任何内容均表示该类型项目的任意长度列表。

*   |    以竖线分隔的多个项目表示只能指定其中一个项目  

*   <>    尖括号中的文本表示变量的数据 。如<finename>表示 “此处需要插入您要使用的文件名”有时会简单的写成大写字母，如FILENAME.



```sh
date 命令用于显示时间  

[root@client ~]# date
2018年 04月 20日 星期五 09:23:02 CST
[root@client ~]# date +%R
09:23
[root@client ~]# date +%x
2018年04月20日
[root@client ~]#
```

passwd 命令用于更改用户密码：不指定用户名即修改当前用户密码，使用root 修改密码无需知道原密码。默认情况下密码策略是有要求的，需要包含小写字母、大写字母、数字和符号，并且不以字典中的单词为基础。  
```sh
[root@client ~]# passwd client
更改用户 client 的密码 。
新的 密码：
无效的密码： 密码少于 8 个字符
重新输入新的 密码：
passwd：所有的身份验证令牌已经成功更新。
[root@client ~]# 
[root@client ~]# passwd
更改用户 root 的密码 。
新的 密码：
[client@client ~]$ passwd
更改用户 client 的密码 。
为 client 更改 STRESS 密码。
（当前）UNIX 密码：
新的 密码：
重新输入新的 密码：
passwd：所有的身份验证令牌已经成功更新。
[client@client ~]$

```

Linux 不需要文件扩展名做为依据分类文件，file 命令可以扫描文件内容的开头，显示 文件的类型。

```sh  

[client@client ~]$ file /etc/passwd
/etc/passwd: ASCII text
[client@client ~]$ file /bin/passwd
/bin/passwd: setuid ELF 64-bit LSB shared object, x86-64, version 1 (SYSV), dynamically linked (uses shared libs), for GNU/Linux 2.6.32, BuildID[sha1]=1e5735bf7b317e60bcb907f1989951f6abd50e8d, stripped
[client@client ~]$ file /home
/home: directory

```  

head 和tail 命令分别显示文件的开头和结尾部分。默认情况下都是显示10行数据 。使用-n 选项可以指定需要显示的行数。
```sh
[client@client ~]$ head /etc/passwd
[client@client ~]$ tail /etc/passwd
[client@client ~]$ tail -n 6 /etc/passwd
```
wc 命令可以计算文件中行、字和字符的数量。它可以授受 -l、 -w 或 -c选项，分别用户显示行数（lines）、字数（words）和字符数（characters）
```sh
[client@client ~]$ wc /etc/passwd
  22   42 1051 /etc/passwd        #行、字、字符
[client@client ~]$ wc -l /etc/passwd
22 /etc/passwd
[client@client ~]$ wc -c /etc/passwd
1051 /etc/passwd
[client@client ~]$ wc -w /etc/passwd
42 /etc/passwd
[client@client ~]$ wc -c /etc/group /etc/hosts    #指定多个文件
567 /etc/group
181 /etc/hosts
748 总用量
```
#### Tab 补全

tab 补全可用于命令补全和文件名补全部分命令还可以补全参数选项  
```sh
[client@client ~]$ pas<tab>    #自动列出以pas开头的不唯一命令
passwd  paste   
[client@client ~]$ pass<tab>    #自动补全pass开头的唯一命令
[client@client ~]$ passwd
```
history 命令显示之前执行的命令的列表，带有命令编号作为前缀。感叹号 ! 是元字符，用于扩展之前的命令而不必重新键入它们。!number 扩展至与指定编号匹配的命令。 !string 扩展至最近一个以指定字符串开头的命令。方向上下键可以向上或向下查找最近使用过的命令。左右键则开始进行命令行修改。  
```sh
histort
!48
!ls
```
Esc + .  组合键可使shell 将上一条命令的最后一个单词（参数）复制到当前命令行中的光标所处的位置。如果重复使用，它将继续转到更早的命令。  

|快捷方式  |描述  |
| :-- | :-- |
|Ctrl + a  | 跳到命令行的开头  |
|Ctrl + e  | 跳到命令行的末尾  |
|Ctrl + u  | 将光标位置到命令行开头的内容清除  |
|Ctrl + k  | 将光标位置到命令行末尾的内容清除|
|Ctrl + -> 方向  | 跳到命令行中后一字的开头  |
|Ctrl + <-  | 跳到命令行中前一字的开头  |
|Ctrl + l  | 清除当前屏幕显示 |
|Ctrl + r  | 在历史记录列表中搜索某一命令
