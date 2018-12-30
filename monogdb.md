
## MongoDB shell methods

#### 分组统计
> 分组统计，并累加数量

    db.users.group(
        {
            key: {sex: 1},
            $reduce: function(curr, result){
                result.num++;
            },
            initial: { num: 0},
            finalize: function(result) {
              result.num = parseInt(result.num);
            }
        }
    )
    
> key：按照key进行分组。    
> initial：每组都分享的“初始化函数”。可以在此处初始化一些变量，供每组进行使用。   
> $reduce：该函数有两个参数，第一个参数是当前document对象，第二个参数是上次操作的累计对象。collection中有多少个document就会调用多少次$reduce。        
> condition：过滤条件。   
> finalize：该函数会在每组document执行完成后，就会调用该函数，可以在这个函数中，做一些后续的工作，比如进行计数操作，统计结果的个数。 

#### 查询指定字段非空

    db.news.find({name: {$ne: null}})

#### 批量更新

    db.questions.updateMany({isCommonly: false},  { $set: {reply: 0} })

****

## MongoDB Aggregation pileline

#### 聚合分组统计
> 简单分组统计

    db.news.aggregate([
        {
          $group: {
              _id: "$name",
              count: {$sum: 1}
          }
        },
        {
          $match: {count: {"$gt": 1} }
        }
    ])

#### 查询排除空字符或空值后分组统计

    db.table1.aggregate([
        {
          $match: {$and: [ {name: {$ne: ""}}, {name: {$ne: null}  } ] }
        },
        {
          $group: {
              _id: "$name",
              count: {$sum: 1}
          }
        },
        {
          $sort: {count: -1}
        },
        {
          $project: {
              name: "$_id",
              num: "$count"
          }
        }
    ])

#### 分组统计, 根据类型分组统计, 把需要的属性放入数组中

    db.tables.aggregate([
        {
          $lookup:
            {
              from: 'fields',
              localField: '_id',
              foreignField: 'tableId',
              as: 'fields'
            }
        },
        {
          $match:
            {
              status: 1
            }
        }, 
        {
          $project:
            {
              _id: 1,
              type: 1,
              name: 1,
              title: 1,
              field: {
                $filter: {
                  input: '$fields',
                  as: 'num',
                  cond: {$eq: ['$$num.status', 1]}
                }
              }
            }
        },
        {
          $group:
            {
              _id: '$type',
              title: {
                $push: {
                  name: '$name',
                  title: '$title',
                  _id: '$_id',
                  fields: '$field'
                }
              }
            }
        }
    ])


#### $map 使用

    db.questions.aggregate([    
        {
            $project:
                {
                    title: 1,
                    telphone: 1,
                    createStr: {
                        $dateToString: {
                            format: "%Y-%m-%d %H:%M:%S",
                            date: {$add: ["$createTime", 8 * 60 * 60000]}
                        }
                    },
                    createTime: 1,
                    username: 1,
                    email: 1,
                    content: 1,
                    reply: {$size: '$comments'},
                    viewNum: 1,
                    collectionNum: 1,
                    likeNum: 1,
                    type: 1,
                    status: 1,
                    isCommonly: {$cond: {if: {$eq: ["$isCommonly", true]}, then: 1, else: 0}},
                    comments: {$map:
                        {
                            input: "$comments",
                            as: "comment",
                            in: {
                                content: '$$comment.content',
                                replyuser: '$$comment.replyuser',
                                replyuserId: '$$comment.replyuserId',
                                replydate: '$$comment.replydate',
                                replytime:
                                    {
                                        $dateToString: {
                                            format: "%Y-%m-%d %H:%M:%S",
                                            date: {$add: ['$$comment.replydate', 8 * 60 * 60000]}
                                        }
                                    }
                            }
                        }
                    },
                    images: '$images',
                    _id: 1,
                    userId: 1
                }
        },
        {
            $match: {status: 0}
        }
    ])
    
