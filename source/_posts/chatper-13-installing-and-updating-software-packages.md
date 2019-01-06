---
title: Chatper 13. Installing and updating software packages
url: 173.html
id: 173
categories:
  - RHEL124
date: 2018-04-17 08:49:48
tags:
---

红帽提供软件更新服务工具（收费）需要购买服务，并利用注册工具（subscription-manager-gui）进行注册软件管理服务器.

#### Register 用户和红帽账号绑定

    1.在命令行command 输入 subscription-manager-gui,或者在GNOME界面Application-->Other-->Red Hat Subscription Manager 进入，输入对应的root 密码就可以进入图形操作，进入图形后点击右上角的Register会进入一个新的对话窗，subsription 默认服务器地址：subscription.rhn.redhat.com.Next后会要求输入RedHat的账号密码，默认会自动检查相应的订阅，也可以自己手动检查。最后点击Register完成注册。完成后就可以检查更新了。

    2.使用命令行完成自动注册
```sh
    subscription-manager register --username=yourname --password=yourpassword  #订阅
    subscription-manager list --available | less    #查看有效的订阅
    subscription-manager attach --auto    #自动检查订阅
    subscription-manager list --consumed    #查看consumed（消费） 订阅
    subscription-manager unregister    #取消订阅
```


##### Subscribe 订阅授权给指定的产品，选择/删除需要授权的产品

Enable repositories 启用软件包的存储库（理解成yum 源库），每个订阅默认会开启多个存储库，可以根据需要关闭不需要的，如源代码、更新

Review and track  查看和审查自己的订阅信息，可以在本地和红帽网站上查询

###### 订阅的授权证书存放在/etc/pki 及其子目录中

/etc/pki/product    #安装在Red Hat中的产品证书
/etc/pki/consumer    #存储在这个系统中的RedHat的账号的证书
/etc/pki/entitlement    #包含了订阅了哪个许可的证书

可以使用rct程序检查证书，相比下subscription-manager程序读取证书更加友好  

* * *

rpm and yum

rpm =red hat packet manager

rpm 包的文件格式：

name-version-release.architectrue

httpd-tools.2.4.6.7-7.e17.x86_64.rpm  

httpd-tools=name    名字

2.4.6.7=version    版本

7.el7=release    基于版本的发行号

x86_64=arch    架构

默认安装时只需要使用RPM包的名字，如果有多个版本存在默认安装版本最高的

###### 每个RPM包包含以下三个组成部份：

软件安装的文件、

与软件包（元数据）有关的信息，摘要，描述、是否要求安装其它软件，授权许可、更改日志、以及其它详细信息

在安装、更新或删除此软件包时可能运行的脚本、或此过程中可能触发的脚本。  

如果软件构建为不冲突的文件名，则可以安装多个版本。例如kernel 否则只能安装一个版本。

###### yum---------软件包管理器

PackageKit 和yum 等工具是rpm的前端应用，可以用于安装单个软件包或软件包集合，并解决RPM无法解决的依赖关系。

yum 的主要配置文件为：/etc/yum.conf,其它存储库配置文件位于在/etc/yum.repos.d目录中。  

存储库配置文件至少包含一个存储库ID （在方括号中）、一个名称以及软件包存储库的URL位置。URL可以指向本地目录（文件）或远程网络共享(http和ftp等)。如果将该URL粘贴到浏览器中，则显示的内容应该有RPM软件包（可能位于一个或多个子目录中）。以及包含可用软件包相关信息的repodata目录。  
```sh
#yum 命令用于列出存储库、软件包和软件包组
yum repolist 
yum list yum*    #显示已安装和可用的软件包
yum grouplist
yum search apache    #在名字和摘要字段搜索关键字列出的软件包
yum search all 'web server'    #搜索名字、摘要、描述等字段中包含'web server'的软件包
yum info PACKAGENAME    #提供与指定软件包相关的详细信息，包括安装所需的磁盘空间。
yum provides /var/www/html    #显示与指定的路径名（通常包含通配符）匹配的软件包
yum install PACKAGENAME    #获取并安装软件包，包括依赖项
yum update PACKAGENAME    #获取并安装更新版本的软件包，包括所有依赖项。通常该进程尝试适当保留配置文件，但是在某些情况下，如果打包商认为旧文件在更新后将无法使用，则可能对其进行重命名，如果未指定软件包名称，它将安装所有相关更新
yum remove PACKAGENAME    #删除已安装的软件包、包括所有支持软件包。有可能会导致意外删除软件包，因此删除前要仔细检查要删除的软件包列表。
yum help

uname -r     #仅显示内核 的版本和发行版本
uname -a     #将显示内核发行版和其它信息
```


