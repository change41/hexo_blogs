---
title: RH134 第七章 管理 SELINUX 安全性
url: 377.html
id: 377
categories:
  - RHEL134
date: 2018-05-21 17:41:40
tags:
---

### SElinux 安全的基本概念  

Security Enhanced Linux（SELinux）是一个额外的系统安全层。SELinux 的主要目标是防止已遭泄露的系统服务访问用户数据。大多数Linux管理员都熟悉标准的用户/组/其他权限安全模型。这种基于用户和组的模型称为自由决定的访问控制。SELinux 提供另一层安全，它基于对象并由更加复杂的规则控制，称为强制访问控制。

![blob.png](1526607016211181.png)

要允许远程匿名访问Web服务器，必须打开防火墙端口。然而，恶意人员却有机会通过安全漏洞侵入系统，而且如果他们破坏web 服务器进程，还会取得其权限，即apache 用户和apache 组的权限。该用户/组具有对文档根目录（/var/www/html）等项目的读取权限，以及对 /tmp 、/var/tmp 和所有人均可编写的任何其他文件/目录的写入权限  

![image.png](1526867174600183.png)

SELinux 是用于确定哪个进程可以访问哪些文件、目录和端口的一组安全规则。每个文件文件、进程和端口都具有特别的安全标签，称为SELinux 上下文。上下文是一个名称，SELinux 策略使用它来确定某个进程能否访问文件、目录或端口。除非显式规则授予访问权限，否则，在默认情况下，策略不允许任何交互。如果没有允许规则，则不允许访问。  

SELinux 标签具有多种上下文：用户、角色、类型和敏感度。目标策略（即 RHEL 中启用的默认策略）会根据类型上下文来制定自己规则。类型上下文名称通常以 \_t 结尾。

Web 服务器的类型上下文是 httpd_t 。

通常位于 /var/www/html 中的文件和目录的类型上下文是 httpd\_sys\_content_t 。 

通常位于 /tmp 和 /var/tmp 中的文件和目录的类型上下文是 tmp_t 。

Web 服务器端口的类型上下文是 http\_port\_t .

存在某个策略规则 ，其允许 Apache （作为httpd\_t 运行的Web 服务器进程）访问上下文通常位于 /var/www/html 及其他 Web 服务器目录 （httpd\_sys\_content\_t） 中的文件和目录。对于通常位于 /tmp 和 /var/tmp 中的文件，策略中没有允许 规则 ，因此不允许进程访问。有了 SELinux ，恶意用户就无法访问 /tmp 目录。SELinux 还有适用于 NFS 和 CIFS 等远程文件系统的规则，尽管这些文件系统上的所有文件都使用相同的上下文标签。  

许多处理文件的命令具有一个用于显示或设置 SELinux 的上下文选项（通常是 -Z ）.例如，ps、ls、cp 和 mkdir 全都使用 -Z 选项来显示或设置 SELinux 上下文。

![image.png](1526868364153324.png)

###### SELinux 模式  

若出于故障排除目的，可使用 SELinux 模式暂时禁用 SELinux 保护

![image.png](1526868454617069.png)  

在强制（Enforcing）模式中，SELinux 主动拒绝访问尝试读取类型上下文 tmp_t 的文件的Web 服务器。在强制模式中，SELinux 不仅记录而且提供保护。  



![image.png](1526868484423514.png)

许可（Permissive ）模式通常用于对问题进程故障排除，在许可模式中，即使没有显式规则， SELinux 也会允许所有交互，而且会记录它在强制模式中拒绝的那些交互。可使用此模式来暂时允许访问 SELinux 正在限制的内容。无需重新启动即可在强制模式和许可模式之间相互转换。

第三种模式是禁用（Disabled）模式，会完全禁用SELinux 。需要重新启动系统才能彻底禁用SELinux ，或是从禁用模式转为强制模式或许可模式。

###### TIPS:

