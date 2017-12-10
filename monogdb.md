

## Mongodb 

#### Aggregate
多表联合查询(Multiple collections union query)
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




