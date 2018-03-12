
## MySQL 常用语句

[MySQL查看当前用户、存储引擎、日志](http://www.cnblogs.com/xiaoit/p/3376596.html)

查看MySQL用户权限

    show grants for 你的用户
    show grants for root@'localhost';

[MySQL的Grant命令](http://www.cnblogs.com/hcbin/archive/2010/04/23/1718379.html)


create table t(id int auto_increment not null, c1 int, c2 int, c3 int, primary key(id));

show create table t ;

create trigger inst_t before insert on t for each row set new.c3=new.c1+new.c2;

show triggers;

create trigger upd_t before update on t for each row set new.c3=new.c1+new.c2;

update t set t.c1=5 where id = 1;

create view vw_t as select id, c1, c2, c1+c2 as c3 from t;

select * from vw_t;






