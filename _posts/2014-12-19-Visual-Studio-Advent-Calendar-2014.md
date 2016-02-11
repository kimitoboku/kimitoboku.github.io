---
layout: post
title: Visual Studio入門記録
date: 2014-12-19
tags: [雑多,Visual Studio,git]
categorise: 雑多
---

[Visual Studio Advent Calendar 2014](http://qiita.com/advent-calendar/2014/vs,"VisualStudioAdventCalendar2014-Qiita")の19日目の記事です。

なんか、みなさん技術的な事を書き書きしてましたけど、俺はそんな事をおかまない無しで、VisualStudioを使い初めたんでその感想とか雑多とか書き書きします!!

最近、大学の先輩に紹介されたりしてプログラミングっぽいバイトを初めて、そこで、C#をする事になってので、それで、VisualStudioを使い初めました。

って事で、VisualStudioをわさわさした感想を書きます!!

**ただ、私は基本的にプログラミングをした事が無い人間なのでそんな感じの人の入門してみた記事として読んで下さい!**

## VisualStudioおさわり初日
今迄は基本的にエディタはEmacsを基本的に使ってきました。そんでもって、たまにEclipseを試みたりはしたものの実質まともに使う初めて統合開発環境でした。

初めての統合開発環境なのでとりあえず、びくびくしながら使い初めました。

とりあえず、起動するとこんな感じのUIが立ち上がります。そんでもって最初に思ったのが、やっぱり、[emacs-window-manager](https://github.com/kiwanami/emacs-window-manager)は統合開発環境ぽかったんだなーって感じです。

emacs-window-managerはEmacsでウィンドウを管理してくれるような拡張機能です。そのデフォルトのUIでこんな感じのUIがあったので、あぁ、そんな感じで見えるのねーと思って使い初めました。

そんでもってまず、ツール->オプション->環境->キーボードのマップスキームを開いてEmacsのスキームが無くてここで、テンションが半分くらいに下りました。

下ったテンションで触り初めるのは悪いのでとりあえず、一旦、VisualStudioから離れまして、VisualStudioでも使えるGitの設定とかをしようって勝手に思いまして、Gitのインストールをしました。

アルバイトとか言え会社でプログラムを書くという事で、働く先の会社ではGitは使ってない感じらしいのですが、手元ではちゃんと管理したいなーと思い、そんでもって、今時な感じならGitだよなー、VisualStudioさんともちゃんと連携出来るらしいしーって事で、Gitにしました。

そんでもって、VisualStudioだけもあれかな?と思い、SourceTreeとかもついでにインストールしました。そんでもってリポジトリとかも欲しいかな?とか思ったので[前に書いた記事](http://blog.techack.net/archive/2014/11/27/cloud-storage-git/)みたいな感じにしました。

OneDriveさんの容量が最近は無料で30GB使えるらしいのでとりあえず、gitのリポジトリとスマートフォンで撮影したカメラロールとBlogの記事の画像用としか使ってないのでたぶん、永遠に大丈夫だと思います!! 
ただ、まぁ、そのうちOffice365のSoloを契約しようと思ってるのでもっと関係ない感じします。

そんでもって、Gitの設定を考えるついでに、VisualStudio向けのgitignoreを探し初めました。

そしたら、GithubのGithubのアカウントの中にgitignoreを纏めたプロジェクトがあったので、その中を漁ると[VisualStudio向けのgitignoreのテンプレート](https://github.com/github/gitignore/blob/master/VisualStudio.gitignore)があったので、これを使いたいと思います。

このあたりくらいに、VisualStudioを使うやる気が復活して来たのでVisualStudioを使うのを再開していきました。

とりあえず、最初なのでコンソールアプリケーションでこんにちは世界をやろうかと思いやってみたりしました。

そんでもって、ここで初めてVisualStudioのエディタに触りました。とりあえず、Helloってクラスを作ってそれで色々とVisualStudioさんを触てみようかなーって事で次の感じに書きました。

<iframe src="https://onedrive.live.com/embed?cid=C541F8D96BDDCFDF&resid=C541F8D96BDDCFDF%212650&authkey=AP2Hg-sKVKdl5qA" width="320" height="175" frameborder="0" scrolling="no"></iframe>

<iframe src="https://onedrive.live.com/embed?cid=C541F8D96BDDCFDF&resid=C541F8D96BDDCFDF%212649&authkey=AKxMqjKiJ6UzOHI" width="320" height="175" frameborder="0" scrolling="no"></iframe>

C#も初めてだったのでとりあえず、簡単に適当に作ってみました。Helloな感じのクラスです。

動きはまぁ、見れば分かると思います。とりあえず、たったこんだけ書いただけで、VisualStudioの補完すげぇ!!! ってなってました。

Emacsにも気の効いたauto-complete.elという良い感じの補完がありましたが、VisualStudioさんの補完はそんなもんじゃない感がこれだけですっごい伝わってきました。

そんでもって、統合開発環境だしなんか上の方にテストっていうメニューがあるくらいなのでテストも出来るんだろうと思い、テストを探し初めました。

なんか調べると、ファイル->追加->新しいプロジェクト->インストール済->Visual C#->テスト->単体テスト プロジェクト からテストの追加が出来るっぽいのでしてみました。お名前はHelloTestにしました。

そうするとソリューションエクスプローラさんにHelloTestが追加されます。そんでもってこれでテストする物を参照設定に追加します。

<iframe src="https://onedrive.live.com/embed?cid=C541F8D96BDDCFDF&resid=C541F8D96BDDCFDF%212651&authkey=AGkdNC6vnQygMqc" width="320" height="220" frameborder="0" scrolling="no"></iframe>

ここから、テストコードっぽいのを書いていきます。ここで、ちょっと、問題があったのでHelloクラスにpublicを追加しました。

そんでもってテストコード的な何かを書いていくとこんな感じになりました。

<iframe src="https://onedrive.live.com/embed?cid=C541F8D96BDDCFDF&resid=C541F8D96BDDCFDF%212652&authkey=APbN4hlcTis69jE" width="320" height="175" frameborder="0" scrolling="no"></iframe>

そして、テストの実行はメニューのテスト->実行->すべてのテスト で全ての自分がTestMethodと指定されているのが実行されて、テストが成功かどうがとかがテストエクスプローラが表示されて分かるのでこれでテストが出来ました! やった!!

こんな感じで初めてのVisualStudioおさわりの一日目は終りました。

## VisualStudioおさわりそのあと
そんでもって、ここからはその後、VisualStudioをさわって行ってした事をかきかきします。

まず、した事は、Emacsのキーバインドを探しました。探したのですが、Expressには拡張機能をインストールする事が出来ない!! って事なので、諦めてテンションが下りました。

そんでもって、次に考えたのはFontを設定しました。このままでも問題なかったのですが、AdobeのSource Code Proが好きなのでとりあえずこれに設定します。

設定のしかたは、ツール->オプション->環境->フォントおよび色から変更出来ます。

<iframe src="https://onedrive.live.com/embed?cid=C541F8D96BDDCFDF&resid=C541F8D96BDDCFDF%212659&authkey=ACgh2VJeMR2on2o" width="320" height="186" frameborder="0" scrolling="no"></iframe>

そんなこんなでしばらく、VisualStudioを使っていると、MicrosoftさんのカンファレンスのConnect();ってやつでVisualStudioのComunity版っていうプラグインが使えるのが無料で出たぞー!って事で、拡張機能とかをインストールしてみようかなーって思いインストールしてみました。

ただ、Comunity版はバイトでは使えない感じなのでそんなガチガチにカスタマイズも出来ないので、とりあえず、Emacsの拡張機能を入れてと思ったのですが、Emacsの拡張機能の検索などを行える窓から見つけられず、ぐぐるとGithubの方にあったのでインストールしてみました。

まぁ、その結果は、はい、標準な感じのEmacsとか自分でカスタマイズしているEmacsを使っている身の私に使えるわけはありませんでした!!

って事で、自分が知ってて、それでいてノリと感で使えそうなキーバインドと言えばVimなんのでVimのキーバインドを探すとVsVimっていう拡張機能がそんざいしたので使ってみる事にしました。
インストールはツール->拡張機能と更新プログラムからオンライン->VisualStudioギャラリーの検索からVsVimと検索するとみつかったのでインストールします。

<iframe src="https://onedrive.live.com/embed?cid=C541F8D96BDDCFDF&resid=C541F8D96BDDCFDF%212660&authkey=AHcAyeUmy5dkyss" width="320" height="198" frameborder="0" scrolling="no"></iframe>

そして、インストールするとこんな感じのUIになりました。

<iframe src="https://onedrive.live.com/embed?cid=C541F8D96BDDCFDF&resid=C541F8D96BDDCFDF%212661&authkey=AILLiyA3zHdjcdg" width="320" height="175" frameborder="0" scrolling="no"></iframe>

まぁ、見た目ではぜんぜん分かりませんが、使いがってといたしましては、完全にVimです!! 普通にイメージしてる通りの感じのVimです、なので、勘とノリで良い感じのエディット出来ます。初めてVisualStudioを使う人はぜひ使った方が良いと思います!!

となまぁ、こんな感じの環境でVisualStudioを使っています。


## おわりに
Advent CalendarでVisualStudioの入門記事とかそれっぽい感じの記事が無かったのでVisualStudio触りたての自分の触りたての感想を書き書きしてみました。

VisualStudioは今迄はぜんぜん使おうと思わなかったのですが、いざ使ってみると、デバッグなどがしやすかったり補完が良い感じに効きすぎたり、定義へのジャンプがきっちり出来たりと使い易かったので、これからは普通に楽しくVisualStudioを使って遊ぼうかなーとか思ってます。

あ、あと、実は12月の28日あたりが誕生日なのでそのあたりは実家に帰ってて居ないのでクリスマスあたりに[プレゼント](http://bit.ly/emaxser)を頂けると喜びます!!! >突然の乞食<
