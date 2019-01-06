---
title: iptables 端口转发
url: 269.html
id: 269
categories:
  - 未分类
date: 2018-04-24 11:26:46
tags:
---

##### 将firewalld切换到 iptables  
1\. 停止并禁用 firewalld  
```sh
sudo systemctl stop firewald.service && sudo systemctl disable firewald.service  
```
2.安装iptables-services、iptables-devel  
```sh
sudo yum install iptables-services iptables-devel  
```
3.启用并启动iptables  
```sh
sudo systemctl enable iptables.service && sudo systemctl start iptables.service
```
* * *



**a.同一端口转发**(192.168.0.132上开通1521端口访问 
  ```sh
iptables -A RH-Firewall-1-INPUT -m state --state NEW -m tcp -p tcp --dport 1521 -j ACCEPT)
iptables -t nat -I PREROUTING -p tcp --dport 1521 -j DNAT --to 192.168.0.211  
iptables -t nat -I POSTROUTING -p tcp --dport 1521 -j MASQUERADE  
```  
**b.不同端口转发**(192.168.0.132上开通21521端口访问 
  ```sh
iptables -A RH-Firewall-1-INPUT -m state --state NEW -m tcp -p tcp --dport 21521 -j ACCEPT)

iptables -t nat -A PREROUTING -p tcp -m tcp --dport**21521** -j DNAT --to-destination**192.168.0.211:1521**  
iptables -t nat -A POSTROUTING -s 192.168.0.0/16 -d 192.168.0.211 -p tcp -m tcp --dport 1521 -j SNAT --to-source 192.168.0.132  
```  

**以上两条等价配置(更简单\[指定网卡\]):**  
```sh
iptables -t nat -A PREROUTING -p tcp -i eth0 --dport 31521 -j DNAT --to 192.168.0.211:1521  
iptables -t nat -A POSTROUTING -j MASQUERADE  
```

###### 保存iptables  
```sh
service iptables save  

service iptables restart
```
##### 二、 用iptables做本机端口转发  

  代码如下：  
```sh
iptables -t nat -A PREROUTING -p tcp --dport 80 -j REDIRECT --to-ports 8080  
```
  估计适当增加其它的参数也可以做不同IP的端口转发。  
  如果需要本机也可以访问，则需要配置OUTPUT链(********特别注意:本机访问外网的端口会转发到本地,导致访不到外网,如访问yown.com,实际上是访问到本地,建议不做80端口的转发或者指定目的 -d localhost)：  
```sh
  iptables -t nat -A OUTPUT -d localhost -p tcp --dport 80 -j REDIRECT --to-ports 8080  
```
原因：  
外网访问需要经过PREROUTING链，但是localhost不经过该链，因此需要用OUTPUT。  

#######################################################################################  

概述：公司有一些核心MySQL服务器位于核心机房的内网段，作为运维人员，经常需要去连接这些服务器，因无法直接通过外网访问，给管理造成了不便。  

思路：虽然解决此问题的方法及思路有很多，但当下想使用IPTABLES的端口重定向功能解决此问题，比较简单易用，而且扩展性也比较好，依次类推，可以运用到其他的端口转发方面的应用。  
##### 网络环境：  
公网服务器      ：eth0:公网IP    eth1:内网IP - 192.168.1.1  
mysql服务器：eth1:内网IP - 192.168.1.2  
实现方法：通过访问公网IP的63306端口来实现到内网MYSQL服务器的3306端口的访问  
##### 在公网服务器上：  
###### 配置脚本：  
```sh
iptables -t nat -A PREROUTING -p tcp --dport 63306 -j DNAT --to-destination 192.168.1.2:3306  
iptables -t nat -A POSTROUTING -d 192.168.1.2 -p tcp --dport 3306 -j SNAT --to 192.168.1.1  
```
###### 允许服务器的IP转发功能：
```sh  
echo 1 > /proc/sys/net/ipv4/ip_forward  
```
###### 使用方法：
```sh  
mysql -h 公网IP -p 63306 -uroot -p  
```
 ###############################################################################################  

由于业务需要，服务器越来越多，内网服务器无外网环境管理甚是不便，所以折腾了一下外网到内网的端口转发以达到轻松管理的目的，贴一下心得。  

###### S1:  
eth0 10.0.0.1  
eth1 x.x.x.x  

###### S2:  
eth0 10.0.0.2  

S1 8082端口转发到内网机器22端口  
iptables规则配置如下：  
```sh
iptables -t nat -A PREROUTING -d x.x.x.x -p tcp --dport 8082 -j DNAT --to-destination 10.0.0.2:22  
iptables -t nat -A POSTROUTING -d 10.0.0.2 -p tcp --dport 22 -j SNAT --to-source x.x.x.x  
````
说明：  
```sh
iptables -t nat -A PREROUTING -d "对外公网ip" -p tcp --dport "对外端口" -j DNAT --to "内部实际提供服务的ip":"实际提供服务的端口"  
iptables -t nat -A POSTROUTING -d "内部实际提供服务的ip"-p tcp --dport "实际提供服务的端口" -j SNAT --to-source "运行iptables机器的内网ip"
```
* * *
