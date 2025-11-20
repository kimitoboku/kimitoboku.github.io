---
layout: post
title: VPNCを使ってpcfファイルからVPN接続
date: 2015-08-07
tags: [VPN,Network,雑多]
categorise: Network
---

Linuxから大学にVPNするのにVPNCを使えば簡単なのですがあんまり使ってる人を見ないのでとりあえず記事でも書いておこう。

## VPNC
VPNCは独自の設定ファイルからVPN接続を行うためのコマンドです。pcfファイルからその設定ファイルを作成するコマンドも付属している。

## VPNCのインストール

openSUSEではVPNCは公式リポジトリに存在するのでzypperコマンドでそのままインストールする事が出来ます。

> $ sudo zypper install vpnc

## pcfファイルからconfファイルの生成
大学のVPN接続のpcfファイルは学内の情報メディア基盤センターのVPNのページからダウンロードする事が出来ます。

TUT-IPSec.pcfからconfファイルを生成するには次のコマンドを使用します。

> $ pcf2vpnc TUT-IPSec.pcf > TUT-IPSec.conf

このコマンドで生成する事が出来ます。

## VPN接続
このconfファイルを使用して大学にVPN接続する事が出来ます。

> $ sudo vpnc ./TUT-IPSec.conf  
> root's password:  
> Enter username for *.*.* :  
> Enter password for hoge@*.*.* :  
> VPNC started in background (pid: 24438)...  

ここで大学基盤センターのアカウントのユーザ名とパスワードを入力する事で接続が完了します。

VPNの切断は次のコマンドで行えます。

> $ sudo vpnc-disconnect

## ちょっとしたVPNの使い方
VPNで接続した状態であると、学内のLinuxサーバにsshで接続する事が出来ます。

sshにはSOCKSプロキシを貼るための機能があります。

という事で次のコマンドをVPN接続した状態で行います。

> $ ssh -f -N -D 1080 [ID]@wlinux0.edu.tut.ac.jp

[ID]となっている所に情報メディア基盤センターのアカウントを入れこのコマンドの後にパスワードを入れる事でSOCKSプロキシとして動作させる事が出来ます。

あとはブラウザのプロキシ設定などでURLをlocalhost、ポートを1080とすると完全な学内専用のサービスにブラウザからアクセスする事が出来ます