最好使用许可模式，而不是彻底关闭 SELinux 。原因之一在于即使在许可模式中，内核也将根据需要自动维护 SELinux 文件系统标签，从而避免为了启用 SELinux 而重启系统，重新标记文件系统所带来的昂贵费用。

要显示当前使用的有效 SELinux 模式，使用 getenforce 命令  
```sh
[root@client ~]# getenforce 
Enforcing
```
###### SELinux 布尔值  

SELinux 布尔值的更改 SELinux 策略行为的开关。 SELinux  布尔值是可以启用或禁用的规则，安全管理可以使用 SELinux 布尔值来有选择地调整策略。

getsebool  命令用于显示 SELinux 布尔值及其当前值。 -a 选项可列出所有布尔值
```sh
[root@client ~]# getsebool -a
abrt_anon_write --> off
abrt_handle_event --> off
abrt_upload_watch_anon_write --> on
antivirus_can_scan_system --> off
………………
```
###### 更改 SELinux 模式

setenforce 命令修改当前的 SELinux 模式。
```sh
[root@client ~]# setenforce 
usage:  setenforce [ Enforcing | Permissive | 1 | 0 ]
```
暂时性设置 SELinux 模式的另一种做法是在启动时将参数传递给内核。传递内核参数 enforcing=0 会使系统在启动时进入许可模式。值 1 将指定强制模式。可在指定 selinux=0 参数时禁用 SELinux 。值 1 将启用 SELinux 。  

###### 设置默认 SELinux 

确定在启动时使用哪种 SELinux 模式的配置文件是 /etc/selinux/config .配置文件中包含有用的注释信息

![image.png](1526871627344712.png)

使用 /etc/selinux/config 更改启动时的默认 SELinux 模式。在上述示例中，它被设置为强制模式。  

传递 selinux= 和/或 enforcing= 内核参数会覆盖在 /etc/selinux/config 中指定的任何默认值。

###### 更改 SELinux 上下文

初始 SELinux 上下文

通常文件父目录的 SELinux 上下文决定该文件的初始 SELinux 上下文。父目录的上下文会分配给新建文件。这适用于 vim、cp、和touch等命令。但是，如果文件是在其他位置创建并且权限得以保留，（如使用 mv 或 cp -a），那么原始 SELinux 上下文将不会发生更改。

![image.png](1526872601651338.png)  

更改文件的 SELinux 上下文。可使用两个命令来更改文件 SELinux 上下文： chcon 和restorecon 。chcon 命令将文件的上下文更改成已指定为该命令参数的上下文。 -t 选项经常只用于指定上下文的类型。

restorecon 命令是更改文件或目录的 SELinux 上下文的首选方法。不同于 chcon ，在使用此命令时，不会明确指定上下文，它使用 SELinux 策略中的规则来确定应该是哪种文件上下文。

###### TIPS：

不应使用 chcon 来更改文件的 SELinux 上下文。在明确指定上下文时，可能会出错。如果在系统启动时重新标记了其它文件系统，文件上下文将会还原为默认上下文。
```sh
[root@server0 ~]# mkdir /virtual
[root@server0 ~]# ls -Zd /virtual/
drwxr-xr-x. root root unconfined_u:object_r:default_t:s0 /virtual/
[root@server0 ~]# chcon -t httpd\_sys\_content_t /virtual/
[root@server0 ~]# ls -Zd /virtual/
drwxr-xr-x. root root unconfined_u:object_r:httpd_sys_content_t:s0 /virtual/
[root@server0 ~]# restorecon -v /virtual/
restorecon reset /virtual context unconfined_u:object_r:httpd_sys_content_t:s0->unconfined_u:object_r:default_t:s0
[root@server0 ~]# ls -Zd /virtual/
drwxr-xr-x. root root unconfined_u:object_r:default_t:s0 /virtual/
```
###### 定义 SELinux 默认文件上下文规则  

