---
title: RH134 第四章 计划将来的linux 任务
url: 354.html
id: 354
categories:
  - RHEL134
date: 2018-05-14 09:25:12
tags:
---

**使用at 计划一次性任务**

at 不是单机工具，而是一个系统守护进程（atd），它有一组命令行工具可与守护进程（at,atd 等）进行交互。在默认的RHEL安装过程中，atd 守护进程将自动安装和启用。atd 守护进程可以在at软件包中找到。

用户（包括root）可使用命令行工具 at 为 atd 守护进程的作业排除。atd 守护进程提供了 a 到 z 共26个队列。作业按字母顺序排列，队列越后，系统优先级越低

**计划作业**

使用命令 at <TIMESPEC> 可以计划新作业。at 随后会读取从stdin 执行的命令。对于较大的命令以及错别字敏感的命令，使用来自脚本文件(例如at now +5min <myscript) 的输入重定向比在终端窗口中手动输入所有命令要简单。手动输入命令时，可以通过 Ctrl +D 来完成输入。

<TIMESPEC> 允许许多强大的组合，使用户（几乎）可以自由地来说明应运行作业的确切时间。通常这些组合以时间（例如02:00pm,13:59 甚至teatime）开头，后面接一个可选日期或将来的天数。

*   now +5min

*   teatime tomorrow (下等茶时间16:00)

*   noon +4    days  (noon 12:00)

*   5pm august 3 2016 


**检查管理作业**

stq 或者 at -l 
```sh
[root@desktop0 ~]# at -l    #查看任务计划
1Wed May  9 12:00:00 2018 a root
#共4列
```


*   作业编号，当前为1

*   该作业计划的日期和时间，Wed May 9 12:00:00 2018

*   作业所在队列是a

*   作业所有者（以及将运行作业的用户身份），当前为root




普通的非特权用户只能查看和控制自己的作业。root 可以查看和管理所有作业  

要检查执行作业时运行的实际命令，请使用命令at -c <JobNumber> ,该输入首先会显示所设置作业环境，以便在用户创建作业时反映用户的环境，后跟运行的实际命令。

**删除作业**

atrm <JobNumber\> 将会删除计划的作业。当不再需要作业时（例如，远程防火墙配置成功且不需要重置时）

atrm 1    #删除任务计划 1

```sh

[root@desktop0 ~]# echo "date > ~/myjob" | at now +3min    #设置任务计划
job 4 at Tue May  8 15:16:00 2018
[root@desktop0 ~]# atq        #查看任务计划
4Tue May  8 15:16:00 2018 a root

[root@desktop0 ~]# at -q g teatime tomorrow    #在任务队列 g 创建作业任务
at> touch /home/student/tea            #任务内容
at> <EOT>                        #Ctrl + D 退出任务编辑
job 6 at Wed May  9 16:00:00 2018
[root@desktop0 ~]# atq        #   查看任务
6Wed May  9 16:00:00 2018 g root
[root@desktop0 ~]# at -q b 16:05 tomorrow    #在任务队列 b 创建作业任务
at> touch /home/student/cookies
at> <EOT>
job 7 at Wed May  9 16:05:00 2018
[root@desktop0 ~]# atq    #查看
6	Wed May  9 16:00:00 2018 g root
7	Wed May  9 16:05:00 2018 b root
[root@desktop0 ~]# at -c 6     #查看作业任务6的详细信息
[root@desktop0 ~]# atrm 6    #删除
[root@desktop0 ~]# atq
7	Wed May  9 16:05:00 2018 b root
```

**使用cron计划周期性作业**

at 是一次性作业任务，在RHEL 中附带了特别针对周期性作业的crond 守护进程，且默认开机启用并启动。crond 是由多个配置文件和系统范围内的文件控制的，每个用户对应一个配置文件（使用crontab(1) 命令进行编辑）。这些配置文件使用户和管理员拥有细微的控制权，可以控制应执行周期性作业的确切时间。crond 守护进程作为 cronie软件包的一部分安装。  

