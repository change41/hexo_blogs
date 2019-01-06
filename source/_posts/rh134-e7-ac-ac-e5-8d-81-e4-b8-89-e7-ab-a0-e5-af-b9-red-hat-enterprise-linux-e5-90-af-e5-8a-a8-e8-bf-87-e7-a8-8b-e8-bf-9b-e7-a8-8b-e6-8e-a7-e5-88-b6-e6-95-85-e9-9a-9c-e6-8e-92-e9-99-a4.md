---
title: RH134 第十三章 对 RED HAT ENTERPRISE LINUX 启动过程进程控制故障排除
url: 505.html
id: 505
categories:
  - RHEL134
date: 2018-10-16 11:38:24
tags:
---

##### REHL 7 启动过程  

1、计算机已接通电源

2、系统固件搜索可启动设备

3、系统固件从磁盘读取启动加载器，然后将系统控制权交给启动加载器。在 RHEL 7 中这通常是 grub2。

 通过以下方式进行配置 ：grub2-install 

4、启动加载器从磁盘加载其配置，然后向用户显示用于启动的可能配置的菜单。

   通过以下方式进行配置：/etc/grub.d/ 、/etc/default/grub 和 （非手动） /boot/grub2/grub.cfg  

5、在用户做出选择（或发生自动超时）后，启动加载器会从磁盘加载配置的内核及initramfs 并将它们置于内存中。initramfs 是经过 gzip 的cpio 归档，其中包含启动时所有必要硬件的内核模块、初始化脚本等。在 RHEL7 中，initramfs 包含自身可用的整个系统。  

  通过以下方式进行配置：/etc/dracut.conf  

6、启动加载器将系统控制权交给内核，从而传递启动加载器的内核命令行中指定的任何选项，以及initramfs 在内存中的位置。

   通过以下方式进行配置：/etc/grub.d/、/etc/default/grub 和 (非手动) /boot/grub2/grub.cfg  

7、对于内核可在 initamfs 中找到驱动程序的所有硬件，内核会初始化这些硬件，然后作为 PID 1 从 initramfs 执行 /sbin/init 。在 RHEL 7 中initramfs 包含systemd 的工作副本作为 /sbin/init ，并包含 udev 守护进程

  通过以下方式进行配置 init = 命令行参数  

8、initramfs 中的 systemd 实例会执行 initrd.target 目标的所有单元。这包括在 /sysroot 上挂载实际的 root 文件系统 。

   通过以下方式进行配置： /etc/fstab   

9、内核 root 文件系统从initramfs root 文件系统切换（回转）为之前挂载于 /sysroot 上的系统 root 文件系统。随后 ，systemd 会使用系统中安装 systemd 副本来自动重新执行。

10、systemd 会查找从内核命令传递或系统中配置的默认目标，然后启动（或停止）单元，以符合目标的配置，从而自动解决单元间的依赖关系。本质上，systemd 目标是一组应在激活后达到所需系统状态的单元。这些目标通常至少包含一个生成基于文本的登录或图形登录屏幕。

   通过以下方式进行配置： /etc/systemd/system/default.target 、/etc/systemd/system/  

##### 启动、重新启动和关闭  

-------------

要关闭或从命令行重新启动正在运行的系统，管理员可以使用systemcl 命令

systemctl poweroff 会停止所有运行的服务，卸载所有文件系统（或者在文件系统无法卸载时以只读形式将其重新挂载），然后关闭系统。

systemctl reboot 会停止所有运行的服务，卸载所有文件系统，然后重新启动系统。

为了方便身后兼容，poweroff 和 reboot 命令仍然存在，但是在RHEL 7 中，它们是指向 systemctl 工具的的符号链接。

### tips:

systemctl halt 和 halt 也用于停止系统，但与其poweroff 不同，这些命令不会关闭系统而是让系统进入能安全地手动关闭的状态。  

### 选择systemd 目标

systemd 目标是一组应在启动后到达所需状态的systemd 单元。下表列出了这些目标的最重要的信息。

|目标|用途
| :--
|graphical.target|多用户、图形+文本
|multi-user.target|多用户、文本登录
|rescue.target|sulogin 提示，表示基本系统初始化已完成
|emergency.target|sulogin 提示，表示 initramfs 回转完成，且系统 root 以只读形式挂载于 / 上

某个目标可能属于另一目标：例如 graphical.target 包含 multi-user.target 。后者反过来取决于 basic.target 和其他目标，使用以下命令可从命令行查看这些依赖关系；  
```sh
systemctl list-dependencies graphical.target | grep target    #查看依赖关系
systemctl list-units --type=target --all #查看所有可用目标的描述
systemctl list-units-files --type=target --all #查看磁盘上安装的所有目标的概述
systemctl isolate multi-user.target    #在运行的系统中，切换到其他目标，类似于老版本 init 5
```
隔离某个目标会停止该目标（及其依赖项）不需要的所有服务，并启动任何尚未启动的所需服务。

##### 注意：

并非所有目标都能隔离。只有单元文件中设置了 AllowIsolate=yes 的目标才可以隔离；例如 graphical.target 目标可以隔离，但 cryptsetup.target 目标不能隔离。AllowIsolate 设置在target 文件中配置

