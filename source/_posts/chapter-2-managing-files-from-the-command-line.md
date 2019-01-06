---
title: Chapter 2 . Managing Files From The Command Line
url: 254.html
id: 254
categories:
  - RHEL124
date: 2018-04-20 14:25:46
tags:
---

![图片.png](1524194156616572.png)



|位置  |用途  |
| :-- | :-- |
|/usr  |安装的软件、共享的库，包括文件和静态只读程序数据。重要的子目录有：<br /> \-/usr/bin:用户命令;<br /> \-/usr/sbin:系统管理命令;<br /> \-/usr/local:本地自定义软件  |
|/etc  |特定于此系统的配置文件  |
|/var  |特定于此系统的可变数据，在系统启动之间保持永久性。动态变化的文件（如数据库、缓存目录、日志文件、打印机后台处理文档和网站内容）可以在/var下找到  |
|/run  | 自上次系统启动以来启动的进程的运行数据。这包括进程ID文件和锁定文件等等。此目录中的内容在重启时重新创建。（此目录整合了旧版RHEL中的/var/run 和/var/lock)  |
|/home  |普通用户存储其个人数据和配置文件的主目录  |
|/root  |管理员超级用户root的主目录。  |
|/tmp  |供临时文件使用的全局可写空间。10天内未访问、未更改或未修改的文件将自动从该目录中删除。还有一个临时目录/var/tmp，该目录中的文件如果在30天内未曾访问、更改或修改过，将被自动删除  |
|/boot  |开始启动过程所需的文件  |
|/dev  |包含特殊的设备文件，供系统用于访问硬件。  |
在RHEL7中，/ 目录下四个较旧的目录现在与它们在/usr 中对应的目录拥有完成相同的内容：|

*   /bin 和 /usr/bin

*   /sbin 和 /usr/sbin

*   /lib 和/usr/lib

*   /lib64 和/usr/lib64


在RHEL 的较早版本中，这些是不同的目录，包含几组不同的文件。在RHEL7中 / 中的目录是/usr 中对应目录的符号连接。