如果从cron 作业运行的命令向末重定向的 stdout 或 stderr 生成任何输出，则crond 守护进程将尝试使用系统中配置的邮件服务器将该输出通过电子邮件发送给拥有该作业的用户（除非被覆盖）。根据环境，这可能需要其它配置。

**计划作业**

普通用户使用crontab 命令来管理作业，可以通过四种方式调用该
命令：

|命令|预期用途
| :--
|crontab -l|列出当前用户的计划任务
|crontab -r|删除当前用户的所有计划任务
|crontab -c|编辑当前用户的计划任务
|crontab <filename>|删除所有作业，并替换为从<filename>读取作业。如果未指定任何文件，则将使用stdin 

root 可以使用 -u  username 选项管理其他用户的作业。不建议使用crontab 命令来管理系统作业。

在使用crontab -e 编辑作业时，编辑器会启动（如果editor 环境变量尚未设置其它值，则默认为vi），正在编辑的文件，每行均有一个作业。允许有空行，并且注释的行以 （#）开头。环境变量也可以使用格式：NAME=value 来声明，并且会影响声明所在行下面的所有行。crontab 中的常见变量包括 SHELL 和 MAILTO 。设置SHELL 变量将会更改用于其下面的行中执行命令的shell ，而设置 MAILTO 变量将会更改发送到电子邮件地址输出（所有）

重要提示：发送电子邮件可能需要另外配置本地邮件服务器或系统中的SMTP转发

各个作业都包含 6 个字段，详述了执行的时间和内容，如果前 5 个字段都与当前日期和时间相匹配，则会执行最后一个字段中的命令，这些字段包括：

*   分钟 

*   小时 

*   几号 

*   月份 

*   星期几 

*   命令


如果几号和星期几字段都不是 \* ，则该命令将在其中任一字段匹配时执行，例如 \* \* 15 * 5 ls ,将在每月 15 号或每周 5 执行ls命令

前 5 个字段全部使用相同的语法规则：

*   \* 表示“无关紧要”/始终

*   数字可用于指定分钟，小时，日期或工作日。（对于工作日0 - 7，0表示星期日，1表示星期一，依次类推。7也表示星期日）

*   x-y 表示范围，x到y(含)

*   x,y 表示列表。列表也可以包含范围，例如“分钟”列中的5,10-13,17,表示作业应当在每小时的第5，10-13，17分钟分别运行一次

*   \*/x 表示x的时间间隔，例如分钟列 \*/7 表示每 7 分钟运行一次。


此外，可以使用三个字母的英文缩写来表示月份和工作日，例如Jan ,Feb 以及 Tue , Wed .

最后一个字段包含要执行的命令，如果尚未声明shell的环境变量，则该命令将由 /bin/sh 执行。如果命令中包含未转义的百分比符号(%),则该百分比符号将被当作新行，且百分比符号之后的所有内容将反馈到stdin 中的命令。
```sh
0 9 2 2 * /usr/local/bin/yearly\_bakcup    #在每年的2月2上午9点整执行命令 /usr/local/yearly\_backup
*/7 9-16 * Jul 5 echo "China"      #在七月每周五的上午9点 和下午5点之间，每七分钟向该作业的所有者发送包含单词的 China 的电子 邮件
58 23 * * 1-5 /usr/local/bin/daily\_report    #在每个工作日午夜前2分钟运行命令/usr/local/daily\_report
0 9 * * 1-5 mutt -s "Checking in" boss@example.com % Hi there boss ,just checking in . 
#在每个工作日（周一到周五）的上午9点整，使用mutt 向 boss@example.com 发送邮件。
```

```sh
[student@desktop0 ~]$ crontab -e
no crontab for student - using an empty one
crontab: installing new crontab
[student@desktop0 ~]$ crontab -l
*/2 9-16 * * 1-5 date >> /home/student/my_first_cron_job
[student@desktop0 ~]$ cat my_first_cron_job 
Tue May  8 17:10:02 CST 2018
[student@desktop0 ~]$ crontab -r
[student@desktop0 ~]$ crontab -l
no crontab for student
[student@desktop0 ~]$
```
**计划系统cron作业**

