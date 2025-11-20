---
layout: post
title: セキュリティ・キャンプ 2014に参加出来るっぽい
tags: [セキュリティ]
categorise: 日常
date: 2014-06-22
---

# タイトルのまんま
[セキュリティ・キャンプ全国大会2014](http://www.ipa.go.jp/jinzai/camp/2014/zenkoku2014.html)に参加出来る事が決定しました。

参加するクラスはネットワーク・セキュリティ・クラスです。

去年とかも応募したのですが、落ちてしまって、そして某足軽君が行ける事になってるのを見て無駄に悔しくて一年間くらいちょっとネットワーク系の事とか調べたりしたりしたような気がしないでもないです

セキュリティはそれほど詳しくないですがインターネット(ノット?)が基本的に大好きなので自分の回りの人と自分が楽に安全に楽しめるように成れば良いなぁと思ってるので楽して生きるために頑張りたいです。

## 応募用紙の取り出し
と言っても他の人がやってらっしゃるので、 某三村さんの記事あたりを見るとすっごい良く分かると思うので、俺がやった事をまとめとしてちょちょっと。

とりあえず、ダウンロードしてきたファイルに拡張子等が付いていなかったので、fileコマンドを使用するとパケットキャプチャファイルだと教えてくれました。

パケットキャプチャファイルだと別ればとりあえずもう、Wiresharkで開いてみると、完全にhttpでファイルをダウンロードしてるパケットだったので、Wiresharkのオブジェクトを取り出す機能を使用して問題の内容を取り出しました。

また、某先輩に言われてこのファイルを読むと中身にコンテンツのタイプをgzipに指定している部分があったのでどーにか取り出せないかとやってみたりとかしたのですが、バイナリからだとファイルを分割して送信されているらしき所が
上手く判定出来なかったので失敗しました。


> fileコマンド  
fileコマンドは渡されたファイルをファイルシステムテスト、マジックナンバーテスト、言語テストの順番でそのファイルの形式を確認してくれるコマンドです。  

>マジックナンバー  
マジックナンバーはファイルの先頭部分などに存在するのファイルの形式などを識別するために使用される特定の数値。

>Wireshark  
Wiresharkはネットワーク解析ソフトでパケットキャプチャ機能や様々な解析のための機能を提供してくれている便利なツール


# 応募用紙に書いた内容?
をまんま公開するのはちょっと、精神的に辛いのでどんな感じの事を書いたのかを要約して書きかきします。

まぁ、前半の部分は全部公開しちゃって大丈夫なはず。精神的に

## ☆ 基礎知識を問う質問(回答必須)

### i) あるTCPポートにSYNパケットを送るとどんなパケットが返ってきますか？
SYN ACKフラグの立ったパケットが帰ってくるはずなので。

TCP/IP上で動作するhttpのパケットで確認してみると。



Id = 12  
Source = 192.168.11.2  
Destination = 173.194.38.55  
Captured Length = 78  
Packet Length = 78  
Protocol = TCP  
Information = 51484 -> HTTP ([SYN], Seq=140737417735616, Ack=4294967296, Win=65535)  
Date Received = 2014-05-24 04:14:34 +0000  
Time Delta = 0.7928600311279297  
  
Id = 13  
Source = 173.194.38.55  
Destination = 192.168.11.2  
Captured Length = 66  
Packet Length = 66  
Protocol = TCP  
Information = HTTP -> 51484 ([ACK, SYN], Seq=140736165417646, Ack=8519314881, Win=42900)  
Date Received = 2014-05-24 04:14:34 +0000  
Time Delta = 0.8011610507965088  
  
Id = 14  
Source = 192.168.11.2  
Destination = 173.194.38.55  
Captured Length = 54  
Packet Length = 54  
Protocol = TCP  
Information = 51484 -> HTTP ([ACK], Seq=140737417735617, Ack=7266996911, Win=16384)  
Date Received = 2014-05-24 04:14:34 +0000  
Time Delta = 0.8012058734893799  
  
Id = 15  
Source = 192.168.11.2  
Destination = 173.194.38.55  
Captured Length = 130  
Packet Length = 130  
Protocol = TCP  
Information = 51484 -> HTTP ([ACK, PUSH], Seq=140737417735617, Ack=7266996911, Win=16384)  
Date Received = 2014-05-24 04:14:34 +0000  
Time Delta = 0.8013410568237305  
  
Id = 16  
Source = 173.194.38.55  
Destination = 192.168.11.2  
Captured Length = 60  
Packet Length = 60  
Protocol = TCP  
Information = HTTP -> 51484 ([ACK], Seq=140736165417647, Ack=8519314957, Win=670)  
Date Received = 2014-05-24 04:14:34 +0000  
Time Delta = 0.8092708587646484  

Id = 17  
Source = 173.194.38.55  
Destination = 192.168.11.2  
Captured Length = 627  
Packet Length = 627  
Protocol = TCP  
Information = HTTP -> 51484 ([ACK, PUSH], Seq=140736165417647, Ack=8519314957, Win=670)  
Date Received = 2014-05-24 04:14:34 +0000  
Time Delta = 0.8540668487548828  


となり、
SYN->  
<-SYN ACK  
->ACK  

の3way handshakeが行われてからデータのやりとりを開始する事を確認した。

また、IDが12のパケットのシークエンス番号が140737417735616で14のパケットでは140737417735617となっておりシークエンス番号の増加が確認出来き、IDが13と16のパケットのシークエンス番号が140736165417646と140736165417647となっておりこちらもシークエンス番号の増加が確認出来きた。
しかし、ACKの値が受信したシークエンス番号から計算されるという所は確認が出来なかった。


### ii）閉じているUDPポートにUDPパケットを送ると返ってくるパケットは何ですか？
サーバーの設定によるがICMPのポート到達不能エラーが帰ってくるはずなのでUDPのパケットを開いていないポートに送信してみる。

{% highlight c linenos %}
//UPDを送信するコード そうしんするIPは自分のVPS
#include<sys/types.h>
#include<sys/socket.h>
#include<netinet/in.h>

int main(void){
  int sock;
  struct sockaddr_in addr;

  sock = socket(AF_INET,SOCK_DGRAM,0);

  addr.sin_family = AF_INET;
  addr.sin_port = htons(34234);
  addr.sin_addr.s_addr = inet_addr("49.212.146.45");

  sendto(sock,"TEST",4,0,(struct sockaddr *)&addr,sizeof(addr));

  close(sock);

  return 0;
}
{% endhighlight %}

このコードで次のパケットが送信される


Id = 136  
Source = 192.168.11.2  
Destination = 49.212.146.45  
Captured Length = 46  
Packet Length = 46  
Protocol = UDP  
Information = 59095 > 34234  
Date Received = 2014-05-24 04:07:20 +0000  
Time Delta = 5.160772085189819  
Headerlength: 4 bytes,   
Data follows:  
00000   54 45 53 54  TEST  


そうすると次のパケットが帰ってくる


Id = 137  
Source = 49.212.146.45  
Destination = 192.168.11.2  
Captured Length = 74  
Packet Length = 74  
Protocol = ICMP  
Information = Destination unreachable (Code=Code: Port unreachable)  
Date Received = 2014-05-24 04:07:20 +0000  
Time Delta = 5.171937227249146  


予想の通りのICMPのポートの到達不能エラーが帰ってきた。

### iii）ICMP Echo Requestを送ると返ってくると想定されるパケットは何ですか？
ICMP Echo Requestを送信するとEcho Replyタイプになったデータが同じSourceとDestinationが入れ変り、識別子がそのパケットに変更されたパケットが帰ってくるはずなのでpingがICMP Echo Requestを使用しているので確かめてみると。

送信パケット


Source = 192.168.11.2  
Destination = 173.194.38.7  
Type = IP (0x0800)  
Length = 64 bytes  
Type = 8 (Echo request)  
Identification = 0x7203 (29187)  
Data = 537f062a000b3f5108090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f202122232425262728292a2b2c2d2e2f3031323334353637  



返信パケット


Source = 173.194.38.7  
Destination = 192.168.11.2  
Type = IP (0x0800)  
Length = 64 bytes  
Type = 0 (Echo reply)  
Identification = 0x24eb (9451)  
Data = 537f062a000b3f5108090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f202122232425262728292a2b2c2d2e2f3031323334353637  


になっておりその通りに動作を行なっていた。

### iv）WindowsのtracertとLinuxのtracerouteの違いを説明してください。
WindowsのtracertはICMPを使用して動作するが、LinuxのtracerouteはUDPを用いで動作するはずである。

まず、Linuxで動作させたtracerouteの送信パケットを見てみると


Id = 7  
Source = 192.168.11.2  
Destination = 173.194.38.31  
Captured Length = 66  
Packet Length = 66  
Protocol = UDP  
Information = 51924 > 33435  
Date Received = 2014-05-24 03:58:09 +0000  
Time Delta = 0.8109159469604492  
Time to live = 1  

Id = 9  
Source = 192.168.11.2  
Destination = 173.194.38.31  
Captured Length = 66  
Packet Length = 66  
Protocol = UDP  
Information = 51924 > 33436  
Date Received = 2014-05-24 03:58:09 +0000  
Time Delta = 0.8117408752441406  
Time to live = 1  

Id = 11  
Source = 192.168.11.2  
Destination = 173.194.38.31  
Captured Length = 66  
Packet Length = 66  
Protocol = UDP  
Information = 51924 > 33437  
Date Received = 2014-05-24 03:58:09 +0000  
Time Delta = 0.8119409084320068  
Time to live = 1  

Id = 13  
Source = 192.168.11.2  
Destination = 173.194.38.31  
Captured Length = 66  
Packet Length = 66  
Protocol = UDP  
Information = 51924 > 33438  
Date Received = 2014-05-24 03:58:09 +0000  
Time Delta = 0.8121449947357178  
Time to live = 2  

Id = 15  
Source = 192.168.11.2  
Destination = 173.194.38.31  
Captured Length = 66  
Packet Length = 66  
Protocol = UDP  
Information = 51924 > 33439  
Date Received = 2014-05-24 03:58:09 +0000  
Time Delta = 0.8174099922180176  
Time to live = 2  

Id = 17  
Source = 192.168.11.2  
Destination = 173.194.38.31  
Captured Length = 66  
Packet Length = 66  
Protocol = UDP  
Information = 51924 > 33440  
Date Received = 2014-05-24 03:58:09 +0000  
Time Delta = 0.8216619491577148  
Time to live = 2  

Id = 19  
Source = 192.168.11.2  
Destination = 173.194.38.31  
Captured Length = 66  
Packet Length = 66  
Protocol = UDP  
Information = 51924 > 33441  
Date Received = 2014-05-24 03:58:09 +0000  
Time Delta = 0.8255949020385742  
Time to live = 3  

Id = 21  
Source = 192.168.11.2  
Destination = 173.194.38.31  
Captured Length = 66  
Packet Length = 66  
Protocol = UDP  
Information = 51924 > 33442  
Date Received = 2014-05-24 03:58:09 +0000  
Time Delta = 0.8298270702362061  
Time to live = 3  

Id = 23  
Source = 192.168.11.2  
Destination = 173.194.38.31  
Captured Length = 66  
Packet Length = 66  
Protocol = UDP  
Information = 51924 > 33443  
Date Received = 2014-05-24 03:58:09 +0000  
Time Delta = 0.8336858749389648  
Time to live = 3  

Id = 25  
Source = 192.168.11.2  
Destination = 173.194.38.31  
Captured Length = 66  
Packet Length = 66  
Protocol = UDP  
Information = 51924 > 33444  
Date Received = 2014-05-24 03:58:09 +0000  
Time Delta = 0.8377158641815186  
Time to live = 4  

Id = 27  
Source = 192.168.11.2  
Destination = 173.194.38.31  
Captured Length = 66  
Packet Length = 66  
Protocol = UDP  
Information = 51924 > 33445  
Date Received = 2014-05-24 03:58:09 +0000  
Time Delta = 0.8422000408172607  
Time to live = 4  

Id = 29  
Source = 192.168.11.2  
Destination = 173.194.38.31  
Captured Length = 66  
Packet Length = 66  
Protocol = UDP  
Information = 51924 > 33446  
Date Received = 2014-05-24 03:58:09 +0000  
Time Delta = 0.8464679718017578  
Time to live = 4  

Id = 31  
Source = 192.168.11.2  
Destination = 173.194.38.31  
Captured Length = 66  
Packet Length = 66  
Protocol = UDP  
Information = 51924 > 33447  
Date Received = 2014-05-24 03:58:09 +0000  
Time Delta = 0.8504970073699951  
Time to live = 5  

Id = 37  
Source = 192.168.11.2  
Destination = 173.194.38.31  
Captured Length = 66  
Packet Length = 66  
Protocol = UDP  
Information = 51924 > 33449  
Date Received = 2014-05-24 03:58:09 +0000  
Time Delta = 0.8805060386657715  
Time to live = 5  

Id = 39  
Source = 192.168.11.2  
Destination = 173.194.38.31  
Captured Length = 66  
Packet Length = 66  
Protocol = UDP  
Information = 51924 > 33450  
Date Received = 2014-05-24 03:58:09 +0000  
Time Delta = 0.88484787940979  
Time to live = 6  

Id = 43  
Source = 192.168.11.2  
Destination = 173.194.38.31  
Captured Length = 66  
Packet Length = 66  
Protocol = UDP  
Information = 51924 > 33451  
Date Received = 2014-05-24 03:58:09 +0000  
Time Delta = 0.9007840156555176  
Time to live = 6  

Id = 47  
Source = 192.168.11.2  
Destination = 173.194.38.31  
Captured Length = 66  
Packet Length = 66  
Protocol = UDP  
Information = 51924 > 33452  
Date Received = 2014-05-24 03:58:09 +0000  
Time Delta = 0.9190299510955811  
Time to live = 6  

Id = 49  
Source = 192.168.11.2  
Destination = 173.194.38.31  
Captured Length = 66  
Packet Length = 66  
Protocol = UDP  
Information = 51924 > 33453  
Date Received = 2014-05-24 03:58:09 +0000  
Time Delta = 0.9270999431610107  
Time to live = 7  

Id = 54  
Source = 192.168.11.2  
Destination = 173.194.38.31  
Captured Length = 66  
Packet Length = 66  
Protocol = UDP  
Information = 51924 > 33454  
Date Received = 2014-05-24 03:58:09 +0000  
Time Delta = 0.9431729316711426  
Time to live = 7  

Id = 58  
Source = 192.168.11.2  
Destination = 173.194.38.31  
Captured Length = 66  
Packet Length = 66  
Protocol = UDP  
Information = 51924 > 33455  
Date Received = 2014-05-24 03:58:09 +0000  
Time Delta = 0.9598278999328613  
Time to live = 7  

Id = 60  
Source = 192.168.11.2  
Destination = 173.194.38.31  
Captured Length = 66  
Packet Length = 66  
Protocol = UDP  
Information = 51924 > 33456  
Date Received = 2014-05-24 03:58:09 +0000  
Time Delta = 0.967059850692749  
Time to live = 8  

Id = 65  
Source = 192.168.11.2  
Destination = 173.194.38.31  
Captured Length = 66  
Packet Length = 66  
Protocol = UDP  
Information = 51924 > 33457  
Date Received = 2014-05-24 03:58:09 +0000  
Time Delta = 1.076746940612793  
Time to live = 8  

Id = 67  
Source = 192.168.11.2  
Destination = 173.194.38.31  
Captured Length = 66  
Packet Length = 66  
Protocol = UDP  
Information = 51924 > 33458  
Date Received = 2014-05-24 03:58:09 +0000  
Time Delta = 1.084051847457886  
Time to live = 8  

Id = 69  
Source = 192.168.11.2  
Destination = 173.194.38.31  
Captured Length = 66  
Packet Length = 66  
Protocol = UDP  
Information = 51924 > 33459  
Date Received = 2014-05-24 03:58:09 +0000  
Time Delta = 1.091171979904175  
Time to live = 9  

Id = 73  
Source = 192.168.11.2  
Destination = 173.194.38.31  
Captured Length = 66  
Packet Length = 66  
Protocol = UDP  
Information = 51924 > 33460  
Date Received = 2014-05-24 03:58:09 +0000  
Time Delta = 1.151911973953247  
Time to live = 9  

Id = 75  
Source = 192.168.11.2  
Destination = 173.194.38.31  
Captured Length = 66  
Packet Length = 66  
Protocol = UDP  
Information = 51924 > 33461  
Date Received = 2014-05-24 03:58:09 +0000  
Time Delta = 1.159287929534912  
Time to live = 9  

Id = 77  
Source = 192.168.11.2  
Destination = 173.194.38.31  
Captured Length = 66  
Packet Length = 66  
Protocol = UDP  
Information = 51924 > 33462  
Date Received = 2014-05-24 03:58:09 +0000  
Time Delta = 1.166629076004028  
Time to live = 10  

Id = 83  
Source = 192.168.11.2  
Destination = 173.194.38.31  
Captured Length = 66  
Packet Length = 66  
Protocol = UDP  
Information = 51924 > 33463  
Date Received = 2014-05-24 03:58:09 +0000  
Time Delta = 1.238141059875488  
Time to live = 10  

Id = 85  
Source = 192.168.11.2  
Destination = 173.194.38.31  
Captured Length = 66  
Packet Length = 66  
Protocol = UDP  
Information = 51924 > 33464  
Date Received = 2014-05-24 03:58:09 +0000  
Time Delta = 1.245821952819824  
Time to live = 10  

Id = 87  
Source = 192.168.11.2  
Destination = 173.194.38.31  
Captured Length = 66  
Packet Length = 66  
Protocol = UDP  
Information = 51924 > 33465  
Date Received = 2014-05-24 03:58:09 +0000  
Time Delta = 1.253227949142456  
Time to live = 11  

Id = 91  
Source = 192.168.11.2  
Destination = 173.194.38.31  
Captured Length = 66  
Packet Length = 66  
Protocol = UDP  
Information = 51924 > 33466  
Date Received = 2014-05-24 03:58:09 +0000  
Time Delta = 1.269459009170532  
Time to live = 11  

Id = 93  
Source = 192.168.11.2  
Destination = 173.194.38.31  
Captured Length = 66  
Packet Length = 66  
Protocol = UDP  
Information = 51924 > 33467  
Date Received = 2014-05-24 03:58:09 +0000  
Time Delta = 1.276155948638916  
Time to live = 11  


となっておりUDPで動作している事が確認出来た。

Windowsのtracertのパケットを観察してみると


4	1.155242000	192.168.11.6	173.194.38.56	ICMP	106	Echo (ping) request  id=0x0001, seq=42/10752, ttl=1  
6	1.158363000	192.168.11.6	173.194.38.56	ICMP	106	Echo (ping) request  id=0x0001, seq=43/11008, ttl=1  
8	1.160939000	192.168.11.6	173.194.38.56	ICMP	106	Echo (ping) request  id=0x0001, seq=44/11264, ttl=1  
24	6.674609000	192.168.11.6	173.194.38.56	ICMP	106	Echo (ping) request  id=0x0001, seq=45/11520, ttl=2  
26	6.682627000	192.168.11.6	173.194.38.56	ICMP	106	Echo (ping) request  id=0x0001, seq=46/11776, ttl=2  
28	6.688931000	192.168.11.6	173.194.38.56	ICMP	106	Echo (ping) request  id=0x0001, seq=47/12032, ttl=2  
33	7.700407000	192.168.11.6	173.194.38.56	ICMP	106	Echo (ping) request  id=0x0001, seq=48/12288, ttl=3  
35	7.707149000	192.168.11.6	173.194.38.56	ICMP	106	Echo (ping) request  id=0x0001, seq=49/12544, ttl=3  
37	7.713497000	192.168.11.6	173.194.38.56	ICMP	106	Echo (ping) request  id=0x0001, seq=50/12800, ttl=3  
45	8.724440000	192.168.11.6	173.194.38.56	ICMP	106	Echo (ping) request  id=0x0001, seq=51/13056, ttl=4  
47	8.731367000	192.168.11.6	173.194.38.56	ICMP	106	Echo (ping) request  id=0x0001, seq=52/13312, ttl=4  
49	8.744569000	192.168.11.6	173.194.38.56	ICMP	106	Echo (ping) request  id=0x0001, seq=53/13568, ttl=4  
51	9.754305000	192.168.11.6	173.194.38.56	ICMP	106	Echo (ping) request  id=0x0001, seq=54/13824, ttl=5  
53	9.761093000	192.168.11.6	173.194.38.56	ICMP	106	Echo (ping) request  id=0x0001, seq=55/14080, ttl=5  
55	9.768844000	192.168.11.6	173.194.38.56	ICMP	106	Echo (ping) request  id=0x0001, seq=56/14336, ttl=5  
59	10.780171000	192.168.11.6	173.194.38.56	ICMP	106	Echo (ping) request  id=0x0001, seq=57/14592, ttl=6  
61	10.792900000	192.168.11.6	173.194.38.56	ICMP	106	Echo (ping) request  id=0x0001, seq=58/14848, ttl=6  
63	10.804177000	192.168.11.6	173.194.38.56	ICMP	106	Echo (ping) request  id=0x0001, seq=59/15104, ttl=6  
67	11.814143000	192.168.11.6	173.194.38.56	ICMP	106	Echo (ping) request  id=0x0001, seq=60/15360, ttl=7  
69	11.828017000	192.168.11.6	173.194.38.56	ICMP	106	Echo (ping) request  id=0x0001, seq=61/15616, ttl=7  
71	11.838012000	192.168.11.6	173.194.38.56	ICMP	106	Echo (ping) request  id=0x0001, seq=62/15872, ttl=7  
73	12.847262000	192.168.11.6	173.194.38.56	ICMP	106	Echo (ping) request  id=0x0001, seq=63/16128, ttl=8  
75	12.857432000	192.168.11.6	173.194.38.56	ICMP	106	Echo (ping) request  id=0x0001, seq=64/16384, ttl=8  
77	12.867300000	192.168.11.6	173.194.38.56	ICMP	106	Echo (ping) request  id=0x0001, seq=65/16640, ttl=8  
102	18.385592000	192.168.11.6	173.194.38.56	ICMP	106	Echo (ping) request  id=0x0001, seq=66/16896, ttl=9  
104	18.402726000	192.168.11.6	173.194.38.56	ICMP	106	Echo (ping) request  id=0x0001, seq=67/17152, ttl=9  
106	18.412728000	192.168.11.6	173.194.38.56	ICMP	106	Echo (ping) request  id=0x0001, seq=68/17408, ttl=9  
119	23.926610000	192.168.11.6	173.194.38.56	ICMP	106	Echo (ping) request  id=0x0001, seq=69/17664, ttl=10  
121	23.937736000	192.168.11.6	173.194.38.56	ICMP	106	Echo (ping) request  id=0x0001, seq=70/17920, ttl=10  
123	23.948326000	192.168.11.6	173.194.38.56	ICMP	106	Echo (ping) request  id=0x0001, seq=71/18176, ttl=10  
161	29.462742000	192.168.11.6	173.194.38.56	ICMP	106	Echo (ping) request  id=0x0001, seq=72/18432, ttl=11  
163	29.472473000	192.168.11.6	173.194.38.56	ICMP	106	Echo (ping) request  id=0x0001, seq=73/18688, ttl=11  
165	29.488740000	192.168.11.6	173.194.38.56	ICMP	106	Echo (ping) request  id=0x0001, seq=74/18944, ttl=11  


のようになっており予想通りICMPで動作している事を確認した。


### v）WindowsのpingとLinuxのpingの違いを説明してください。
LinuxとWindowsのpingの違いが分からなかったのでそれぞれのパケットを見てみます。

Linuxのpingの送信パケットの内容を見てみると


Packet length = 98 バイト  
Time to live = 64  
ICMP-Header{  
	Type = 8 (Echo request)  
	Data = 5ea9845300000000914e030000000000101112131415161718191a1b1c1d1e1f202122232425262728292a2b2c2d2e2f3031323334353637  
}  


となっておりWindowsの送信パケットを見てみると


Packet length = 74 バイト  
Time to live = 128  
ICMP-Header{  
	Type = 8 (Echo request)  
	Data = 6162636465666768696a6b6c6d6e6f7071727374757677616263646566676869  
}  


となっておりTime to liveがLinuxでは64、Windowsは128でWindowsの方がパケットとしての生存時間が長い。

ICMPのEcho RequestのデータがLinuxでは!"#$%&'()*+,-./01234567となっているが、Windowsではabcdefghijklmnopqrstuvwabcdefghiになっている。

あと気になったのでMacでの送信パケットを見てみると


Packet length = 98 バイト  
Time to live = 64  
ICMP-Header{  
	Type = 8 (Echo request)  
	Data = 5385fc09000db9e108090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f202122232425262728292a2b2c2d2e2f3031323334353637  
}  


となっておりLinuxとほぼ同じ動作を行なっていた。

### vi）パケットを送るときに分割して送ることを何と言いますか？
IPフラグメンテーションといいプロトコルが指定してるサイズ以上でフラグメンテーションのフラグが許可になっている時にパケットを分割して送信を行なう。

フラグメンテーションが行なわれているか確認するためにping -s 5000として断片化されるかを確認してみる。

送信パケット


66	2.871552000	192.168.11.2	49.212.146.45	ICMP	1514	Echo (ping) request  id=0x4b1c, seq=0/0, ttl=64  
67	2.871563000	192.168.11.2	49.212.146.45	IPv4	1514	Fragmented IP protocol (proto=ICMP 1, off=1480, ID=8f51)  
68	2.871567000	192.168.11.2	49.212.146.45	IPv4	1514	Fragmented IP protocol (proto=ICMP 1, off=2960, ID=8f51)  
69	2.871570000	192.168.11.2	49.212.146.45	IPv4	602	Fragmented IP protocol (proto=ICMP 1, off=4440, ID=8f51)  


返答パケット


74	2.936957000	49.212.146.45	192.168.11.2	IPv4	778	Fragmented IP protocol (proto=ICMP 1, off=0, ID=71f4) [Reassembled in #80]  
75	2.936960000	49.212.146.45	192.168.11.2	IPv4	770	Fragmented IP protocol (proto=ICMP 1, off=744, ID=71f4) [Reassembled in #80]  
76	2.936962000	49.212.146.45	192.168.11.2	IPv4	778	Fragmented IP protocol (proto=ICMP 1, off=1480, ID=71f4) [Reassembled in #80]  
77	2.936963000	49.212.146.45	192.168.11.2	IPv4	770	Fragmented IP protocol (proto=ICMP 1, off=2224, ID=71f4) [Reassembled in #80]  
78	2.936965000	49.212.146.45	192.168.11.2	IPv4	778	Fragmented IP protocol (proto=ICMP 1, off=2960, ID=71f4) [Reassembled in #80]  
79	2.936966000	49.212.146.45	192.168.11.2	IPv4	770	Fragmented IP protocol (proto=ICMP 1, off=3704, ID=71f4) [Reassembled in #80]  
80	2.936967000	49.212.146.45	192.168.11.2	ICMP	602	Echo (ping) reply    id=0x4b1c, seq=0/0, ttl=52  


IPプロトコルのとしてフラグメンテーションが行われて分割されている事を確認した。


またパケットは上記で送信パケットは私の送信する環境の最大である1514バイトを先頭から分割していっているが、返答パケットでは778バイトと770バイトが順番になって送信されていると初めて知りました。また、IPフラグメンテーションのオフセットでは前に送信したICMPプロトコルのデータサイズがセットされている事も確認した。
また、送信パケットをもう少し見てみると、IPv4プロトコルのチェックサムが00 00となっており、送信元パケットではチェックサムが機能を行っていなかった。

これは、送信時に全てのデータを確認してから処理しているのではなく、先頭から切って送信を行っているのでチェックサムの計算が出来ないからではないかと考える。

返答パケットはパケットが8バイトの差はあっても均等にして返信されている事と、チェックサムが全て計算されている事から、すべてのデータを確認してから処理をしていると考える。


### vii）HTTPで動作しているサービスをHTTPSに変更することで起きうるデメリットを説明してください。
そのWebページの中でhttpを呼び出している所があると安全ではないリソースが含まれていると警告を出力される。

SSLハンドシェイクや暗号化,復号化でWebページの表示速度が遅くなる。

### viii）この応募用紙をダウンロードしたサーバのヘッダ情報をpcapファイルの中から抜き出して答えてください。
応募用紙のダウンロードを行なうパケットの応募用紙をGETするリクエストの応答のACKの次のパケットのHTTPのデータ部を取り出すと次のようになっている


HTTP/1.1 200 OK  
Date: Tue, 11 Nov 2014 08:06:38 GMT  
Server: Apache/2.2.16 (Debian)  
Last-Modified: Tue, 11 Nov 2014 08:04:32 GMT  
ETag: "414f6-8fa-50790baaae400"  
Accept-Ranges: bytes  
Vary: Accept-Encoding  
Content-Encoding: gzip  
Content-Length: 1236  
Connection: close  
Content-Type: text/plain  
  
(Blogに整形する所で微妙になったので省略)  


この中のHTTPのヘッダ情報は


HTTP/1.1 200 OK  
Date: Tue, 11 Nov 2014 08:06:38 GMT  
Server: Apache/2.2.16 (Debian)  
Last-Modified: Tue, 11 Nov 2014 08:04:32 GMT  
ETag: "414f6-8fa-50790baaae400"  
Accept-Ranges: bytes  
Vary: Accept-Encoding  
Content-Encoding: gzip  
Content-Length: 1236  
Connection: close  
Content-Type: text/plain  


となり、これがこのファイルをダウンロードした時のサーバのヘッタ情報である。

##☆ 記述式質問
記述質問は自分の考えなのでこっぱずかしいので要約して!

### 1. このクラスを希望した自分なりの理由を教えてください。また、この講義で学んだことを何に役立てたいかを教えてください。
ネットワークの技術に興味がありその技術を使用して自分で運用していくにはその技術を攻撃などから守る方法を知っていなければ的な事を書きかき。

### 2. あなたが今「一番興味がある」プロトコルはなんですか？またそのプロトコルのどのようなところに興味がありますか？
セキュリティとかにちょっと興味を持った切っ掛けがまっちゃ139勉強会での某浸透いうな先生だったのでそれも関連して、DNSに興味があります的な事を書き書き。

### 3. あなたの学校のネットワークを許可なくこっそり使って通信している人がいるかもしれません。 そういう心配が起こった時にあなたはどのような行動をとりますか。説明してください。
まず、その心配が起こった原因を探します。なぜ、学校のネットワークを使用している人が居るかもしれないと思ったのか、そしてその原因から他人が使用している事が判明すれば学校のネットワークを管理してる所に無許可で使用している人のログの確認、生徒教員への影響の確認その根本原因の究明などの対処を求めます。もし、原因が見つからなければそのような気がするのでという事を学校のネットワークを管理している所に行き調査をお願いする。

### 4. あるホームページを参照した際に表示が大変遅く感じました。この場合、原因として考えられる事象を説明してください。なお、想定される原因の数は多いほど望ましい。
Webページへのアクセスが増加している。

サーバー上でのなんらかのプロセスがメモリリーク等を起こしている。

サーバーのパッケージの自動アップデートが走っている。

ホームページへアクセスしてる自分のネットワークが混雑している。

ルータ等のネットワーク機器の不具合によるパケットロスが増加している。

Webページ内に画像等の大きいファイルが存在する。

重いJavaScriptが実行されている。

サーバがDos攻撃などを受けている。

ブラウザの不具合によりjavascriptなどの動作が重くなっている。

とな感じに箇条書きで書き書き。

### 5. あなたがネットカフェで入手したとあるファイルをネットワーク経由であなたの自宅に安全に送付するための方法について解説してください。解説してある手法は多いほど望ましい。
scpを使用してファイルを転送する

Dropbox等のローカルで暗号化を行なうタイプのファイル同期サービスを使用する

みたいな感じに箇条書きで書き書き。

### 6. 興味を持っているプログラミング言語は何ですか？使ったことがあるプログラミング言語や愛用しているプログラミング言語について説明してください。
ここはもう、最近、好きなGo言語について書き書きしました。

### 7. 情報家電を１つ取り上げ、どんなプロトコルを使うか、サービスとして何が想定されるかを説明してください。また、その情報家電が悪用された場合、どのような脅威が想定されるか説明してください。
情報家電が何かちょっとよく分からなかったので、とりあえず、エアコンを想定して書き書き。

どのような脅威が想定されるかは、外部からエアコンなどをコントロール出来れば、電力の消費量に大きく影響出来るので国家テロが出来る的な感じの事を書き書き。

### 8. 今一番注目しているネットワークプロトコルおよび実装について説明してください。また、そのネットワークプロトコルが悪用されてしまう可能性についても説明してください。
とりあえず、普通にHTTP2.0について書き書き

悪用されてしまう可能性についての所は、必ずTLS上にコネクションを貼るので，こないだのOpenSSLの件があれば、標準化されている以上は多くの人が使う事になるので危険どあっぷ的な事を書き書き。

### 9. そのほかアピールしたいこと、書き足りないことがあれば自由に書いてください。
インターネットが好きだぞー! って書きました。


# 以上!!
まぁ、こんな感じで書けるだけ書きました。
とりあえず、セキュリティ・ミニキャンプで手を動かせ!! 的な事を言われたのでとりあえず手を動かせるだけ、動かしてみましたっ

来年以降、セキュリティ・キャンプが開催されるならそれに参加したい人の参考にでも成れば良いですねっ


