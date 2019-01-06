---
title: Chapter 7. Monitoring and Managing Linux Processes
url: 195.html
id: 195
categories:
  - RHEL124
date: 2018-04-19 11:24:41
tags:
---

Linux 版本的ps命令支持三种选项格式，包括：

*   UNIX（POSIX）选项，可以分组但必须以连字符（-）开头；

*   BSD 选项，可以分组但不可与连字符同用；

*   GNU长选项，以双连字符开关。


例如：ps -aux 不同于 ps aux  
```sh
ps   aux    #显示所有进程，包含用户感兴趣的列，以及没有控制终端的进程。
ps   lax    #长列表，提供更多详细信息，可以避免查询用户名来加快显示。
ps -ef  #显示所有进程。
ps #默认不排序，除非指定-O 或者 --sort 
ps j #显示后台作业信息
```
```sh
 #&符号放在尾部，放到后台执行的效果，但是如果一行有多个命令，仅将最后一个放后台，除非使用$()括起来。
jobs #显示后台运行的进程，同ps j 类似
Ctrl + z #把当前执行的命令放到后台，状态为stopped
bg  %id    #启动后台指定进程(stopped-->running)
fg   %id    #指定后台进来显示在前台
```
```sh
vmstat 2 10    #2秒刷新显示10次
```
```sh
top
    M  #按内存排序
    K    #结束进程
```
```sh
free -m
cat /proc/cpuinfo
uptime
grep "model name" /proc/cpuinfo
gnome-system-monitor
```
#### top 各列含义：

*   用户名称(user)，是进程所有者  

*   虚拟内存(virt)，是进程正在使用的所有内存，包括常驻集合、共享库，以及任何映射或交换的内存页。（PS命令中为VSZ）  

*   常驻内存(res)，是进程所用的物理内存，包括任何驻留的共享对象。（PS命令中为rss）

*   进程状态(s)


    D=不间断的睡眠uninterruptable sleeping

                R=运行或可运行running or runnable

                S=睡眠sleeping

                T=停止或追踪stopped or traced

                Z=僵尸zombie




Ctrl-z(暂停，转后台)，Ctrl-c（中断），Ctrl-d (终止)  
```sh
kill    PID
kill    -signal PID
kill    -l
killall   command_pattern
killall  -signal command_pattern
killall   -signal -u username command_pattern
pkill    command_pattern
pkill    -signal command_pattern
pkill   -G GID command_pattern
pkill    -P PPID command_pattern
pkill -t terminal\_name -U UID command\_patern
pkill -SIGKILL -u bob #向bob用户发送sigkill 指令

w -f  #显示当前登录的用户，-f显示远程登录系统名称
w  -h -u username
pgrep -l -u username
pstree -p username
```

|名称          |标 志  |内核定义的状态名称和描述  
| :--
|运行中  |R  |TASK_RUNING:进程正在CPU上执行，或者正在等待运行。处于运行中（或可运行）状态时，进程可能正在执行用户作业或内核作业（系统调用），或者已排队并就绪。  
|睡眠  |S  |TASK_INTERRUPTIBLE:进程正在等待某一条件：硬件请求、系统资源访问或信号。当事件或信号满足条件时，该进程将返回到运行中。  
||D  |TASK_INTERRUPTIBLE：此进程也在睡眠，但与S状态不同，不会响应传递的信号。仅在特定的条件下使用，其中进程中断可能会导致意外的设备状态。  
||K  |TASK_KILLABLE:与不可中断的D状态相同，但有所修改，允许等待中的任务通过响应信号而被中断（彻底退出 ）。实用程序通常将可中断的进程显示为D状态。。  
|已停止  |T  |TASK_STOPPED：进程已被停止（暂停），通常是通过用户或其他进程发出的信号。进程可以通过另一信号返回到运行中状态，继续执行（恢复）  
||T  |TASK_TRACED:正在被调试的进程也会临时停止，并且共享同一个T状态标志。  
|僵停  |Z  |EXIT_ZOMBIE：子进程在退出时向父进程发出信号。除进程身份（PID）之外的所有资源都已释放。  
||X  |EXIT_DEAD:当父进程清理（获取）剩余的子进程结构时，进程现在已经彻底释放。此状态从不会在进程列出实用程序中看到。  

使用时可以通过短名称(HUP)或正确的名称（SIGHUP）指代信号  

|信号编号  |短名称  |定义  |用途  
| :--
|1  |HUP  |挂起  |用于报告终端控制进程的终止。也用于请求进程重新初始化（重新加载配置）而不终止  
|2  |INT  |键盘中断  |导致程序终止可以被拦截或处理。通过键盘INTR字符（Ctrl-c）发送  
|3  |QUIT  |键盘退出  |与SIGINT相似，但也在终止时生成进程转储。通过键入QUIT字符（Ctrl-\\）发送。  
|9  |KILL  |中断，无法拦截  |导致立即终止程序，无法被拦截、忽略或处理；总是致命的。  
|15（默认）  |TERM  |终止  |导致程序终止。和SIGKILL不同，可以被拦截、忽略或处理。要求程序终止的友好方式；允许自我清理。  
|18  |CONT  |继续  |发送到进程使其恢复（若已停止）。无法被拦截。即使被处理，也始终恢复进程  
|19  |STOP  |停止，无法拦截  |暂停进程。无法被拦截或处理  
|20  |TSTP  |键盘终止  |和SIGSTOP不同，可以被拦截、忽略或处理。通过键入SUSP字符（Ctrl-z）发送。  



#### top中的基本击键操作
|键  |用途  
| :--
|?或h  |交互式击键操作的帮助  
|l、t、m  |切换到负载、线程、内存标题行  
|1  |标题中切换显示单独CPU信息或所有CPU的汇总。  
|s(1)  |更改刷新（屏幕）率，以带小数的秒数表示（如0.5、1、5）。  
|b  |切换反射突出显示运行中的进程；默认为粗体  
|B  |在显示中使用粗体，用于标题以运行中的进程。  
|H  |切换线程；显示进程摘要或单独线程。  
|u,U  |过滤任何用户名称（有效、真实）  
|M  |按内存使用率以降序方式对进程列表排序  
|P  |按处理器使用率，以降序方式对进程列表排序  
|k(1)|中断进程。若有提示，输入PID，再输入signal  
|r(1)|调整进程的nice值。若有提示，输入PID，再输入nice_value  
|W  |写入（保存）当前的显示配置，以便在下一次重新启动top时使用  
|q  |退出  
|注：  |安全模式中不可用
