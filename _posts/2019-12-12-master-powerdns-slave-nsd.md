---
layout: post
title: openSUSEでPowerDNSをmaster，NSDをSlaveとしたDNSを構築
date: 2019-12-12
tags: [Network, DNS, openSUSE]
categorise: Network
---

初めての人は初めまして，そうじゃない人も初めまして．
日本openSUSEユーザ会でopenSUSEの話をしない担当，川上です．

今日は，前回の続きで，PowerDNSをDNSとして使って行きます．
具体的には，PowerDNSをmasterサーバに，NSDをSlaveサーバとして使用します．
PowerDNSをmasterサーバとして他のDNS実装を公開するコンテンツサーバとして使用するのはよくある構成だと思います．
PowerDNSはMySQLなどのデータベースをバックエンドとしてレコードを管理する事が出来るので，DNSをAPI的に使用したい場合にはよく用いられる構成だと思います．

環境としては，前回のPowerDNSの構築の続きとして構築して行きます．
必要なパッケージとして，NSDのインストールを行います．
```console
$ sudo zypper install nsd
```

今回は実験用の環境として，同じマシンでPowerDNSとNSDを同じマシンで構築するので，PowerDNSの動作するポートの変更を行います．
実際の環境では，おそらく別のマシンで動作させるので，必要のない設定だと思います．
PowerDNSのポートは `local-port` を変更する事で，変更する事が出来ます．
```
$ sudo vim /etc/pdns/pdns.conf
local-port=5353
$ sudo systemctl restart pdns
$ sudo lsof -i:5353
COMMAND    PID USER   FD   TYPE DEVICE SIZE/OFF NODE NAME
pdns_serv 2585 pdns    5u  IPv4  32463      0t0  UDP *:mdns
pdns_serv 2585 pdns    6u  IPv6  32464      0t0  UDP *:mdns
pdns_serv 2585 pdns    7u  IPv4  32465      0t0  TCP *:mdns (LISTEN)
pdns_serv 2585 pdns    8u  IPv6  32466      0t0  TCP *:mdns (LISTEN)
```

# NSDをSlaveとして使用する設定
続いてNSDの設定を行います．
```
$ sudo vim /etc/nsd/nsd.conf
$ sudo cat nsd.conf
server:
        server-count: 1

        ip-address: 0.0.0.0

        zonesdir: "/etc/nsd/zones"
        zonelistfile: "/var/lib/nsd/zone.list"

        database: ""

        logfile: "/var/log/nsd/nsd.log"
        pidfile: "/run/nsd/nsd.pid"

        xfrdfile: "/var/lib/nsd/xfrd.state"

remote-control:
        control-enable: yes
        control-interface: 127.0.0.1
        control-port: 8952
        server-key-file: "/etc/nsd/nsd_server.key"
        server-cert-file: "/etc/nsd/nsd_server.pem"
        control-key-file: "/etc/nsd/nsd_control.key"
        control-cert-file: "/etc/nsd/nsd_control.pem"

pattern:
        name: "pdns_slave"
        zonefile: "zones/%s.zone"
        allow-notify: 127.0.0.1@5353 NOKEY
        request-xfr: 127.0.0.1@5353 NOKEY
```
この設定では，DNSとして起動する基本的な設定と，リモートコントロール，そして，patternの設定を行なっています．
リモートコントロールは後でゾーンの追加や統計情報の所得などに使うので設定しています．
patternはNDSの機能で，同じような設定のゾーンコンフィグをパターンとして纏めることができ， `nsd-control` からのゾーンの追加などを可能にします．
今回は，masterサーバとしてポート番号を変更した PowerDNSを指定しています．
`allow-notify` がゾーンの変更の通知を受けとるサーバを指定します．
`request-xfr` がゾーン転送を行い実際にゾーンを所得するmasterサーバの指定になります．

続いて，nsd-controlの設定を行います．
```
$ sudo nsd-control-setup
```
このコマンドを実行すると `/etc/nsd` 以下に鍵ファイルなどを作成して， `nsd-control` コマンドが使用出来るようになります．


では，ゾーンの追加を行なってみます．
```
$ sudo nsd-control addzone s9i.net pdns_slave
```
これで，NSD側のゾーンの設定は完了です．

続いて，PowerDNSの設定を行ないます．
pdnsutilコマンドを用いて以下のコマンドを実行します．
```
$ pdnsutil set-meta s9i.net ALLOW-AXFR-FROM 127.0.0.1
$ pdnsutil set-meta s9i.net ALSO-NOTIFY 127.0.0.1
```
これはそれぞれ，ゾーンが変更される度に，通知を送る先のIPアドレスの指定と，ゾーン転送を許可するIPアドレスの設定を行なっています．
この設定はPowerDNSのBackendであるMySQLのデータベースに挿入されます．

では，名前解決の確認をしてみます．

```
dig @localhost www.s9i.net

; <<>> DiG 9.11.2 <<>> @localhost www.s9i.net
; (1 server found)
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 25164
;; flags: qr aa rd; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 1
;; WARNING: recursion requested but not available

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 4096
;; QUESTION SECTION:
;www.s9i.net.                   IN      A

;; ANSWER SECTION:
www.s9i.net.            60      IN      A       10.1.1.1

;; Query time: 0 msec
;; SERVER: 127.0.0.1#53(127.0.0.1)
;; WHEN: Thu Dec 05 01:17:13 UTC 2019
;; MSG SIZE  rcvd: 56
```
とこのように，NSDから，正しく名前解決が出きている事が分かります．


# まとめ
今回は前回構築したPowerDNSをmasterサーバとして，NSDをSlaveとしたDNSサーバを構築しました．
この構成はPowerDNSのAPIを用いてゾーンやレコードの管理を行うことが出来るため，使い勝手のよい構成です．
ぜひ使ってみてください．
