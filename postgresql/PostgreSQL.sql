
-- PostgreSQL 

------------------- 查询语句

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

-- 区分大小写
SELECT * FROM t_user a WHERE UPPER(a.name) LIKE UPPER('%ml%')

-- 将逗号分隔字符串转换为数组
-- 查询包含指定号码的人员
SELECT * from (
  SELECT a.id, a."no", a.NAME, a.TYPE, regexp_split_to_array(a."operator", ',') operators from users a 
) b where '11' = ANY (b.operators)

-- 将逗号分隔字符串转换为表，再关联查询
-- 例如：查找所有有权限的操作人员才可以编辑数据
-- operator: 1,4,23,24,26
SELECT * FROM t_sell M,
	(
		SELECT
			A . ID,
			regexp_split_to_table(A .operator, ',') AS userId
		FROM
			t_sell A
	) n
WHERE
	M ."id" = n. ID
AND TRIM (n.userId) = #{ userId }
AND M .status = 1


------------------- 更新语句

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

					  
					  
-- 在PostgreSQL中可以直接对时间进行加减运算：

SELECT now()::timestamp + '1 year';  --当前时间加1年
SELECT now()::timestamp + '1 month';  --当前时间加一个月
SELECT now()::timestamp + '1 day';  --当前时间加一天
SELECT now()::timestamp + '1 hour';  --当前时间加一个小时
SELECT now()::timestamp + '1 min';  --当前时间加一分钟
SELECT now()::timestamp + '1 sec';  --加一秒钟
select now()::timestamp + '1 year 1 month 1 day 1 hour 1 min 1 sec';  --加1年1月1天1时1分1秒
SELECT now()::timestamp + (col || ' day')::interval FROM table; --把col字段转换成天 然后相加

