---
layout: post
title: PowerDNSでMySQLをバックエンドにした時のゾーン転送受信時のクエリについて
date: 2019-12-23
tags: [Network, DNS, openSUSE]
categorise: Network, DNS
---

初めての方は初めまして．
そうじゃない方も初めまして．
日本openSUSEユーザ会でopenSUSEに関係のない話をする担当の川上です．

今日は，PowerDNSをSlaveとして運用するのはおすすめしないよという話をします．
おすすめしない事を記事にするのはなかなか見ないと思いますが，そういう記事だってあって良いじゃないというお気持ちです．

環境に関しては，前々回の記事で，PowerDNSとNSDを使って，MasterとSlave構成について記事を書きました．
今回は，その環境をそのままで，PowerDNSとNSDのMasterとSlaveの構成を逆にしてみます．



まずはPowerDNSの設定 `/etc/pdns/pdns.conf` を以下のように変更します．
```
setgid=pdns
setuid=pdns

launch=gmysql
gmysql-host=127.0.0.1
gmysql-user=power_admin
gmysql-password=password
gmysql-dbname=powerdns

slave=yes
```
変更点としては，PowerDNSの起動ポートを53番に，そして，`slave` を `yes` に設定します．
PowerDNSではデフォルトではSlaveとして動作することが出来ない設定になっています．

続いて，NSDの設定 `/etc/nsd/nsd.conf` を行います．
```
server:
        ip-address: 0.0.0.0@5353

        zonesdir: "/etc/nsd/zones"

remote-control:
        control-enable: yes

        control-interface: 127.0.0.1

        control-port: 8952

        server-key-file: "/etc/nsd/nsd_server.key"

        server-cert-file: "/etc/nsd/nsd_server.pem"

        control-key-file: "/etc/nsd/nsd_control.key"

        control-cert-file: "/etc/nsd/nsd_control.pem"

zone:
        name: "example.com"
        zonefile: "example.com.zone"
        provide-xfr: 0.0.0.0/0 NOKEY
        notify: 127.0.0.1 NOKEY
```
そして，ゾーンの配置を行います．
今回は，ゾーンファイルとして，Wikipediaのゾーンファイルのexampleをそのまま持ってきました． [^1]

続いて，PowerDNSでSlaveのゾーンを作成します．
PowerDNSでSlaveの作成には `pdnsutil` コマンドを使用します．
```
pdnsutil create-slave-zone example.com. 127.0.0.1:5353
```
これらのコマンドは，スレーブゾーンを作成します．
一番後ろの部分はMasterサーバのIPアドレスとポートを設定します．
53番ポートの場合は指定は必要ありません．

続いて，PowerDNSのBackendであるMySQLにおいて，クエリのログを確認する設定を行います．
MySQLの設定は `/etc/my.cnf` の修正を行います．
`[mysqld]` セクションにクエリログの所得の設定と保存場所を設定します．
```
[mysqld]
general_log=1
general_log_file=/var/log/mysql/query.log    
```

では，PowerDNSのゾーン転送受信時のSQLクエリを確認してみましょう．
現在の状態では，それぞれのサーバの起動時に受信してしまっているので，ゾーンに対して，新たにレコードを追加しましょう．
今回は， `text.example.com.` というレコードを追加しました．
それと同時に， `SOA` レコードのシリアル値も変更しましょう．
DNSにおいてシリアル値の値が大きくなってない場合には，ゾーン転送は行われません．
ゾーンファイルを修正したら，NSDにて以下のコマンドを実行しましょう．
```
nsd-control reload example.com
```
これで，編集したゾーンファイルが読み込まれ，SlaveサーバにNotifyを送信します．

