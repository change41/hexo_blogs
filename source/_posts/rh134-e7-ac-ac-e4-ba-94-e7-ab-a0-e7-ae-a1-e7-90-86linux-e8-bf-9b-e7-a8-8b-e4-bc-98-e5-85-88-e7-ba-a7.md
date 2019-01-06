---
title: RH134 第五章 管理Linux 进程优先级
url: 362.html
id: 362
categories:
  - RHEL134
date: 2018-05-14 11:30:58
tags:
---

###### Linux 进程调度和多任务   

   通过使用称为时间片的技术，Linux（和其它操作系统）实际能够运行的进程数（和线程数）可以超出可用的实际处理单元数。操作系统进程调度程序将在单个核心上的进程之间快速切换，从而给用户一种有多个进程在同时运行的印象。  

相对优先级

   由于不是每种进程都与其它进程同样重要，可告知高度程序为不同的进程使用不同的调度策略。常规系统上运行的大多数进程所使用的调度策略称为SCHED\_OTHER(也称为SCHED\_NORMAL),但还有一些其他策略可用于不同的目的。  

   由于并非所有进程都以同样的方式创建，可为采用SCHED_NORMAL 策略运行的进程指定相对优先级。此优先级称为进程的 nice 值，一个进程可以有正好 40 种不同的 nice 值。这些 nice 值正好从 -20 到 19。默认情况下，进程将继承其父进程的 nice 级别，通常为 0 ， nice 值 级别越高，表示优先级越低（该进程容易将其 CPU 使用量让给其他进程）； nice 级别越低，表示优先级越高（该进程更加不倾向于让出CPU）。  

![image.png](1526262567734231.png)

###### nice 级别和权限

   为很占CPU资源的进程设置较低的 nice 级别可能对同一系统上运行的其它进程的性能造成负面影响，所以仅允许 root 用户（更具体的说，具有 CAP\_SYS\_NICE 功能的用户）设置负 nice 级别以及降低现有进程的 nice 级别。  

   普通非特权用户仅允许设置正的nice 级别。此外，他们只能对现有进程提升 nice 级别。而不能降低 nice 级别  

###### TIP：

   除 nice 级别以外，还有更多方法可以影响进程优先级和资源使用情况。有备用的高度程序策略和设置、控制组（cgroups）等等，但是 ,nice 级别是最容易的，并且系统管理员和普通用户都可以使用。  

使用 nice 和 renice  影响进程优先级

###### 查看 nice 级别

   可以通过多种不同的方式查看现有进程的 nice 级别。大多数进程管理工具（如 gnome-system-monitor）默认情况下已显示 nice 级别，或可以配置为显示 nice 级别。  

###### 使用top 显示 nice 级别

   top 命令可用于通过交互方式查看（和管理）进程。在默认配置中，top 将显示与 nice 级别有关的两列：N1 表示实际 nice 级别，而PR将 nice 级别显示为映射到更大优先级队列： nice 级别 -20 映射到优先级 0 ，而 nice 级别 +19 映射到优先级39。  

###### 使用ps 显示 nice 级别

   ps 命令也可以显示进程的 nice 级别，但它在大多数默认输出格式中并不显示，然后，用户可以通过 ps 准备请求所需的列，而 nice 字段的名称为 nice   

#ps 请求包括 pid 、名称和nice 级别，按 nice 级别降序排列：
```sh
[root@server0 ~]# ps axo pid,comm,nice --sort=-nice
   PID COMMAND          NI
   286 khugepaged       19
   884 alsactl          19
  2639 tracker-miner-f  19
   285 ksmd              5
   927 rtkit-daemon      1
     1 systemd           0
     2 kthreadd          0
     3 ksoftirqd/0       0
     7 migration/0       -
     8 rcu_bh            0
```
某些进程的nice 级别可能报告为 - 。这些进程使用不同的高度策略运行，并且调度程序几乎将他们视为具有较高优先级。通过从ps 请求 cls 字段，可以显示调度程序策略。此字段中的 TS 表示该进程在 SCHED_NORMAL 下运行并且可以使用 nice 级别；任何其它内容都表示正在使用不同的调度程序策略。  

###### 启动具有不同 nice 级别的进程

启动进程时，它通常将继承父进程的 nice 级别。这表示从命令行启动一个进程时，它将与从其启动的shell进程具有相同的nice 级别。在大多数情况下，这将导致新进程运行的 nice 级别为 0 。

要启动具有不同 nice 级别的进程，用户和系统管理员可以使用 nice 工具运行其命令。不带任何其它选项的情况下，运行 nice <COMMAND> 将启动 nice 级别为 10 的 <COMMAND>.通过 nice 命令使用 -n <NICELEVEL> 选项，可以选择其他 nice 级别。如：启动 nice 级别为 15 的命令 dogecoinminer 并将其立即发送到后台:
```sh
nice -n 15 dogecoinminer &
```
###### TIP:

非特权用户允许设置正的 nice级别 （0 - 19 ）。只有 root 可以设置负的 nice级别 （- 20 到 -1）。

###### 更改现有进程的 nice 级别

可以在命令行中使用 renice 命令来更改现有进程的 nice 级别。 renice 命令的语法如下：

renice -n <NICELEVEL> <PID> ... （可以一次指定多个进程）

renice -n -7 $(pgrep origami@home)    #将所有origami@home进程的 nice 级别更改为 -7 

###### TIP: 

普通用户仅允许提升 nice 级别，只有 root 才能使用 renice 降低 nice 级别。

也可以使用 top 命令（以交互方式）更改进程的 nice 级别，在top 中，按 r ，然后跟要更改的 PID 和 新的 nice 级别  

![image.png](1526266653786433.png)

![image.png](1526266685205928.png)

![image.png](1526266750818667.png)

![image.png](1526266722562134.png)
