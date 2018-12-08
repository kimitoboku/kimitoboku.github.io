---
layout: post
title: openSUSEに新しめのEmacsのインストールとおすすめのプラグイン紹介
date: 2018-12-08
tags: [openSUSE, Emacs]
categorise: 雑多
---

はじめましてのかたははじめまして．
そうでないかたも初めまして．
日本openSUSEユーザ会で，名古屋やら浜松あたりでいろいろしている，来年度からは東京住み予定の川上です．

この記事は，[openSUSE Advent Calendar 2018 - Adventar](https://adventar.org/calendars/3372)の8日目の記事です．
今日は，Emacsのインストールについてです．

皆さん，Emacsは使ってますか？
自分はまだまだ使っています．
最近はVS Codeが優勢だったりするらしい今日この頃です[^1]．
そんな事は関係なく，Emacsの開発はずいずい前に進んでいます．
開発が前に進むという事は，安定重視のディストリビューションでは，少し古いEmacsを使うことになってしまいます．
そこで，今日はopenSUSEのLeap 15.0で新しめのEmacsを使う方法を紹介します．
まぁ，とは言っても，単純にEditorリポジトリを追加するだけです．

まず，現在インストール可能なEmacsのバージョンを確認してみます．
```shell
$ zypper info emacs
Loading repository data...
Reading installed packages...


Information for package emacs:
------------------------------
Repository     : openSUSE-Leap-15.0-Update 
Name           : emacs                     
Version        : 25.3-lp150.2.3.1          
Arch           : x86_64                    
Vendor         : openSUSE                  
Installed Size : 67.7 MiB                  
Installed      : No                        
Status         : not installed             
Source package : emacs-25.3-lp150.2.3.1.src
Summary        : GNU Emacs Base Package    
Description    :                           
    Basic package for the GNU Emacs editor. Requires emacs-x11 or
    emacs-nox.
```
という事で，現在，インストール可能なバージョンは25.3のようです．
[GNU Emacs - GNU Project](https://www.gnu.org/software/emacs/index.html#Releases)によると，現在のEmacsの最新バージョンは26.1のようなので，1つ前のバージョンという事になります．
まぁ，1つ前のバージョンでも十分といえば十分なのですが，そこは最新版を使いたいところです．

という事で，Editorリポジトリを追加します．
```shell
$ sudo zypper addrepo https://download.opensuse.org/repositories/editors/openSUSE_Leap_15.0/editors.repo
$ sudo zypper refresh
```
とりあえず，これで，リポジトリの追加は完了です．
インストール可能なEmacsのバージョンを確認してみましょう．
```shell
$ zypper info emacs
Loading repository data...
Reading installed packages...


Information for package emacs:
------------------------------
Repository     : Text editors and hex editors for Linux (openSUSE_Leap_15.0)
Name           : emacs                                                      
Version        : 26.1-lp150.314.8                                           
Arch           : x86_64                                                     
Vendor         : obs://build.opensuse.org/editors                           
Installed Size : 69.3 MiB                                                   
Installed      : No                                                         
Status         : not installed                                              
Source package : emacs-26.1-lp150.314.8.src                                 
Summary        : GNU Emacs Base Package                                     
Description    :                                                            
    Basic package for the GNU Emacs editor. Requires emacs-x11 or
    emacs-nox.
```
ぶじ，26.1がインストール可能となっていますね．
あとは，普通にインストールしましょう．
```shell
$ sudo zypper install emacs
```
これで，新しめのEmacsのインストールが完了です．
快適なEmacs環境で快適に作業していきましょう！！
[^1]: [2018.stateofjs.com/other-tools/#text_editors](https://2018.stateofjs.com/other-tools/#text_editors)

# おすすめのEmacsプラグイン
Emacsのインストールだけでは味気ないので，今時なEmacsプラグインと，自分のおすすめEmacsのプラグインの紹介でもしたいと思います．

## dumb-jump
dumb-jump[^2]は，IDEなどによくある，関数の定義元にジャンプという機能を提供するプラグインです．
dumb-jumpは40弱の言語に対応しており，手軽に使うことが出来ます．
Emacsで定義元にジャンプと言えば，[etags](https://www.gnu.org/software/emacs/manual/html_node/emacs/Create-Tags-Table.html)などを思い浮かべる方も多いと思います．
etagsとdumb-jumpの最大の違いは，事前にインデックスの作成を行わずに使用可能だという点です．
インデックスを作成せずにどうやってジャンプするのかと言うと，正規表現を使います．
正規表現でgrepコマンドやagコマンド[^3]，rgコマンド[^4]を用いて，定義元を検索し，ジャンプすることが出来ます．(ripgrepが個人的にはもっとも高速でおすすめです)

[^2]:  [GitHub - jacktasia/dumb-jump: an Emacs "jump to definition" package](https://github.com/jacktasia/dumb-jump)
[^3]: [ggreer/the_silver_searcher: A code-searching tool similar to ack, but faster.](https://github.com/ggreer/the_silver_searcher)
[^4]: [BurntSushi/ripgrep: ripgrep recursively searches directories for a regex pattern](https://github.com/BurntSushi/ripgrep)

## magit
magit[^5]はEmacs上で動作するgitクライアントです．
magitのためにEmacsを使っている人すら居るのじゃないかというくらい現代では必須のプラグインです．
melpaのダウンロード数でも，ライブラリを除けばもっともインストールされているプラグインです．
magitの解説だけで1記事書けてしまうので，ぜひ[[Emacs] magitチュートリアル - Qiita](https://qiita.com/maueki/items/70dbf62d8bd2ee348274)あたりを見て，使ってみて下さい．
まよったらとりあえず，magit-status関数を呼び出して"?"キーを入力すれば良いと思います．

[^5]: [GitHub - magit/magit: It's Magit! A Git porcelain inside Emacs.](https://github.com/magit/magit)

## helm
helm[^6]も今更説明は必要ないかもしれませんが，Emacsでインクリメンタルに補完や検索を行うためのインターフェースです，元々はるびきちさんのanythingからフォークして開発されています．
 現代だと，helmを参考にして作られたコマンドラインでインタラクティブな検索を行うpeco[^7]というコマンドが流行しているので，そちらを使ったことある方などは使いやすいかもしれません．

[^6]: [GitHub - emacs-helm/helm: Emacs incremental completion and selection narrowing framework](https://github.com/emacs-helm/helm)
[^7]: [peco/peco: Simplistic interactive filtering tool](https://github.com/peco/peco)

## projectile
projectile[^8]はEmacs上で使うことの出来るプロジェクト内のファイル管理ツールです．
gitやmercurial、bundler、sbを自動で認識して，その管理下のファイルへのジャンプを簡単に行うことが出来ます．
自分はhelmと連携出来るhelm-projectile[^9]を使ってさらにここから検索してジャンプしたりしてます．

[^8]: [GitHub - bbatsov/projectile: Project Interaction Library for Emacs](https://github.com/bbatsov/projectile)
[^9]: [bbatsov/helm-projectile: Helm UI for Projectile](https://github.com/bbatsov/helm-projectile)

## flycheck
flycheck[^10]はEmacs内で動作するシンタックスエラーチェッカーです．
似たような拡張としては昔からあるflymakeがありますが，flycheckの方が多くの言語に対応しているので，今ではflycheckを主に使っています．

[^10]: [GitHub - flycheck/flycheck: On the fly syntax checking for GNU Emacs](https://github.com/flycheck/flycheck)

## E2WM 
E2WM[^13]はEmacsのレイアウトを定義して，瞬時にそのレイアウトを指定して使用するための拡張機能です．
E2WMが良いのは，デフォルトで5つのレイアウトが定義されている点です．
この5つのレイアウトだけで実は自分は満足しちゃっている所も有ります．
EmacsをIDEみたいなレイアウトで使いたい！と思ったことのある人はぜひ使ってみて下さい．
バッファのヒストリーや，imenu，ファイラーなど，欲しい機能がコンパクトにまとまって居ます．

[^13]: [kiwanami/emacs-window-manager: Customizable window manager for emacs](https://github.com/kiwanami/Emacs-window-manager#code-perspective)

## howm
howm[^11]はEmacs内で動作するWikiです．
検索機能と，リンク機能，タスク管理くらいのシンプルなWikiです．
シンプルながら，使いやすく，記法も数種類だけなので，マークアップなどには自分の好きなマークアップランゲージを使用することが出来ます．
自分は，hownとorg-mode[^12]を使用して研究のメモや，実験の概要を残したりしています．
現在，自分の最もおすすめなプラグインです．
ドキュメント内の詳細なタスク管理は，org-modeの機能でまかない，プロジェクト単位の管理をhowmで行って居ます．

[^11]: [howm: Hitori Otegaru Wiki Modoki](https://howm.osdn.jp/index-j.html)
[^12]: [Org mode for Emacs – Your Life in Plain Text](https://orgmode.org/)

# まとめ
という事で，openSUSEにおいて，新しめのEmacsを手軽にインストールする方法の紹介を行いました．
その紹介に追加して，自分のおすすめEmacsプラグインの紹介も行いました．
これらのプラグインは基本的に有名な物ばっかりなので，既に知っている人には特に追加の情報は無かったと思いますが，快適にEmacsを使う上で自分には必須のプラグイン達ですので，ぜひ皆さん使ってみて下さい．
