
- [MySQL 使用常用知识](#mysql)     
  - [MySQL 安装](#mysql_install)      
  - [MySQL 服务器](#mysql_server)    
  - [MySQL 函数](#mysql_function)    
  
	
## <a id="mysql">MySQL 使用常用知识</a>


### <a id="mysql_install">MySQL 安装</a>

官网地址：https://dev.mysql.com/downloads/repo/yum/

『***CentOS 7*** 』    
安装步骤：    
1. 下载校验。
```
	wget https://dev.mysql.com/get/mysql57-community-release-el7-9.noarch.rpm
	md5sum mysql57-community-release-el7-9.noarch.rpm
```
2. 执行安装。
```
	sudo rpm -ivh mysql57-community-release-el7-9.noarch.rpm
	sudo yum install mysql-server
```
遇到确认提示直接按 `y`， 接受 GPG key， 允许下载内容。

3. 启动数据库
```
	sudo systemctl start mysqld
	sudo systemctl status mysqld
```
看到类似如下信息，表示启动成功。

	Dec 01 19:02:20 centos-512mb-sfo2-02 systemd[1]: Started MySQL Server.

在安装成功后，会给MySQL的 root 帐户生成一个临时密码，保存在 mysqld.log 中，用一下命令查看：

	sudo grep 'temporary password' /var/log/mysqld.log
输出

	2016-12-01T00:22:31.416107Z 1 [Note] A temporary password is generated for root@localhost: mqRfBU_3Xk>r
`mqRfBU_3Xk>r` 这个就是临时密码，记住他，后面修改密码会用到。

4. 配置数据库
```
	sudo mysql_secure_installation
```
系统会提示输入密码，输入后，出现修改密码的提示。

	The existing password for the user account root has expired. Please set a new password.

	New password:
输入两次新密码即可。
> 注意： MySQL 5.7 对密码要求 12 个字符以上，并且至少包含一个大写字母，一个小写字母，一个数字和一个特殊字符。

接着，会出现下面的提示：

	Estimated strength of the password: 100
	Change the password for root ? (Press y|Y for Yes, any other key for No) :
输入 no 即可。

后面还会弹出几个提示，按 y。

4. 测试数据库       
安装、配置完成后，测试一下是否安装成功。
```
	mysqladmin -u root -p version
```
输出类似下面的内容：

	mysqladmin  Ver 8.42 Distrib 5.7.16, for Linux on x86_64
	Copyright (c) 2000, 2016, Oracle and/or its affiliates. All rights reserved.

	Oracle is a registered trademark of Oracle Corporation and/or its
	affiliates. Other names may be trademarks of their respective
	owners.

	Server version          5.7.16
	Protocol version        10
	Connection              Localhost via UNIX socket
	UNIX socket             /var/lib/mysql/mysql.sock
	Uptime:                 2 min 17 sec

	Threads: 1  Questions: 6  Slow queries: 0  Opens: 107  Flush tables: 1  Open tables: 100  
	Queries per second avg: 0.043
表示安装成功了。

参考资料：     
[How To Install MySQL on CentOS 7](https://www.digitalocean.com/community/tutorials/how-to-install-mysql-on-centos-7)


### <a id="mysql_server">MySQL 服务器</a>

如果你指定 localhost 作为一个主机名【也就是你在本机上连接本机的mysql服务】， mysqladmin 默认使用Unix套接字文件连接，而不是TCP/IP。
从MySQL 4.1 开始，通过`--protocol= {TCP |SOCKET | PIPE | MEMORY}` 选项，你可以显示地指定连接协议，举例如下：

socket 连接：

    [zzz@zzz mysql]$ mysql -uroot
    ERROR 2002 (HY000): Can't connect to local MySQL server through socket
    '/home/zzx/mysql/mysql.sock' (2)

tcp 连接：

    [zzz@zzz mysql]$ mysql --protocol=TCP -uroot -p -P3307 -hlocalhost

**auth_socket**     
如果您安装5.7并且没有为root用户提供密码，它将使用auth_socket插件。该插件不关心，也不需要密码。它只检查用户是否使用UNIX套接字进行连接，然后比较用户名。
```sql
mysql> USE mysql;
mysql> SELECT User, Host, plugin FROM mysql.user;

+------------------+-----------------------+
| User             | plugin                |
+------------------+-----------------------+
| root             | auth_socket           |
| mysql.sys        | mysql_native_password |
| debian-sys-maint | mysql_native_password |
+------------------+-----------------------+
```
改变插件：
```sql
$ sudo mysql -u root # I had to use "sudo" since is new installation

mysql> USE mysql;
mysql> UPDATE user SET plugin='mysql_native_password' WHERE User='root';
mysql> FLUSH PRIVILEGES;
mysql> exit;
```

### <a id="mysql_function">MySQL 函数</a>   
#### 日期函数
date_add() 为日期增加一个时间间隔

    set @dt = now();
    select date_add(@dt, interval 1 day); -- add 1 day
    select date_add(@dt, interval 1 hour); -- add 1 hour
    select date_add(@dt, interval 1 minute); -- ...
    select date_add(@dt, interval 1 second);
    select date_add(@dt, interval 1 microsecond);
    select date_add(@dt, interval 1 week);
    select date_add(@dt, interval 1 month);
    select date_add(@dt, interval 1 quarter);
    select date_add(@dt, interval 1 year);
    select date_add(@dt, interval -1 day); -- sub 1 day

参考资料：      
[MySQL 内置函数](https://dev.mysql.com/doc/refman/5.6/en/func-op-summary-ref.html)

## MySQL 变量
##### FOREIGN_KEY_CHECKS    
MySQL还原数据库，禁用和启用外键约束的方法(FOREIGN_KEY_CHECKS) 
禁用

    SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0
 
启用

    SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS
> 有时还原数据库时，因为表有约束导致40014错误，可以通过关闭外键约束，还原成功时再启用。

#### DELIMITER
告诉mysql解释器，该段命令是否已经结束了，mysql是否可以执行了。默认情况下，delimiter是分号;。

## MySQL 命令
查看是否还有其他进程在使用

    mysql -uroot -proot -h127.0.0.1 -P3306 -e 'show processlist;'

备份数据

    mysqldump -uroot -proot express_user > ~/expressuser.sql

查看mysql是否运行

    ps aux | grep mysql
    
查看创建表语句

    show create table seckill\G
    
升级数据库版本

    mysql_upgrade -u root -p  
> mysql_upgrade examines all tables in all databases for incompatibilities with the current version of MySQL Server. mysql_upgrade also upgrades the system tables so that you can take advantage of new privileges or capabilities that might have been added.  
  

mysql 新设置用户或更改密码后需用flush privileges刷新MySQL的系统权限相关表，否则会出现拒绝访问，还有一种方法，就是重新启动mysql服务器，来使新设置生效。

    flush privileges

Grant 命令

    grant 权限 on 数据库对象 to 用户

查看字符集   

    show variables like 'character_set_%';    
    show variables like 'collation_%';
    
>   mysql 插入数据乱码解决方法：         
>       alter database jiefang character set utf8;    
>       set names 'utf8';    
>       set character_set_server=utf8;     
>   设置好后重新创建表

mysql 初始化       
以管理员身份打开命令行窗口, 运行:

	mysqld --initialize-insecure 
> 1.不设置root密码
  2.不能手动建data文件夹

删除 mysql 服务 

	sc delete mysql


修改密码

	ALTER USER 'root'@'localhost' IDENTIFIED BY '********'



 
*** 

参考资料：   
[MySQL的Grant命令](http://www.cnblogs.com/hcbin/archive/2010/04/23/1718379.html)   
[mysql 权限](http://blog.csdn.net/liang_0609/article/details/52473689)

## MySQL 常用语句

### DDL（Data Definition Language）数据库定义语言


### DML（Data Manipulation Language）数据操纵语言


### DCL（Data Control Language）数据库控制语言

查看MySQL用户权限

    show grants for 你的用户
    show grants for root@'localhost';

[MySQL的Grant命令](http://www.cnblogs.com/hcbin/archive/2010/04/23/1718379.html)    

使用ALTER USER命令可以用来修改用户的口令,设置口令过期,锁定以及解锁用户等等。

修改用户的口令，将用户的口令修改为新的密码               

    ALTER USER SCOTT IDENTIFIED BY NEWPASSWORD;
    v5.7
    ALTER USER 'root'@'localhost' IDENTIFIED BY 'root12345678';
> MySQL5.7 为了安全，密码设置规则做了改变，详见： [MySQL5.7 修改](http://www.cnblogs.com/ivictor/p/5142809.html)

设置用户口令过期，通过设置用户过期，这样该用户在下次登录的时候就必须要修改密码。

    ALTER USER SCOTT PASSWORD EXPIRE;


锁定用户，将用户锁定之后，被锁定的用户是不能够再次登录到系统中。

    ALTER USER SCOTT ACCOUNT LOCK;



### TCL（Transaction Control Language）事务控制语言


[MySQL查看当前用户、存储引擎、日志](http://www.cnblogs.com/xiaoit/p/3376596.html)


create table t(id int auto_increment not null, c1 int, c2 int, c3 int, primary key(id));

show create table t ;

create trigger inst_t before insert on t for each row set new.c3=new.c1+new.c2;

show triggers;

create trigger upd_t before update on t for each row set new.c3=new.c1+new.c2;

update t set t.c1=5 where id = 1;

create view vw_t as select id, c1, c2, c1+c2 as c3 from t;

select * from vw_t;


## 创建用户并授权(5.7)

#### 创建用户
CREATE USER 'mysql'@'%' IDENTIFIED BY 'mysql123'; 

#### 授权
GRANT all ON lenos.* TO 'mysql'@'%';

#### 修改密码
SET PASSWORD FOR 'root'@'localhost' = PASSWORD('root1234');

#### 撤销权限
REVOKE privilege ON databasename.tablename FROM 'username'@'host';

## MySQL 变量

#### validate_password_policy  密码验证策略
|Policy	|Tests Performed|
|----|--------|
|0 or LOW	    |Length|
|1 or MEDIUM	|Length; numeric, lowercase/uppercase, and special characters|
|2 or STRONG	|Length; numeric, lowercase/uppercase, and special characters; dictionary file|
默认是1，即MEDIUM，设置的密码必须符合长度，且必须含有数字，小写或大写字母，特殊字符。


#### validate_password_length  密码验证长度

#### 创建表时使用编码
```sql
CREATE TABLE menu (
    id int(4) primary key NOT NULL auto_increment,
    icon varchar(1000),
    category varchar(100),
    logo varchar(2000),
    parent_id int(4)
    classify int(2),
    remark varchar(255),
    create_user int(4),
    create_time timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    update_user int(4),
    update_time timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    status int(2) DEFAULT 1,
)character set utf8
```


#### 更改表的编码

alter table address convert to character set utf8


在命令行输入：mysqld -nt --skip-grant-tables
以管理员身份重新启动一个cmd命令窗口，输入：mysql -uroot -p，Enter进入数据库。



当一张表中的数据有层级关系时，要更新层级数据：
update t_area t, t_area t2 set t.parent_name = t2.name where t.parent_id = t2.id;
而使用以下语句：
update t_area t set t.parent_name = (select t2.name from t_area t2 where t.parent_id = t2.id);
会报错：
 You can't specify target table 't' for update in FROM clause



#### MySQL字符集设置

	character_set_server：默认的内部操作字符集
	character_set_client：客户端来源数据使用的字符集
	character_set_connection：连接层字符集
	character_set_results：查询结果字符集
	character_set_database：当前选中数据库的默认字符集
	character_set_system：系统元数据(字段名等)字符集

查询字符集命令：      

	• SHOW CHARACTER SET;
	• SHOW COLLATION;
	• SHOW VARIABLES LIKE ‘character%’;
	• SHOW VARIABLES LIKE ‘collation%’;
例如：

	mysql> show variables like 'character%';
	+--------------------------+----------------------------------------+
	| Variable_name            | Value                                  |
	+--------------------------+----------------------------------------+
	| character_set_client     | utf8mb4                                |
	| character_set_connection | utf8mb4                                |
	| character_set_database   | latin1                                 |
	| character_set_filesystem | binary                                 |
	| character_set_results    | utf8mb4                                |
	| character_set_server     | latin1                                 |
	| character_set_system     | utf8                                   |
	| character_sets_dir       | E:\mysql-5.7.24-winx64\share\charsets\ |
	+--------------------------+----------------------------------------+
字符集使用注意事项：    
⑴ 建立数据库/表和进行数据库操作时尽量显式指出使用的字符集，而不是依赖于MySQL的默认设置      
⑵ my.cnf(my.ini)中的default_character_set设置只影响mysql命令连接服务器时的连接字符集，不会对使用libmysqlclient库的应用程序产生任何作用    
⑶ 对字段进行的SQL函数操作通常都是以内部操作字符集进行的，不受连接字符集设置的影响      

修改默认字符集      
(1) 修改mysql的配置文件 my.cnf(my.ini) 文件中的字符集键值

	default-character-set = utf8
   	character_set_server =  utf8
修改完后，重启mysql的服务

(2) 使用mysql的命令

     mysql> SET character_set_client = utf8 ;
     mysql> SET character_set_connection = utf8 ;
     mysql> SET character_set_database = utf8 ;
     mysql> SET character_set_results = utf8 ;
     mysql> SET character_set_server = utf8 ;
     mysql> SET collation_connection = utf8 ;
     mysql> SET collation_database = utf8 ;
     mysql> SET collation_server = utf8 ;

另 `SET NAMES 'utf8';` 相当于下面的三句指令：

	SET character_set_client = utf8;
	SET character_set_results = utf8;
	SET character_set_connection = utf8;



