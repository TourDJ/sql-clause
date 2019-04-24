


## mongodb 安装

* Install any missing dependencies

### debian

    sudo apt-get install libcurl3 libgssapi-krb5-2 libkrb5-dbg libldap-2.4-2 libpcap0.8 libpci3 
    libsasl2-2 libsensors4 libsnmp30 libssl1.0.0 libwrap0
    
* Download and extract the MongoDB Enterprise packages.

* Ensure that the MongoDB binaries are in your PATH     
    
        Copy these binaries into a directory listed in your PATH variable such as /usr/local/bin, 
        Create symbolic links to each of these binaries from a directory listed in your PATH variable

* Create the data directory and log directory

* Set permissions for the data directory.

### ubuntu
Install using .tgz Tarball

* Download the MongoDB .tgz tarball.
* Extract the files from the downloaded archive.
* Set env.

*** 

## mongodb 卸载
以 ubuntu 为例，如果是以 apt-get 方式安装：       
1.停止服务

    sudo service mongod stop (systemV)
    sudo systemctl stop mongod (systemd)

2.完全清除

    sudo apt-get purge mongodb-org*

3.删除剩余文件

    sudo rm -r /var/log/mongodb
    sudo rm -r /var/lib/mongodb

## mongodb 配置
mongodb4 的配置文件使用 YAML 格式。 


    systemLog:
       destination: file
       path: "/var/log/mongodb/mongod.log"
       logAppend: true
    storage:
       journal:
          enabled: true
    processManagement:
       fork: true
    net:
       bindIp: 127.0.0.1
       port: 27017
    setParameter:
       enableLocalhostAuthBypass: false
    ...
 
## mongodb 使用

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



db.grantRolesToUser("myUserAdmin", [ { role: "read", db: "admin" } ])
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


