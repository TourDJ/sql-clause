
## MySQL 使用索引





### Using temporary 和 Using filesort解决方案

Using temporary（临时表）

#### Using filesort（文件排序）

使用order by的字段要使用索引，如果没有使用该索引，会出现了Using filesort文件排序，使其查询变慢。

在创建组合索引时，where条件的字段的索引在orderBy的字段之前，如果orderBy是多字段，则必须依照顺序创建。
