---
title: RH134 第十一章 访问具有网络文件系统（NFS）的网络存储
url: 437.html
id: 437
categories:
  - RHEL134
date: 2018-09-10 17:47:03
tags:
---

###### 手动挂载和卸载 NFS 共享

NFS （网络文件系统）是由Linux 、UNIX 及类似操作系统用作本地文件系统的一种互联网标准协议。它是一种活动扩展之下的开放标准，可支持本地 Linux 权限和文件系统功能。

RHEL 7 在默认情况下支持NFSv4 （版本4）,向下兼容v3及v2版本。NFSv4使用 TCP 协议与服务器进行通信，而较早版本的NFS则可能使用 TCP 或UDP 。

NFS 服务器导出共享（目录）,而NFS 客户端将导出的共享挂载到本地挂载点（目录）.本地挂载点必须已存在。可以通过多种方式挂载NFS 共享

*   使用mount 命令手动挂载 NFS 共享。

*   使用/etc/fstab 在启动时自动挂载 NFS共享。

*   通过称为自动挂载的过程要挂需要挂载 NFS 共享。


###### 保护 NFS 共享的文件访问权限

NFS 服务器通过多种方法保护文件的访问权限：none ,sys,krb5,krb5i和 krb5p .NFS 服务器可以选择为每个导出的共享提供一种方式或多种广场。NFS 客户端必须使用为已导出共享规定的方法之一连接到该共享，该方法以挂载选项 sec=method 的形式指定。

###### 安全性方法：  

none:可对文件进行匿名访问，对服务器的写入（如允许）将分配 UID,GID为nfsnobody 

sys:文件访问权限基于UID和GID的值的标准Linux 文件权限。如果未指定，则此方法是默认值

krb5:客户端必须使用Kerberos 证明身份，然后适用标准Linux 的文件权限 

krb5i:添加加密性强的保证，确保每个请求中的数据未被篡改。

krb5p:为客户端与服务器之间的所有请求添加加密，防止网络中的数据泄露。这会对性能产生影响。

###### TIPS：

Kerberos 选项将至少需要 /etc/krb5,keytab和本节中未论述的其它身份验证配置（加入kerberos域）。/etc/krb5.keytab 通常将由身份验证或安全性管理员提供。请求包含主体和 / 或 nfs 主体（最好包含两者）的keytab

连接到Kerberos 保护的共享时，NFS 使用 nfs-secure 服务来帮助协商和管理与服务器之间的通信。此服务必须正在运行，才能使用受保护的NFS共享；对其使用 start 和 enable 命令以确保其始终可用。
```sh
yum install -y nfs-secure
systemctl enable nfs-secure
systemctl start nfs-secure
```
######  挂载 NFS 共享有三个基本步骤：

1、识别 NFS 服务器的管理员可能提供导出详细信息，包括安全性要求。或者 NFSv4 共享可通过挂载NFS 服务器的根文件并浏览已导出目录来识别。以root 用户身份执行此操作。使用 Kerberos 安全对共享的访问将被拒绝，但共享（目录）名称将可见。可以浏览其它共享目录。
```sh
mkdir /mountpoint
mount /serverX:/ /mountpoint 
ls /mountpoint
```
可以使用 showmount 发现 NFSv2和 NFSv3共享
```sh
showmount -e serverX
```
2、挂载点：使用mkdir  在合适的地方创建挂载点
```sh
mkdir -p /mountpoint
```
3、挂载：这里有两种选择，手动挂载，或并入 /etc/fstab 文件中，为任一操作切换到root 或使用sudo

*   手动使用 mount 命令

```sh
mount -t nfs -o sync serverX:/share /mountpoint
```
-t nfs 选择是 NFS 共享的文件系统类型（未严格要求）。-o sync 选择使用 mount 立即与 NFS 服务器同步写操作（默认为异步）。默认安全性方法（sec=sys）将用于尝试挂载NFS 共享，使用标准 Linux 文件权限。  

*   /etc/fstab 使用vim 编辑 /etc/fstab 文件，将挂载条目添加到文件底部。 NFS 共享将在每次系统启动时挂载。

```sh

vim /etc/fstab 
……
serverX:/share /mountpoint nfs sync 0 0

root 用户使用 umount  命令手动卸载共享  

umount /mountpoint
```
###### 通过 NFS 自动挂载网络存储

自动挂载器是一种服务(autofs) ，它可以根据需要自动挂载 NFS 共享，并将在不再使用 NFS共享时自动卸载这些共享。

自动挂载器优势

*   用户无需具有root 特权就可以运行 mount /umount 命令

*   自动挂载器中配置的 NFS 共享可供计算机上的所有用户使用，受访问权限约束

*    NFS 共享不像 /etc/fstab 中的条目一样永久连接，从而可释放网络和系统资源。

*   自动挂载器完全在客户端配置，无需进行任何服务器配置

*   自动挂载器与 mount 命令使用相同的挂载选项，包括安全性选项。

*   支持直接和间接挂载点映射，在挂载点位置方面提供了灵活性。

*   间接挂载点可通过 autofs 创建和删除，从而减少了手动管理这些挂载点的需求。

*   NFS 是自动挂载器的默认文件系统，但自动挂载器也可以用于自动挂载多种不同的文件系统 。

*   autofs 是管理方式类似于其他系统服务的一种服务。


###### 创建自动挂载

