---
title: Chapter 11. Manager Network
url: 140.html
id: 140
categories:
  - RHEL124
date: 2018-04-11 16:05:34
tags:
---

常见服务端口查看文件：/etc/services  
rhel 7开始网卡的命令开头规则为：  
以太网：en；无线网：wl；WWAN：ww；  
后面根网卡接口类型：  
hotplug 热插拔：s; PCI接口 :p  
主板集成：o；x:MAC地址使用  
最后的数字是：索引、ID或端口。  
如：eno1,ens33,enp2s0,eth0  
无法确认的情况下，使用ethN 传统的形式。  

biosdevname 包用来定义udev设备的名称规则，PIC(S)网卡名pYpX ，Y代表slot number ,X 代表当前板卡的第几个口

  

  

 ==============================================================
```bash

ip addr show ens33      #查看信息
ip -s link show eth0      #显示统计信息tatistics（统计）
ip route                 #查看路由
ping -c3 192.168.1.1  -cN     #指定ping的次数
tracepath access.redhat.com      #跟踪路由，默认使用UDP路由，然后UDP经常被封

```
traceroute 有 -I(ICMP) , -T (TCP) 选项  
RTT  :Round trip timging; MTU:Maximum transmission unit  
ss  -ta 显示tcp  socket 统计信息 -t=tcp ,-a=all.   ss类似netstat 命令  
-n 以数字形式显示端口或地址  
-t  tcp  
-u     udp  
-l     显示处于Listening状态的服务  
-a  显示所有  
  

-p   显示进程使用的socket

  

 ==============================================================

  
配置文件位置/etc/sysconfig/network-scripts/  
网络管理服务：NetworkManager,命令是nmcli  

```bash

nmcli con show                 #显示所有连接的网卡
nmcli con show --active         #显示处于激活状态的网卡
nmcli con show "ens33"            #显示网卡的详细信息,对应的详细说明查看man nm-settings 
nmcli dev status
nmcli dev show ens33               #显示指定网卡
nmcli dev show                    #显示网卡
nmcli con show                    #显示连接
nmcli con up  <"ID">              #启用网卡
nmcli con down  <"ID">             #关闭网卡
nmcli dev dis  <"ID">             #断开连接
nmcli net off                     #停用网卡
nmcli net on                      #启用网卡
nmcli con add  ….               #添加连接
nmcli con mod  <"ID">             #修改连接
nmcli con del  <"ID">             #删除连接
man nm-connection-editor            #查看详细说明

```
==============================================================

```bash

nmcli con add con-name "default" type ethernet ifname eth0
nmcli con add con-name "static" ifname eth0 autoconnect no type ethernet ip4 172.25.1.10/24 gw4 172.25.1.254 
nmcli con up "static"
nmcli con up "default"
nmcli con mod "static" connection.autoconnect yes
nmcli con mod "static" ipv4.dns 172.24.1.254
nmcli con mod "static" +ipv4.dns 8.8.8.8
nmcli con mod "static" ipv4.address "172.25.2.10/24 172.25.2.254"
nmcli con mod "static" +ipv4.address 192.168.1.1/24

```
 ==============================================================

  
修改配置文件后使用  

```bash

nmcli con reload  重新加载配置文件  
nmcli con down;nmcli con up  
  
```
 ==============================================================
```bash
hostname  查看主机名

hostnamectl set-hostname deskop.example.com

hostnamectl status   #查看主机信息，包括主机名、计算机类型、系统类型、版本、架构
cat /etc/hostname  #主机名保存的文件，/etc/sysconfig/network (老版本)

```

/etc/hosts 文件配置静态域名解析，本地解析

getent hosts www.baidu.com  #getent 解析域名，同nslookup，对hosts文件有支持 
host classroom.example.com  #解析域名，同nslookup

/etc/resolv.conf  配置 DNS 服务器地址,支持内容如下：

    nameserver: DNS 的IP地址，最多可以设置3个

    search : 一般用域名，

    domain :一般用域名

PEERDNS=no 时，不会影响/etc/resolv.conf ，如果网卡配置PEERDNS=yes ,重启网卡时会覆盖resolv.conf
