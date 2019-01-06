---
title: Chapter 8.systemctl
url: 134.html
id: 134
categories:
  - RHEL124
date: 2018-04-11 15:56:50
tags:
---


```sh
systemctl is-active firewalld
systemctl is-enabled firewalld
systemctl status firewalld
systemctl stop firewalld
systemctl start firewalld
systemctl restart firewalld
systemctl reload firewalld
systemctl enable firewalld
systemctl disable firewalld
systemctl --type=service    == systemctl -t service
systemctl --type=service --faild
systemctl list-units --type=service --all  #显示所有服务，包括未激活的
systemctl list-unit-files --type=service  #显示服务文件
systemctl list-dependencies UNIT     #查看进程依赖关系
systemctl list-dependencies cups.socket --reverse   #查看需要启动的依赖
systemctl mask firewalld     #停用/屏蔽firewalld服务
systemctl unmask firewalld    #开启/显示firewalld服务

```  


![8-1.png](1523433401385622.png)  
 ==============================================================================  

###### systemctl type 类型  
```sh
[root@client ~]# systemctl -t help  
Available unit types:  
service  
socket  
busname  
target  
snapshot  
device  
mount  
automount  
swap  
timer  
path  
slice  
scope
```
