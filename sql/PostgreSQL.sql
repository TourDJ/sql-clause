
-- PostgreSQL 查询语句

-- 查询
SELECT * from t_user where id='test' and status<>0 ORDER BY id ;

-- 连接查询
SELECT a.* from t_user a, t_role b 
where code='test'and a.id=b.uid ;

-- 查询所有表中记录在另一张表中有相关记录的数据
SELECT * from t_user b 
where EXISTS (
  SELECT 1 from t_person a where a.code='test'and a.status=0 and a.uid=b.id ;
)

-- 查询名称不为空的记录
SELECT * from t_user a WHERE a.name<>'' ;


-- 更新语句

-- 更新所有 kind 记录为空的数据
UPDATE t_library set kind=1 where kind is NULL ;

-- 更新所有 kind 所有记录为空的数据
UPDATE t_library a set unit=(
  SELECT unit from t_library_all b where b.code='test' and b.status=0 and b.lid=a.id
)
WHERE a.unit is NULL ;

-- 更新时间为当前时间
UPDATE t_library a set create_time=now() where a.create_time is null ;

-- 更新一张表中一个子段为另一个子段的截取值
update t_user set "source"=substring(name from 2 for 3) ;

-- 更新子段为另一个表中的子段，并转换类型
update t_menu a set "period"=(
  select cast(source as integer ) from menu_all b where a.no=b.no and b.no<>'——' and b.source<>''
)
where a.no<>'012' ;

-- 分割字符串为数组
UPDATE test set dates=regexp_split_to_array(atrr, E'～')


-- 
UPDATE test set (f, t) = (dates[1], dates[2])


-- 
UPDATE test set f=regexp_replace(f, '-1-', '-01-')



-- 创建视图

CREATE VIEW view_user as
SELECT a."id", a."no", a."name", a.role from t_user a
WHERE a.status=1

