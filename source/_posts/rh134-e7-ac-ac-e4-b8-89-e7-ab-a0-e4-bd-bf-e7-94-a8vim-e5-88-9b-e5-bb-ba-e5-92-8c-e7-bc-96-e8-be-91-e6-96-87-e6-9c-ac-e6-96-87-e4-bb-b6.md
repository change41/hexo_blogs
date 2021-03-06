---
title: RH134 第三章 使用VIM创建和编辑文本文件
url: 338.html
id: 338
categories:
  - RHEL134
date: 2018-05-08 11:07:04
tags:
---

当非特权用户在RHEL7 计算机上使用vi时，执行的命令将是vim。这是在shell 启动时通过/etc/profile.d/vim.sh 中设置的别名完成的。  

对于 UID 小于或等于200的用户，没有设置这一别名。这些用户将执行vi，也就是vi兼容模式中的vim。这意思意味了典型vi中没有的功能将被禁用。在需要较新的功能时，建议始终执行vim 命令。而不要依赖不一定可用的别名。用户通常需要以root身份操作时尤其需要这么做。

**三种不同版本的vim   
**

vim-minimal:仅提供vi功能和相关命令，此版本包括在RHEL7最小化安装里。

vim-enhanced：此版本提供vim命令，提供表达式，高亮，文件类型插件，和拼写检查

vim-X11：此版本提供gvim 图形化的vim.同时支持鼠标

**vim 的三个主要模式：**

| 功能 |模式
| :--
|命令模式|此模式用于文件导航，剪切和粘贴以及简单命令。 撤销，重做和其他操作也可以从此模式执行
|插入模式|此模式用于正常文本编。替换模式是插入模式的一种变体，替换文本而不是插入文本。
|执行模式|此模式用于保存，退出和打开文件，以及搜索和替换等更复杂的操作。从这种模式中，可以将程序的输出插入到当前文件中.配置 vim等等。 任何操作都有可能可能使用ex这个模式完成。

打开文件后，vim将在命令模式中启动。将在屏幕左下角看到有关已打开文件信息（文件名、行数、字符数），并将在右下角看到当前的光标位置（行、字符）以及正在显示文件的哪个部分（ALL表示全部，Top表示文件前几行，Bot 表示文件底部），或者显示百分比来表示当前所处文件位置。最下方线条在vim术语中称为标尺。  

要切换到插入模式，系统提供了可用的命令，且每个命令在键盘上均分配有一个不同的键

|键|结果
| :--
|i|切换到插入模式，并在当前光标位置之前插入
|a|切换到插入模式，并在当前光标位置之后插入
|I|将光标移至当前行的开头位置，并切换到插入模式
|A|将光标移到当前行的结尾位置，并切换到插入模式
|R|从光标下的字符开始，切换到替换模式。处理替换模式时，不会插入文件，输入的每个字符均将替换当前文档中的字符。
|o|在当前行的下方新打开一个行，并切换到插入模式。
|O|在当前行的上方新打开一个行，并切换到插入模式。

每次处于插入或替换模式时，标尺将会显示--INSERT-- 或 --REPLACE--。按Esc 即可返回命令模式。

RHEL 随附的vi和vim 版本已经配置为在命令和插入模式中识别和使用常规光标键以及如PgUp和End等键，这并不是vi所有安装版本上的默认行为。事实上，之前版本的vi根本不识别光标键，而是只允许在命令模式中使用诸如hjkl的键来操作。  

**vim光标操作**


|键  |结果
| :--
|h|向左移动一个位置
|l|向右移动一个位置
|j|向下移动一下位置
|k|向上移动一个位置
|^|移至当前行首
|$|移至当前行尾
|gg|移至文件第一行
|G|移至文件最后一行

保存文件通过ex模式实现，在命令模式下按  :（冒号）进入 ex模式

|键|结果
| :--
|:wq|保存并退出当前文件
|: x  |保存当前文件（如果存在未保存的更改），然后退出
|:w|保存当前文件并保留在编辑器中
|:w <filename>|以其他文件名保存当前文件
|:q|退出当前文件（仅在没有未保存更改的的情况下）
|:q!|退出当前文件，忽略任何未保存更改，！表示强制
|:3|跳到第3行

高级移动命令，仅在命令模式中可用，所有移到命令可以通过键入数字来加上前缀，如5w,将光标移动5个单词，或者12j将光标向下移到12行。实际上，每个命令（包括切换到插入模式）都可通过实际命令前键入重复次数来重复执行一定的次数，在vim术语中，这称为计数。  

|键|结果
| :--
|w|将光标移到下一单词的开头（w包含标点符号）
|b|将光标移到上一单词的开头（b包含标点符号）
|(|将光标移到当前或上一句子的开头
|)|将光标移到下一句子的开头
|{|将光标移到当前/上一段落的开头
|}|将光标移到下一段落的开头

替换文本，vim允许用户通过"change"命令替换大量（或少量）文件。"change"命令的使用方式为：按 c 键，后面加上光标移动；例如cw可以将当前光标位置更改到当前单词的末尾。要替换的文本被删除（放置在未命名寄存器中），vim 也会切换到插入模式。  

