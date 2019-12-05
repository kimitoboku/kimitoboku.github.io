---
layout: post
title: openSUSEにPowerDNSをインストール
date: 2019-12-05
tags: [Network, DNS, openSUSE]
categorise: Network
---


初めましての方は初めまして，そうでない方も初めまして，openSUSEユーザ会でopenSUSEに関係ない話をする担当の川上です．
今回は，DNS権威サーバの実装の1つであるPowerDNSをMySQLバックエンドでインストールする方法の紹介をします．
インストール環境はopenSUSE Leap 15.1です．
数少ないopenSUSE成分です．

PowerDNSは，様々な拡張がありバックエンドを独自に開発する事が出来るDNSサーバです．
PowerDNSで最も，よく使用されるバックエンドがMySQLやPostgreSQLバックエンドといったデータベースサーバをバックエンドとする物です．
DNSレコードの管理や，ゾーン転送，TSIG KEYなどをデータベースで管理する事が出来ます．
なので，PowerDNSをmasterサーバにして，他のDNS実装をSlaveとし，外部に公開するのがおすすめです．

# インストール
openSUSEではPowerDNSはパッケージとして提供されているので，`zypper` コマンドからインストールする事が出来ます．
今回はMySQLバックエンドを使用するので，データベースとして `mariadb` もインストールしておきます．
```console
$ sudo zypper install pdns pdns-backend-mysql
$ sudo zypper install mariadb mariadb-client
```

まず，データベースの初期設定を行います．
PowerDNS用のデータベースとPowerDBS用のユーザを作成します．
```console
$ sudo systemctl start mariadb
$ mysql -u root -p
> CREATE DATABASE powerdns;
> GRANT ALL ON powerdns.* TO 'power_admin'@'localhost' IDENTIFIED BY 'password';
> GRANT ALL ON powerdns.* TO 'power_admin'@'localhost.localdomain' IDENTIFIED BY 'password';
> FLUSH PRIVILEGES;
```

続いて，データベースにPowerDNS用のテーブルを作成していきます．
テーブルのschemaｈあPowerDNSのGithubのMySQL Backendのディレクトリにて提供されています．
```
$ wget https://raw.githubusercontent.com/PowerDNS/pdns/rel/auth-4.1.x/modules/gmysqlbackend/schema.mysql.sql
$ mysql -u root -p powerdns < schema.mysql.sql
```

ここまで出来たら，あとは，PowerDNSの設定ファイルにMySQLバックエンドを使用するという事と，接続設定を記述して完了です．
```console
$ sudo cat /etc/pdns/pdns.conf
setgid=pdns
setuid=pdns

launch=gmysql
gmysql-host=127.0.0.1
gmysql-user=power_admin
gmysql-password=password
gmysql-dbname=powerdns
$ sudo systemctl start pdns
```
これで，PowerDNSをMySQLバックエンドで起動することが出来ました．

動作の確認をしていきます．
PowerDNSではデータベースバックエンドを使用している場合には `pdnsutil` コマンドを用いてゾーンの追加などのデータベースに関わる設定を行うことが出来ます．
ひとまず，ゾーンの追加と，レコードの追加を行ってみます．
```
$ pdnsutil create-zone s9i.net.
$ pdnsutil add-record s9i.net. www A 60 10.1.1.1
```
これで， `s9i.net` というゾーンと `www.s9i.net` というレコードを追加することが出来ました．
名前解決の動作確認を行ってみます．
```
$  dig @localhost www.s9i.net.

; <<>> DiG 9.11.2 <<>> @localhost www.s9i.net.
; (1 server found)
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 43703
;; flags: qr aa rd; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 1
;; WARNING: recursion requested but not available

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 1680
;; QUESTION SECTION:
;www.s9i.net.                   IN      A

;; ANSWER SECTION:
www.s9i.net.            60      IN      A       10.1.1.1

;; Query time: 1 msec
;; SERVER: 127.0.0.1#53(127.0.0.1)
;; WHEN: Mon Dec 02 14:51:24 UTC 2019
;; MSG SIZE  rcvd: 56
```
このように名前解決出来ていることが分かります．

この時の，データベースの中身は以下のようになっています．
```
MariaDB [powerdns]> select * from domains;
+----|---------|--------|------------|--------|-----------------|---------+
| id | name    | master | last_check | type   | notified_serial | account |
+----|---------|--------|------------|--------|-----------------|---------+
|  1 | s9i.net |        |       NULL | NATIVE |            NULL |         |
+----|---------|--------|------------|--------|-----------------|---------+
1 row in set (0.00 sec)

MariaDB [powerdns]> select * from records;
+----|-----------|-------------|------|-----------------------------------------------------------------------------|------|------|-------------|----------|-----------|------+
| id | domain_id | name        | type | content                                                                     | ttl  | prio | change_date | disabled | ordername | auth |
+----|-----------|-------------|------|-----------------------------------------------------------------------------|------|------|-------------|----------|-----------|------+
|  1 |         1 | s9i.net     | SOA  | a.misconfigured.powerdns.server hostmaster.s9i.net 1 10800 3600 604800 3600 | 3600 |    0 |        NULL |        0 | NULL      |    1 |
|  2 |         1 | www.s9i.net | A    | 10.1.1.1                                                                    |   60 |    0 |        NULL |        0 | NULL      |    1 |
+----|-----------|-------------|------|-----------------------------------------------------------------------------|------|------|-------------|----------|-----------|------+
2 rows in set (0.00 sec)
```
これらのデータベースを操作することで，PowerDNSに好き勝手にゾーンの作成やレコードの追加，修正を行う事が出来ます．


# まとめ
PowerDNSをMySQLバックエンドでインストールしました．
PowerDNSは他にもAPIサーバとして動作させる事も出来，その場合は，REST APIを用いて，統計情報なども所得することが出来ます．
PowerDNSは内部でmasterサーバとして使用するには便利な実装なので，楽しく使って行くと良いと思います．
