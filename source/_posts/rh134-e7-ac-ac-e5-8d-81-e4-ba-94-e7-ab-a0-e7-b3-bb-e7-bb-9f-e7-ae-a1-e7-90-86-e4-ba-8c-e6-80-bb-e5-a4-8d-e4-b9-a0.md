---
title: RH134 第十五章 系统管理二总复习
url: 525.html
id: 525
categories:
  - RHEL134
date: 2018-10-18 17:17:36
tags:
---

一、系统应借助以下设置业验证使用 LDAP 和 Kerberos  的用户身份：  

|   名称 |  值 |
| :------ | :-------- |
| LDAP 服务器 | classroom.example.com |
| 搜索基础 | dc=example,dc=com |
| 使用 TLS | 是 |
| TLS CA 证 | http://classroom.example.com/pub/example-ca.crt |
| Kerberos 域 | EXAMPLE.COM |
| Kerberos KDC | classroom.example.com |
| Kerberos 管理服务器 | classroom.example.com |


为了进行测试，可用用户ldapuserX ,密码为kerberos 

1、安装 authconfig-gtk , sssd 软件包
```sh
[student@desktop0 Desktop]$ sudo yum install -y authconfig-gtk sssd
```
2、运行authconfig-gtk ,并输入提供的信息，请不要忘记取消选中使用 DNS 查找域的 KDC 选项  
```sh
[student@desktop0 Desktop]$ sudo authconfig-gtk
```
![image.png](1539846626591619.png)

二、LDAP 用户的主目录应当在访问时自动挂载。这些主目录是由NFS 共享 classroom.example.com:/home/guests 提供的

1、安装autofs 软件包
```sh
[student@desktop0 Desktop]$ sudo yum install autofs -y
```
2、创建包含以下内容的新文件 /etc/auto.master.d/guests.autofs
```sh
/home/guests /etc/auto.guests
```
3、创建包含以下内容的新文件 /etc/auto.guests
```
* -rw,sync classroom.example.com:/home/guests/&
```
4、启用并启动 autofs.service 服务
```sh
[student@desktop0 Desktop]$sudo systemctl enable autofs.service
[student@desktop0 Desktop]$sudo systemctl start autofs.service
```
三、server0 会导出 CIFS 共享，westeros 。该共享应当在启动时自动挂载到挂载点 /mnt/westeros 。要挂载该共享，您需要使用用户名 tyrion 密码 slapjoffreyslap 。该密码不应存储在非特权用户只可以读取的任何位置。

1、安装 cifs-utils 软件包
```sh
[student@desktop0 Desktop]$ sudo yum install cifs-utils -y
```
2、创建挂载点  
```sh
[student@desktop0 Desktop]$sudo mkdir -p /mnt/westeros
```
3、创建包含以下内容的凭据文件，/root/tyrion.creds，然后将该文件的权限设置为：0600  
```
username=tyrion
password=slapjoffryslap
```
```sh
[student@desktop0 Desktop]$sudo chmod 0600 /root/tyrion.creds
```
4、将以下行添加到 /etc/fstab：  
```sh
//server0.example.com/westeros /mnt/westeros cifs creds=/root/tyrion.creds 0 0
```
5、挂载所有文件系统，然后检查挂载的文件系统。  
```sh
[student@desktop0 Desktop]$sudo mount -a
[student@desktop0 Desktop]$cat /mnt/westeros/README.txt
```
四、server0 会导出 NFSv4 共享 /essos  。需要使用 Kerberos 身份验证、加密和完整性检查来在启动时将该共享以只读写形式挂载到 /mnt/essos 。

