---
layout: post
title: dabble.meが何時の間にか複数の画像のuploadに対応していた
date: 2025-12-28
tags: [雑多, 日記]
categorise: 雑多
---

自分は3年前程度から [dabble.me](https://dabble.me/) という日記サービスを利用しています。
`dabble.me` はメールに返信する形で日記を書けるサービスです。
毎日決まった時間にメールが来て、1日そのメールの返信に起きた事や考えた事のメモって、翌朝そのメールの返信を送信するという形で日記を書いています。

この `dabble.me` なのですが、自分が使い初めた頃には、1エントリーにつき1枚の画像を添付する事が出来ました。
そのため、返信に添付する画像の選別などにちょっと悩む事がありました。
ただ、何時のまにか5枚まで添付出来るようになっておりもはやこの問題に悩む事がなくなりました。

`dabble.me` を利用している第一の理由はメール形式で自分の生活リズムにあっているからなのですが、第二の理由として[OSSとしてコードが公開されている](https://github.com/parterburn/dabble.me/tree/main)という点があります。
なので、何時、対応したのか軽く調べてみました。

まず、Docの更新は、2023年の5月に更新されていました。

- [Update marketing language: Commit eb71ee8](https://github.com/parterburn/dabble.me/commit/eb71ee895151a1b379afa2846def68e38b45f873)

そうですね、つまり1年半くらい前から出来たみたいです。(1年半も余分に悩んでいたのか)

2023年に、MailgunのAPIとして、複数のfileの取得に対応したようです。

- [Collage multiple files + fix tagger: Commit 8328ce0](https://github.com/parterburn/dabble.me/commit/8328ce064ac5cd8f68480d89b812c9b91960f941)

ただ、5件というのが個人的にCodeを見つける事が出来ませんでした。
自分の目では7件取得しているように見えるのですが、5件というのは何処から来ているのかは分かりませんでした。

- [github.com/parterburn/dabble.me/dabble.me/app/lib/email_processor.rb#L101C13-L101C32](https://github.com/parterburn/dabble.me/blob/5251541e2899bb8ed91cdf411820bc016e938306/app/lib/email_processor.rb#L101C13-L101C32)

添付のURLのFilterした物の7件をとってきているように見える。

自分の、Rails力がないので、GrepとDocから探せるのはここまででした。

自堕落で日記が続かない人もメールの返信は出来ると思うので続けられます!
しかも、OSSでソースコードも読める!
`dabble.me` はいい!