さて，本題のPowerDNSのゾーン転送受信時のクエリを確認してみましょう．
ゾーン転送受信時のクエリは以下の通りです．
```
     42 Prepare   insert into records (content,ttl,prio,type,domain_id,disabled,name,ordername,auth,change_date) values (?,?,?,?,?,?,?,?,?,NULL)
                   42 Execute   insert into records (content,ttl,prio,type,domain_id,disabled,name,ordername,auth,change_date) values ('ns.example.com username.example.com 2007120718 86400 7200 2419200 3600',3600,0,'SOA',1,0,'example.com',NULL,1,NULL)
                   42 Reset stmt
                   42 Execute   insert into records (content,ttl,prio,type,domain_id,disabled,name,ordername,auth,change_date) values ('ns.example.com',3600,0,'NS',1,0,'example.com',NULL,1,NULL)
                   42 Reset stmt
                   42 Execute   insert into records (content,ttl,prio,type,domain_id,disabled,name,ordername,auth,change_date) values ('ns.somewhere.example',3600,0,'NS',1,0,'example.com',NULL,1,NULL)
                   42 Reset stmt
                   42 Execute   insert into records (content,ttl,prio,type,domain_id,disabled,name,ordername,auth,change_date) values ('mail.example.com',3600,10,'MX',1,0,'example.com',NULL,1,NULL)
                   42 Reset stmt
                   42 Execute   insert into records (content,ttl,prio,type,domain_id,disabled,name,ordername,auth,change_date) values ('mail2.example.com',3600,20,'MX',1,0,'example.com',NULL,1,NULL)
                   42 Reset stmt
                   42 Execute   insert into records (content,ttl,prio,type,domain_id,disabled,name,ordername,auth,change_date) values ('mail3.example.com',3600,50,'MX',1,0,'example.com',NULL,1,NULL)
                   42 Reset stmt
                   42 Execute   insert into records (content,ttl,prio,type,domain_id,disabled,name,ordername,auth,change_date) values ('192.0.2.1',3600,0,'A',1,0,'example.com',NULL,1,NULL)
                   42 Reset stmt
                   42 Execute   insert into records (content,ttl,prio,type,domain_id,disabled,name,ordername,auth,change_date) values ('2001:db8:10::1',3600,0,'AAAA',1,0,'example.com',NULL,1,NULL)
                   42 Reset stmt
                   42 Execute   insert into records (content,ttl,prio,type,domain_id,disabled,name,ordername,auth,change_date) values ('192.0.2.3',3600,0,'A',1,0,'mail.example.com',NULL,1,NULL)
                   42 Reset stmt
                   42 Execute   insert into records (content,ttl,prio,type,domain_id,disabled,name,ordername,auth,change_date) values ('192.0.2.4',3600,0,'A',1,0,'mail2.example.com',NULL,1,NULL)
                   42 Reset stmt
                   42 Execute   insert into records (content,ttl,prio,type,domain_id,disabled,name,ordername,auth,change_date) values ('192.0.2.5',3600,0,'A',1,0,'mail3.example.com',NULL,1,NULL)
                   42 Reset stmt
                   42 Execute   insert into records (content,ttl,prio,type,domain_id,disabled,name,ordername,auth,change_date) values ('192.0.2.2',3600,0,'A',1,0,'ns.example.com',NULL,1,NULL)
                   42 Reset stmt
                   42 Execute   insert into records (content,ttl,prio,type,domain_id,disabled,name,ordername,auth,change_date) values ('2001:db8:10::2',3600,0,'AAAA',1,0,'ns.example.com',NULL,1,NULL)
                   42 Reset stmt
                   42 Execute   insert into records (content,ttl,prio,type,domain_id,disabled,name,ordername,auth,change_date) values ('192.0.2.161',3600,0,'A',1,0,'test.example.com',NULL,1,NULL)
                   42 Reset stmt
                   42 Execute   insert into records (content,ttl,prio,type,domain_id,disabled,name,ordername,auth,change_date) values ('example.com',3600,0,'CNAME',1,0,'www.example.com',NULL,1,NULL)
                   42 Reset stmt
                   42 Execute   insert into records (content,ttl,prio,type,domain_id,disabled,name,ordername,auth,change_date) values ('www.example.com',3600,0,'CNAME',1,0,'wwwtest.example.com',NULL,1,NULL)
                   42 Reset stmt
                   42 Query     commit
```
となまぁ，見れば分かりますね．
追加されたレコードは1つだけなのに，PowerDNSでは全てのレコードにInsertが処理されている事が分かります．
PowerDNSはゾーン転送はAXFRにのみに対応しており，ゾーン転送では全てのレコードを受信します．
そして，その受信したレコードを全てDBに1行ずつ挿入して行きます．
つまり，レコードの件数回のSQLクエリが発行されます．
例えば，1万件のレコードが存在するゾーン転送の場合は，1万件のSQLクエリが発行されます．

## まとめ
PowerDNSがゾーン転送を受信した時に発行されるクエリを確認しました．
PowerDNSは実装上，あまり，Slaveサーバに向いていないことが分かったと思います．
PowerDNSをあまりSlaveに使用することはないかと思う人は居るかもしれませんが．OpenStackのDNSコンポーネントであるDesignateはPowerDNSをBackendとして動作することをサポートしており，PowerDNSがゾーン転送のSlaveサーバになります．

PowerDNSはAPIでゾーンの作成なども出来るので，便利ではあるのですが，Slaveサーバとして大規模に使うには少し厳しい実装ですね．




[^1]: [Zone file - Wikipedia](https://en.wikipedia.org/wiki/Zone_file)