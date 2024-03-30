---
layout: post
title: NSDIの論文に目を通す技術
date: 2024-03-30
tags: [雑多]
categorise: 雑多
---

NSDI 2024の季節になり、今年も論文をさらう時期になってきた。
とはいえ、全部の論文を良い感じにさらうのは面倒なので、楽をしたい。
PythonとGoogle Spreadsheetの力を借りて、楽に論文を読みたい。

楽に論文をさらうには以下のステップをおすすめしたい。
1. NSDIのページから論文の一覧を取り出しCSV形式にする
2. Google spreadsheetでCSVを開き、GOOGLETRANSLATE関数でAbstractを日本語に変換する。


## NSDIのページから論文の一覧を取り出す

これはPythonくんの力を借りる。

用意したソースコードはこちらになる。

<script src="https://gist.github.com/kimitoboku/389760710df01f69b1951df3a1d3ca64.js"></script>

このScriptは、NSDIのtechnical sessionのURLを渡すとそこに含まれて居る論文のタイトルと、Abstractを抽出してくれる。
もし、著者などが欲しければ追加で、抽出すると良い。
自分がどうせ後から、paperpileに突っ込むのでページのlinkだけ挿入している。

あとはこれを実行してあげれば良い。

```console
$ python nsdi_to_csv.py https://www.usenix.org/conference/nsdi24/technical-sessions nsdi_2024.csv
```

これで、nsdi_2024.csvというCSVが出来上がる

## Gogole Spreadsheetで論文を翻訳

あとは、このCSVを適当にGoogle DirveにUploadしてspreadsheetで開いて触るだけ。

![](http://blog.techack.net/image/google_dirve_nsdi.png "google_dirve_nsdi.png")

spreadsheetで開いたら、 `=GOOGLETRANSLATE(C2, "en", "ja")` みたいな感じで関数を使う。

![](http://blog.techack.net/image/google_spreadsheet_translate.png "google_spreadsheet_translate.png")

あとはこれを、全体にえいやと広げれば、NSDIの全ての論文のAbstractが翻訳出来る。

![](http://blog.techack.net/image/google_spreadsheet_all_translate.png "google_spreadsheet_all_translate.png")


## まとめ

とりあえず、雑に、NSDIの論文をさらう方法を紹介した。
方法としては、NSDIのカンファレンスのページをScrapingして、Google spreadsheet経由でAbstractを翻訳するだけである。
雑な方法だが、ひとまず、目を通すには便利。
