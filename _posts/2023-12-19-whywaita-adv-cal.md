---
layout: post
title: Whywaitaに健やかに働いて貰うためにPowerDNSでGSLBっぽい事をする
date: 2023-12-19
tags: [雑多, 映画]
categorise: 雑多
---

初めての方は初めまして。
そうでないかたもほぼほぼ初めまして。

この記事は [whywaita Advent Calendar 2023](https://adventar.org/calendars/8553)の19日目の記事です。
昨日はIzacchi16-sanの [Flutterアプリでwhywaitaアイコン回してみた - Izacchi16のブログ](https://izacchi16.hatenablog.jp/entry/2023/12/18/201418) でした。
Whywaitaは基本的に回されがちなイメージがありますね。

whywaita advent calendarのために4年ぶりにBlogを再開してみたので、Blogが継続出来ると良いですね。

Whywaitaには、健やかに働いて欲しい気持ちでいっぱいの今日この頃です。
そんな中で、やはり健やかに働いて貰うためには、自分の書いているような無駄な文章を労働中のWhywaitaに読ませてはいけない、そう強く心にもって、日々生活を行って居ます。

と、いう事で、今回の前置きはおいておいて、今回は、PowerDNSを用いたGSLBの話です。
GSLBとはGlobal Server Load Balancingの略で、例えば、Clientのsrc IPなどによって、アクセするするサーバを変えたりする技術諸々を指してそう呼ばれています。
近年では、主に、DNSを用いて行われる事が多い技術です。

DNSを用いたGSLBを提供するOSSとしては、以下のようなソフトウェアが知られています。
- [gdnsd](https://gdnsd.org/)
- [GitHub - acudovs/powergslb: PowerGSLB - PowerDNS Remote GSLB Backend](https://github.com/acudovs/powergslb)
- [GitHub - polaris-gslb/polaris-gslb: A free, open source GSLB (Global Server Load Balancing) solution.](https://github.com/polaris-gslb/polaris-gslb)
- [GitHub - datianshi/opensource-gslb](https://github.com/datianshi/opensource-gslb)


この中で、現在も開発が行われている物はgdnsdのみで、他のOSSについては、PowerGSLBの3年前が直近で開発が止まってしまっている状態です。

実装としては、gdnsdとopensource-gslbがDNSサーバとHealth check機能が一体となって動作する、DNSサーバ実装で、PowerGSLBとPolaris-gslbがPowerDNSのremote backendを利用して、Webサービスに近い形でGSLBの実装を行って居ます。
PowerDNSのremote backendは、PowerDNSプロセスからBackendにHTTPやunix domain socketなど様々なバックエンドに対して問い合わせを行い、その応答をClientに返すというPowerDNSのbackendの1つです。
このremote backendを用いる事で、容易に、DNS機能開発を行う事が出来ます。
しかし、PowerDNSのremote backendを利用した、OSSのGSLBの開発は止まっている状態です。
動いている物があれば、Contributionしたかったのですが、OSSとして動いている物がないので、仕方有りませんこの心は、別の趣味の実装に閉じ込めて起きましょう。

ここまで、書いてきましたが、GSLBとして実装されているDNSサービスで、現在も開発が行われているのはgdnsdのみになります。
gdnsdはconfig+拡張されたzonefileという形式でgslbの設定を行う事が出来ます。
しかし、gdnsdは、APIなどで設定を行えるわけではないため、gdnsdでサービスを作る場合には、gdnsdのconfigを生成してプロセスを管理するといったシステムが必要になります。
なので、gdnsd単体でサービスを作れるというわけではないです。

これらの課題を解決する事が可能な、物が存在します。
PowerDNSのLua Recordsです。
PowerDNSのLua RecordsはPowerDNSを利用したGSLB系のOSSが衰退した後釜としてよく利用されている機能になります。
Lua Recordsはその名前の通り、PowerDNSのレコードのレスポンスをLuaでScriptを書いて、操作する事が出来るという機能です。
また、PowerDNSにはMySQLやPostgreSQLをBackendとする機能や、API機能などもあり、そのままサービスとして利用する事が出来ます。

さて、長くなりましたが、今回は、PowerDNSのLua Recordsを用いて、GSLBを行うという話です。
Whywaitaが楽しく仕事が出来るように応答を操作していきたいと思います。

今回は、Dockerを用いてPowerDNSの単体動作構成で、Lua Recordsの紹介を行って行きます。
MySQL + PowerDNS構成については[それ単体で過去に記事を書いているのでご確認下さい。(4年くらい前の記事なので、正しく動くのだろうか)](https://blog.techack.net/archive/2019/12/05/install-powerdns)
今回はLua Recordsを試して遊びやすいので、Bind Backendを利用して動作確認を行って行きます。

まず、PowerDNSをBind BackendでLua Recordsを有効化して起動させましょう。
3分クッキングよろしく、既に、用意されたrepositoryがこちらになります。

[kimitoboku/powerdns_lua_records_sample](https://github.com/kimitoboku/powerdns_lua_records_sample/tree/master)

とりあえず、このrepositoryで `docker compose up -d` をすれば、PowerDNSがBind BackendでLua recordsを有効化した状態で起動します。
ただ、それだけでは味気ないので設定の紹介をします。

```
launch=bind
setgid=pdns
setuid=pdns
local-port=5353
any-to-tcp=no
enable-lua-records=1
lua-health-checks-interval=5
bind-config=/etc/powerdns/named.conf
bind-check-interval=1
loglevel=7
query-cache-ttl=0
```

大事なのは、launchにbindを設定し、 `bind-config` を設定する事と、 `enable-lua-records` を設定する事です。
これで、namedの設定でレコードをzonefileの形式で読み込む事で、Lua Recordsを動作させることが出来ます。

named.confは以下のようになっており、 `example.com` のZoneを読み込むだけです。
```
options {
  directory "/etc/powerdns";
};

zone "example.com" {
  type master;
  file "example.com.zone";
};
```

そして、 `example.com.` のZonefileは以下の内容になっています。
```
$TTL 86400
@            IN      SOA dns.example.com. root.example.com. (
                     2023122101 ; serial
                     3600       ; refresh 1hr
                     900        ; retry 15min
                     604800     ; expire 1w
                     86400      ; min 24hr
)
             IN      NS     ns.example.jp.
ns           IN      A      192.168.56.1
random	     IN      LUA    A "pickwrandom({ {1, '1.2.3.4'}, {2, '4.3.2.1'} })"
```

初期としては、 `random.example.com.` というレコードセットをLua Recordsとして用意しています。
`ramdon.example.com.` は 1:2の割合でレコードの返答をrandomに選択して応答します。
Lua Recordsでは、通常のZonefileではレコードのタイプを指定する所に `LUA` というタイプを利用します。
そして、データの先頭で応答する方を指定してその後に文字列としてLuaのコードを記述します。
基本的に使われるのは `A`、`AAAA`、`CNAME` あたりが使われます。

ひとまず、起動して、問い合わせを行ってみましょう。
```
$ docker compose up -d
[+] Building 0.0s (0/0)                                              docker:desktop-linux
[+] Running 1/1
 ✔ Container powerdns_lua_records_sample-powerdns-1  Started                         0.0s

$ dig @localhost -p 15353 random.example.com

; <<>> DiG 9.10.6 <<>> @localhost -p 15353 random.example.com
; (2 servers found)
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 59170
;; flags: qr aa rd; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 1
;; WARNING: recursion requested but not available

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 1232
;; QUESTION SECTION:
;random.example.com.            IN      A

;; ANSWER SECTION:
random.example.com.     86400   IN      A       4.3.2.1

;; Query time: 3 msec
;; SERVER: ::1#15353(::1)
;; WHEN: Sun Dec 17 16:46:46 JST 2023
;; MSG SIZE  rcvd: 63

```

randomに問い合わせが変更されているのか確認してみましょう。
```
$ for i in $(seq 1 1000); do; dig @localhost -p 15353 random.example.com +short;done | sort| uniq -c
 289 1.2.3.4
 711 4.3.2.1
```
だいたい、Lua Records通りに1:2の割合になっているのではないでしょうか。
とりあえず、データを変更してこの重みがどうなるのか、確認してみましょう。
Zonefileの `random` の行を以下のように変更してみます。
```
{% raw %}
random       IN      LUA    A "pickwrandom({ {1, '1.2.3.4'}, {100, '4.3.2.1'} })"
{% endraw %}
```
PowerDNSの設定で、`bind-check-interval=1` という設定を行って居るので、1秒間に1回Zonefileに変更があればreloadされます。
また、動作確認をしてみましょう。
```
$ for i in $(seq 1 1000); do; dig @localhost -p 15353 random.example.com +short;done | sort| uniq -c
   8 1.2.3.4
 992 4.3.2.1
```
重みが正しく動作している事が分かりましたね。

と、いう事で、いよいよ本題の、whywaitaに仕事をしてもらうために、設定を変える方法を見ていきましょう。
Lua Recordsでは [view関数](https://doc.powerdns.com/authoritative/lua-records/functions.html#view)を利用する事で、ClientのSrc IP Rangeを用いて応答を変更する事が出来ます。
以下のようにレコードを作成出来ます。
```
{% raw %}
src          IN      LUA    A "view({{{'192.168.0.0/16'}, {'192.168.1.54'}}, {{'0.0.0.0/0'}, {'192.0.2.1'}}})"
{% endraw %}
```
このレコードはリクエストのSrc IPが `192.168.0.0/16` のRange内の場合には、 `192.168.1.54` を返し、それ以外の場合には `192.0.2.1` を返します。
とりあえず、Docker Containerの外と中で問い合わせを行ってみましょう。
まず、外から
```
$ dig @localhost -p 15353 src.example.com

; <<>> DiG 9.10.6 <<>> @localhost -p 15353 src.example.com
; (2 servers found)
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 65019
;; flags: qr aa rd; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 1
;; WARNING: recursion requested but not available

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 1232
;; QUESTION SECTION:
;src.example.com.               IN      A

;; ANSWER SECTION:
src.example.com.        86400   IN      A       192.168.1.54

;; Query time: 5 msec
;; SERVER: ::1#15353(::1)
;; WHEN: Sun Dec 17 17:06:51 JST 2023
;; MSG SIZE  rcvd: 60
```
そして、PowerDNSが動いてるContainerの中です。
```
$ dig @localhost -p 5353 src.example.com

; <<>> DiG 9.16.44-Debian <<>> @localhost -p 5353 src.example.com
; (2 servers found)
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 59224
;; flags: qr aa rd; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 1
;; WARNING: recursion requested but not available

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 1232
;; QUESTION SECTION:
;src.example.com.               IN      A

;; ANSWER SECTION:
src.example.com.        86400   IN      A       192.0.2.1

;; Query time: 2 msec
;; SERVER: 127.0.0.1#5353(127.0.0.1)
;; WHEN: Sun Dec 17 08:07:15 UTC 2023
;; MSG SIZE  rcvd: 60

```
応答が変わっている事が分かると思います。
このように、Src IPアドレスに応じて、問い合わせを変更する事が出来ます。
また、Luaのソースコードなので、Randmonと組み合わせる事も出来ます。

```
{% raw %}
src-rand     IN      LUA    A "view({{{'192.168.0.0/16'}, {pickwrandom({{1, '1.2.3.4'}, {1, '1.2.3.5'}})}}, { {'0.0.0.0/0'}, { pickwrandom({ {1, '4.3.2.1'}, {1, '4.3.2.2'}})}}})"
{% endraw %}
```

動作確認してみましょう。

Docker Containerの外から実行すると以下のような結果になりました。
```
for i in $(seq 1 1000); do; dig @localhost -p 15353 src-rand.example.com +short;done | sort| uniq -c
 518 1.2.3.4
 482 1.2.3.5
```
Docker Containerの中から実行すると以下のような結果になりました。
```
$ for i in $(seq 1 1000); do dig @localhost -p 5353 src-rand.example.com +short; done | sort | uniq -c
    505 4.3.2.1
    495 4.3.2.2
```
src ipによる選択と重み付けにより選択が両方動作している事が分かります。

このようにLuaのコードを書いて自由にレコードを操作できことにより、柔軟にレコードを組み立てる事が出来ます。
例えば、Lua RecordsにはHealth checkを行ってレコードを変更する、 `ifurlup` 関数などがあり、DRのためのGSLBといった処理も行う事が出来ます。

Lua Recordsで使える仕様などについては、PowerDNSのドキュメントを確認して見て下さい。([Lua Records — PowerDNS Authoritative Server documentation](https://doc.powerdns.com/authoritative/lua-records/))

あとは、whywaitaが労働中に使ってるDNS CacheのIPアドレスが分かれば、応答を変えて見せ方を変える事が出来ますね。
まぁ、それを得るのが最難関なので、この計劃はここで頓挫です。
やろうと思えばいろいろやり方はあると思いますが、置いておきましょう。

## まとめ
PowerDNSのLua Recordsという機能を使って、応答を操作する機能の紹介を行いました。
Lua Recordsを使う事で柔軟にレコードの応答を操作する事で、GSLBとして利用する事が出来ます。
OSSのGSLBの実装としては、最も使われている物の一つではあると思うので、便利に使える機会には使ってみても良いのではないでしょうか。

明日は、papix-sanの記事です。
