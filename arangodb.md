
## [Arangodb AQL 常用语句](#AQL)
  
> An AQL query must either return a result (indicated by usage of the RETURN keyword) or execute a data-modification operation (indicated by usage of one of the keywords INSERT, UPDATE, REPLACE, REMOVE or UPSERT). The AQL parser will return an error if it detects more than one data-modification operation in the same query or if it cannot figure out if the query is meant to be a data retrieval or a modification operation.

> AQL only allows one query in a single query string; thus semicolons to indicate the end of one query and separate multiple queries (as seen in SQL) are not allowed.

### 查询语句

#### 根据内嵌属性查找记录
> **对表中多个属性过滤，如果属性是对象则取出值比较，如果属性是数组则再迭代过滤。**    
> IS_ARRAY(): 内置函数，判断对象是否是数组

        FOR p IN culture_person
        LET follow = IS_ARRAY(p.follow) ? p.follow : []
        LET attend = IS_ARRAY(p.attend) ? p.attend : []
          FOR a IN attend
          FILTER a.orgId == "6481522"
            or
          POSITION(follow, "6481522") == true
        RETURN p

***

#### 多个查询条件，并排序分页
> 查询条件可以用 and， or 连接，用法类似 SQL 语句，
> SORT, LIMIT 用法也类似 SQL

        FOR c IN culture   
        FILTER c.orgId == "5682513"   
        and ( (c.status == 2) 
            or ((c.creator == "5485266" or  c.role > 2) and c.status in [1, 3])
        )  
        SORT c.top desc, c.updateTime desc  
        LIMIT 0, 20   
        RETURN c
***

#### 模糊查询
> 模糊查询的功能类似于 SQL 中的 LIKE 用法，在 AQL 中有几个函数实现了该功能。
> 包括：CONTAINS, LIKE, REGEX_TEST 

         FOR c IN organization
         FILTER CONTAINS(c.orgName, "刘")  
         and c.orgType IN [1 ] 
         SORT c.updateTime desc  
         LIMIT 0, 20   
         RETURN c
***

### 查询统计
> 统计过滤后的记录数

         FOR c IN cultureorg  
         FILTER 1 == 1  
         and CONTAINS(c.orgName, "刘")  
         and c.orgType IN [1 ] 
         SORT c.updateTime desc  
         COLLECT WITH COUNT INTO num
         RETURN num
***

#### 多表关联查询
> 根据过滤条件在表中查找记录并与其它表关联获取相关字段值
> DATE_DIFF 是时间比较函数

        FOR r IN radar   
        FILTER  r.lo >= -990 and r.lo <= 101000      
        and r.la >= -990 and r.la <= 101000     
        and DATE_DIFF(r.scanTime, DATE_NOW(), "s") <= 1000000      
        and r.userId == "4003461"      
        LET userId = r.userId       
        FOR u IN user      
        FILTER u._key == userId      
        RETURN {_key: u._key, nickName: u.profile.nickName, avatar:u.profile.avatar}
***

#### 根据过滤指定值是否在数组中存在的条件查询
> POSITION 函数查找指定字段中是否存在给定字符串

        FOR p IN person
        LET orgs = p.follow
        FILTER POSITION(orgs, "5299783") == true
        COLLECT WITH COUNT INTO num  
        RETURN num
***

#### 根据拼接两个字段的值来模块查询
> 多表关联查询，并合并多表中的记录
> 可以先拼接几个字符串后再对拼接后的值模糊查询

        FOR p IN persons   
        LET name = CONCAT(p.surname, p.name)   
        FILTER CONTAINS(name, "刘")   
        FOR r IN resource   
        FILTER r._key == p.treeKey 
        FOR g IN catalog 
        FILTER g._key == r.gcId 
        RETURN {p, r, g}
***

#### 多个表关联查询
> 多表关联查询

        FOR b IN bind
        FILTER b._from == "user/4003461"
        LET fkey = b.familyKey
          FOR f IN tree
          FILTER f._key == fkey
            FOR fp IN Pedigree
            FILTER fp.familyKey == f._key
          RETURN fp.gcKey
***

#### 统计
> 先过滤记录在根据指定字段统计

        FOR p IN persons
        FILTER COUNT(p.children) > 0
        FOR c IN p.children
        LET l = LENGTH(c)
        COLLECT a = l WITH COUNT INTO num
        RETURN num
***

#### 分组
> 简单分组查询

        FOR p IN persons
        COLLECT treekey = p.treeID
        RETURN treekey
***

#### 使用正则条件查询
> 使用正则表达式查询，类似于 javascript 中的正则

        FOR u IN user
        FILTER u._key == "4003461"
        and REGEX_TEST(u.profile.trueName, "张.*", false)
        RETURN u
***