基本多表关联查询
> $match 放在最后面时需要注意过滤的字段在 $project 中是否显示出来

    db.questions.aggregate([
        { 
            $lookup:
            { 
                from: 'tags',
                localField: 'type',
                foreignField: '_id',
                as: 'tag' 
           } 
        },
        { 
            $lookup:
            { 
                from: 'collections',
                localField: '_id',
                foreignField: 'tid',
                as: 'collection' 
            } 
           },
        { 
            $project:
            { 
                title: 1,
                telphone: 1,
                _id: 1,
                   userId: 1,
                   tag: 1,
                   collection: '0',
                   status: 1 
               } 
          },
        { 
            $match: { status: { '$gte': 0 } } 
        }
    ])

#### 分组统计, 查询条件使用动态生成的正则表达式
> provs 是查询条件(provs is query condition)

    var rPlace = new RegExp("^(" + provs + ").*")

    db.table1.aggregate([
        {
          $match: {field11: rPlace}
        },
        {
          $group: {
              _id: "$place",
              count: {$sum: 1}
          }
        },
        {
          $project: {
              place: "$_id",
              num: "$count"
          } 
        }
    ])

#### 多表联合查询(Multiple collections union query)
> 场景： 三张表（新闻、评论，用户），查询新闻详细内容，同时查出新闻的所有评论及评论的用户信息
> scenario: three collections(news, comments, users), query news detail, meanwhile need news' all comment and user's info.

    db.news.aggregate([
            {
                $lookup:
                    {
                        from: 'comments',
                        localField: '_id',
                        foreignField: 'newsId',
                        as: 'comments'
                    }
            },
            {
              $unwind: "$comments"
            },
            {
                $project:
                    {
                        title: 1,
                        createStr: {
                            $dateToString: {
                                format: "%Y-%m-%d %H:%M:%S",
                                date: {$add: ["$createTime", 8 * 60 * 60000]}
                            }
                        },
                        createTime: 1,
                        type: 1,
                        viewNum: 1,
                        collectionNum: 1,
                        likeNum: 1,
                        shareNum: 1,
                        commentNum: 1,
                        content: 1,
                        status: 1,
                        images: '$images',
                        _id: 1,
                        comments: 1
                    }
            },
            {
                $match: {_id: ObjectId("5a2b9144b30eec39b0b37a4c")}
            },
            {
              $lookup:
                    {
                        from: 'users',
                        localField: 'comments.userId',
                        foreignField: '_id',
                        as: 'users'
                    }
            }
    ])
    

多表联合查询并分组统计
> ?

    db.tables.aggregate([
      {
        $lookup:
          {
            from: 'fields',
            localField: '_id',
            foreignField: 'tableId',
            as: 'fields'
          }
      },
      {
        $unwind: '$fields'
      },
      {
        $match:
          {
            status: 1,
            _id: ObjectId("599d6432a02c4f0357cca299"),
            'fields.status': 1
          }
      },
      {
        $group:
          {
            _id: '$_id',
            title: {$first: '$title'},
            name: {$first: '$name'},
            fields: {
              $push:
                {
                  'name': '$fields.name',
                  'needQuery': '$fields.needQuery',
                  'needSort': '$fields.needSort',
                  'isRef': '$fields.isRef',
                  'title': '$fields.title'
                }
            }
            
          }
      }, 
      {
        $lookup:
          {
            from: 'templates',
            localField: '_id',
            foreignField: 'tableId',
            as: 'templates'
          }
      }, 
      {
        $project: {
          _id: 1,
          title: 1,
          fields: 1,
          name: 1,
          templates: {
            $filter: {
              input: "$templates",
              as: "template",
              cond: {$eq: ["$$template.status", 1]}
            }
          }
        }
      }
    ])


