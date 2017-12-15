
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
