<h1>ArangoDB 的使用 -- 安装和配置</h1>

<p><a href="https://www.arangodb.com/why-arangodb/cn/">ArangoDB</a>&nbsp;是一个开源的分布式原生多模型数据库，是兼有图 (graph)、文档 (document)和键/值对 (key/value) 三种数据模型的 NoSQL 数据库。ArangoDB 使用类SQL的查询语言(AQL)构建出高性能应用程序。</p>

<h2>ArangoDB 的安装</h2>

<p>ArangoDB 支持在 Windows、Linux、Dcoker、Mac&nbsp;等多种系统下运行。本文将以 Windows、Linux 系统为例讲解如何安装和配置。</p>

<h3>Windows 下 ArangoDB 的安装</h3>

<p>Windows 下可以下载压缩包版，也可以下载可执行文件版。我比较喜欢使用压缩包版，下载后选择一个目录直接解压就可以了。解压后的目录结构大致包括：</p>

<ul>
	<li>etc：所有的配置文件在该目录下</li>
	<li>usr：包括数据库的执行文件，js 的模块类库</li>
	<li>var：数据目录和FOXX 程序目录</li>
</ul>

<p>启动文件在 usr/bin/ 目录下，启动时打开一个终端，切换到该目录下，执行启动文件，或在也可以做成 windows 的服务。</p>

<h3>Linux 下 ArangoDB 的安装</h3>

<p>本文是以 CentOS 7 为例，其他 Linux 发行版依照官方给的提示操作即可。</p>

<p>使用 root 的权限执行以下命令：</p>

<pre>
<code> 
cd /etc/yum.repos.d/
curl -OL https://download.arangodb.com/arangodb33/CentOS_7/arangodb.repo
yum -y install arangodb3-3.3.7

yum -y install arangodb3-debuginfo-3.3.7(默认情况下不是必须的)</code></pre>

<p>安装成功后，仔细查看一下终端的输出信息：</p>

<blockquote>
<p>SECURITY HINT:<br />
run &#39;arango-secure-installation&#39; to set a root password<br />
the current password is<em> </em><strong>&#39;894a31beb567898c6dc0easdefga1eb6b&#39;</strong></p>
</blockquote>

<p>可以发现，默认用户为 root，同时提供了一个临时密码，以及修改 root 密码的命令：arango-secure-installation，该命令实际上是 arangod 的一个软链接，而 arangod 就是 ArangoDB 的数据库服务器命令了，可以用来启动数据库，修改密码等。</p>

<p>同时 ArangoDB 提供了 web 客户端来操作数据库，启动数据库服务器后即可打开，默认端口为 8529，使用初始的密码登陆后也可以修改密码，对命令行生疏的同学来说要方便多了，毕竟图形界面比较直观些。</p>

<h2>ArangoDB 的配置</h2>

<p>ArangoDB 的配置文件有很多，我们平常配置最多的是 arangod.conf，Linux 下该文件的目录通常在&nbsp;/etc/arangodb3/ 下，Windows 下因为我常习惯于用压缩包版，所以他的配置文件就在解压缩目录的 etc/arangodb3 目录下。</p>

<p>通常要配置的内容有数据的存放路径，日志路径，访问地址等。</p>

<p>配置数据路径：</p>

<blockquote>
<p>directory = /var/lib/arangodb3</p>
</blockquote>

<p>配置日志路径：</p>

<blockquote>
<p>file = /var/log/arangodb3/arangod.log</p>
</blockquote>

<p>配置访问路径：</p>

<blockquote>
<p>endpoint = tcp://127.0.0.1:8529</p>
</blockquote>

<p>如果只在本机访问没有问题，但如果要在局域网、外网访问则还必须加上局域网、外网的访问地址：</p>

<blockquote>
<p>endpoint = tcp://192.168.1.101:8529</p>
</blockquote>

<p>修改完后重启一下数据库就可以在本机以外访问了。</p>

<p>&nbsp;</p>

<h2>ArangoDB 启动</h2>

<p>初始安装后会提供一串很长的密码，不太容易记住，所以我们要修改一下密码。我主要介绍两种修改密码的方法：在终端使用命令修改和在图形界面中修改。</p>

<p>1，在终端修改密码</p>

<p>在终端输入以下命令：</p>

<pre>
<code>sudo arango-secure-installation</code></pre>

<p>系统会提示你输入 root 的密码：</p>

<blockquote>
<p>Please enter password for root user:&nbsp;</p>
</blockquote>

<p>输入两遍新密码即完成了密码更改，貌似不校验旧密码。</p>

<p>密码修改完后启动数据库登陆即可。</p>

<p>2，图形界面修改密码</p>

<p>使用图形界面操作，首先要启动 ArangoDB 数据库，有两种方式可启动数据库，一是直接使用上面提到的 arangod 命令：</p>

<pre>
<code>sudo arangod</code></pre>

<p>或者使用系统的服务 systemd 操作</p>

<pre>
<code>sudo systemctl start arangodb3</code></pre>

<blockquote>
<p>......</p>

<p>INFO ArangoDB (version 3.3.7 [linux]) is ready for business. Have fun!</p>
</blockquote>

<p>启动后查看终端或日志中有以上提示，表示启动成功。</p>

<p>查看一下 ArangoDB 的状态：</p>

<pre>
<code>sudo systemctl status arangodb3</code></pre>

<p>如果显示类似如下：</p>

<blockquote>
<p>Active: active (running) since ...</p>
</blockquote>

<p>表明启动成功。</p>

<p>两种启动方式比较推荐后一种，通过系统启动可以方便统一管理。</p>

<p>启动后即可在浏览器中打开客户端界面，输入 http://localhost:8529：</p>

<p><img alt="" height="512" src="https://static.oschina.net/uploads/space/2018/0427/134534_y5Ov_3550986.png" width="797" /></p>

<p>username 默认为 root，密码就是那初始的一长串字符。</p>

<p>登陆后，数据库就选择 _system，此时也只有这一个数据库，进入到主页。</p>

<p><img alt="" height="512" src="https://static.oschina.net/uploads/space/2018/0427/140446_Z3VK_3550986.png" width="774" /></p>

<p>在左边栏中选择 USERS，然后点击 root 用户，进去后就会看到修改密码的按钮，点击就可以修改密码了。</p>

<blockquote>
<p>_system 数据库是 ArangoDB 系统级的数据库，通过该数据库可以管理用户和数据库。 通常不要在该库下存储业务数据，我们要为每个业务创建单独的用户和数据库。</p>
</blockquote>

<p>到此基本安装配置就完成了。</p>