#### 多表关联查询后取出关联表的部分字段
场景：三张表（questions、 users、tags）,查询问题表中指定 id 的记录，并要查出改问题的发布人的信息，该问题的标签信息
> 使用 $arrayElemAt 可满足此需求

    db.questions.aggregate([
        {
            $match: {_id: ObjectId("5a2dd86c5e44de70bfda11af")}
        },
        {
          $lookup: {
                  from: "users",
                localField: "userId",
                foreignField: "_id",
                as: "users"
          }
        },
        {
          $lookup: {
                  from: "tags",
                localField: "type",
                foreignField: "_id",
                as: "tags"
          }
        },
        {
            $project:
                {
                    title: 1,
                    telphone: 1,
                    createStr: {
                        $dateToString: {
                            format: "%Y-%m-%d %H:%M:%S",
                            date: {$add: ["$createTime", 8 * 60 * 60000]}
                        }
                    },
                    createTime: 1,
                    username: 1,
                    email: 1,
                    content: 1,
                    reply: {$size: '$comments'},
                    viewNum: 1,
                    collectionNum: 1,
                    likeNum: 1,
                    type: 1,
                    tag: {$arrayElemAt: ['$tags.name', 0]},
                    icon: {$arrayElemAt: ['$tags.icon', 0]},
                    status: 1,
                    isCommonly: {$cond: {if: {$eq: ["$isCommonly", true]}, then: 1, else: 0}},
                    images: '$images',
                    _id: 1,
                    userId: 1,
                    userName: {$arrayElemAt: ['$users.nickname', 0]},
                    avatar: {$arrayElemAt: ['$users.avatar', 0]}
                }
        }
    ])

#### 多表中的内嵌属性关联并将内嵌属性展开
场景：先将 columns 表的 childs 属性展开，展开后取出特定的属性与 children 关联后将查询出的数组属性再展开 

    db.columns.aggregate([
        {
            $match:{status: 1, childs: {$exists:true}}
        },
        {
            $unwind: '$childs'
        },
        {
            $project:
            {
                childName:'$childs.childName',
                cid:'$childs._id',
                childTable:'$childs.childTable',
                sort:'$childs.sort',
                _id:1,
            }
        },
        {
            $lookup:
            {
                from: 'children',
                localField: 'cid',
                foreignField: 'columnId',
                as: 'childs'
            }
        },
        {
            $project:
            {
                childName:1,
                cid:1,
                childTable:1,
                sort:1,
                childs:{$arrayElemAt: [ '$childs', 0 ]}
            }
        },
        {
            $sort:{sort:1}
        },
        {
            $project:
            {
                childName:1,
                cid:1,
                childTable:1,
                sort:1,
                normalSearch:{
                    $filter: {
                        input: '$childs.searchs',
                        as: 'num',
                        cond: { $eq: [ '$$num.searchMode', 'normal' ]}
                    }
                },
                highSearch:{
                    $filter: {
                        input: '$childs.searchs',
                        as: 'num',
                        cond: { $eq: [ '$$num.searchMode', 'high' ]}
                    }
                },
                refTables:'$childs.refTables',
                detail:'$childs.detail',
                groupFields:'$childs.groupFields',
                showDetail:'$childs.showDetail',
                showMode:'$childs.showMode',
                hasRef:'$childs.hasRef',
                showSearch:'$childs.showSearch'
            }
        }
    ])

#### 多表子属性展开关联后再展开结果数据并分组统计后过滤
场景： 先展开 roles 表的 menus 属性与多表关联，接着展开查询结果并根据 _id 分组统计, 最后过滤排序

    db.roles.aggregate([
        {
            $unwind:'$menus'
        },
        {
            $lookup:
            {
                from: 'menus',
                localField: 'menus',
                foreignField: '_id',
                as: 'info'
            }
        },
        {
            $lookup:
            {
                from: 'admins',
                localField: '_id',
                foreignField: 'roleId',
                as: 'admin'
            }
        },
        {
            $match: {_id: ObjectId("596de7822dfc42070ca0f969")}
        },
        {
            $unwind: '$info'
        },
        {
            $group:
            {
                _id: '$_id',
                roleName: {$first: '$name'},
                list: {
                    $push: {
                        name:'$info.name',
                        icon:'$info.icon',
                        url:'$info.url',
                        status:'$info.status',
                        sort:'$info.sort'
                    }
                },
                admin: {
                    $first:
                    {
                        $filter: {
                            input: '$admin',
                            as: 'num',
                            cond: { $eq: [ '$$num._id', ObjectId("596de7822dfc42070ca0f969")]}
                        }
                    }
                }
            }
        },
        {
            $project:
            {
                roleName: 1,
                menus: {
                    $filter: {
                        input: '$list',
                        as: 'num',
                        cond: { $eq: [ '$$num.status', 1 ]}
                    }
                },
                admin: { $arrayElemAt: [ '$admin.username', 0 ]},
                _id: 0
            }
        },
        {
            $sort:{
                sort:1
            }
        }
    ])