可以从 [http://classroom.example.com/pub/keytabs/desktop0.keytab](http://classroom.example.com/pub/keytabs/desktop0.keytab) 下载系统的keytab 

1、创建挂载点
```sh
[student@desktop0 Desktop]$sudo mkdir -p /mnt/essos
```
2、下载系统的 keytab   
```sh
[student@desktop0 Desktop]$sudo wget -O /etc/krb5.keytab http://classroom.example.com/pub/keytabs/desktop0.keytab
```
3、将以下行添加到 /etc/fstab :  
```sh
[student@desktop0 Desktop]$server0.example.com:/essos /mnt/essos nfs sec=kerb5p,rw 0 0
```
4、启动并启用 nfs-secure.service 服务  
```sh
[student@desktop0 Desktop]$sudo systemctl enable nfs-secure.service 
[student@desktop0 Desktop]$sudo systemctl start nfs-secure.service
```
5、挂载所有文件系统
```sh
[student@desktop0 Desktop]$sudo mount -a
```
五、在新的2 G 卷组stark 中配置新 512M 逻辑卷 arya 。  

新逻辑卷应使用 xfs 文件系统进行格式化，并永久挂载到 /mnt/underfoot 

1、在第二块磁盘上创建 2G 的分区

![image.png](1539847801848346.png)

2、将新分区变为物理卷
```sh
[student@desktop0 Desktop]$sudo pvcreate /dev/sdb1
```
3、使用新物理卷构建新卷组  
```sh
[student@desktop0 Desktop]$sudo vgcreate stark /dev/sdb1
```
4、在新卷组中创建 512M 的新逻辑卷  
```sh
[student@desktop0 Desktop]$sudo lvcreate -n arya -L 512M stark
```
5、使用 xfs 文件系统对新 LV 进行格式化  
```sh
[student@desktop0 Desktop]$ sudo mkfs -t xfs /dev/mapper/stark-arya
```
6、创建挂载点   
```sh
[student@desktop0 Desktop]$sudo mkdir -p /mnt/underfoot
```
7、将以下行添加到 /etc/fstab   
```sh
/dev/mapper/stark-arya /mnt/underfoot xfs defaults 1 2
```
8、挂载所有文件系统  
```sh
[student@desktop0 Desktop]$sudo mount -a
```
六、系统应该配备新的 512 M 交换分区，并在启动时自动激活。  

1、第二块磁盘上创建 512 M 的新分区，然后将该分区类型设置为 82 

![image.png](1539848579837356.png)

2、将新分区格式化成交换分区  
```sh
[student@desktop0 Desktop]$sudo mkswap /dev/sdb2
```
3、检索UUID 中的交换分区  
```sh
[student@desktop0 Desktop]$sudo blkid /dev/sdb2
```
4、向/etc/fstab 添加以下行；确保使用上一步找到的UUID，假设为UUID=dfce28a9-015d-4908-8206-840920260310  
```sh
UUID=dfce28a9-015d-4908-8206-840920260310  swap swap defaults 0 0
```
5、激活所有交换分区  
```sh
[student@desktop0 Desktop]$sudo swapon -a
```
七：创建新组 kings ，以及四个属于该组的新用户： stannis，joffery,renly和robb。  

1、创建 kings 组
```sh
[student@desktop0 Desktop]$sudo groupadd kings
```
2、创建四个用户，并将他们添加到kings 组   
```sh
[student@desktop0 Desktop]$for NEWUSER in stannis joffrey renly robb; do
>sudo useradd -G kings ${NEWUSER}
>done
```
八、创建新目录 /ironthrone  该目录由拥有权限 0700 的 root:root 所有。

配置该目录，以便 kings 组中的用户拥有该目录的读写权限，但用户 joffrey 除外，该用仅被授予读取特权。

这些限制还应当应用到 /ironthrone 目录下创建的所有新文件和目录。

1、创建权限正常的目录
```sh
[student@desktop0 Desktop]$sudo mkdir -m 0700 /ironthone
```
2、 在 /ironthone 中添加 ACL ，从而向 kings 组中的用户授予读写特权。请不忘记添加执行权限，因为这是一个目录。  
```sh
[student@desktop0 Desktop]$sudo setfacl -m g:kings:rwX /ironthone
```
3、为用户 joffrey 添加ACL ，使其拥有只读和执行权限  
```sh
[student@desktop0 Desktop]$sudo setfacl -m u:joffrey:r-x /ironthone
```
4、也添加前两个 ACL 作为默认 ACL   
```sh
[student@desktop0 Desktop]$sudo setfacl -m d:g:kings:rwx /ironthone
[student@desktop0 Desktop]$sudo setfacl -m d:u:joffrey:r-x /ironthone
```
九、安装 httpd 和 mod_ssl 软件包，然后启用并启动 httpd.service 服务

1、安装 httpd 和 mod_ssl 软件包
```sh
[student@desktop0 Desktop]$sudo yum install httpd mod_ssl -y
```
2、启动并启用 httpd.service 服务  
```sh
[student@desktop0 Desktop]$sudo systemctl enable httpd
[student@desktop0 Desktop]$sudo systemctl start httpd
```
十、在系统上所有行防火墙的默认区域打开端口12345/tcp 

1、在防火墙默认区域永久配置中打开端口 12345/tcp 
```sh
[student@desktop0 Desktop]$sudo firewall-cmd --permanent --add-port=12345/tcp
```
2、重新加载防火墙以激活更改  
```sh
[student@desktop0 Desktop]$sudo firewall-cmd --reload
```
十一、创建新目录 /docroot 。确保该目录的 SELinux 上下文设置为 Public\_content\_t ，并且该上下文在重新标记操作后继续生效  

1、创建/docroot 目录
```sh
[student@desktop0 Desktop]$sudo mkdir /docroot
```
2、为 /docroot 目录及其所有子目录添加新的默认上下文  
```sh
[student@desktop0 Desktop]$sudo semanage fcontext -a -t public_content_t '/docroot(/.*)?'
```
3、重新标记 /docroot 目录  
```sh
 [student@desktop0 Desktop]$sudo restorecon -RvF /docroot
```
十二、http://server0.example.com/logfile 包含最近项目的日志。下载该文件，然后将所有以 ERROR 或 FAIL 结尾的行提取到文件 /home/student/errors.txt ，所有行都应按日志文件中显示的顺序排列。  

1、下载文件
```sh
[student@desktop0 Desktop]$wget http://server0.example.com/logfile
```
2、将以 ERROR 和 FAIL 结尾的第一行提取到文件 /home/student/errors.txt 中，同时保持行顺序不变  
```sh
[student@desktop0 Desktop]$grep -e "ERROR$" -e "FAIL$" logfile > /home/student/errors.txt
```
十三、系统中应该有一个用于存储临时文件 /run/veryveryvolatile 的新目录。每当运行 systemd-tmpfiles --clean 时，任何超过 5秒的文件都应该从该目录中删除。  

该目录应该拥有权限 1777 并由 root:root 所有。

1、创建包含以下内容的新文件 /etc/tmpfiles.d/veryveryvolatile.conf:
```sh
d /run/veryveryvolatile 1777 root root 5s
```
2、使用 systemd-tmpfiles 创建目录。  
```sh
[student@desktop0 Desktop]$sudo systemd-tmpfiles --create
```
