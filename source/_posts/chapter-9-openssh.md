---
title: Chapter 9. Openssh
url: 128.html
id: 128
categories:
  - RHEL124
date: 2018-04-11 15:53:20
tags:
---



##### ssh host keys  

~/.ssh/known_hosts 保存服务器公钥  

/etc/ssh 下查看本机产生的密钥  

   

##### 基于用户名和密码  

 PasswordAuthentication yes  

##### 基于key密钥  

client:  

ssh-keygen 产生密钥(公钥和私钥)（~/.ssh/id\_rsa,id\_rsa.pub 默认）  

ssh-copy-id    root@server0  传输公钥到服务器  

server:  

ssh-copy-id 命令结束后，本端会产生认证文件  

 =========================================  

 #### 配置ssh  

###### 禁用root ssh登录  

/etc/ssh/sshd_config  

将#PermitRootLogin yes 改成PermitRootLogin no .去掉#，改yes为no,重启服务  

PermitRootLogin  without-password   设置root只能使用key方式  

###### 阻止密码认证方式  

PasswordAuthentication yes 改 no  

=========================================  

###### 高级功能ssh-agent  
  
ssh-add  


Administration Guide Chapter 8.2.4.2:Configuring ssh-agent  

https://access.redhat.com/documentation/en-us/red\_hat\_enterprise\_linux/7/html/system\_administrators_guide/s1-ssh-configuration  

ssh servername -X 调用远程服务的桌面环境到本地使用
