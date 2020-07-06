
## MySQL 使用索引





### Using temporary 和 Using filesort解决方案

#### Using temporary（临时表）

左联接表时，如果orderBy使用的字段是第二张表的字段就会生成Using temporary。



#### Using filesort（文件排序）

使用order by的字段要使用索引，如果没有使用该索引，会出现了Using filesort文件排序，使其查询变慢。

在创建组合索引时，where条件的字段的索引在orderBy的字段之前，如果orderBy是多字段，则必须依照顺序创建。




排序尽量对第一个表的索引字段进行，可以避免mysql创建临时表，这是非常耗资源的。


### 参考资料

[Mysql-explain之Using temporary和Using filesort解决方案](https://www.cnblogs.com/fuhui-study-footprint/p/11648185.html)             