yum 有两种类型的组：常规组是软件包集合，环境组是其他组的集全。这些组包含自己的软件包。

与yum list 相似，yum group list (或 yum grouplist ) 将列出已安装和可用的组名称，有些组通过环境安装，默认为隐藏，这些隐藏组也可以通过yum group list hidden 命令列出。如果添加ids 选项，则会显示组ID。  
```sh
yum grout list hidden    #显示隐藏组
yum group list = yum grouplist    #显示已经安装和可选安装的软件包组。
yum group info = yum groupinfo    #它将列出改必选、默认和可选软件包名称或组ID。
```


#软件包名称或组前面可能标有标记。如下图：  

![图片.png](1523863565421240.png)
```sh
yum group install = yum groupinstall     #组安装
yum group remove = yum groupremove    #组删除
yum group mark install GROUPNAME    #标记为已安装，下次更新时将安装缺少的软件包和其依赖项。RHEL7 以后增加的命令
tail -5 /var/log/yum.log    #查看事务历史记录
yum history     #查看安装和删除事务的摘要
yum history undo 6    #撤销事务



yum repolist all    #查看所有可用的存储库
yum-config-manager     #启用和禁用存储库，这将更改/etc/yum.repos.d/redhat.repo 文件中的enabled 参数
yum-config-manager  --enable rhel-7-public-bate-debug-rpms      #案例
```
第三方存储库：网站、ftp服务器、本地文件系统。将文件放到/etc/yum.repos.d/ 目录中以启用对第三方内容库的支持。内容库配置必须以.repo 结尾。

存储库定义包含存储的URL和名称、也定义是否使用GPG检查 软件包签名；如果是，则还检查URL是否指向受信任的GPG密钥。
```sh
yum-config-manager --add-repo="http://dl.fedoraproject.org/pub/epel/beta/7/x86_64/"    #增加epel的源，
```
执行完修改/etc/yum.repos.d/下生成的配置文件，提供自定义名称和GPG密钥位置。管理员应将该密钥下载到本地文件，而不是让yum从外部来源检索该密钥。

安装Red Hat Enterprise Linux 7 EPEL存储库软件包:(默认提供配置文件、GPG公钥做为软件安装包的一部分)
```sh
rpm --import http://dl.fedoraproject.org/pub/epep/RPM-KEY-EPEL-7   
``` 
#如果不先安装GPG密钥安装软件时会报错，可以通过--nogpgcheck 忽略检查，不推荐这样操作。
```sh
yum install http://dl.fedoraproject.org/pub/epep/beta/7/x86_64/epel-release-7-0.1.noarch.rpm
```
配置文件通常在一个文件中列举多个存储库引用。每一存储库引用的开头为包含在方括号里的单一词语名称。可以通过“enabled=0 ”参数来关闭不需要使用的存储库。
```sh
yum-config-manager #永久的启用或禁用存储库
yum --enablerepo=PATTERN 
yum --disablerepo=PATTERN 
yum-config-manager --disable content.example.com\_rhel7.0\_x86\_64\_rht    
#content.example.com\_rhel7.0\_x86\_64\_rht 通过yum repolist 查看
```
###### rpm  
```sh
rpm -q PACKAGENAME    #查看指定安装的软件名称，列出软件包的名称和版本，与yum list 类似
rpm -qa         #查看所有安装的软件
rpm -q -p PACKAGENAME.rpm     #-p 指定安装软件包文件
rpm -q -f filename     #查看哪个软件包提示了这个文件或文件夹
rpm -q -i :软件包信息与yum info 类似
rpm -q -l :    rpm -q -l yum-rhn-plugin    #列出指定软件安装产生的文件
rpm -q -c：    rpm -q -c yum-rhn-plugin    #仅列出配置文件。
rpm -q -d:    rpm -q -d yum-rhn-plugin    #仅列出文档文件
rpm -q --scripts :    rpm -q --scripts openssh-server    #列出可能在安装或删除软件之前或之后运行的shell脚本
rpm -q --changelog :    rpm -q --changlog audit    #列出软件包的更改信息
```
cpio 从rpm包提示文件而不安装该软件包。rpm2cpio PACKAGERFILE.rpm 传送到cpio -id ，它会提取RPM中存储的所有文件。需要时会创建子目录树，也可以指定目录。
```sh
rpm2cpio wonderwidgets-1.0-4.x86_64.rpm | cpio -id "*.txt"
```
