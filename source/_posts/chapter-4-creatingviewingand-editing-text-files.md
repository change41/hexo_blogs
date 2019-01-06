---
title: 'Chapter 4 Creating,Viewing,And Editing Text Files'
url: 284.html
id: 284
categories:
  - RHEL124
date: 2018-04-27 16:49:36
tags:
---

|编号  |通道名称  |描述  |默认连接  |用法  
| :--
|0  |stdin  |标准输入  |键盘  |仅读取  
|1  |stdout  |标准输出  |终端  |仅写入  
|2  |stderr  |标准错误  |终端  |仅写入  
|3+  |filename  |其它文件  |无  |读取/写入  

重定向输出到文件

|用法  |说明  |视觉效果  
| :--
|>file  |重定向stdout到文件（1）  |![图片.png](1524818205308304.png)
|>>file  |重定向stdout到文件，附加到当前文件内容后面（2）  |![图片.png](1524818219547743.png)
|2>file  |重定向stderr到文件（1）  |![图片.png](1524818191991552.png)
|2>/dev/null  |将stderr错误信息重定向到/dev/null从而将它丢弃  |![图片.png](1524818180473442.png)
|&>file  |将stdout和stderr合并到一个文件（1）  |![图片.png](1524818174855912.png)
|>>file 2>&1  |合并stdout和stderr，并且附加到当前文件内容后面（2）（3）  |![图片.png](1524818166553035.png)
|注  |（1）覆盖现在文件，如果为新文件则创建文件<br/>（2）附加到现有文件，如果为新文件则创建文件<br/>（3）重定向顺向很重要，可避免出现意外的命令行为。2>&1 将stderr发送到与stdout相同的位置。要使其生效，在向stdout中添加stderr之前，需要首先重定向stdout.尽管&>>是向文件中附加stdout和stderr的备选方法，但2>&1 是通过管道同时发送stdout和stderr所需要的方法。

```sh
date > /tmp/saved-timestamp    #保存时间到文件

tail -n 100 /var/log/dmesg > /tm/last-100-boot-messages    #复制文件日志的最后100行到另一个文件

cat file1 file2 file3 file4 > /tmp/all-four-in-one    #将四个文件连接成一个

ls -a > /tmp/my-file-names    #将当前目录的隐藏文件名和常规文件名列出到文件中

echo "new line of information" >>/tmp/many-lines-of-information    #将输出附加到现有文件

diff previous-file current-file >> /tmp/tracking-changes-made    #将比较内容输出附加到现有文件

find /etc -name passwd 2> /tmp/errors    #将错误重定向到文件

find /etc -name passwd >/tmp/output 2> /tmperrors    #将进程输出和错误消息分别保存到单独文件

find /etc -name passwd >/tmp/output 2>/dev/null    #忽略并丢弃错误消息

find /etc -name passwd &> /tmp/save-both    #将输出和错误消息存储在一起

find /etc -name passwd  >> /tmp/save-toth 2>&1    #将输出和生成的错误消息附加到现有文件

```
#### 构建管道 “|”

从一个进程标准输出到另一个进程的标准输入

![image.png](1524823380758403.png)


```sh
ls -l /usr/bin | less
ls | wc -l > /tmp/how-many-files    #计算输出列出中的行数并重定向到文件
ls -t | head -n 10 > /tmp/ten-last-changed-files    #抓取列表的前几行、或后几行，或选定的行并重定向到文件
```
![image.png](1524823368317604.png)

使用 tee 命令传送，tee 命令显示或重定向通常因传送而被隐藏的中间结果。
```sh
ls -l | tee /tmp/saved-output    #在终端上查看 ls 列表同时将该列表存储到文件中

#确定当前窗口的终端设备。将结果作为邮件发送，并在此窗口中查看相同的结果。
tty
ls -l | tee /dev/pts/0 | mail -s subject student@desktop1.example.com
```

* * *

vi && vim

![image.png](1524823338808284.png)

vim 的四个模式：编辑模式，命令模式，可视模式，扩展命令模式。默认启动进行命令模式，可用于导航、剪切和粘贴，以及其他文件操作，通过单字符进行各个模式：

"i" 进入插入模式，编辑模式，按Esc 退出到命令模式

"v" 进入可视模式，在其中可以选择多个字符进行操作，使用"V"键选择多选，使用Ctrl+v 可选择文本块。v,V,Ctrl+v 同样可用于退出可视模式

":" 冒号,启动扩展命令模式,可以执行写入、退出、保存等

命令模式：u键撤销上次的编辑操作，x键删除光标所在的字符，:w 保存 :wq 保存退出  :q! 强制退出放弃修改。

可视模式：y ：复制，p：粘贴 ，上下左右选择字符。

安装vim-enhanced软件包提供vimtutor针对每一个操作的练习。可以安装学习一下

图形编辑器gedit 、nano
