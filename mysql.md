

## MySQL 安装

下载 Linux 通用版 mysql-5.7.20-linux-glibc2.12-i686.tar.gz

    root@# sudo groupadd mysql  
    root@# sudo useradd -g mysql mysql  
    root@# cd /usr/local  
    root@# tar zvxf /media/mysql-5.0.90-linux-i686-glibc23.tar.gz 
    root@# mv mysql-5.0.90-linux-i686-glibc23 mysql
    root@# cd mysql  
    root@# sudo chown -R mysql .  
    root@# sudo chgrp -R mysql .  
