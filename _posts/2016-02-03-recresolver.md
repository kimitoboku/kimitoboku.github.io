---
layout: post
title: DNSをなんとなく眺めるためのツールを作ってる
date: 2016-02-03
tags: [DNS,Network,雑多]
categorise: 雑多
---

最近Blog記事を書いてなかったのと最近作ってるツールがあるのでその紹介みたいな感じの事をカキカキします。

# RecResolve
RecResolveというツールを最近は作ってます。このツールは普段ちょっとTwitterでDNSのレコードなどが話題になった時に手元でどんな感じに反復検索が行われているのかを確認するために作ったツールです。
Githubのページは[ここです](https://github.com/kimitoboku/RecResolve "kimitoboku/RecResolve")

## Install
Go言語はワンバイナリになるから良いんだ！配布しやすいんだ！という声をよく聞きますが自分で作った適当なツールなのでそんな面倒な事はしません。使いたい時はGo言語をインストールして下さい。

> $ go get github.com/kimitoboku/RecResolve

そうすると$GOPATH/binにRecResolveが配置されてるはずなので、これで使用する事が出来ます。

<blockquote>
<pre><code>
$ RecResolve   
NAME:  
   RecResolve - It is a tool to see Iterative Search of the DNS is how to.  
  
USAGE:  
   RecResolve [global options] command [command options] [arguments...]  
   
VERSION:  
   0.0.4  
  
COMMANDS:  
   rec, r       Iterative Search  
   norec, n     No Iterative Search  
   help, h      Shows a list of commands or help for one command  
   
GLOBAL OPTIONS:  
   --root "202.12.27.33"        Root DNS Server's IP address  
   --debug                      Debug Option for Developer [$false]  
   --fool                       Believe something like flue record [$false]  
   --help, -h                   show help  
   --version, -v                print the version  
</code></pre>
</blockquote>

りあえず実行し使い方が出力されればインストール成功です。

## Run

>  $ RecResolve rec ドメイン名

でDNSキャッシュサーバが行うネームサーバ自体のドメイン名検索込の反復検索のような動きをして名前解決を頑張ってくれます。実行すると次のように出力されます。

<blockquote>
<pre><code>
$ RecResolve rec www.amazon.co.jp  
202.12.27.33=>  
        jp. -> c.dns.jp.  
156.154.100.5=>  
        amazon.co.jp. -> ns2.p31.dynect.net.  
        202.12.27.33=>  
                net. -> g.gtld-servers.net.  
        192.42.93.30=>  
                dynect.net. -> ns2.dynamicnetworkservices.net.  
                202.12.27.33=>  
                        net. -> j.gtld-servers.net.  
                192.48.79.30=>  
                        dynamicnetworkservices.net. -> ns2.dynamicnetworkservices.net.  
                Answer : 204.13.250.100=>  
                        ns2.dynamicnetworkservices.net. -> 204.13.250.100  
        Answer : 204.13.250.100=>  
                ns2.p31.dynect.net. -> 204.13.250.31  
204.13.250.31=>  
        www.amazon.co.jp. -> ns-346.awsdns-43.com.  
        202.12.27.33=>  
                com. -> k.gtld-servers.net.  
        192.52.178.30=>  
                awsdns-43.com. -> g-ns-1195.awsdns-43.com.  
        Answer : 205.251.196.171=>  
                ns-346.awsdns-43.com. -> 205.251.193.90  
Answer : 205.251.193.90=>  
        www.amazon.co.jp -> 54.240.252.0  
</code>
</pre>
</blockquote>

出力の見方としては、

<blockquote>
<pre><code>
202.12.27.33=>  
        jp. -> c.dns.jp.  
</code>
</pre>
</blockquote>

は202.12.27.33が返してきた返答で、jp.についてはc.dns.jp.が知っているよという意味になっています。

<blockquote>
<pre><code>
Answer : 205.251.193.90=>  
        www.amazon.co.jp -> 54.240.252.0  
</code>
</pre>
</blockquote>

は205.251.193.90が返答でwww.amazon.co.jpは54.240.252.0だよ、という意味になっています。

動作は単純で、まずはルートDNSに聞きに行き、知っているDNSコンテンツサーバを返してもらいそれにまた聞きに行ってをアンサーが返ってくるまで繰り返すという物になっています。


>  $ RecResolve norec ドメイン名

でDNSコンテンツサーバのドメイン名の解決をしない反復検索を行います。

<blockquote>
<pre><code>
$ RecResolve norec www.amazon.co.jp  
202.12.27.33=>  
        jp. -> c.dns.jp.  
156.154.100.5=>  
        amazon.co.jp. -> ns1.p31.dynect.net.  
ns1.p31.dynect.net.=>  
        www.amazon.co.jp. -> ns-1705.awsdns-21.co.uk.  
Answer : ns-1705.awsdns-21.co.uk.=>  
        www.amazon.co.jp -> 54.240.248.0  
</code>
</pre>
</blockquote>

出力の見方はrecの時と同じです。おそらく、こちらがdig +norecでDNSレコードが正しく設定されて検索出来るかなーってやる時の動作になっていると思います。

## Options
検索時に使用するオプションはrootとfoolがあります。

### rootオプション
rootオプションは検索時に使用するルートDNSのIPアドレスを指定する事が出来ます。初期値ではm.root-servers.netのIPアドレスになっています。

<blockquote>
<pre><code>
$ RecResolve --root "198.41.0.4" norec www.amazon.co.jp  
198.41.0.4=>  
        jp. -> e.dns.jp.  
192.50.43.53=>  
        amazon.co.jp. -> ns1.p31.dynect.net.  
ns1.p31.dynect.net.=>  
        www.amazon.co.jp. -> ns-1055.awsdns-03.org.  
Answer : ns-1055.awsdns-03.org.=>  
        www.amazon.co.jp -> 54.240.248.0  
</code>
</pre>
</blockquote>

最初に聞きに行っているルートDNSが変わっているます。recの時はDNSコンテンツサーバのドメイン名の解決の時にもこの時指定されたrootサーバが指定されます。自分でDNSルートサーバを立てた時などに使えるオプションになっています。
    
### foolオプション
foolオプションはDNSコンテンツサーバが返してくる、グルーレコードのような物を信用するオプションです。このオプションはrecの場合にのみ有効です。このオプションを指定すると世の中綺麗じゃないんだなぁということを認識する事が出来ます。

<blockquote>
<pre><code>
$ RecResolve --fool rec www.amazon.co.jp  
202.12.27.33=>  
        jp. -> d.dns.jp.  
210.138.175.244=>  
        amazon.co.jp. -> ns1.p31.dynect.net.  
        202.12.27.33=>  
                net. -> k.gtld-servers.net.  
        192.52.178.30=>  
                dynect.net. -> ns2.dynamicnetworkservices.net.  
        Answer : 204.13.250.100=>  
                ns1.p31.dynect.net. -> 208.78.70.31  
208.78.70.31=>  
        www.amazon.co.jp. -> ns-959.awsdns-55.net.  
        202.12.27.33=>  
                net. -> h.gtld-servers.net.  
        192.54.112.30=>  
                awsdns-55.net. -> g-ns-1399.awsdns-55.net.  
        Answer : 205.251.197.119=>  
                ns-959.awsdns-55.net. -> 205.251.195.191  
Answer : 205.251.195.191=>  
        www.amazon.co.jp -> 54.240.252.0  
</code>
</pre>
</blockquote>

例えば

>         192.52.178.30=>  
>                 dynect.net. -> ns2.dynamicnetworkservices.net.  
>         Answer : 204.13.250.100=>  
>                 ns1.p31.dynect.net. -> 208.78.70.31  

でns2.dynamicnetworkservices.net.はdynect.net.の内部レコードでないのに次の行でアンサーがが返ってきています。これはグルーレコードのような物を信用した証です。嫌な世界ですね。


# まとめ
自分で使うツールもとりあえずGithubに公開してみれば良いんじゃね！という事でとりあえず作って公開してみました。

自分で作ってるんで、こういう事が出来たら便利だと思うよ！みたいな案とか教えて頂けると俺の環境が潤うので嬉しいので、どしどし、何か言って下さい。

