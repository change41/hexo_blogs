---
title: Chapter 15. Using virtualized system
url: 187.html
id: 187
categories:
  - RHEL124
date: 2018-04-18 10:57:03
tags:
---

KVM(基于内核的虚拟机)是标准Red Hat Enterprise Linux 内核中内置的完整虚拟化解决方案。它可以运行多款未经修改的Windows 和Linux 虚拟客户操作系统。Red Hat Enterprise Linux中的KVM系统管理程序通过libvirt API 和实用程序进行管理。如virt-manager 和virsh等。由于Red Hat Enterprise Linux 是红帽企业虚拟化和红帽OpenStack 平台的基础。因此KVM是红帽云基础架构多种产品的一致组件。

![图片.png](1524011869875353.png)

*   KVM提供横跨所有红帽产品的虚拟机（VM）技术，不仅包含Red Hat Enterprise Linux 的单机物理实例，更有OpenStack 云平台。从上图的左上角起：

*   物理（传统）系统-Red Hat Enterprise Linux 安装在传统硬件上，提供KVM虚拟化，最高可达单一系统的物理极限，并且由virt-manager 等libvirt实用程序进程管理。Red Hat Enterprise Linux 实例也可通过红帽云访问。直接托管在红帽认证云提供商处。

*   红帽企业Linux 通常配置为胖主机，即在支持VM的同时，也提供其他本地和网络服务、应用和管理功能。

*   红帽企业虚拟化（RHEV）--支持跨越多个红帽企业虚拟化系统管理程序 （RHEV-H）系统的KVM实例。提供由RHEV管理（RHEV-H）管理的KVM迁移、冗余和高可用性。

*   红帽企业虚拟化系统管理程序 是瘦主机，是专门精简和调优过的Red Hat Enterprise Linux 版本，专用于满足和支持虚拟客户机VM的唯一目的。

*   RHEL OpenStack平台——在带有KVM的Red Hat Enterprise Linux 基础上使用集成和调优的OpenStack 的红帽私有云架构，通过红帽OpenStack 仪表板（Horizon 组件）或红帽 CloudForms 进程管理。

*   公共云中的OpenStack——在红帽认证云提供商处实施的OpenStack 公共云架构，由OpenStack Horizon 组件或红帽 CloudForms进行管理。

*   混合云——红帽CloudForms 云管理实用程序管理和迁移红帽RHEV和OpenStack 架构之间的KVM实例，以及通过第三方OpenStack和VMware平台转换KVM实例。

*   KVM实例配置在红帽产品之间兼容。安装要求、参数和步骤在受支持的平台上相当的。


KVM系统管理程序需要Intel 处理器（Intel VT-x 和基于X86 的系统的Intel 64扩展），或者AMD处理器（AMD-V 及AMD64扩展）。验证是否支持可能通过：
```sh
grep --color -E "vmx|svm" /proc/cpuinfo
```


在Red Hat Enterprise Linux 上构建主机时并不需要No eXecute (NX)功能（Intel 称之为eXecute Disable(XD),AMD则称之为Enhanced Virus Protection）,但是红帽企业虚拟化系统管理程序（RHEV-H）需要此功能。  
```sh
grep --color -E "nx" /proc/cpuinfo
```


构建RHEL虚拟化主机至少需要qemu-kvm和qemu-img软件包，以提供用户级KVM模拟器和磁盘映像管理器
```sh
yum install qemu-kvm qemu-img
```


建议安装的其它虚拟化管理软件包有：

*   python-virtinst —— 提供virt-install命令，供创建虚拟机使用

*   libvirt —— 提供主机和服务库，以便与系统管理程序和主机系统交互  

*   libvirt-python —— 包含允许Python应用使用libvirt API的模块  

*   virt-manager —— 为管理VM提供虚拟机管理器图形工具，将libvirt-client库用作管理  

*   libvirt-client —— 为访问libvirt服务器提供客户端API和库，以及用于管理和控制VM的virsh命令行工具。  

```sh
yum install python-virtinst libvirt libvirt-python virt-manager libvirt-client
```
RHEL7 更新版anaconda图形安装程序 ，安装程序时不再提供选择个别RPM软件的功能，而只能选择基地环境和适合于所选基础的附加程。因而消除了猜测、使用配置更加精简。在安装完成后依然可能通过rmp 、yum或GNOME PackageKit 安装其他所需的RPM软件包。  



Red Hat Enterprise Linux 使用基于libvirt的工具，作为虚拟化管理的默认方式。其支持RHEL 5 Xen 系统管理程序，以及RHEL 5、6和7上的KVM。下列管理工具使用libvirt:

*   virsh —— virsh 命令行管理工具是图形版 virt-manager 应用程序的代替工具。无特权用户能以只读模式使用模式virsh，或者通过root 访问权限使用完整的管理功能。virsh命令是编写虚拟化管理脚本的理想选择。

*   virt-manager —— virt-manager 是一款图形化桌面工具，可以访问虚拟客户机控制台，用于执行虚拟机创建、迁移、配置和管理任务。可以通过单一界面管理本地和远程系统。

*   RHEV-M —— 红帽企业虚拟化管理器为物理和虚拟资源提供一个中央化管理平台，允许在主机之间启用、停止、构建和迁移虚拟机。RHEV-M 也可以管理数据中心的存储和网络组件，提供安全的远程图形化虚拟客户机控制台访问方式。


virsh 作为交互式shell使用:

list —— 查看，--all 可查看全部  

destroy —— 强制关闭，后面跟虚机名，与将其拔出相似  

stop —— 暂时运行，后面跟虚机名

start —— 启动虚机，后面跟虚机名

edit —— 编辑域的配置文件，这会在虚拟客户机下一次启动时产生作用

connect —— 使用qemu://host 语法连接本地或远程KVM主机。  

nodeinfo —— 返回主机的基地信息，如CPU和内存等。  

autostart —— 将KVM域配置为在主机系统启动时启动。  

console —— 连接到虚拟客户机的虚拟串行控制台。  

create —— 从XML 配置文件创建域，并将它启动。  

define —— 从XML 配置谁的创建域，但不启动它。  

undefine —— 取消定义域。如果域为不活动，则域配置将被删除。  

reboot —— 重新启动域，就如从客户机内部运行reboot 命令一样  

shutdown —— 正常地关闭域，就如从虚拟客户机内部运行shutdown 一样。  

screenshot —— 为当前域控制台抓取屏幕截图，并存储在文件中。  



|配置说明|红帽产品|
| :-- | :-- |
|提供KVM支持的单系统硬件|红帽企业Linux  |
|提供虚拟化冗余的多系统硬件  |红帽企业虚拟化  |
|提供私有云的多系统硬件  |RHEL OpenStack平台  |
|提供公共云的云提供商  |公共云中的OpenStack  |
|用于独立KVM主机的管理实用程序  |virt-manager|
|用于多主机虚拟化平台的管理实用程序 |RHEV-M  |
|用于所有虚拟化和云平台组合的管理实用程序  |CloudForms|