#### 使用给定数组过滤
> 根据常量数组过滤

        FOR p IN persons
        FILTER p.treeKey in [
          "1246017",
          "1246537",
          "4200480"
        ]
        COLLECT WITH COUNT INTO num
        RETURN num
***

#### 查询时间
> 查找数组类型的时间

        RETURN DATE_ISO8601(1505354933442)
***

#### 查找当前节点的始先祖
> 查询当前节点到祖先节点的路径关系，并记录代数

        FOR pl IN (
            FOR a IN persons
            FILTER a._id == "persons/1832466"
                FOR p IN persons
                FILTER p.gender == 0
                    LET person = (
                    FOR vertex
                      IN INBOUND SHORTEST_PATH
                      a TO p
                      relationships
                        RETURN vertex
                    )
                RETURN {p,pll:length(person)}
        )
        SORT pl.pll desc
        limit 1
        RETURN pl
***

#### 查找当前节点所有直系祖先
> 查找当前节点的直系祖先

        FOR t IN (
        FOR a IN persons
        FILTER a._id == "persons/1832466"
            FOR p IN persons
            FILTER p.gender == 0
                LET person = (
                FOR vertex
                  IN INBOUND SHORTEST_PATH
                  a TO p
                  relationships
                    RETURN vertex
                )
            RETURN {person,len:length(person)}
        )
        SORT t.len desc
        limit 1
        RETURN t
***

#### 多表关联并聚合查询
> 场景：一个组织包含多个人，一个人只能对应一个组织，现要根据人名模糊查询人员，并查询对应的组织。
> 要求：
>     显示方式是列表显示组织，人员统计显示在对应的组织下

    --limit 放在前面会导致数据减少
    FOR p In persons
    LET name = CONCAT(p.surname, p.name)
    FILTER CONTAINS(p.name, "有成")
      FOR r IN resource
      FILTER r._key == p.treeKey
        FOR c IN catalog
        FILTER c.status == 1 and c._key == r.gcId
        SORT c.genealogyName desc    
    COLLECT catalog = c INTO persons
    LIMIT 0, 20
    RETURN { 
        catalog: catalog,
        persons: {
            _key: persons[*].p._key,
            surname: persons[*].p.surname,
            name: persons[*].p.name    
        }
    }
 
> 统计数量

      FOR p In persons
      LET name = CONCAT(p.surname, p.name)
      FILTER CONTAINS(p.name, "有成")
        FOR r IN resource
        FILTER r._key == p.treeKey
          FOR c IN catalog
          FILTER c.status == 1 and c._key == r.gcId
          SORT c.genealogyName desc
      COLLECT catalog = c 
      WITH COUNT INTO number
      RETURN number
***

#### 图查询
>  查询图结构

      FOR v, e, p 
      IN 1..4 
      OUTBOUND 'persons/1109806' 
      GRAPH 'testGraph' 
      OPTIONS {bfs:true}
      filter e.type == "http://www.example.org/ParentChild"
      RETURN {v, p1:count(p.edges)}
***

#### 查询坐标位置
> 查找指定坐标和半径范围内的位置

      FOR c IN WITHIN('location', 12.23, 23.12, 200, "find")
      FILTER c.scanTime > 200000  
      RETURN c
***

#### 左外关联
> Arangodb 不直接支持外关联，但是可以通过子查询实现。

            FOR vertex 
             IN 0..2  OUTBOUND "organization/5122557" 
             relation   
             LET v = vertex   
             FILTER CONTAINS(v.name, "邮局")      
             let users = (    
               FOR u IN user      
                 FILTER u.status == 1 and u._key == v.createUserId      
                 RETURN u
             )
             FOR user IN (
                LENGTH(users) > 0 ? users :
                  [ { /* no match exists */ } ]
                )
            RETURN { 
                username: user.username,
                mobileArea: user.mobileArea,
                mobile: user.mobile,
                org: v
            }
***

#### 外关联返回路径

      FOR vertex, edge, path   
      IN 0..1000  OUTBOUND "organization/5122557"   
      relation   
      LET v = vertex 
      let users = ( 
        FOR u IN user 
        FILTER u.status == 1 and u._key == v.userID
        RETURN u 
      ) 
      FOR user IN ( 
        LENGTH(users) > 0 ? users : [ {} ] 
      ) 
      RETURN path
***

#### 外关联统计

      FOR vertex, edge, path   
      IN 0..1000  OUTBOUND "organization/5122557"  
      relation     
      LET v = vertex 
      let users = ( 
        FOR u IN user 
        FILTER u.status == 1 and u._key == v.createUserId 
        RETURN u 
      ) 
      FOR user IN ( 
        LENGTH(users) > 0 ? users : [ { } ] 
      ) 
      COLLECT WITH COUNT INTO num
      RETURN num
