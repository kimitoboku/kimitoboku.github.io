---
layout: post
title: devcontainer/cliが便利だったので普段の開発環境にこれを使っても良いかもしれない
date: 2025-12-14
tags: [Linux, Container, Docker]
categorise: Linux
---

VS Codeを使ってないのだが、devcontainerは使いたいなぁと思っていて、存在は知っていたが使ってなかった、devcontainer cliを使ってみた。

[github.com/devcontainers/cli](https://github.com/devcontainers/cli)

devcontainersの標準化のために作られたcliという感じでめちゃくちゃ開発されているわけではないが、近年はOSSでも、devcontainerを利用して開発環境を提供してくれる事が大くなってきているため、便利そうだなぁと思っていた。
今回、devcontainerを使う必要が発生したので使ってみたら便利だったので、趣味の開発環境をdevcontainerに移しても良いなぁと思う。

devcontainerが設定されているrepoで以下のコマンドでしゅっと開発用のimageを作ってくれる。

```console
devcontainer up --workspace-folder .
```

あとは、execするだけ

```console
devcontainer exec --workspace-folder . bash
```

ファイルトとかは普通にbind mountされているので適当に外側でcodeを書いて、実行などをcontainerの中でやれば良い。
このあたりが1コマンドでちゃんとしているのが凄い良い。
ごちゃごちゃあった開発用の物とかはこれに集約しても良いかなぁって思う。

`devcontainer stop` がまだ未実装 ([PRはある](https://github.com/devcontainers/cli/pull/1041))なので、dockerでコンテナを手動でstopさせる必要がある。
少し面倒だけど、まぁ、そんなに困るほどでもない。

TypeScriptで書かれている事が少し不満、便利ツールなのだけど、持ち運びに少し不便で、dockerを呼び出しているだけなので、Goとかで書いてくれないかなぁとちょっと思う。


今回使った、envoyの開発環境の作りかた。

```console
git clone git@github.com:envoyproxy/envoy.git
cd envoy

devcontainer up --workspace-folder .
devcontainer exec --workspace-folder . bash

: login devcontainer shell
: build & test
./ci/do_ci.sh dev

: test only
bazel test
```

[Building Envoy with Bazel](https://github.com/envoyproxy/envoy/blob/main/bazel/README.md#building-envoy-with-bazel)