## mongodb 安装

* Install any missing dependencies
#### debian

    sudo apt-get install libcurl3 libgssapi-krb5-2 libkrb5-dbg libldap-2.4-2 libpcap0.8 libpci3 
    libsasl2-2 libsensors4 libsnmp30 libssl1.0.0 libwrap0
    
* Download and extract the MongoDB Enterprise packages.

* Ensure that the MongoDB binaries are in your PATH     
    
        Copy these binaries into a directory listed in your PATH variable such as /usr/local/bin, 
        Create symbolic links to each of these binaries from a directory listed in your PATH variable

* Create the data directory and log directory

* Set permissions for the data directory.
*** 
    
## mongodb shell

#### 启动 mongodb
> 指定配置文件

    monogd --config /etc/mongodb.conf

> 指定数据文件、日志文件、端口等参数

    mongod -port 27017 -dbpath /data/mongodb/data/m1 --logpath /data/mongodb/log/m1.log

#### 连接 mongodb
> 未启用用户认证

    mongo

> 启用用户认证

    mongo --host 127.0.0.1:27017 -authenticationDatabase admin -u admin -p

#### 数据导出
    mongoexport --host 127.0.0.1:27017 -u admin -d post -c users /authenticationDatabase:admin
    /authenticationMechanism:SCRAM_SHA_1 -o "d:\data\user.json"

***


## mongodb 权限认证

MongoDB数据库在默认是没有用户名及密码，不用安全验证的，只要连接上服务就可以进行CRUD操作。

