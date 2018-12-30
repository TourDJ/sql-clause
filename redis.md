


SET key value

    redis> SET mykey "Hello"
    "OK"
    redis> GET mykey
    "Hello"
    redis> 


Redis是REmote DIctionary Server的缩写。Redis是一种高级key-value数据库。它跟memcached类似，不过数据可以持久化，而且支持的数据类型很丰富。
有字符串，链表，集合和有序集合。支持在服务器端计算集合的并，交和补集(difference)等，还支持多种排序功能。所以Redis也可以被看成是一个数据结构服
务器。 

> Redis的所有数据都是保存在内存中，然后不定期的通过异步方式保存到磁盘上(这称为“半持久化模式”)；也可以把每一次数据变化都写入到一个append only 
file(aof)里面(这称为“全持久化模式”)。

## 安装

    ivan@debianJF:~$ wget http://download.redis.io/releases/redis-3.0.7.tar.gz
    ivan@debianJF:~$ tar zxvf redis-3.0.7.tar.gz
    ivan@debianJF:~$ cd redis-3.0.7
    ivan@debianJF:~$ make

> make 命令执行后，最好执行下 make test 命令，验证数据库安装是否正常。此步骤有可能报 “ couldn't execute "tclsh8.5": no such file or directory ” 错误，安装一下 tcl8.5+ 即可。

    ivan@debianJF:~$ make install

> make install命令执行完成后，会在/usr/local/bin目录下生成本个可执行文件，分别是redis-server、redis-cli、redis-benchmark、
  redis-check-aof 、redis-check-dump，它们的作用如下：  
    * redis-server：Redis服务器的daemon启动程序     
    * redis-cli：Redis命令行操作工具。也可以用telnet根据其纯文本协议来操作    
    * redis-benchmark：Redis性能测试工具，测试Redis在当前系统下的读写性能       
    * redis-check-aof：数据修复   
    * redis-check-dump：检查导出工具     
    *   

> 为什么没用标准的Linux安装三板斧呢？官方维基是这样说的：  
  Redis can run just fine without a configuration file (when executed without a config file a standard configuration is used). 
  With thedefault configuration Redis will log to the standard output so you can check what happens. Later, you canchange the 
  default settings.

## 配置
redis的配置文件在你的安装目录里。

    cp redis.conf /usr/local/redis

参数介绍：
* daemonize：是否以后台daemon方式运行
* pidfile：pid文件位置
* port：监听的端口号
* timeout：请求超时时间
* loglevel：log信息级别
* logfile：log文件位置
* databases：开启数据库的数量
* save * *：保存快照的频率，第一个*表示多长时间，第二个*表示执行多少次写操作。在一定时间内执行一定数量的写操作时，自动保存快照。可设置多个条件。
* rdbcompression：是否使用压缩
* dbfilename：数据快照文件名（只是文件名，不包括目录）
* dir：数据快照的保存目录（这个是目录）
* appendonly：是否开启appendonlylog，开启的话每次写操作会记一条log，这会提高数据抗风险能力，但影响效率。
* appendfsync：appendonlylog如何同步到磁盘（三个选项，分别是每次写都强制调用fsync、每秒启用一次fsync、不调用fsync等待系统自己同步）

## 使用
启动

    sudo ./redis-server
    sudo ./redis-server ./redis.conf

客户端连接

    sudo ./redis-cli
    sudo ./redis-cli -p 6380 (如果用的不是默认端口)

停止

    sudo ./redis-cli shutdown


## 将redis做成一个服务
复制脚本到/etc/rc.d/init.d目录。启动脚本 redis_init_script 位于位于Redis 安装的 /utils/ 目录下。

    cp redis_init_script /etc/init.d/redisd


如果这时添加注册服务：

    chkconfig --add redis
将报以下[错误](http://www.cnblogs.com/goodspeed/archive/2012/10/18/2729615.html)：
redis服务不支持chkconfig, 为此，我们需要更改redis脚本。 在启动脚本开头添加如下两行注释以修改其运行级别：

    #!/bin/sh
    # chkconfig:   2345 90 10
    # description:  Redis is a persistent key-value database
    #
再设置即可成功。    
  
设置为开机自启动服务器

      chkconfig redisd on

将Redis的命令所在目录添加到系统参数PATH中

    vi /etc/profile
    export PATH="$PATH:/usr/local/redis/bin"
这样就可以直接调用redis-cli的命令了。

> Redis有两种存储方式，默认是snapshot方式，实现方法是定时将内存的快照(snapshot)持久化到硬盘，这种方法缺点是持久化之后如果出现crash则会丢失一段数据。因此在完美主义者的推动下作者增加了aof方式。aof即append only mode，在写入内存数据的同时将操作命令保存到日志文件。
