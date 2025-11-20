---
layout: post
title: クラウドストレージをgitのリポジトリに使う時のメモ
date: 2014-11-27
tags: [git,雑多]
categorise: 雑多
---

なんかバイトでプログラムを書く事になったのでバイト先ではgitは使ってないっぽいですけど、とりあえず、自分の中でソースコードがごたごたしないために適当にgitで管理しようかなーとか思ったのでそのためのメモです

とりあえず、OneDrive上でやると仮定してやっていきます。

>
cd $HOME/OneDrive  
mkdir Git-Repo.git  
cd Git-Repo.git  
git init --bare  

こんな感じのコマンドでbareリポジトリ(裸のリポジトリ?)を作成します。

bareリポジトリはまぁ、普通にgit initのコマンドを使った時にProject/.gitみたいな感じで存在するやつです。bareする時はディレクトリの名前の最後は.gitってしてあげて下さい。

そんでもって、これから新しいプロジェクトを作成する時は

>
cd $HOME/src  
git clone $HOME/OneDrive/Git-Repo.git  

ってな感じにすると$HOMEのsrcにGit-Repoが作成されます。こんなかでコードを書き書きしてaddしてcommitしてから

>
git push

とかすると$HOME/OneDrive/Git-Repo.gitに更新などをプッシュ出来ます。
クローンして来た時はデフォルトでpush先がクローンしてきたリポジトリになると思います

そんでもって、既にある物をbareリポジトリにプッシュしたい時は次のコマンドで

>
cd Project  
git init  
git remote add od $HOME/OneDrive/Work/研修プログラム.git  
git push od master  

みたいな感じで、odってリモートを追加して、pushでodに向けてmasterを投げ投げするって感じのコマンドです。

まぁ、これはOneDriveでやってますけど、基本的にDropBoxでもなんでもクラウドストレージ系なら良いので適当な感じにプライベートなリポジトリを作っちゃいましょ

私はOneDriveが最近、無料で30GBあるのでそれを使っちゃおうって感じに思ったのでOneDriveでやりました。
