
## MySQL 常用语句

[MySQL查看当前用户、存储引擎、日志](http://www.cnblogs.com/xiaoit/p/3376596.html)

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


create table t(id int auto_increment not null, c1 int, c2 int, c3 int, primary key(id));

show create table t ;

create trigger inst_t before insert on t for each row set new.c3=new.c1+new.c2;

show triggers;

create trigger upd_t before update on t for each row set new.c3=new.c1+new.c2;

update t set t.c1=5 where id = 1;

create view vw_t as select id, c1, c2, c1+c2 as c3 from t;

select * from vw_t;