***

#### 外关联查询分页

      FOR vertex, edge, path   
      IN 0..1000  OUTBOUND "organization/5122557"   
      relation        
      LET v = vertex 
      let users = ( 
      FOR u IN user 
      FILTER u.status == 1 and u._key == v.createUserId 
      RETURN u 
      ) FOR user IN ( 
      LENGTH(users) > 0 ? users : [ { } ] ) 
      LIMIT 0, 2
      RETURN {  
          username: user.profile.trueName || user.profile.nickName, 
          tmobileArea: user.mobileArea, 
          tmobile: user.mobile, 
          org: v 
      }
***

#### 分组统计

      FOR o IN organization 
      FILTER o._key IN ["5122557", "15924843", "7148108", "5894726"]
        FOR c IN catalog
        FILTER c.orgId == o._key
      COLLECT 
          orgId = o._key
          WITH COUNT INTO number
      RETURN {
          orgId: orgId,
          num: number
      }

------------------------------------------------------------------------------------------------

## 增、删、改语句

#### 批量更新表数据
> 根据过滤条件更新多表记录

        FOR c IN catalog
        FILTER c.titleNo != null
        UPDATE c WITH {"owner": "上海民防局"} IN catalog
***

#### 单表更新
> 查出单表更新

        UPDATE {"_key": "4213557"} 
        WITH { location: [10, 11] } 
        IN user RETURN NEW
***

#### 循环更新
> 根据给定的值来更新

        FOR p IN persons
        FILTER p.treeKey in [
          "1246017",
          "1246537",
          "4200480"
        ]
        UPDATE p WITH {type: 1} INTO persons
***

#### 删除数据
> 根据过滤条件删除

        FOR a IN album
        FILTER a.isGenealogyVolume == 1
        REMOVE a IN album
***

#### 更换对象内部属性名称
> 把 series 表中 creator 属性中的几个属性重命名

        FOR s IN series
        UPDATE s WITH {
        creator: {
            _key: s.creator.userId,
            name: s.creator.userName,
            avatar: s.creator.userAvatar,
            userId: null,
            userName: null,
            userAvatar: null
        }
        } IN test_series
        OPTIONS { keepNull: false }
***

#### 合并多表中的属性
> 以一张表为主，关联多表来更新主表

        FOR a IN user
          FOR b IN userprofile
          FILTER a.userId == b.userId
        UPDATE a WITH {profile: b.profile}
        IN user
***

#### 根据正则过滤记录并更新数据
> 更新条件：以什么开头、结尾或包含等等，并分割现有字段的值来更新

        FOR a IN a_user
          FILTER REGEX_TEST(a.username, "^(\\+86).*") 
                 and LENGTH(a.username) == 14
        UPDATE a WITH {mobileArea: SUBSTRING(a.username, 0, 3), mobile: SUBSTRING(a.username, 3)} IN a_user
***

#### 简单插入数据
> 复制表记录

        FOR a IN t_series
          INSERT a INTO series
***

#### 多表关联更新
> 说明：series 表与 user 表关联，并使用现有的表中的值来更新 series 表中creator字段的值， creator 是对象类型，包含了一些属性。

        FOR a IN series
          FOR u IN user
          FILTER a.creator._key == u.userId
        UPDATE a WITH {creator: {_key: u._key, userId: a.creator._key}} IN series
***

#### 插入边数据
> 说明： 在图数据库中，一个关系包括两个顶点和一条边，所以关系表中保存的是两个顶点的id，插入数据时，如果对应的边id不存在，就会插入不成功。

>> 确保一个顶点是否存在存在实体，去除不存在的  
    
    FOR f IN friend
    FOR u IN user
    FILTER f.userId == u.userId
    (RETURN f | UPDATE f WITH {from: u._id} IN friend)

>> 确保另一个顶点是否存在存在实体，去除不存在的 
    
    FOR f IN friend
    FOR u IN user
    FILTER f.relationUid == u.userId
    (RETURN f | UPDATE f WITH {to: u._id} IN friend)

>> 取出两个顶点对应的实体都存在的记录    
    
    FOR f IN friend
    FOR u IN user
    FILTER f.userId == u.userId2
    INSERT f INTO friend2 
    
    FOR f IN friend2
    FOR u IN user
    FILTER f.relationUid == u.userId2
    INSERT f INTO friend3

>> 插入边数据  
    
    FOR f IN friend3
      INSERT {
        _from: f.from,
        _to: f.to
      }
      INTO friend4
***

#### 单表数据
> ?

        INSERT 
        { 
            name: "测试计划",
            createID: "1",
            createTime: DATE_NOW(),
            updateTime: DATE_NOW(),
            startPeopleID: "3423"
        } 
        INTO plan
        RETURN NEW
***
