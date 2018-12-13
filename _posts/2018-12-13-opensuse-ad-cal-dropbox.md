---
layout: post
title: openSUSEでDropboxを使う
date: 2018-12-13
tags: [openSUSE, Dropbox]
categorise: 雑多
---

はじめましてのかたははじめまして．
そうでない方も初めまして．
日本openSUSEユーザ会で浜松と名古屋の間にいる川上です．

これは，[openSUSEアドベントカレンダー](https://adventar.org/calendars/3372)の13日目の記事です．

みなさん，ストレージサービスは何を使っていますか？
Google Driveだったり，OneDriveだったり，または自分でNextCloudで構築していたりするかもしれません．
私は公式で，LinuxのサポートもしてくれているDropboxを主に使用しています．
しかし，このDropboxが11月からLinuxではext4というファイルシステムのみのサポートに変更されてしまいました．
/proc/filesystemの読み取りを禁じるだけでなぜか他のファイルシステムのチェックが動かないなんて噂[^1]ももありますが，今回は正当に対処しましょう．
openSUSEでは，基本的にルートファイルシステムはbtrfs，ホーム以下はxfsとなっており，そのままでは，Dropboxさんがファイルシステムを認識してしまい，ファイルを同期することが出来ません．
そこで，今回はloop-backファイルシステムを用いて，Dropboxのフォルダをマウントしようと思います．

[^1]: [Not working on dropbox-lnx.x86_64-62.3.93 · Issue #4 · dark/dropbox-filesystem-fix](https://github.com/dark/dropbox-filesystem-fix/issues/4) こんなざるな条件分岐なサービスの品質は大丈夫なのか？という話は置いておきましょう

## Dropboxのインストール
まず，Dropboxで使用するext4のディレクトリを作成します．
```shell
$ truncate -s 4G loop-dropbo
$ sudo mkfs.ext4 loop-dropbox
$ mkdir /home/username/Dropbox
$ sudo mount -o loop -t ext4 loop-dropbox /home/username/Dropbox
$ sudo chown username /home/username/Dropbox
```
truncateコマンドを用いて4GBの空ファイルを作成しています．
ここは使用しているDropboxの容量にあわせましょう．
mkfs.ext4コマンドで，ファイルシステムを構築します．
そして，構築したファイルシステムをloopオプションを付けてマウントします．
この時，ディレクトリの所有者はrootになっているので，自分のアカウントに変更します．
これで，openSUSEでext4のフォルダが出来ました．

これを永続化する設定は/etc/fstabに以下のように追記します．
```/etc/fstab
/path/to/loop-dropbox /home/username/Dropbox ext4 loop 0 0
```

続いて，Dropboxのインストールです．
```shell
$ sudo zypper install dropbox-cli
$ dropbox start -i
```
Dropboxはコマンドラインインターフェースのみ公式リポゾトリに提供されているので，コマンドラインインターフェースをインストールしそれを用いてインストールします．
後は，手順に任せて，ログインするだけで，Dropboxを使うことが出来ます．

# まとめ
今回はopenSUSEでDropboxのインストールを行いました．
Dropboxのサポートがext4のみになったため少し手順は面倒に鳴りましたが，それでも，公式でLinuxをサポートしてくれているオンラインストレージサービスは少ないのでこれからも使って行きたいと思います．