除了用户cron作业外，还有系统cron作业，系统cron作业不是使用crontab 命令定义的，而是在一组配置文件中配置的。这些配置文件之间主要区别在于一个额外的的字段，该字段位置位置星期几和命令字段之间，指定了作业应在哪个用户下运行。

/etc/crontab 的随附注释中包含了实用的语法图

![image.png](1525771056304457.png)

系统作业配置文件在 /etc/crontab 和 /etc/cron.d/* .安装cron 作业的软件包应当通过在/etc/cron.d/ 中放置文件才能执行安装操作，但是，管理员还可以使用此位置来更轻松的将相关作业分到单个文件中，或者使用配置管理系统推送作业。

还有预定义作业每小时，每天、每周和每月运行一次，这个作业将分别执行位于/etc/cron.hourly/ 、/etc/cron.daily/、/etc/cron.weekly 和 /etc/cron.monthly/ 中的所有脚本，请注意，这些目录包含可执行脚本，而不包含cron配置文件 。

/etc/cron.hourly/* 脚本是使用run-parts 命令从/ec/cron.d/0hourly 中定义的作业执行的，每日、每周和每月的作业也使用run-parts命令执行，但是人其它配置文件 /etc/anacrontab 执行。  

过程anacrontab 是由单独的守护进程(anacron)处理的，但是在RHEL 7 中，该文件由常规crond 守护进程解析。该文件旨在确保重要的作业始终运行，且不会因为系统在应执行作业时关闭或休眠而意外跳过。

/etc/anacrontab 的语法与其它cron 配置文件有所不同。它每行正好包含四个字段：

Period in days    #每多少天运行一次
Delay in minutes     #在启动该作业前，cron守护进程应等待的时间
Job identifier     #此为 /var/spool/anacron/ 中文件的名称，该文件将用于检查该作业是否已运行。在cron 从/etc/anacrontab 启动作业时，它会更新此文件的时间戳。同一时间戳可用于检查 作业上次运行的时间。
Command    #要执行的命令



/etc/anacrontab 还包含使用语法 NAME=value 的环境变量声明，特别相关的是 START\_HOURS\_RANGE: 作业不会在些范围外启动。

**管理临时文件**

使用systemd-tmpfiles 管理临时文件

用户高度可见的临时文件和目录（常规用户所使用和滥用的/tmp）  

特定于任务的历史文件和目录（例如守护进程以及/run下特定用户的易失性目录，易失性的文件值存在内存中，在系统重启或断电时，所有内容都会丢失。）

为保持系统充分运行，有必要创建那些不存在的目录和文件，因为守护进程可能会依靠它们存在，而清除旧文件后就不会填满磁盘空间或提供错误信息。

旧版本中，系统管理员依靠RPM软件包和systemV初始脚本来创建这些目录，依靠名为tmpwatch的工具来配置目录中删除未使用的旧文件。在RHEL7 中，systemd 提供了一个更加结构化的可配置方法来管理临时目录和文件，systemd-tmpfiles.

在systemd启动系统后，其中一个启动的服务单元是systemd-tmpfiles-setup。该服务运行命令：
```sh
systemd-tmpfiles --create
systemd-tmpfiles --remove
systemd-tmpfiles --clean
```


该命令会从 /usr/lib/tmpfiles.d/\*.conf、/run/tmpfiles.d/\*.conf 和 /etc/tmpfiles.d/\*.conf 读取配置文件。系统将会删除这些配置文件中标记要删除的任何文件和目录，并且会创建标记要创建（或修复权限）的任何文件和目录，并使其拥有正确的权限（如有必要）

**定期清理**

为确保长期运行的系统不会用陈旧数据填满磁盘，也有一个systemd 定时器单元会按固定间隔调用systemd-tmpfiles --clean 

systemd 定时器单元是一类特殊的systemd服务，它有一个\[Timer\]块会指示同名服务的启动频率。

在RHEL 7 系统中，systemd-tmpfiles-clean.timer 单元的配置如下所示：

![blob.png](1526219726507971.png)

这表示同名服务（systemd-tmpfiles-clean.service）将在systemd启动15分钟后启动，然后每隔24小时启动一次。

命令systemd-tmpfiles --clean 解析的配置文件与systemd-tmpfiles --create 相同，但前者不会创建文件和目录，而是会清楚在比配置文件中定义的最长期限更近的时间尚未访问、更改或修改的所有文件。

**tip:**

man page tmpfiles.d(5)声称，系统会删除时间“长于”配置文件中日期字段的期限文件。这并不完全正确。

Linux 文件系统中遵循PSOSIX标准的文件有三个时间戳：atime(上次访问文件的时间)、mtime（上次修改文件内容的时间）、以及 ctime （上次由 chown 、chmod等更改文件状态的时间）。大多数 Linux 文件系统都没有创建时间戳。这在类似Unlix 的文件系统中很常见。

如果这三个时间戳比systemd-tmpfiles期限配置都旧，则文件将会被视为未使用。如果其中任一时间戳比期限配置新，则根据systemd-tmpfiles的期限将不会删除文件。

可以在文件上运行stat 命令(stat filename)，以查看所有这三个时间戳的值，ls -l 命令通常会显示mtime。



**systemd-tmpfiles 配置文件**

tmpfiles.d(5) 手册中详述了system-tmpfiles的配置文件格式

基本语法由七列构成：“类型”、“路径”、“模式”、UID、GID、“期限”和“参数”。“类型”指的是systemd-tmpfiles应执行的操作；例如 d 表示创建还不存在的目录，或者 Z 表示以递归方式恢复SElinux 上下文以及文件权限和所有权。  

d /run/systemd/seats 0755 root root -
\#在创建文件和目录是，如果目录/run/systemd/seats还不存在，则创建该目录，所有者为用户root和组root,权限设置为 rwxr-xr-x.系统不会清除该目录。
D /home/student 0700 student student 1d
\#如果目录/home/student 还不存在，请创建该目录。如果存在，则清空其所有内容。运行systemd-timpfiles --clean 时，删除在超过一天时间内尚未被访问、更改或修改过的所有文件
L /run/fstablink - root root /etc/fastab
\#创建指向/etc/fstab的符号链接 /run/fstablink 。绝对不要自动清除这一行。



配置文件优先级，配置文件位置可位于三个位置：

/etc/tmpfiles.d/*.conf
/run/tmpfiles.d/*.conf
/usr/lib/tmpfiles.d/*.conf



/usr/lib/tmpfiles.d/ 中的文件是由相关RPM软件包提供的，不应该由系统管理员进行编辑。

/run/tmpfiles.d/ 下的文件本身是易失性文件，通常有守护进程用来管理自己运行时的临时文件。

/etc/tmpfiles.d/ 下的文件旨在供管理员配置自定义临时位置，以及覆盖供应商提供的默认值。

如果出现同名配置文件优先权依次是： /etc/tmpfiles.d/ >> /run/tmpfiles.d/ >> /usr/lib/tmpfiles.d/ 。

给定优先权规则后，管理员将相关文件复制到/etc/tmpfiles.d/ 然后编辑该配置文件，即可轻松覆盖供应商提供的设置。如果以这种方式工作，则确保可从中央配置管理系统轻松管理管理员提供的设置，并且软件包的更新不会覆盖这些设置。  

在测试新配置或修改后的配置时，对于仅在一个配置文件外应用命令会十分有用。在命令行中指定配置文件中的名称即可实现这一点。

systemd-tmpfiles --creat tmp.conf    #测试tmp.conf文件
systemd-tmpfiles --clean tmp.conf
