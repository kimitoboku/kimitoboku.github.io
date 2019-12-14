---
layout: post
title: openSUSEでnetboxをインストール
date: 2019-12-14
tags: [Network, ipam, openSUSE]
categorise: Network
---

初めての方は初めまして，そうじゃない方も初めまして．
日本openSUSEユーザ会でopenSUSEに関係のない話をする担当の川上です．

今日は，OSSでDigitalOceanが開発している[netbox](https://github.com/netbox-community/netbox)というIPAMをopenSUSEにインストールする記事です．
最近，ちょっと検証として使ったりしてます．
実運用ではCentOSを使うかもしれませんが，検証くらいはopenSUSEでやって行きます．

# PostgreSQLの準備
netboxはIPアドレスを格納するのに，PostgreSQL独自のIPアドレスタイプを使用するので，PosgtreSQLを使用する必要があります．
MySQLは使えません．

まず，PostgreSQLのインスト-ルと初期設定です．
```
$ sudo zypper install postgresql postgresql-server postgresql-devel
$ sudo systemctl start postgresql.service
$ sudo su - postgres
$ psql
psql (10.10)
Type "help" for help.

postgres=# CREATE DATABASE netbox;
CREATE DATABASE
postgres=# CREATE USER netbox WITH PASSWORD 'password';
CREATE ROLE
postgres=# GRANT ALL PRIVILEGES ON DATABASE netbox TO netbox;
GRANT
postgres=# \q
$ vim /var/lib/pgsql/data/pg_hba.conf #ident を md5に変更
# TYPE  DATABASE        USER            ADDRESS                 METHOD

# "local" is for Unix domain socket connections only
local   all             all                                     peer
# IPv4 local connections:
host    all             all             127.0.0.1/32            md5
# IPv6 local connections:
host    all             all             ::1/128                 md5
# Allow replication connections from localhost, by a user with the
# replication privilege.
local   replication     all                                     peer
host    replication     all             127.0.0.1/32            md5
host    replication     all             ::1/128                 md5
$ sudo systemctl restart postgresql.service
$  psql -U netbox -W -h localhost netbox
Password for user netbox:
psql (10.10)
Type "help" for help.

netbox=>\q

```
ここで，大事なのは， `/var/lib/pgsql/data/pg_hba.conf` を編集しないと，PostgreSQLにパスワードでアクセス出来ないので注意して下さい．


# netboxのインストール
続いて，netboxをインストールして言います．
といっても，必要な依存関係をインストールして，netboxのソースコードを配置して，データベースのマイグレーションを行うだけです．
```
$ sudo zypper install python3-devel libffi-devel libxml2-devel python3-setuptools libxslt-devel graphviz openssl-devel redis
$ wget https://github.com/netbox-community/netbox/archive/v2.6.8.tar.gz
$ sudo tar -xzf v2.6.8.tar.gz -C /opt
$ sudo ln -s netbox-2.6.8/ netbox
$ cd netbox
$ pip3 install -r requirements.txt 
$ cd netbox/netbox
$ cp configuration.example.py configuration.py
$ vim configuration.py # データベースと，運用するホスト，シークレットを変更してください．
$ cd /opt/netbox/netbox
$ python3 manage.py migrate
$ python3 manage.py createsuperuser
$ python3 manage.py collectstatic
```

# Netboxのホスティング
ここまできたら，後は，Netboxをホスティングするだけです．
今回はサーバにWSGIサーバにgunicorn，デーモン化にSupervisorを，リバースプロキシとしてNginxを使用します．
```
# pip3 install gunicorn
$ sudo zypper install python2-setuptools supervisor # Leap 15.1のsupervisorの依存関係にpython2-setuptoolsが足りない気がする
```

あとはサーバの設定をして行きます．
まずデーモン化です．
```
$ sudo vim  /etc/supervisord.conf 
...
[program:netbox]
command = gunicorn -c /opt/netbox/gunicorn_config.py netbox.wsgi
directory = /opt/netbox/netbox/
user = nginx
stdout_logfile=/var/log/supervisord/netbox.log
stderr_logfile=/var/log/supervisord/netbox_error.log
$ sudo systemctl start supervisord
```

あとはNginxの設定です．
```
$ sudo vim /etc/nginx/conf.d/netbox.local.conf 

server {
    listen 80;

    server_name netbox.local;

    client_max_body_size 25m;

    location /static/ {
        alias /opt/netbox/netbox/static/;
    }

    location / {
        proxy_pass http://127.0.0.1:8001;
        proxy_set_header X-Forwarded-Host $server_name;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
$ sudo systemctl start nginx.service
```

# まとめ
これで，netboxのインストールが行えました．
netboxはipamとしてはラックの配置など機能がおおくなかなか使いこなすのは難しそうですが，使いこなせると便利な気配はすごいしているので，ちゃんと使って行きたい所です．
