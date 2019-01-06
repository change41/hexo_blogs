---
title: RH134 第十四章 使用 FIREWALLD 限制网络通信
url: 511.html
id: 511
categories:
  - RHEL134
date: 2018-10-17 18:20:04
tags:
---

##### Netfilter 和 firewalld 概念  

Linux 内核包含一个强大的网络过滤子系统 netfilter.netfilter 子系统允许内核模块对遍历系统的每个数据进行检查。这表示在任何传入、传出或转发的网络数据包到达用户喷雾健康的组件之前，都可以通过编程方式检查 、修改、丢弃、或拒绝这些数据包。这是在 RHEL 7 计算机上构建防火墙的主要构建块。

##### 与 netfilter 交互

尽管管理员理论上可以编写自己的内核模块与 netfilter 交互，但通常不会这样做。取而代之会使用其他程序来与 netfilter 交互。这些程序中，最常见和最知名的是iptables 。在先前的 RHEL  版本中， iptables 是与内核 netfilter 子系统交互的主要方法。

iptables 命令是一个低级工具，使用该工具正常管理防火墙可能具有挑战性。此外，它仅能调整 ipv4 防火墙规则。为保证更完成的防火墙覆盖率，需要使用其他实用程序，例如用于 ipv6 的ip6tables 和用于软件桥的ebtalbes 。

##### firewalld 简介。

RHEL 7 中引入了一种与 netfilter 交互的新方法：firewalld , firewalld 是一个可以配置和监控系统防火墙规则的系统守护进程。应用可以通过 DBus 消息系统与 firewalld 通信以请求打开端口，此功能可以禁用或锁定。该守护进程不仅涵盖ipv4、ipv6，还能涵盖 ebtables 设备。 firewalld 守护进程从 firewalld 软件包安装。此软件包属于Base 安装的一部分，但不属于minimal安装的一部分。

firewalld 将所有网络流量分为多个区域，从而简化防火墙管理。根据数据包源 ip 地址或传入网络接口等条件。流量将转入相应的防火墙规则。每个区域都可以具有自己的要打开和关闭的端口和服务列表。

###### tips:

对于笔记本电脑或经常更改网络的其他计算机，可以使用 NetworkManager 自动设备连接防火墙区域。（ZONE=home）可以使用适于特定连接的规则来自定义区域。

对于传入系统的每个数据包，将首先检查其源地址。如果该原地址关联到特定区域，则将分析该区域的规则。如果该源地址未关联某个区域，则将使用传入网络接口的区域。

如果出于某种原因，网络接口未与某个区域关联，则将使用默认区域。默认区域本身不是一个单独的区域；它是其他区域中的一个。默认情况下使用 public 区域，但系统管理员可以更改此默认值。

大多数区域会允许与特定端口和协议（“631/udp”）或预定义服务（"ssh"）的列表匹配的流量通过防火墙。如果流量不与允许的端口/协议或服务匹配，则通常会被拒绝。（trusted区域默认情况下允许所有流量，它是此规则的一个例外）。

###### 预定义区域

|区域名称  |默认配置
| :--
|trusted|允许所有传入流量
|home|除非与传出流量相关，或与 ssh、mdsn、ipp-client、samba-client 或 dhcpv6-client 预定义服务匹配，否则拒绝传入流量
|internal|除非与传出流量相关，或与 ssh、mdsn、ipp-client、samba-client 或 dhcpv6-client 预定义服务匹配，否则拒绝传入流量（一开始与 home 区域相同）
|work|除非与传出流量相关，或与 ssh、ipp-client 或 dhcpv6-client 预定义服务匹配，否则拒绝传入流量
|public|除非与传出流量相关，或与 ssh 或 dhcpv6-client 预定义服务匹配，否则拒绝传入流量，新增加网络接口的默认区域
|external|除非与传出流量相关，或与 ssh 预定义服务匹配，否则拒绝传入流量，通过此区域转发的 ipv4 传出流量将进行伪装，以使其看起来像是来自传出接口的ipv4地址
|dmz|除非与传出流量相关，或与 ssh 预定义服务匹配，否则拒绝传入流量
|block|除非与传出流量相关，否则拒绝传入流量
|drop|除非与传出流量相关，否则拒绝传入流量（甚至不产生包含 ICMP 错误的响应）

有关所有可用预定义区域及其预期用途的列表，参阅 firewalld.zones(5)手册页。  

###### 预定义服务  

