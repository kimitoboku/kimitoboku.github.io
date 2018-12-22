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

これは，[openSUSEアドベントカレンダー](https://adventar.org/calendars/3372)の23日目の記事です．

みなさん，最近は，Rustが流行ってますね．
うちの大学の研究室のあたりでも，Rustで実験に使うプログラムを書いてる人がいたりだとか，Rust製のツールを使用したりしています．
Rust製のツールで有名な物だと，高速なgrep系のツールであるripgrep[^1]があったりしますね．

さて，Rust製のツールを自分のLinux環境にインストールする上で，やっぱり大事なのは，パッケージングですよね．
開発環境なら，別にcargo installすればよくない？という気持ちは分かりますが，サーバにインストールとかする時などは，rpmとかでバイナリだけインストールしたいですね．

ということで，今日は，Rust製のバイナリをカラーリングして表示したり，C言語の配列に変換したりするツールを使って，パッケージングの練習をしていきましょう．

[^1]: [BurntSushi/ripgrep: ripgrep recursively searches directories for a regex pattern](https://github.com/BurntSushi/ripgrep)
[^2]: [sitkevij/hex: 🔮 Futuristic take on hexdump, made in Rust.](https://github.com/sitkevij/hex)

## 必要ツールのインストール
openSUSEなので，とりあえず，Open Build Service(OBS)[^3]を使って行きましょう．
OBSについては，まぁ，身近のopenSUSEユーザに効いてみて下さい．

[^3]: [Welcome - openSUSE Build Service](https://build.opensuse.org/)

OBSをコマンドラインで扱うツールとしてoscコマンドがあります．
oscコマンドをインストールしましょう．
```shell
$ sudo zypper install osc
```
oscコマンドを使用するには，OBSのアカウントも必要なので，アカウントを作成して，ついでにパッケージングで使用するhomeプロジェクトも作成しましょう．

そして，rpm開発の便利ツールであるところのrpmdevtoolsをインストールしましょう．
```shell
$ sudo zypper install rpmdevtools
```

## パッケージングの開始
まず，パッケージングを行うプロジェクトのチェックアウトをします．
今回は自分のハンドルネームのkimitobokuで例示していきます．
```shell
$ osc co home:kimitoboku
$ cd home:kimitoboku
```

新しいパッケージの作成
```shell
$ osc mkpac hex
```

パッケージのディレクトリが出来るので，移動します
```shell
$ cd hex
```

specファイルの作成
```shell
$ rpmdev-newspec hex
```

ビルドに使用するリソースをhexのパッケージングディレクトリに追加します．
まず，ソースコードをダウンロードします．
```shell
$ wget https://github.com/sitkevij/hex/archive/v0.1.2.tar.gz -O hex-0.1.2.tar.gz
```
続いて，依存ライブラリをまとめてインストールします．
まず，hexのソースコードを適当なフォルダに展開します．
```shell
$ tar -vxf hex-0.1.2.tar.gz
$ cd hex-0.1.2
```

依存ライブラリをまとめるのにはcargo vendorを使用します．
Rustのパッケージングをしようということなので，cargoコマンドはインストールされていると，以下のコマンドでインストール出来ます．
```shell
$ cargo install cargo-vendor
```

Rust製のアプリケーションのソースコードディレクトリに行き以下のコマンドを実行します．
```
$ cargo vendor
$ tar -Jcf vendor.tar.xz ./vendor
```
hex-0.1.2.tar.gzとvendor.tar.xzをパッケージングディレクトリに配置します．


続いて，作成したhex.specファイルの編集を行います．
今回の内容だと，以下のようなspecになります．
重要なのは，cargo-home/configに設定を書き込んであるあたりです．
これさえ書き込んでおけば，ここを見て，依存関係を解決してくれます．
```hex.spec

Name:           hex
Version:        0.1.2
Release:        0
Summary:        hex takes a file as input and outputs a hexadecimal colorized view to stdout.
License:        MIT
Group:          Productivity/Text/Utilities
Url:            https://github.com/sitkevij/hex
Source0:        https://github.com/sitkevij/hex/archive/v%{version}.tar.gz#/%{name}-%{version}.tar.gz
Source1:        vendor.tar.xz
BuildRequires:  cargo
BuildRequires:  rust
BuildRequires:  rust-std
BuildRequires:  cmake
BuildRequires:  zlib-devel
BuildRoot:      %{_tmppath}/%{name}-%{version}-build

%description
Futuristic take on hexdump.
hex takes a file as input and outputs a hexadecimal colorized view to stdout.

%prep
%setup -q
%setup -q -D -T -a 1
mkdir cargo-home
cat >cargo-home/config <<EOF
[source.crates-io]
registry = 'https://github.com/rust-lang/crates.io-index'
replace-with = 'vendored-sources'
[source.vendored-sources]
directory = './vendor'
EOF

%build
export CARGO_HOME=$PWD/cargo-home
cargo build --release %{?_smp_mflags}

%install
export CARGO_HOME=$PWD/cargo-home
cargo install --root=%{buildroot}%{_prefix}

rm %{buildroot}%{_prefix}/.crates.toml


%files
%defattr(-,root,root)
%doc LICENSE README.md
%{_bindir}/hexrpmdev-newspec 

```

ということで，ここまで来るとあとは，ビルドするだけです．
ビルドはoscコマンドから出来ます．
```shell
$ osc build --local-package
```
とかしておくと，homeプロジェクトの設定にて，ビルド対象なものから選んで，ビルドをしてくれます．

ビルドが完了したら，/tmp以下にrpmとかも出来ていますが，OBSにコミットしましょう．
まず，チェンジログを記入して，リソースを追加してコミットします．
```shell
$ osc vc
$ osc add hex-0.1.2.tar.gz  hex.changes  hex.spec  vendor.tar.xz
$ osc commiti
```
以上で，OBSにコミットされて，ビルドはOBSが自動的にやってくれます．

# まとめ
Rust製のアプリケーションをhexを例に，パッケージングする方法について雑に書きました．
Rust製のアプリケーションは，今後も増えていくと思うので，みなさん，適当にパッケージングして公開していきましょう．
あと，OBSを使わない場合は，specファイルと，cargo vendorあたりだけ見て，rpmbuildあたりを使って下さい．
