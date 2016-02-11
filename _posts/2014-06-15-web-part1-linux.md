---
layout: post
title: Linuxの勉強会一回目でやった所
date: 2014-06-14
tags: [Linux,勉強会]
categorise: Linux
---

# Linux勉強会的なので自分が担当した所の解説

とりあえず、勉強会中のコマンドのログをぺたぺた

>: 1402723810:0;mkdir hoge  
: 1402723844:0;cd hoge/  
: 1402723870:0;touch README  
: 1402723898:0;ls -l  
: 1402723951:0;ls -a  
: 1402723967:0;ls -al  
: 1402723996:0;ls -all  
: 1402724011:0;ls --all  
: 1402724036:0;pwd  
: 1402724128:0;cd /etc/kernel/postinst.d/  
: 1402724161:0;cd -  
: 1402724273:0;echo "test"  
: 1402724375:0;echo "test" >> README  
: 1402724384:0;echo "tetestst" >> README  
: 1402724389:0;echo "tetestsll\t" >> README  
: 1402724395:0;echo "tetestsll\t\0" >> README  
: 1402724399:0;echo "tetestttsll\t\0" >> README  
: 1402724406:0;echo "tetestttsll\rrt\0" >> README  
: 1402724408:0;echo "tetestttsll\rrrrrt\0" >> README  
: 1402724411:0;echo "tetestttsll\rrrrrrrrrt\0" >> README  
: 1402724413:0;echo "tetestttsll\rrrrrrrrrrrrrt\0" >> README  
: 1402724422:0;cat README  
: 1402724437:0;head README  
: 1402724510:0;cat README | grep 0  
: 1402724543:0;dpkg --get-selections | grep openssl  
: 1402724589:0;vim README  
: 1402724737:0;vim /etc/rpc  
: 1402724796:0;file README  
: 1402724817:0;emacs README  
: 1402724862:0;ps  
: 1402724885:0;ps aux  
: 1402724901:0;ps aux | grep kimitoboku  
: 1402724949:0;man loadkey  
: 1402724995:0;ps aux | less  
: 1402725029:0;top  
: 1402725197:0;ping www.tut.ac.jp  
: 1402725323:0;ip addr | less  
: 1402725362:0;man ip  
: 1402725413:0;ip route  
: 1402725421:0;ip rule  
: 1402725440:0;man printf  
: 1402725456:0;man puts  
: 1402725795:0;ip addr  
: 1402725799:0;ll  
: 1402725807:0;netstat  
: 1402725893:0;aptitude search man-page  
: 1402726542:0;traceroute google.com  
: 1402726546:0;traceroute google.com | less  
: 1402726626:0;df  
: 1402726655:0;ping u-tokyo.ac.jp  
: 1402726665:0;traceroute u-tokyo.ac.jp | less  
: 1402726735:0;whois jp.com  
: 1402726739:0;whois jp.com | less  
: 1402726815:0;nslookup google.com  
: 1402726819:0;nslookup google.com | less  
: 1402754542:0;rm -r hoge/  


となまぁ、こんな感じになっているので、使ったコマンドを解説していきます

## mkdir
ディレクトリ作成コマンド  

### 使用方法
$ mkdir [options] dirnames  
Options:  
-m [mode] : パーミッションの指定を行う 指定の方法はchmodと同じ方法で行なう  
-p        : パスを含めて作成を行う場合に、その作成するまでの親のディレクトリなどが存在しない場合は親のディレクトリごと作成する  


## cd
カレントディレクトリを指定したパスに変更するコマンド  

### 使用方法
$ cd dire  
また  
$ cd -  
で直前に居たディレクトリに移動する  


## touch
ファイルの最終アクセス時間と最終更新時間を更新を行う。指定したファイルが存在しない場合にはその名前の空のファイルを作成する  

