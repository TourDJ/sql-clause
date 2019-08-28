
## mongoose 中间件

中间件也称 pre 和 post 钩子函数，通过向异步函数传值实现业务逻辑。mongoose 中总共有 4 种中间件：文档、模块、聚合和查询。


### 文档中间件
文档中间件包括：

   * init
   * validate
   * save
   * remove

> 中间件是一种控制函数，类似插件，能控制流程中的init、validate、save、remove方法。

#### pre
  一共有两种pre中间件： serial 和 parallel。   
  
serial 中间件是一个一个的执行  

    var schema = new Schema(..);
    schema.pre('save', function(next) {
      // do stuff
      next();
    });

parallel 提供更细粒度的操作

    var schema = new Schema(..);

    // `true` means this is a parallel middleware. You **must** specify `true`
    // as the second parameter if you want to use parallel middleware.
    schema.pre('save', true, function(next, done) {
      // calling next kicks off the next middleware in parallel
      next();
      setTimeout(done, 100);
    });

#### post
发生在被附挂的方法之后. post中间件不直接参与到整个流程, 所以他的callback没有next也没有done。

    schema.post('init', function(doc) {
      console.log('%s has been initialized from the db', doc._id);
    });
    schema.post('validate', function(doc) {
      console.log('%s has been validated (but not saved yet)', doc._id);
    });
    schema.post('save', function(doc) {
      console.log('%s has been saved', doc._id);
    });
    schema.post('remove', function(doc) {
      console.log('%s has been removed', doc._id);
    });

> 中间件就相当于java中的过滤器、拦截器，在执行某个方法前，将其拦截住，也有点像AOP中的前置注入。


