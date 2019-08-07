# ArangoDB v3.4.x 使用说明

ArangoDB 目前的最新稳定版本是 3.4.x。

使用之后发现，3.4 与 之前版本的使用有一些不一样。如果你使用的是tar包版，最直观的感受是目录结构不一样了。

* bin
* README
* usr

根据官方说明得知启动命令为：

<blockquote>
arangodb --starter.mode single --starter.data-dir /tmp/mydata
</blockquote>

`data-dir`&nbsp;&nbsp;表示用于存储启动程序生成的所有数据的目录（并保存实际的数据库目录）（默认为当前路径）