### 使用方法
$ touch [options] filename  
Options:  
-a        : ファイルの最終アクセス時間を更新する  
-c        : ファイルが存在しなかった場合でも空のファイルを作成しない  
-t [time] : ファイルの更新の日時をtimeに変更する。timeは"[[CC]YY]MMDDhhmm"の形式にする  


## ls
指定したディレクトリ内のファイルとその情報を表示する。デフォルトではカレントディレクトリが指定される  

### 使用方法
$ ls [options] dir  
Options:  
-a : 隠しファイルも含めた全てのファイルを表示する  
-l : ファイルの情報を表示する  


## pwd
現在のディレクトリを表示する  

### 使用方法
$ pwd  


## echo
指定したものを表示するコマンド  

### 使用方法
$ echo [options] string  
Options:  
-n : 改行を出力しない  
-e : エスケープ文字を有効にする  
string : 文字列や環境変数やシェル変数など  


## cat
ファイルの中身を表示する。また、複数ファイルを指定した場合はそのファイルを連結したものを出力する。  

### 使用方法
$ cat [options] file  
Options:  
-n : 行番号を表示する  


## head
ファイルの先頭から一定行数を表示する。デフォルトでは10行の表示を行う。  

### 使用方法
$ head [options] filename  
Options:  
-n num : 表示する行数をnumに変更する  


## vim
ディタ  

### 使用方法
vimtutorやって下さい  
:q!で終了出来ます  

## emacs
高機能ディタ  

### 使用方法
C-f : 右に移動する  
C-b : 左に移動する  
C-p : 上に移動する  
C-n : 下に移動する  
C-a : 行頭まで移動する  
C-e : 行末まで移動する  
C-d : カーソルの位置にある文字を削除する  
C-o : カーソルの場所に改行を行いカーソルはそのまま  
C-m : カーソルの場所で改行を行ないカーソルを次の行の行頭に移動する  
C-v : カーソルを一画面分だけ下げる  
M-v : カーソルを一画面分だけ上げる  
M-< : カーソルをファイルの先頭に移動する  
M-> : カーソルをファイルの最後に移動する  
C-x C-f : ファイルを開く  
C-x C-s : ファイルを保存する  
C-x C-c : Emacsを終了する  


## ps
プロセスの状態の一覧を表示する  

### 使用方法
$ ps [options]  
Options:  
a : 全てのユーザーのプロセスの状態を表示する  
f : プロセスの親子関係をツリーとして表示する  
u : プロセスのユーザー名と開始時刻を表示する  
x : デーモンプロセスも表示する  


## top
Linuxのプロセスを表示する  

### 使用方法
$ top [options]  
topコマンドの使いかたは説明が文字だと辛いので触ってみて下さい  


## ping
サーバーにICMP Echo requestを送信するコマンド  

### 使用方法
$ ping [options] host  
Options:  
-s size : 送信するパケットのサイズをsizeにするデフォルトでは「!"#$%&'()*+,-./01234567」が送信される  
-t time : タイムアウトの時間をtimeにする  


## traceroute
hostへのパケットの経路を表示する  

### 使用方法
$ traceroute [options] host  
-I : パケットの経路を確認する時に送信するパケットのプロトコルをICMPにする。  
-p port : portに送信するポートを指定する  


## whois
whoisサーバーのドメインのデータベースにしアクセスしドメインの情報を表示する  

### 使用方法
$ whois [options] string  
Options:  
-h host : whoisサーバーをhostに指定する  


## rm
ファイル、ディレクトリを削除する  

### 使用方法
$ rm [options] (filename|dir)  
Options:  
-f : ファイルのパーミッションを気にせずに削除を行う。また、ファイルが存在しなかった場合もエラーを帰さない  
-d : ディレクトリも削除する  
-r : ディレクトリとその中身を削除する  



# まとめ
となまぁ、第一回ではこんな感じのコマンドを使用しましたとさ  
ここらへんは普通に使うので覚えといて損は無いんじゃないですかねっ  
