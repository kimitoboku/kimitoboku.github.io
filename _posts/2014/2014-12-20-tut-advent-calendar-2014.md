---
layout: post
title: 技科大がpingを返してくれない
date: 2014-12-20
tags: [雑多]
categorise: 雑多
---

前回の記事がその場凌ぎの雑な記事だったので、今回はちょっと、ちゃんと書こうかなとか思ってたのですが、書き初めたのが12月20日の21時30分です。はたしてこの記事はの間に合うのかどうがか見物(?)です。

豊橋技術科学大学のドメインのwww/.tut/.ac/.jp/.にICMP echoリクエストを送っても返答がないので何で返答してないのかを勝手に考えてみました。

ICMP echoリクエストにリプライが返ってくるサーバとしては情報・知能工学課程のWebページのwww/.cs/.tut/.ac/.jp/.はpingを送るとちゃんと返ってきます。
また、学内で使われている学生がアクセス出来るLinuxサーバにもpingを送ると返答して決ます。

ちょっと調べただけでも、学内でもICMP Echoなどがリジェクトされるのは少数派なようです。

そんでもって、学内から学外へのICMPなども拒否されてます。学内の無線LANから外にICMP echoリクエストを送ると外に出る前に落されているので、ICMPのechoリプライだけでなくリクエストも完全に遮断されてるっぽいです。

ただ、学内のLinux端末からだとリクエストもリプライも通ります。

となまぁ、こんな感じで学内で対応がぐちゃぐちゃです。

普通にICMPなどを遮断する理由としては内部のネットワークの構成を得られないようにするためなどがありますが、ここまでぐちゃぐちゃだと最早そうそう意味がないような気がします。

まぁ、こんな感じだけで書くのもあれなので、もうちょっと書き書きします。

とりあえず。digってみます。

>% dig +norec @a.dns.jp tut.ac.jp  
>    
>; <<>> DiG 9.8.3-P1 <<>> +norec @a.dns.jp tut.ac.jp  
>; (2 servers found)  
>;; global options: +cmd  
>;; Got answer:  
>;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 7574  
>;; flags: qr; QUERY: 1, ANSWER: 0, AUTHORITY: 2, ADDITIONAL: 1  
>  
>;; QUESTION SECTION:  
>;tut.ac.jp.			IN	A  
>  
>;; AUTHORITY SECTION:  
>tut.ac.jp.		86400	IN	NS	dns-x.sinet.ad.jp.  
>tut.ac.jp.		86400	IN	NS	ns0.tut.ac.jp.  
>  
>;; ADDITIONAL SECTION:  
>ns0.tut.ac.jp.		86400	IN	A	133.15.2.24  
>  
>;; Query time: 243 msec  
>;; SERVER: 203.119.1.1#53(203.119.1.1)  
>;; WHEN: Sat Dec 20 21:49:13 2014  
>;; MSG SIZE  rcvd: 90  

うちの大学のDNSコンテンツサーバはsinetと自分の所の二つに分かれてるっぽいですね。

ちゃんと、グルーレコードはsinetの方には書いてないので良い感じですかね。

ついでに、imcもdigってみましょう。

>% dig +norec @ns0.tut.ac.jp. imc.tut.ac.jp  
>  
>; <<>> DiG 9.8.3-P1 <<>> +norec @ns0.tut.ac.jp. imc.tut.ac.jp  
>; (1 server found)  
>;; global options: +cmd  
>;; Got answer:  
>;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 593  
>;; flags: qr aa; QUERY: 1, ANSWER: 1, AUTHORITY: 3, ADDITIONAL: 3  
>  
>;; QUESTION SECTION:  
>;imc.tut.ac.jp.			IN	A  
>  
>;; ANSWER SECTION:  
>imc.tut.ac.jp.		3600	IN	A	133.15.181.70  
>  
>;; AUTHORITY SECTION:  
>imc.tut.ac.jp.		3600	IN	NS	ns0.imc.tut.ac.jp.  
>imc.tut.ac.jp.		3600	IN	NS	ns1.imc.tut.ac.jp.  
>imc.tut.ac.jp.		3600	IN	NS	server1.tut.ac.jp.  
>  
>;; ADDITIONAL SECTION:  
>ns0.imc.tut.ac.jp.	3600	IN	A	133.15.2.28  
>ns1.imc.tut.ac.jp.	3600	IN	A	133.15.20.28  
>server1.tut.ac.jp.	43200	IN	A	133.15.254.1  
>  
>;; Query time: 279 msec  
>;; SERVER: 133.15.2.24#53(133.15.2.24)  
>;; WHEN: Sat Dec 20 22:07:23 2014  
>;; MSG SIZE  rcvd: 153  

あれ、こちらでは、ちょっとアレな所がありますね、erver1/.tut/.ac/.jp/.のIPアドレスがADDITIONAL SECTIONが付いています。このレコードとかなんとかならないですかね。

ついでに、csあたりもdigってみましょう。

>% dig +norec @ns0.tut.ac.jp. cs.tut.ac.jp  
>  
>; <<>> DiG 9.8.3-P1 <<>> +norec @ns0.tut.ac.jp. cs.tut.ac.jp  
>; (1 server found)  
>;; global options: +cmd  
>;; Got answer:  
>;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 3654  
>;; flags: qr; QUERY: 1, ANSWER: 0, AUTHORITY: 2, ADDITIONAL: 2  
>  
>;; QUESTION SECTION:  
>;cs.tut.ac.jp.			IN	A  
>  
>;; AUTHORITY SECTION:  
>cs.tut.ac.jp.		43200	IN	NS	ns0.imc.tut.ac.jp.  
>cs.tut.ac.jp.		43200	IN	NS	ns1.imc.tut.ac.jp.  
>  
>;; ADDITIONAL SECTION:  
>ns0.imc.tut.ac.jp.	3600	IN	A	133.15.2.28  
>ns1.imc.tut.ac.jp.	3600	IN	A	133.15.20.28  
>  
>;; Query time: 257 msec  
>;; SERVER: 133.15.2.24#53(133.15.2.24)  
>;; WHEN: Sat Dec 20 22:18:38 2014  
>;; MSG SIZE  rcvd: 102  

もう、これにいたってはもう、ADDITIONAL SECTIONに間違いしかないですね!!

このあたりのをちゃんとして頂ければ良いのですがね!! まぁ、うちの大学にDNSに詳しい感じの先生はあんまりイメージがないのでなおる事はなさそうですかね?

おし、こまで? と言ってもなんか、何の情報も無い大学へのグチ的なのにしか成らないのでとりあえず、技科大の有益情報を

> VPNではドリームキャンパスなどの一部サービスにアクセス出来ない。 学内Linuxサーバからは学内の全てのサービスのアクセス出来る。学内LinuxサーバへはVPNでアクセス出来る

enjoy!!