firewalld 还随附一些预定义服务，这些服务可用于方便地允许特定网络服务的流量通过防火墙，下表详细说明了防火墙区域默认中使用的预定义的配置。

|服务名称|配置
| :--
|ssh|本地ssh 服务器。到22/tcp的流量
|dhcpv6-client|本地 DHCPv6客户端，到 fe80::/64 IPv6 网络中 546/udp 的流量
|ipp-client|本地IPP 打印，到 631/udp的流量
|samba-client|本地 windows 文件和打印共享客户端，到137/udp,和138/udp的流量
|mdns|多播DNS(mDNS)本地链路名称解析。到5353/udp 指向 224.0.0.251 (IPv4)或 ff02::fb(IPv6)多播地址的流量
|
###### tips:

还存在许多其他预定义服务。firewall-cmd --get-services 命令可以列出这些服务。可在 /usr/lib/firewalld/services 目录中找到用于定义 firewalld 软件包中所含预定义服务的配置文件，其格式由 firewalld.zone(5)定义。本章中不会进一步讨论这些文件。

##### 配置防火墙设置

###### 三种主要方式与 firewalld 交互。

1、直接编辑配置文件

2、使用 firewall-config 图形工具

3、从命令行使用 firewall-cmd 



###### 使用firewall-cmd 配置防火墙设置

firewall-cmd 作为主firewalld 软件包的一部分安装。firewall-cmd 可以执行 firewall-config 能够执行的相同操作。

常用 firewall-cmd 命令及其说明（默认修改运行配置），当指定 --permanent （永久）选项时除外。

|firewall-cmd 命令  |说明
| :--
|--get-default-zone|查询当前默认区域
|--set-default-zone=<ZONE>|设置当前默认区域
|--get-zones|列出所有可用区域
|--get-active-zones|列出当前正在使用的所有区域（具有关联的端口或者源）及其接口信息
|--add-source=<CIDR>\[--zone=<ZONE>\]|将来自 IP 地址或网络 /子网掩码 <CIDR> 的所有流量路由到指定区域，如果未提供 --zone= 选项，则将使用默认区域。
|--remove-source=<CIDR>|从指定区域中删除用于路由来自 ip 地址或 网络/子掩码<CIDR>的所有流量的规则 。如果未提供 --zone= 选项，则将使用默认区域。
|--add-interface=<INTERFACE>|将来自<INTERFACE>网卡的所有流量路由到指定区域。如果未提供 --zone=选项，则将使用默认区域。
|--change-interface=<INTERFACE>|将接口与 <ZONE>而非其当前区域关联。如果未提供 --zone 选项，则将使用默认区域
|--list-all|列出<ZONE>的所有已经配置接口、源、服务和端口。如果未提供 --zone 选项，则将使用默认区域
|--list-all-zoness  |检索所有区域的所有信息。（接口、源、服务、端口）
|--add-service=<SERVICE>|允许到<SERVICE>的流量。如果未提供--zone 选项。则将使用默认区域
|--add-port=<PORT/PROTOCOL>|允许到<PORT/PROTOCOL>端口的流量。如果未提供 --zone 则将使用默认区域
|--remove-service=<SERVICE>|从区域的允许 列表中删除<SERVICE>.如果未提供 --zone 选项则将使用默认区域
|--remove-port=<PORT/PROTOCAL>|从区域的允许列表中删除<PORT/PROTOCOL>端口。如果未提供 --zone 选项，则将使用默认区域
|--reload|丢弃运行时配置并应用永久配置

###### firewall-cmd 示例：

下例显示默认区域设备为 dmz ,来自192.168.0.0/24 网络的所有流量都被分配给 internal 区域。而 internal 区域上打开了用于mysql 的网络端口
```sh
firewall-cmd --set-default-zone=dmz
firewall-cmd --set-source=192.168.0.0/24 --zone=internal    #临时生效
firewall-cmd --add-service=mysql --zone=internal    #临时生效
firewall-cmd --permanent --set-source=192.168.0.0/24 --zone=internal    #永久配置
firewall-cmd --permanent --set-service=mysql --zone=internal    #永久配置
firewall-cmd --reload    #永久配置才需要
```
###### tips:  

对于 firewalld 的基本语法不够的情况，系统管理员还可以添加富规则（一种更具表达力的语法）来编写更加复杂的规则，如果富规则语法也不够，系统管理员还可以直接配置规则，基本上是将与 firewalld 规则混合使用的原始 iptables 语法。