#### 开启认证
> 当admin.system.users一个用户都没有时，即使mongod启动时添加了--auth参数,如果没有在admin数据库中添加用户,此时不进行任何认证还是可以做任何操作(不管是否是以--auth 参数启动),直到在admin.system.users中添加了一个用户。详情请看[这里](http://blog.itpub.net/22664653/viewspace-715617)。  
> 数据库帐号对应着数据库。

如果需要给MongoDB数据库使用安全验证，则需要用--auth开启安全性检查，则只有数据库认证的用户才能执行读写操作，开户安全性检查。开启方法:

可以在配置文件 mongodb.conf 中放开注释 
            
    auth = true 
            
或者在命令行中加入

    mongod --dbpath "D:\mongodb\data\db" --logpath "D:\mongodb\data\log\MongoDB.log" --auth

#### 用户登陆
有两种方式进行用户身份的验证。
* 在客户端连接时指定用户名、密码、db

        mongo --port 27017 -u "adminUser" -p "adminPass" --authenticationDatabase "admin"

* 客户端连接后再进行验证

        mongo --port 27017

        use admin
        db.auth("adminUser", "adminPass")

        // 输出 1 表示验证成功

#### 忘记密码
忘记用户登录密码时，先切换登录方式为不需要验证，然后重启数据库服务，进入到 admin 表中，删除用户，然后重新创建用户名和密码。

    vim /etc/mongodb.conf          # 修改 mongodb 配置，将 auth = true 注释掉，或者改成 false
    service mongodb restart        # 重启 mongodb 服务

    mongo                          # 运行客户端（也可以去mongodb安装目录下运行这个）
    use admin                      # 切换到系统帐户表
    db.system.users.find()         # 查看当前帐户（密码有加密过）
    db.system.users.remove({})     # 删除所有帐户
    db.addUser('admin','password') # 添加新帐户

    vim /etc/mongodb.conf          # 恢复 auth = true
    service mongodb restart        # 重启 mongodb 服务

#### 访问方式
> 生产环境中使用 URI 形式对数据库进行连接

        mongodb://your.db.ip.address:27017/user
        mongodb://simpleUser:simplePass@your.db.ip.address:27017/user


#### 创建用户

* 数据库角色   
1. **数据库用户角色**：read、readWrite   
2. **数据库管理角色**：dbAdmin、dbOwner、userAdmin         
3. **集群管理角色**：clusterAdmin、clusterManager、clusterMonitor、hostManager       
4. **备份恢复角色**：backup、restore    
5. **所有数据库角色**：readAnyDatabase、readWriteAnyDatabase、userAdminAnyDatabase、dbAdminAnyDatabase     
6. **超级用户角色**：root      
7. **内部角色**：__system       
这里还有几个角色间接或直接提供了系统超级用户的访问（dbOwner 、userAdmin、userAdminAnyDatabase  

        db.createUser(
        ...   {
        ...     user: "dba",
        ...     pwd: "dba",
        ...     roles: [ { role: "userAdminAnyDatabase", db: "admin" } ]
        ...   }
        ... )

* 权限    
    **Read**：允许用户读取指定数据库        
    **readWrite**：允许用户读写指定数据库   
    **dbAdmin**：允许用户在指定数据库中执行管理函数，如索引创建、删除，查看统计或访问system.profile    
    **userAdmin**：允许用户向system.users集合写入，可以找指定数据库里创建、删除和管理用户 
    **clusterAdmin**：只在admin数据库中可用，赋予用户所有分片和复制集相关函数的管理权限。   
    **readAnyDatabase**：只在admin数据库中可用，赋予用户所有数据库的读权限 
    **readWriteAnyDatabase**：只在admin数据库中可用，赋予用户所有数据库的读写权限   
    **userAdminAnyDatabase**：只在admin数据库中可用，赋予用户所有数据库的userAdmin权限    
    **dbAdminAnyDatabase**：只在admin数据库中可用，赋予用户所有数据库的dbAdmin权限。   
    **root**：只在admin数据库中可用。超级账号，超级权限
***


## mongodb API
    
#### 创建数据库
> 如果数据库和表不存在，会自动创建

    use myNewDB
    db.myNewCollection1.insertOne( { x: 1 } )

#### 创建集合(表)
> 如果不存在则自动创建

    db.myNewCollection2.insertOne( { x: 1 } )
    db.myNewCollection3.createIndex( { y: 1 } )

#### 查看用户
    
    show users;
    db.system.user.find();

#### 删除用户

    db.dropUser("test"[, writeConcern: { <write concern> }])
    
#### 创建表

    db.createCollection("TableName")
    
#### 查询表/集合

    show tables;
    show collections;


***

## mongodb 聚合管道

在聚合管道中，每一步操作（管道操作符）都是一个工作阶段（stage），所有的stage存放在一个array中。管道中的每一个工作线程，可以理解为一个整个流水线的一个工作阶段stage,这些工作线程之间的合作是一环扣一环的。靠输入口越近的工作线程，是时序较早的工作阶段stage,它的工作成果会影响下一个工作线程阶段（stage）的工作结果,即下个阶段依赖于上一个阶段的输出，上一个阶段的输出成为本阶段的输入。

#### $project 
> 数据投影，主要用于重命名、增加和删除字段

    db.article.aggregate(
        { 
            $project: {
                title: 1 ,
                author: 1,
            }
        }
    );

结果中包含_id,tilte和author三个字段了，默认情况下_id字段是被包含的，1 代表需要显示的字段。如果要想不包含 _id 话可以写成 _id : 0 。

#### $match
> 滤波操作，筛选符合条件文档，作为下一阶段的输入

    db.article.aggregate(
        { 
            $match : { 
                score : { $gt : 70, $lte : 90 } 
            } 
        }
    )
$match的语法和查询表达式(db.collection.find())的语法相同。


#### $unwind
> 将数组元素拆分为独立字段

    db.article.aggregate({$project:{author:1,title:1,tags:1}},{$unwind:"$tags"})


#### $lookup

语法

        {
           $lookup:
             {
               from: <collection to join>,
               localField: <field from the input documents>,
               foreignField: <field from the documents of the "from" collection>,
               as: <output array field>
             }
        }
    
例如  

        lookup({ from: 'series', localField: 'series', foreignField: '_id', as: 'series' })


