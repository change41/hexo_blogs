---
title: Recored  零散记忆
url: 247.html
id: 247
categories:
  - RHEL124
date: 2018-04-20 10:11:27
tags:
---
```sh
LANG=zh_CN.utf8    #设置语言，临时

locale    #检查语言

localectl set-locale LANG=zh_CN.utf8    #设备系统默认语言

vi /etc/locale.conf    #语言的配置文件  
```
tty2等本地文件控制台可显示的字体比gnome-terminal和ssh会话受到的局限多。例如，本地文件控制台中的日语、韩语和中文字符显示可能会不正常。因此最好将英语或其它包含拉丁语字符的语言用于系统的文本控制台。类似的，受到的输入法也受到限制比较多。
```sh
yum install yum-langpacks #先安装才能使用。  

yum langavaliable     #查看系统可用语言包  

yum langlist

yum langinstall code  
```
[http://fedoraproject.org/wiki/QA:Langpack\_Yum\_Application](http://fedoraproject.org/wiki/QA:Langpack_Yum_Application)  

```sh  

NCORE=$( grep -c '^processor' /proc/cpuinfo)    #查看CPU核数
for I in $(  seq $((NCORE\*2-1)))    #设置for 循环，seq 生成序列来自NCORE\*2-1的值，$((NCORE\*2-1)) 计算 NCORE\*2-1
do
echo $I
done

grep -c '^processor' /proc/cpuinfo      #统计匹配到以/proc/cpuinfo中processor 开头的数量
```
