
## postgreSQL 查询语句

[常用SQL操作](http://www.cnblogs.com/kaituorensheng/p/4667160.html#_label9)    
[基本操作](http://www.cnblogs.com/happyhotty/articles/1920455.html)    
[pg_ctl](http://www.cnblogs.com/jackyyou/p/5685502.html)   


#### 递归查询，显示树型结构数据

      WITH RECURSIVE le (id, code,name,parent_code, url, icon, sort, classify) as 
      (
       select id, code,name,parent_code, url, icon, sort, classify from t_menu where code='root' and is_deleted=0
       union all
       select e2.id, e2.code,e2.name,e2.parent_code, e2.url, e2.icon, e2.sort, e2.classify from t_menu e2,le e3 where e3.code=e2.parent_code and e2.is_deleted=0 
      )
      select * from le 
      order by classify, code asc
      LIMIT 100 OFFSET 0

## Debian 源码安装 PostgreSQL

下载源码包并解压

      wget https://www.postgresql.org/ftp/source/v9.6.4/
      tar zxvf postgresql-9.6.4.tar.gz
      cd postgresql-9.6.4

编译安装

      ./configure --prefix=/usr/local/pgsql
      make
      make install

> 编译如果出现以下错误：   
  configure: error: readline library not found   
> 解决方法：     
  You probably need to install libreadline-dev.
  A quick way to search for packages in cases like this is to use a command like:    
    apt-cache search libreadline    
    sudo apt-get install libreadline-dev

创建用户与组：

      groupadd postgres
      useradd -d /home/postgres -s /bin/bash -g postgres -m postgres
      cd /usr/local/pgsql/
      mkdir data
      chown postgres:postgres data/
 

配置环境变量：

      su - postgres
      vi .profile (增加 export PG_DATA=/usr/local/pgsql/data)
      source ./.bash_profile 

初始化数据库：

      initdb -E UNICODE -D /usr/local/pgsql/data
      cd /usr/local/pgsql/data
      touch pgsql.log

修改监听地址与端口参数：

      vi postgresql.conf 
      listen_addresses = '*'         # what IP address(es) to listen on;
                                              # comma-separated list of addresses;
                                              # defaults to 'localhost', '*' = all
                                              # (change requires restart)
      port = 5432                            # (change requires restart)

启动数据库服务器

      pg_ctl -D /usr/local/pgsql/data/ -l pgsql.log start


正则表达式匹配操作符：

|操作符	|描述	|例子|
|-----  |------------------- | -------------|
|~	|匹配正则表达式，大小写相关	 |'thomas' ~ '.*thomas.*'|
|~*	|匹配正则表达式，大小写无关	 |'thomas' ~* '.*Thomas.*'|
|!~	|不匹配正则表达式，大小写相关	|'thomas' !~ '.*Thomas.*'|
|!~*	|不匹配正则表达式，大小写无关	|'thomas' !~* '.*vadim.*'|





