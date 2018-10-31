---
layout: post
title: systemd-nspawnでopenSUSEを使う
date: 2018-01-31
tags: [Linux,openSUSE,container]
categorise: 
---

systemd-nspawnを用いてopenSUSEのコンテナを作成する方法がまとめられていなかったので，まとめます．

# リポジトリの準備
まず，コンテナ用のルートディレクトリを作成する．

```
# mkdir -p /srv/containers/opensuse_leap42
```

このディレクトリ以下にopenSUSEをインストールして行きます．
まず，リポジトリの追加とリポジトリの更新を行います．
zypperコマンドの--rootオプションはルートディレクトリを指定するオプションです，．

```
# zypper --root /srv/containers/opensuse_leap42 addrepo http://download.opensuse.org/distribution/leap/42.3/repo/oss/ repo-oss
# zypper --root /srv/containers/opensuse_leap42 addrepo http://download.opensuse.org/distribution/leap/42.3/repo/non-oss repo-non-oss
# zypper --root /srb/containers/opensuse_leap42 refresh
```

これにより以下のようなディレクトリ構造で、リポジトリデータが格納される。

```
.
├── etc
│   └── zypp
│       └── repos.d
└── var
    ├── cache
    │   └── zypp
    ├── lib
    │   └── rpm
    ├── log
    │   └── zypp
    └── run
        └── zypp.pid

```

# openSUSEのインストール
続いて，openSUSEをインストールして行きます．
以下のコマンドを用いて，最低限必要なパッケージをインストールします．

```
# zypper --root /srv/containers/opensuse_leap42 install openSUSE-release
# zypper --root /srv/containers/opensuse_leap42 install bash procps coreutils emacs
```

システムがインストールされると，以下のような何時も見るルートディレクトリの構造になります．

```
.
├── bin
├── boot
├── dev
├── etc
├── home
├── lib
├── lib64
├── mnt
├── opt
├── proc
├── root
├── run
├── sbin
├── selinux
├── srv
├── sys
├── tmp
├── usr
└── var
```

# コンテナの起動
systemd-nspawnコマンドを用いて，コンテナを機動します．
Dオプションはコンテナのルートディレクトリを指定します．

```
# systemd-nspawn -b -D /srv/containers/opensuse_leap42
```
