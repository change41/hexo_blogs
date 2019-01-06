---
title: Chapter 10.Analyzing and Storing Logs
url: 118.html
id: 118
categories:
  - RHEL124
date: 2018-04-11 14:59:33
tags:
---

![rhel-10-1.png](1523427823840955.png)

|*.info;mail.none;authpriv.none;cron.none|常规日志|messages|
| :-- | :-- |:--|
|authpriv.*|认证日志|secure|
|mail.*|邮件日志|maillog|
|cron.*|任务计划|cron|
|local7.*|启动信息|boot.log|
|uucp,news.crit|新闻类错误|spooler|
|kern.*|内核类|/dev/console|

可以在/etc/rsyslog.conf里配置额外的日志文件，类型如下表，例如
```bash
*.debug   /var/log/messages.debug
```
![rhel-10-2.png](1523429897556805.png)

  

#### journalctl

/run/log/journal   默认位置重启后会清除

如果/var/log/journal 存在，则journalctl 会将日志存放过来，存储大小一般不超过当前文件系统的10%，所以要保留15%的空间

/var/log/journal 文件的权限
```bash

chown root:systtemd-journal /var/log/journal

chmod 2755 /var/log/journal

drwxr-sr-x. 2 root systemd-journal 6 4月   9 16:33 journal/

```
##### 重启journald服务：

```bash

killall -USR1 systemd-journald

#或
reboot

```
 ==========================================================
```bash 

journalctl -n 5     #显示最后5条
journalctl -p err     #指定日志的优先级类型
journalctl -f     #等同于 tail -f

```
  

###### 指定日志的日期：

```bash

journalctl --since today  
journalctl --since 15:30:00  --until 15:35:00
journalctl --since "2018-04-09 15:30:00" --until "2018-04-09 16:00:00"

```  

查看详情,可是加在其它参数后面或者前面

```bash

journalctl -o verbose
journalctl   \_SYSTEMD\_UNIT=sshd.service   _PID=1182     #查看指定进程或服务的日志
journalctl --since 15:00:00 \_SYSTEMD\_UNIT=sshd.service

```  

 ==========================================================

##### rsyslog

```bash

/etc/rsyslog.conf

/etc/rysylog.d/*.conf

man 5 rsyslog.conf

http:// /usr/share/doc/rsyslog-*/manual.html

```  

 ==========================================================

##### logrotate 日志轮巡

/etc/logrotate.conf

/etc/logrotate.d/*.conf

 ==========================================================

##### 标准rsyslog格式

Apr  9 14:59:44 client systemd: Starting Session 2 of user root.

发生的日期  主机  产生日志的程序 ：日志内容

 ==========================================================

##### logger 程序生成日志记录到文件

```bash

logger -p local7.notice "Log entry created on ServerX" 生产notice 日志
logger -p user.debug "debug message test"  产生debug 日志

```  

 ==========================================================

##### 时间的维护：

```bash

tzselect     #交互式设备时区tz=timezone
timedatectl
timedatectl  list-timezones
timedatectl  set-timezone America/Phoenix
timedatectl  set-timezone Asia/Shanghai
timedatectl  set-time 9:00:00   #(YYYY-MM-DD hh:mm:ss)
timedatectl  set-ntp true/false

```  

 ========================================================== 

#### Configuring chronyd

/etc/chrony.conf

修改文件中的服务器位置

chronyc souces -v   验证NTP服务器，并显示详情

ntpd、ntpq 在Redhat7以前使用，用来管理NTP服务器