按c 两下（cc）将开始以行范围的方式替换，即替换一整行（或者带上数字时替换多行）同样的操作也适用于删除（d）

大多数移动命令可以带上i和a前缀，以选择inner 或a 版本的移动。例如ciw将替换整个当前单词，而不仅仅是从当前光标位置起，而caw则执行相同的功能，但包括周围任何空白区。

要替换到行末为止，可以使用cS，但C可执行相同的功能。（同样适用于删除命令（D））

要权替换光标处的字符，可按r再键入新的字符

要改变光标处字符的大小写，或按 ~



删除文本的操作方式与替换文本相同。用于删除文本的命令是d,而且对更改文本有效的所有相同移到也适用于删除，包括D可以删除光标位置到行末的内容。

**复制和粘贴**  

vim 用于描述复制和粘贴操作的术语与大多数人目前熟悉的稍有不同，复制操作也称为拖拉，而粘贴操作则叫做放置，这体现在分配给这些操作的键盘命令上：拖拉是y加上移到，而放置操作则通过p和P执行。

拖拉操作遵循与替换和删除操作相同的通用方案：如用户可以选择键入要重复某一操作的次数，后面加上y，再加上一种移到。例如5yaw，将复制当前的单词，以及后面4个单词（共5个）.按yy将拖拉一整行，等等

放置（粘贴）通过p和P命令执行；小写p将内容放置到当前光标位置的后面（如果粘贴是的是行范围数据，则放在当前行下面），而大写P则放置到当前光标位置的前面或者当前行上方。与所有其它命令一样，放置命令可以加上寄存器粘贴次数作为前缀。

**多个寄存器**

vim 不是仅提供一个供复制和粘贴 使用的剪贴板，而是提供26个命名寄存器，以及欠点特殊用途的寄存器。拥有多个寄存器可以让用户更加高效地很乖剪切和粘贴命令，而不必担心丢失数据，或者过多的移动光标。如果未指定要使用的寄存器，则将使用“未命名”寄存器。常规寄存器称为a到z,通过在命令的计数和实际命令之间放入"registername来选择，例如：要复制当前行和后面2行到t寄存器中，用户可以使用3"tyy

要放置命名寄存器中的内容，只需要在放置命令之前加上"registername，例如："sp将在光标位置后面放置s寄存器中的内容。

每次使用命名寄存器时，未命名寄存器也会更新。

删除和更改操作也可加上寄存器选择作为前缀。未指定寄存器时，将仅使用未命名寄存器。当使用寄存器的大写版本时，被剪切或拖拉的文本将附加到该寄存器，而不是覆盖它。

**特殊寄存器**

有10个数字编号的寄存器，分别为"0 - "9寄存器，"0使用拥有最近拖拉文本的副本，而寄存器"1则具有最近删除的文本的副本。当新的文本补更改或删除时，"1的内容将移到"2中，"2的内容移动"3中，以此类推。与命名寄存器不同，数字编号寄存器的内容不会在会话之间保存。

**可视模式**

在进入可视模式后（通过标尺--VISUAL--表示），任何光标移动将开始选择文本。可视模式中发出的任何更改、删除或拖拉命令不需要光标移动部分，而是对选定的文件起作用。

可视模式有三个类别：基于字符（通过 v 启动）、基于行（通过 V 启动） 、基于块（通过 Ctrl+v 启动）。使用gvim时，也可通过鼠标选择文本。

可视模式中发出的任何ex 命令也默认对选定的文本起作用。

**搜索**

在当前文档中搜索可能通过两种方式：按 / 键从光标处向前搜索，或者按 ？从当前光标位置向后搜索。进入搜索模式后，可以键入要搜索的正则表达式，然后按Enter 键跳到第一个匹配项。

要搜索下一个或者上一个匹配项可分别按 n 和 N 键。

奖励快捷方式：\* 将立即向前搜索光标处的单词。

**搜索和替换**

vim 中的搜索和替换通过 ex 命令实施，其使用的语法与用户通过sed 搜索和替换时所用的相同，包括使用正则表达式进入搜索的功能：

ranges/pattern/string/flags

range 可以是行号（43）、行范围（1，7 表示1 - 7行）、搜索条件（/README\\.txt）、%(当前文档中的所有行；搜索和替换通常仅会对当前行操作)，或者'<,'>(当前的可视选择)。

两个最常见的flaga 是 g （替换一行中多个位置上的pattern） 和 i  （使当前的搜索区分大小写）

:%s/\\<cat\\>/god/gi     #搜索文档中每个位置的cat ，并替换成dog ，不区分大小写，但仅对完整的词语，而不是诸如："catalog" 中的一部分。



**撤消和恢复**

为了允许人为的失误存在，vim配备了撤消/恢复机制。只要在命令模式中按u 即可撤消最近一个操作。如果撤消了过多操作，按 Ctrl + r 即可恢复最近一次撤消。

奖励诀窍：从命令模式中按 . (句号 英文)将对当前恢复最近一个编辑操作。这可以用于对多个行轻松执行同一编辑操作。
