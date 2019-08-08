[TOC]

# ArangoDB v3.4.x 使用说明

ArangoDB 目前的最新稳定版本是 3.4.x。从版本3.4.0开始，除了安装包之外，还可以为`Linux`平台提供 tar.gz 存档。

使用之后发现，3.4 与 之前版本的使用有一些不一样。如果你使用的是tar包版，最直观的感受是目录结构不一样了。

* bin
* README
* usr

发现 .conf 文件及数据相关的一些文件不见了。

官方说明指出，启动命令分为三种：

* Single Server
* Active Failover
* Cluster


Single Server 
-------------
 
Use
 
    arangodb --starter.mode single --starter.data-dir /tmp/mydata
 
where `/tmp/mydata` should point to the directory containing the data. The database itself will be in `/tmp/mydata/single8529/data`.The apps will be stored in `/tmp/mydata/single8529/apps`.
 
Active Failover
---------------
 
An active failover deployment can be started using
 
    arangodb --starter.mode activefailover --starter.data-dir /tmp/mydata
 
Please then read the instructions printed on screen for starting the additional servers.
 
Cluster
-------
 
A cluster can be started using                                                                                                                            
 
    arangodb --starter.mode cluster --starter.data-dir /tmp/mydata
 
Please then read the instructions printed on screen for start


> `data-dir`&nbsp;&nbsp;表示用于存储启动程序生成的所有数据的目录（并保存实际的数据库目录）（默认为当前路径）

## Install distributions
The ArangoDB starter (arangodb) comes with all current distributions of ArangoDB.

If you want a specific version, download the precompiled binary via the [GitHub releases page](https://github.com/arangodb-helper/arangodb/releases).

- [ ] **Cmd Markdown 开发**
    - [ ] 改进 Cmd 渲染算法，使用局部渲染技术提高渲染效率
    - [ ] 支持以 PDF 格式导出文稿
    - [x] 新增Todo列表功能 [语法参考](https://github.com/blog/1375-task-lists-in-gfm-issues-pulls-comments)
    - [x] 改进 LaTex 功能
        - [x] 修复 LaTex 公式渲染问题
        - [x] 新增 LaTex 公式编号功能 [语法参考](http://docs.mathjax.org/en/latest/tex.html#tex-eq-numbers)
- [ ] **七月旅行准备**
    - [ ] 准备邮轮上需要携带的物品
    - [ ] 浏览日本免税店的物品
    - [x] 购买蓝宝石公主号七月一日的船票

abc[^footnote]


[^footnote]: 这是一个 *注脚* 的 **文本**。