配置自动挂载的过程包括多个步骤：

1、安装 autofs 
```sh
sudo yum -y install autofs
```
此软件包含使用自动挂载器挂载NFS 共享所需要的所有内容

2、向/etc/auto.master.d 添加一个主映射文件；此文件确定用于挂载点的基础目录，并确定用于创建自动挂载的映射文件。

使用vim 创建并编辑主映射文件：
```sh
sudo vim /etc/auto.master.d/demo.autofs
```
主映射文件的名称不重要，但它通常是一个有意义的名称，唯一的要求就是扩展名必须为.autofs ，主映射文件可以保存多个映射条目，或者使用多个文件来将配置数据分开。

在此例中，为间接映射的挂载添加主映射条目：
```sh
/shares /etc/auto.demo
```
此条目将使用 /shares目录作为将来间接自动挂载的基础目录。/etc/auto.demo 文件包含挂载详细信息；使用绝对文件名，需要在启动autofs 服务之前 创建auto.demo 文件

要使用直接映射 的挂载点，请向同一文件（或在单独的文件中）添加条目：
```sh
/- /etc/auto.direct
```
所有直接映射条目都使用 “/-”作为基础目录。在此例中，包含挂载详细信息的映射的文件是/etc/auto.direct 

3、创建映射文件，映射文件确定挂载点、挂载选项和挂载的源位置

使用vim 创建并编辑映射文件
```sh
 sudo vim /etc/auto.demo
```
文件名不重要，按照惯例，该文件位于 /etc 中并且名为 auto.name ，其中 name 是对所有包含内容有意义的名称
```sh
work -rw,sync serverX:/shares/work
```
条目的格式为挂载点、挂载选项和源位置。此示例显示基本的间接映射条目。

*   挂载点在 man page 中被称为 "密钥" ,它将由 autofs 服务自动创建和删除。在此例中完全限制挂载点将是 /shares/work; autofs 将根据需要创建和删除/shares 目录和 work 目录

*   挂载选项以 “-”开关，并使用逗号分隔，不带空格。可以选项与手动挂载选项相同。几个常用的自动挂载器特定选项 -fstype= 和 -strict  文件文件系统 不是NFS 则使用fstype ，可指定文件系统 ；挂载文件系统时，使用strict 可将错误视为严重。

*   NFS 共享的源位置遵循 host:/pathname 模式；在此示例中为 serverX:/shares/work ，此目录需要已在 serverX 上导出，并带有读/写访问权限和标准的linux 文件权限的支持，这样才能挂载成功。如果要挂载的文件系统以 “/”开关，例如本地设备条目或者SMB 共享，则需要添加一个“：”作为前缀，例如 SMB 共享为 ：//serverX/share。


4、启动并启用自动挂载服务
```sh
sudo systemctl enable autofs
sudo systemctl start autofs
```
##### 映射文件 \- 直接映射

直接映射用于将NFS 共享映射到现在的挂载点。自动挂载器不会尝试自动创建挂载点；在 autofs 服务启动之前 挂载点必须存在

继续前面的示例，/etc/auto.direct 文件的内容可能 类似下文：
```sh
/mnt/docs -rw,sync serverX:/shares/docs
```
挂载点（或密钥）始终为绝对路径，以 "/" 开关。映射文件其余部分使用相同的结构。

只有最右侧的目录受自动挂载程序控制，因此挂载点挂载点（此示例中为 /mnt ）以上的目录结构不会被 autofs 遮盖。

##### 映射文件 \-\- 间接通配符映射

当 NFS 服务器导出一个目录中的多个子目录时，可将自动挂载程序配置为使用单个映射条目访问这些子目录其中的任何一个，作为示例，对于从NFS 服务器自动挂载用户主目录，此功能非常有用。

继续前面的示例，如果 serverX:/share 导出两个或多个子目录,并且能使用相同的挂载选项访问这些子目录，则/etc/auto.demo 文件内容可能类似于正文：

* -rw,sync serverX:/shares/&

挂载点是“\*”，而源位置上的子目录是 "&" 。条目中的所有其它内容都相同

当用户尝试访问/shares/work 时，挂载点 “\*”（此示例中为work）将代替源位置中的 & 符号，并将挂载 serverX:/shares/work。对于间接示例，autofs 服务将自动创建和删除work 目录。





##### 实验：

###### 间接通配符映射

```sh
sudo -y install autofs
vim /etc/auto.master.d/home.autofs   #主配置文件
###
/home/guests /etc/auto.home
###
vim /etc/auto.home    #详细信息
###
* -rw,sync classroom:/home/guests/&
###
systemctl enable autofs
systemctl start autofs
```
###### 间接映射 
```sh
sudo -y install autofs
vim /etc/auto.master.d/public.autofs   #主配置文件
###
/shares /etc/auto.public
###
vim /etc/auto.public    #详细信息
###
public -rw,sync classroom:/shares/public
###
systemctl enable autofs
systemctl start autofs
```
###### 直接映射（需要提前创建挂载点）
```sh
sudo -y install autofs
vim /etc/auto.master.d/public.autofs   #主配置文件
###
/- /etc/auto.public
###
vim /etc/auto.public    #详细信息
###
/mnt/public -rw,sync classroom:/shares/public
###
mkdir /mnt/public     #创建目录
systemctl enable autofs
systemctl start autofs
```
