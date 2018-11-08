
## postgreSQL 查询语句

[常用SQL操作](http://www.cnblogs.com/kaituorensheng/p/4667160.html#_label9)    
[基本操作](http://www.cnblogs.com/happyhotty/articles/1920455.html)    


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
