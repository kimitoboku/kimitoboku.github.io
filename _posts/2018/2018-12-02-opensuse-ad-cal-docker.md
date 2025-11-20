---
layout: post
title: openSUSEでDockerをインストールして．YaSTでアタッチまで
date: 2018-12-02
tags: [openSUSE, Docker]
categorise: 雑多
---

初めましての方は初めまして，そうでないかたも初めまして．
日本openSUSEユーザ会で，名古屋やら浜松あたりでゆらゆらしている川上です．

今年は，openSUSEのアドベントカレンダーがあるという事なので，ちょこちょこと書いていきたいと思います．
昨日は覆面くんさんがopenSUSEのインストールから軽い紹介まで[覆面くんの覆面写真日記 — USBメモリからでも起動できるLinux 『openSUSE』を試してみるのだ！ の巻](https://blaukrautchen.tumblr.com/post/180681179149/opensuseadventcalendar20181201)をやってくれましたので，今日からはきっとopenSUSEを使って何かをする話など多々出てくると思います．
是非，openSUSEアドベントカレンダーの記事を読んでopenSUSEに興味をもってみて下さい．

今日のネタはopenSUSEでDockerをインストールして使ってみるまでです．
openSUSEは仮想化環境に非常に力を入れたディストリビューションで，KVM，Xenなどの仮想化環境を非常に簡単にインストールして使用することが出来ます．
Dockerのサポートにも力を入れており，OSSのDocker レジストリサービスの[Portus](http://port.us.org/)もSUSEにより開発されています．
Portusの使い方についてはOSC Tokyo 2018春にてユーザ会の橋本修太さんにより発表されているので，見てみて下さい([PortusでプライベートDockerレジストリを作ってみよう 設定編 - Speaker Deck](https://speakerdeck.com/hashimotosyuta/portusdepuraibetodockerrezisutoriwozuo-tutemiyou-she-ding-bian))．

今回はそのあたりの応用よりの話ではなく，単純にDockerをインストールして使ってみるまでです．

# Dockerのインストール
openSUSEではDockerは公式リポジトリに含まれているため，パッケージマネージャから簡単にインストールを行うことが出来ます．
```shell
$ sudo zypper install docker
```
zypperというのがopenSUSEで使用されているパッケージマネージャです．

インストールしたDockerの起動はsystemctlコマンドを用いて起動しましょう．
```shell
$ sudo systemctl enable docker
$ sudo systemctl start docker
```
enableを行うと，次回以降，openSUSEを起動した時にも自動でDockerが起動するようになります．
start を行うと，その場でDockerが起動します．

通常Dockerはunix domain socketでクライアントコマンドとデーモンが通信を行います．
そのため，クライアントコマンドでDockerをパーミッションの問題を無くして使用するために，クライアントユーザをdockerグループに追加しましょう．
openSUSEではYaSTという設定マネージャーが存在します．
Windowsでいうとコントロールパネルのような物です．

YaSTを起動すると以下のような画面のウィンドウが起動します．
![image.png (98.3 kB)]({{site.baseurl}}/image/6e099b4c-7ef2-4bc4-ae56-f38d54a1d7b3.png)
そしてその中から，User and Gruop Managementを選択します．
![image.png (98.9 kB)]({{site.baseurl}}/image/3fee92ac-6a33-4571-81bc-ac78ce8e146b.png)
そうすると，User and Gruop Managementが起動し，ユーザの一覧や，グループの一覧を確認することが出来ます．
今回はユーザにグループを追加したいので，グループに追加するユーザを選択して，Editボタンを押します．
![image.png (46.8 kB)]({{site.baseurl}}/image/017eb426-7ea0-46d3-a1c6-60b64141c178.png)
そうすると，ユーザのパスワードなどを変更する画面が出現します．
その画面の中からDetailsのタブを開きます．
![image.png (45.1 kB)]({{site.baseurl}}/image/5a99aede-39c1-4ceb-8324-f16a88bdb526.png)
Detailsのタブでは，ユーザのIDやホームディレクトリの変更，グループの追加を行うことが出来ます．
グループの追加は，追加したいグループにチェックボックスを入れるだけです．
![image.png (62.6 kB)]({{site.baseurl}}/image/e2ca32e2-4e96-4af3-a4d1-3e6e5ac2ce59.png)
あとはOKを連打してUser and Gruop Managementを修了すれば完了です．
設定を反映するためにログインしなおしましょう．

さて，いよいよHello Worldです．
```
$ docker run hello-world
docker run hello-world
Unable to find image 'hello-world:latest' locally
latest: Pulling from library/hello-world
d1725b59e92d: Pull complete 
Digest: sha256:0add3ace90ecb4adbf7777e9aacf18357296e799f81cabc9fde470971e499788
Status: Downloaded newer image for hello-world:latest

Hello from Docker!
This message shows that your installation appears to be working correctly.

To generate this message, Docker took the following steps:
 1. The Docker client contacted the Docker daemon.
 2. The Docker daemon pulled the "hello-world" image from the Docker Hub.
    (amd64)
 3. The Docker daemon created a new container from that image which runs the
    executable that produces the output you are currently reading.
 4. The Docker daemon streamed that output to the Docker client, which sent it
    to your terminal.

To try something more ambitious, you can run an Ubuntu container with:
 $ docker run -it ubuntu bash

Share images, automate workflows, and more with a free Docker ID:
 https://hub.docker.com/

For more examples and ideas, visit:
 https://docs.docker.com/get-started/
```
となまぁ，これでopenSUSEでのDockerのインストールは終了です．
コマンドラインからのDockerの使用はこれで，ほぼ全て行うことが出来ます．

# YaST2-Dockerのインストール
続いてはYaSTからDockerを触ってみましょう．
YaSTはアプリケーションのプラットフォームでもあるので，YaSTの拡張機能としてDockerを扱う機能もあります．
openSUSE Leap 15.0では，Dockerを扱う拡張機能である，yast2-dockerパッケージが標準パッケージには含まれていないので，リポジトリを追加してあげる必要があります．
yast2の2はYaSTのバージョン名なのでtoとかではないです．
YaST Headリポジトリを追加して，インストールします．
```shell
$ sudo zypper addrepo https://download.opensuse.org/repositories/YaST:/Head/openSUSE_Leap_15.0/YaST:Head.repo
$ sudo zypper refresh
$ sudo zypper install yast2-docker
```

yast2-dockerを選択して起動しましょう．
![image.png (186.6 kB)]({{site.baseurl}}/image/9d423473-89a4-491f-b4a9-f95cac7143b0.png)
起動すると以下のようなウィンドウが出現します．
ここでは，現在ローカルに存在するイメージのリストがあります．
![image.png (47.0 kB)]({{site.baseurl}}/image/09e88d0f-397b-4e1a-a379-70228d640cca.png)
ここから，起動したいイメージを選択して，右のRunボタンを押すと以下のようなポップアップが出現し，マウントするフォルダの選択や，実行するコマンドの選択など行うことが出来ます．
![image.png (53.2 kB)]({{site.baseurl}}/image/680e48c1-71f4-4a7b-85f3-68515a9890a6.png)
のような感じでDockerの実行が出来ます．

また，実行中のコンテナにアタッチすることも出来ます．
自分はどちらかというと，yast2-dockerでコンテナを起動することはありませんが，実行中のコンテナにアタッチすることはよくあります．
とりあえず，httpdをDockerで立てましょう．
```shell
$ docker run -d -p 9999:80 httpd
```
実行しているコンテナが存在すると，yast2-dockerの画面のContainersタブに実行中のコンテナが表示されます．
![image.png (49.4 kB)]({{site.baseurl}}/image/ecad9e0e-aba5-4835-94a0-049e7f60c427.png)
ちゃんと，Webブラウザでhttpdが動いていることも分かります．
![image.png (26.8 kB)]({{site.baseurl}}/image/c743a806-a71b-45c8-8fc8-a59ef312303b.png)
このコンテナにアタッチするには，yast2-dockerのContainersタブで，アタッチしたいコンテナを指定して，右のInject Terminalボタンを押します．
![image.png (50.6 kB)]({{site.baseurl}}/image/e7eac971-e6a0-4c08-a837-6a14ab437fb1.png)
そして，以下のようにdockerにアタッチすることが出来ます．
![image.png (53.8 kB)]({{site.baseurl}}/image/9ff2b8db-89c6-4252-bd42-8d04bae6753f.png)
この機能が，手軽に動作中のログを確認したりするときに便利でよく使います．

# まとめ
今回は，openSUSEでDockerをインストールするまでの解説を行いました．
openSUSEでは，仮想化環境の構築に力を入れているので，簡単にインストールを行う事が出来ます．
また，yast2-dockerを使用することで，イメージの管理や，実行中のコンテナへのアタッチなども簡単に行うことが出来ます．
是非，openSUSEを使って触ってみて下さい．






