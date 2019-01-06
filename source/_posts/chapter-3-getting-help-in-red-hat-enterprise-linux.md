---
title: Chapter 3. Getting Help in Red Hat Enterprise Linux
url: 273.html
id: 273
categories:
  - RHEL124
date: 2018-04-26 11:01:18
tags:
---

|章节  |内容类型  |
| :-- | :--|
|1  |用户命令（可执行命令和shell程序）  |
|2  |系统调用（从用户空间调用的内核例程）  |
|3  |库函数（由程序提供）  |
|4  |特殊文件（如设备文件）  |
|5  |文件格式（用于许多配置文件和结构）  |
|6  |游戏（过去的有趣程序章节）  |
|7  |惯例，标准和其它（协议、文件系统）|
|8 |系统管理和特权命令（维护任务） |
|9  |Linux 内核API（内核调用）  |

#### 导航 man page

|命令  |结果  |
|  :-- | :-- |
|空格键  |向前（向下）滚动一个屏幕  |
|PageDown  |向前（向下）滚动一个屏幕  |
|PageUp  |向后（向上）滚动一个屏幕 |
|向下箭头  |向前（向下）滚动一行  |
|向上箭头  |向后（向上）滚动一行  |
|d |向前（向下）滚动半个屏幕  |
|u  |身后（向上）滚动半个屏幕  |
|/String  |在man page 中向前（向下）搜索string  |
|n  |在man page 中重复之前的向前（向下）搜索 |
|N  |在man page中重复之前的向后（向上）搜索  |
|g  |转到man page的开头  |
|G  |转到man page的末尾  |
|q |退出 man ,并返回到shell命令提示符  |
```sh
man passwd #默认显示章节1,passwd(1)
man 5 passwd #查看passwd 第5章节passwd(5)
```
搜索string时允许正则表达试
```sh
man -k keyword  #执行标题和描述  
man -K keyward #执行全文页面搜索  
```
#根据关键字搜索man page ,关键字搜索依赖mandb(8)生成的索引；必须以root身份运行，该命令每天通过cron.daily 运行。或者anacrontab 在启动一小时内运行（如果过期）

#### pinfo  

man page 的正式格式作用于命令参考时很有用，但作用于普通文档却用处不大。对于此类文档，GNU项目发了一种不同的在线文档系统，称为GNU info。

info 文档结构超链接式的info 节点组成。此格式比man page 更灵活，允许对复杂命令和概念进行彻底的说明。

pinfo info 读取器比原始的info命令更加高级。它设计为与lynx文本web 浏览器击键操作相符，也添加了颜色。可以通过pinfo topic 浏览特定的主题的节点。

pinfo nano #查看nano  

pinfo 和 man page 按键对比

|导航  |pinfo |man page  
| :-- | :--
|向前（向下）滚动一个屏幕  |PageDown 或空格键  |PageDown或空格键  
|向后（向上）滚动一个屏幕  |PageUp 或 b  |PageUp 或b  
|显示主题目录  |d  |-  
|向前（向下）滚动半个屏幕  |-  |d  
|显示主题的顶部（上部） |主页  |1G  
|向后（向上）滚动半个屏幕  |-  |u  
|向前（向下）滚动到下一超链接  |向下箭头  |-  
|打开光标处的主题  |Enter  |-  
|向前（向下）滚动一行  |-  |向下箭头键或Enter  
|向后（向上）滚动到上一超链接  |向上箭头  |-  
|向后（向上）滚动一行  |-  |向上箭头  
|搜索某种模式  |/string  |/string  
|显示主题中的下一个节点（章节） |n  |-  
|重复之前的向前（向下）搜索  |/，再按Enter  |n  
|显示主题中的上一节点（章节）  |p  |-  
|重复之前的向后（向上）搜索  |-  |N  
|退出程序  |q  |q  

#### 读取/usr/share/doc 中的文档

安装软件包时，识别为文档的文件将移到/usr/share/doc/packagename 目录中，一些软件包附带大量的示例、配置文件模板、脚本、教程或用户手册。

firefox [file:///usr/share/doc](http://file:///usr/share/doc)  

yum list *-doc*  #查看所有文档做为一个单独提供的软件  



#### 红帽官方的帮助


man man #查看man的使用方法
```sh
man -t passwd > passwd.ps    #为passwd man page 创建格式化输出文件

file passwd.ps    #查看文件类型

less   passwd.ps #查看文件内容

man -k postscript viewer     #了解用于查看或打印postscript文件命令，-k 指定关键字

man lp    #查看lp命令的用法  

lp passwd.ps -P 2-3     #打印passwd.ps的2-3页
```
