
## MongoDB shell methods

#### 分组统计
> ?

    db.users.group(
        {
            key: {sex: 1},
            reduce: function(curr, result){
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

****

## MongoDB Aggregation pileline

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