###### 设置默认目标

在系统启动且将控制权从 initramfs 交给systemd 后，systemd 会尝试激活 default.target 目标。通常，default.target 目标是 (/etc/systemd/system中) 指向 graphical.target 或 multi-user.target 的符号链接。

systemctl 工具随附两个命令（get-default 和 set-default ） 用于管理该符号链接，而不是手动编辑该连接。
```sh
[root@client ~]# systemctl get-default
multi-user.target
[root@client ~]# systemctl set-default graphical.target
Removed symlink /etc/systemd/system/default.target.
Created symlink from /etc/systemd/system/default.target to /usr/lib/systemd/system/graphical.target.
```
###### 在启动时选择其他目标  

要在启动时选择其它目标，可从启动加载器将特殊选项附加到内核命令行：systemd.init= .

例如，要使系统启动进入救援 shell  （在这种情况下，系统可在（几乎）没有任何服务运行的情况下进行配置更改），则在启动前，可从交互式启动加载器菜单中附加以下内容：

systemd.unit=rescue.target

该配置更改仅影响单个启动，这使其成为排除启动过程故障的有用工具。

要使用这种选择其他目标的方法，请针对 RHEL 7 系统执行以下步骤：

1、（重新）启动系统 

2、按任意键中断启动加载菜单倒计时。

3、将光标移动至要启动的条目

4、按e 编辑当前条目

5、将光标移动至以 linux16 开关行。此为内核命令行

6、附加 systemd.unit=desired.target 

7、按 Ctrl +x 使用这些更改进行启动.

修复常见启动问题  

-----------

### 恢复root 密码  

每个系统管理员都应该能完成一项任务是恢复丢失的root密码，如果管理员仍处于登录状态，不管是作为拥有完成sudo 访问权限的非特权用户，还是作为root 用户，这个任务都很简单。如果未登录则复杂一点。  

有一些方法可用于设备新的root 密码。例如，系统管理员可以使用live cd 启动系统，从此处挂载root文件系统。然后编辑 /etc/shadow 。在本节中，我们将探讨一个无需使用外部介质的方法。

###### 注意：

在RHEL 6及早期版本中，管理员可以启动系统进入runlevel 1 然后看到一个root 提示。在 RHEL7 中与 runlevel 1 最接近的是 rescue.target  和emergency.target 目标，这两个目标都需要 root 密码才能登录 。

在 RHEL 7中，可以使从 initramfs 运行的脚本在某些点暂停，提供 root shell ，然后在该 shell 存在的情况下继续 。虽然主要是为了进行调试，但也可用户恢复丢失的 root 密码。

1、重新启动

2、按任意键中断启动加载器倒计时。

3、将光标移动到需要启动的条目

4、按 e 编辑选定的条目

5、将光标移到内核命令行（以 linux16开头的行）

6、附加 rd.break （就在从initramfs 向实际系统移交控制权前，该操作会中断）。

###### 注意：

    initramfs 提示会显示在内核命令行中指定为最后的任何控制台中。  

7、Ctrl +x 使用这些更改进行启动

###### 注意：    

    预建的映像可能会在内核中放置多个 console = 参数，以全支持各种各校的实施场景，对于 rd.break ，有一点需要注意的是，尽管许多内核消息将会发送到所有控制台，但提示符最终都将使用最后一个控制台。如果未看到提示符，可能要临时调整 console = 参数的顺序。  

此时，会显示 root shell ，且实际系统的 root 文件系统会在 /sysroot 中以只读方式挂载。

###### 重要：

    由于此时尚未启动 selinux ，因此任何创建的新文件都不会创建分配有selinux 上下文。请记住，有些工具（如passwd ）首先会创建一个新文件，然后移动新文件以代替要编辑的文件，从而有地创建不 selinux 上下文的新文件。  

###### 此时要恢复 root 密码，请使用以下步骤：

1、以读写方式重新挂载 /sysroot 

mount -o remount,rw /sysroot

2、切换为 chroot 存入位置，其中 /sysroot 被视为文件系统树的 root 

chroot /sysroot

3、设置新 root 密码

passwd root

4、确保所有未标记的文件（包括此时的 /etc/shadow）在启动过程中都会重新获得标记。

touch /.autorelabel

5、键入 exit 两次，第一次将退出 chroot 存放位置，第二次将退出 initramfs 调试 shell 。此时系统将继续进行启动，执行完整的 selinux 重新标记，然后再次重新启动。  

#### 使用 journalctl 

查看以前（失败）启动日志会很有用。如果 journald 日志已被已久性的，则使用 journaclctl 工具即可查看。

首先确定启用了永久性的 journald 记录
```sh
mkdir -p -m2775 /var/log/journal
chwon :systemd-journal /var/log/journal
killall -USR1 systemd-journald
```
要检查上一次启动的日志文件，请在journalctl 中使用 -b 选项。无需任何参数，-b 选项即可将输出过滤为仅包含与该启动有关的消息，但是如果参数为负数，则此选项将过滤出上次启动。例如：
```sh
journalctl -b -l -p err
```
该命令将显示上次启动中被评为错误或更严重级别的所有消息。

