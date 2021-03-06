
## MySQL 服务器

如果你指定 localhost 作为一个主机名【也就是你在本机上连接本机的mysql服务】， mysqladmin 默认使用Unix套接字文件连接，而不是TCP/IP。
从MySQL 4.1 开始，通过--protocol= {TCP |SOCKET | PIPE | MEMORY} 选项，你可以显示地指定连接协议，举例如下：

socket 连接：

    [zzz@zzz mysql]$ mysql -uroot
    ERROR 2002 (HY000): Can't connect to local MySQL server through socket
    '/home/zzx/mysql/mysql.sock' (2)

tcp 连接：

    [zzz@zzz mysql]$ mysql --protocol=TCP -uroot -p -P3307 -hlocalhost

auth_socket     
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

***

## MySQL 安装
CentOS 7  
参考： [How To Install MySQL on CentOS 7](https://www.digitalocean.com/community/tutorials/how-to-install-mysql-on-centos-7)

*** 

## MySQL 函数   
### 日期函数
#### date_add() 为日期增加一个时间间隔

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