semanage fcontext 命令可用于显示或修改 restorecon 命令用来设置默认文件上下文的规则。它使用扩展正则表达式来指定路径和文件名。fcontext 规则中最常用的扩展正则表达式是 (/.\*)?，这意味着：“（可选）匹配 / 后跟任意的字符”。它将会匹配在表达式前面列出的目录并递归地匹配该目录中的所有内容。

restorecon 命令是 policycoreutil 软件包的一部分； semanage 是 policycoreutil-python 软件包的一部分。
```sh
[root@server0 ~]# touch /tmp/file1 /tmp/file2
[root@server0 ~]# ls -Z /tmp/file*
-rw-r--r--. root root unconfined_u:object_r:user_tmp_t:s0 /tmp/file1
-rw-r--r--. root root unconfined_u:object_r:user_tmp_t:s0 /tmp/file2
[root@server0 ~]# mv /tmp/file1 /var/www/html/
[root@server0 ~]# cp /tmp/file2 /var/www/html/
[root@server0 ~]# ls -Z /var/www/html/
-rw-r--r--. root root unconfined_u:object_r:user_tmp_t:s0 file1
-rw-r--r--. root root unconfined_u:object_r:httpd_sys_content_t:s0 file2
[root@server0 ~]# semanage fcontext -l
………………
/var/www(/.*)?                                     all files          system_u:object_r:httpd_sys_content_t:s0 
………………
[root@server0 ~]# restorecon -Rv /var/www/
restorecon reset /var/www/html/file1 context unconfined_u:object_r:user_tmp_t:s0->unconfined_u:object_r:httpd_sys_content_t:s0
[root@server0 ~]# ls -Z /var/www/html/file
ls: cannot access /var/www/html/file: No such file or directory
[root@server0 ~]# ls -Z /var/www/html
-rw-r--r--. root root unconfined_u:object_r:httpd_sys_content_t:s0 file1
-rw-r--r--. root root unconfined_u:object_r:httpd_sys_content_t:s0 file2
```
以下示例显示了如何使用semanage 为新目录添加上下文。  
```sh
[root@server0 ~]# touch /virtual/index.html
[root@server0 ~]# ls -Zd /virtual/
drwxr-xr-x. root root unconfined_u:object_r:default_t:s0 /virtual/
[root@server0 ~]# ls -Z /virtual/
-rw-r--r--. root root unconfined_u:object_r:default_t:s0 index.html
[root@server0 ~]# semanage fcontext -a -t httpd\_sys\_content_t '/virtual(/.*)?'
[root@server0 ~]# restorecon -RFvv /virtual/
restorecon reset /virtual context unconfined_u:object_r:default_t:s0->system_u:object_r:httpd_sys_content_t:s0
restorecon reset /virtual/index.html context unconfined_u:object_r:default_t:s0->system_u:object_r:httpd_sys_content_t:s0
[root@server0 ~]# ls -Zd /virtual/
drwxr-xr-x. root root system_u:object_r:httpd_sys_content_t:s0 /virtual/
[root@server0 ~]# ls -Z /virtual/
-rw-r--r--. root root system_u:object_r:httpd_sys_content_t:s0 index.html

#实验
[root@server0 ~]# mkdir /custom
[root@server0 ~]# echo "This is server0" >/custom/index.html
[root@server0 ~]# vim /etc/httpd/conf/httpd.conf 
[root@server0 ~]# grep custom /etc/httpd/conf/httpd.conf 
DocumentRoot "/custom"
<Directory "/custom">
[root@server0 ~]# systemctl start httpd
[root@server0 ~]# semanage fcontext -a -t httpd\_sys\_content_t '/custom(/.*)?'
[root@server0 ~]# restorecon -Rv /custom/
restorecon reset /custom context unconfined_u:object_r:default_t:s0->unconfined_u:object_r:httpd_sys_content_t:s0
restorecon reset /custom/index.html context unconfined_u:object_r:default_t:s0->unconfined_u:object_r:httpd_sys_content_t:s0
```
###### 更改 SELinux 布尔值