##### 诊断和修复 systemd 启动问题

如果在启动服务过程中出现问题，则有几个工具可供管理员用于协助调试和 / 或故障排除：

###### 早期调试 shell 

通过运行 systemctl enable debug-shell.service 启动序列早期将在 tty9 (Ctrl + Alt +f9 )上生成一个root shell 。该 shell 会自动作为 root 登录 ，这样管理员可以在系统仍在启动时使用一些其他高度工具。

###### tips :  

在完成调试后，请不要忘记禁用 debug-shell.service 服务，因为该服务会使未经身份验证的 root shell 向任何有本地控制台访问权限的人员开放。

###### 紧急情况和救援目标

通过从启动器加载将 systemd.unit=rescue.target 或 systemd.unit=emergency.target 附加到内核命令行，系统将生成特殊的救援或紧急情况 shell ，而不是正常启动。这两个 shell 都需要提供 root 密码。 emergency 目标使 root 文件系统以只读方式挂载，而rescue.target 等待sysinit.target 先完成，这样更多的系统会进行初始化 （例如日志记录、文件系统等）。

这些 shell 可以用于修复妨碍系统正常启动的任何问题；例如，服务之间的依赖关系循环、或 /etc/fstab  中的错误条目。从这些 shell 退出后，系统会继续进行正常启动过程

###### 阻塞作业

在启动过程中，systemd 会生成大量作业。如果其中某些作业无法完成，则它们会妨碍其他作业运行。要检查当前作业列表，管理员可以使用命令 systemctl list-jobs 。所有列出为 running 的作业都必须先完成，然后列为 waiting 的作业可以继续。

#### 修复在启动时出现的文件系统问题

/etc/fstab 中的错误和损坏的文件系统可能会阻止系统启动。在大多数情况下，systemd 实际上会在超时后继续启动，或者降至需要提供 root 密码的紧急修复 shell 

|问题|结果
| :--
|损坏文件系统|systemd 将会尝试 fsck ,如果问题太严重而无法自动修复，则系统会提示用户从紧急 shell 手动运行 shell 
|/etc/fstab 中引用的设备 /UUID 不存在|systemd 将等待一定的时间，等设备变得可用。如果设备未变得可用，则系统会在超时后用户降至紧急 shell 。
|/etc/fstab 中的挂载点不存在|systemd 会创建挂载点（如果可能） ; 否则，它会降至紧急 shell 

/etc/fstab 中指定的挂载点错误|系统将用户降至紧急 shell 
|在所有情况下，管理员都可以使用 emergency.target 目标来诊断和修复问题，因为在显示紧急 shell 之前 ，不会挂载任何文件系统。

###### 注意：

在文件系统问题中使用自动恢复 shell 时，请不要忘记在编辑 /etc/fstab 后发出 systemctl daemon-reload ，如果不重新加载，systemd 将继续使用旧版本。

###### 修复启动加载器问题  

RHEL 7 中默认使用的启动加载是 grub2, GRand Unified Bootloader 的第二个主要版本

grub2 可以用来在 BIOS和 UEFI系统中进行启动，并且支持启动现代硬件上运行的几乎所有操作系统。

grub2 的主要配置文件是 /boot/grub2/grub.cfg ，但是管理员不应直接编辑文件，而是应用使用一组不同的配置文件和安装的内核列表，并借助名为 grub2-mkconfig 的工具生成配置。

grub2-mkconifg 会查看 /etc/default/grub 的选项（例如要使用的默认菜单超时及内核命令行），然后在 /etc/grub.d/ 中使用一组脚本来生成配置文件。

要永久更改启动加载器配置，管理员需要编辑前面列出的配置文件，然后运行以下命令：
```sh
grub2-mkconfig > /boot/grub2/grub.cfg
```
在进行较大更改的情况下，管理员可能更喜欢不经过重定向即运行该命令，这样可以首先检查结果。

###### 重要指令

要为损坏的 grub2 配置排除故障，管理员需要先了解 /boot/grub2/grub.cfg 的语法。实际可启动条目是在 menuentry 块中编码的。在这些块中，linux16 和 initrd16 行指向（随内核命令行）从磁盘加载的内核以及要加载的 initramfs 。在启动时进行交互编辑的过程中，Tab 实例可用于查找这些文件。

这些块中的 set root 行不指向 rhel 7 系统的root 文件系统，而是指向 grub2 应从加载内核及 initramfs 文件的文件系统。语法为 harddrive,partition ，其中 hd0 是系统中的第一个硬盘驱动器，hd1 是第二个硬盘驱动器，依此类推。指定为 msdos1 的分区是该驱动器上的第一个 MBR 分区，指定为 gpt1 分区的第一个GPT分区  

###### 重新安装启动加载器

在启动加载器自身已损坏的情况下，可以使用 grub2-install 命令重新安装。在 BIOS系统中，应提供 MBR 中应安装 grub2 的磁盘作为参数。在 UEFI 系统中，当 EFI 系统分区挂载于 /boot/efi/上时，无需提供任何参数。