[http://www.pathname.com/fhs/](http://www.pathname.com/fhs/) Filesystem Hierarchy Standard

创建文件夹时应尽量避免出现空格

绝对路径是完全限定名称，自根目录（/）开始，指定到达且唯一代表单个文件所遍历的每个子目录。文件系统中的每个文件都有一个绝对路径。第一个字符是正斜杠（/）的路径名是绝对路径名。例/var/log/message

相对路径与绝对路径一样，相对路径也标识唯一文件，仅指定从工作目录到达该文件所需的路径。第一人字符是正斜杠（/）之外的其它字符路径名的是相对路径。例在/var目录下访问log/message  

对于标准的linux文件系统，文件名路径总长度（包括/）不可超过4095字节。路径中通过/隔开的第一部分不可超过255字节。文件名中不允许出现‘/’和'NUL字符'。

Linux 文件系统，包含但不限于ext4,XFS,BIRFS,GFS2和GlusterFS都是区分大小写的。VFAT和NTFS及Apple的HFS+虽然不区分大小写，但它们具体大小写保留行为，他们使用创建时的大小写显示文件名。

pwd 命令显示当前位置的完成路径名。

ls 命令列出指定目录的目录内容，如未指定则显示当前目录的内容（.表示当前目录。 ..表示父目录）

-l 长列表格式，-a 包含隐藏文件（.开头的文件）的所有文件，-R 递归方式，包含所有子目录。  

cd 命令可更改目录，未指定目录则回到家目录。（~）表示家目录。  

 \- 回到上次的目录，cd ..回到上级目录  

touch 命令通常将文件的时间戳更新为当前日期和时间，而不做其它修改，如果文件名不存在则创建一个空文件。  

|活动  |单一来源 |多来源  |
| :-- | :-- | :-- |
|复制文件  |cp file1 file2  |cp file1 file2 file3 dir(4)  
|移动文件  |mv file1 file2(1)  |mv file1 file2 file3 dir(4)  
|删除文件  |rm file1  |rm -rf file1 file2 file3(5)  
|创建目录  |mkdir dir  |mkdir -p par1/par2/dir(6)  
|移动目录  |mv dir1 dir2(3) |mv dir1 dir2 dir3 dir4(4)  
|删除目录  |rm -r dir1(2)  |rm -rf dir1 dir2 dir3(4)  
|复制目录  |cp -r dir1 dir2(2) |cp -rf dir1 dir2 dir3(5)  
|注  |(1)结果为重命名 <br />(2)需要使用“递归”选项处理来源目录<br />(3)如果dir2存在，则结果为移动。如果dir2不存在则为重命名<br />(4)最后一个参数必须是目录<br />(5)请谨慎使用“force”选项，系统将不会提示您操作<br />(6)使用“创建父级”选项时应小心，无法捕获键入错误。  



模式匹配，通配符  

|模式 |匹配项  |
| :-- | :--|
|*  |由0个或以上字符组成的任何字符串  |
|?  |任何一个字符  |
|~  |当前用户的主目录  |
|~username  |username用户的主目录  |
|~+  |当前工作目录  |
|~-  |上一工作目录  |
|\[abc...\]  |括起的类中的任何一个字符。  |
|\[!abc...\]  |不在括起的类中的任何一个字符  |
|\[^abc...\]  |不在括起的类中的任何一个字符|
|\[\[:alpha:\]\]  |任何字母字符（1）|
|\[\[:lower:\]\]  |任何小写字符（1）|
|\[\[:upper:\]\]  |任何大写字符 （1）|
|\[\[:alnum:\]\]  |任何字母字符或数字（1）|
|\[\[:punct:\]\]  |除空格和字母数字以外的任何可打印的字符。（1）|
|\[\[:digit:\]\]  |任何数字，即0-9（1）|
|\[\[:space:\]\]  |任何一个空白字符；可能包括制表符、换行符或回车符，以及换页符和空格（1）|
|注释  |（1）预设的POSIX字符类；针对当前区域而调整  |

{}大括号扩展用于生成任意字符串。大括号包含字符串的逗号分隔列表或顺序表达式。
```sh
[root@client ~]# echo {sunday,Monday,Tuesday,Wednesday}.log
sunday.log Monday.log Tuesday.log Wednesday.log
[root@client ~]# echo {1..5}.log
1.log 2.log 3.log 4.log 5.log
[root@client ~]# echo file{a..d}.txt
filea.txt fileb.txt filec.txt filed.txt
[root@client ~]# echo file{a,b}{1,2}.txt
filea1.txt filea2.txt fileb1.txt fileb2.txt
[root@client ~]# echo file{a{1,2},b,c}.txt
filea1.txt filea2.txt fileb.txt filec.txt
```
命令替换\`\` 反引号或$()
```sh
[root@client ~]# echo Today is \`date +%A\`
Today is 星期五
[root@client ~]# echo The time is $(date +%M) minutes past $(date +%l%p)
The time is 16 minutes past 4下午
```
防止参数被扩展，为了忽略元字符的特殊含义，使用引用和转义来防止它们被shell 扩展。反斜杠（\\）是bash的一个转义字符，防止其后的一个字符被特殊解释。如果要保护较长的字符串需要使用单引号和双引号括起来。
```sh
[root@client ~]# echo Your username varialbe is \\$USER
Your username varialbe is $USER
[root@client ~]# echo Your username varialbe is $USER 
Your username varialbe is root
[root@client ~]# host=desktop0
[root@client ~]# echo "Will variable $host evaluate to $(hostname)?"
Will variable desktop0 evaluate to client?
[root@client ~]# echo 'Will variable $host evaluate to $(hostname)?' 
Will variable $host evaluate to $(hostname)?
```