SELinux 布尔值是更改 SELinux 策略行为的开关。 SELinux 布尔值是可以启用或禁用的规则。安全管理员可以使用 SELlinux 布尔值来有选择地调整策略。

selinux-policy-devel 软件包提供多个手册页（即 \*\_selinux(8)），可用于解释不同服务的布尔值的含义。如果已经安装此软件包，则 man -k '\_selinux' 命令会列出这些文档。

getsebool 命令用于显示SELinux 布尔值；setsebool 用于修改 SELinux 布尔值。setsebool -P 修改 SELinux 策略，并使修改永久保留。 semanage boolean -l 将显示布尔值是否为永久值，并提供该布尔值的简短描述。



getsebool -a     #查看所有boolean 值
```sh
getsebool httpd_enable_homedirs    #查看指定内容布尔值
setsbool httpd_enable_homedirs [ on | off | 0 | 1 ]     #设置布尔值，1=on,0=off
semanage boolean -l | grep httpd_eable_homedirs    # 查看布尔值是否为永久值（当前，永久）
setsebool -P httpd_enable_homedirs [ on | off | 0 | 1 ]     #设置永久布尔值
semanage boolean -l  -C    #仅列出本地修改的 SELinux 布尔值状态（与策略中默认值不同的任何设置）
```
###### 对 SELinux 进行故障的排除  

1、在考试做任何调整之前，应了解到SELinux 禁止意图访问的这一做法也许非常正确。当Web 服务器尝试访问 /home 中的文件时，如果用户并未发布 Web 内容，则可能表明服务器遭入侵。如果已授权访问权限，则需要采取其他步骤来解决此问题。

2、最常见的 SELinux 问题是使用不正确的文件上下文，此问题会在以下情况中发生：即，使用一个文件上下文在某个位置创建了文件，而该文件又被移至预期会使用其他上下文的地方。在大多数情况下，运行 restorecon 将会更正此问题。以这种方式更正问题对系统剩余部分的安全性有非常小的影响。

3、对于严苛限制性访问的另一个补救措施可以通过调整布尔值。例如：ftpd\_anon\_write 布尔值控制匿名 FTP 用户能否上传文件。如果希望允许匿名 FTP 用户上传文件到服务器，则必须启用此布尔值。调整布尔值需格外谨慎，因为布尔值会对系统的安全性造成广泛影响。

4、SELinux 策略可能存在阻止合法访问的漏洞。由于 SELinux 技术已经成熟，这种情况极少发生。

###### 监控 SELinux 冲突

必须安装setroubleshoot-server 包，以便将 SELinux 消息发送到 /var/log/messages 。setroubleshoot-server 侦听 /var/log/audit/audit.log 中的审核消息，并发送简短摘要到 /var/log/messages 。该摘要包括 SELinux 冲突的唯一标识符 （ UUID ），可用于收集更多信息。 sealert -l UUID  可用于生成特定事件的报告。 sealert -a /var/log/audit/audit.log 用于生成该文件中的所有事件报告。

![image.png](1526892834926496.png)

![image.png](1526892877639896.png)

![image.png](1526892917350022.png)

![image.png](1526892939342968.png)

###### TIPS：

“Raw Audit Messages”部分显示，目标文件 /var/www/html/file3 正是问题所在，同样，目标上下文 tcontext 似乎并不属于Web 服务器。使用 restorecon /var/www/html/file3 命令修复此文件上下文。如果还需要调整其它文件，restorecon 可递归地重置上下文：restorecon -R /var/www/

1、查看 tail -f /var/log/messages  查看有sealert 的内容，确定事件 UUID 

2、运行给出的 sealert -l UUID 查看解决办法

3、运行 2 中的命令给出信息的头部是建议解决方案

4、查看 "Raw Audit Messages" 确定问题文件，给结合步骤 3 给出解决方案。
