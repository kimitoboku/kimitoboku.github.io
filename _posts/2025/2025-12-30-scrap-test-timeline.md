---
title: ScrapをClaude codeくんに実装してもらったのでテスト
layout: scrap
tags: [雑多]
categorise: 雑多
date: 2025-12-30
start_date: 2025-12-30
end_date: 2025-12-30
---

## 2025-12-30 10:05 - Specの記載

```
ZennのScrapのようなページをBlogに作成したいです。
以下のようなMarkdown formatで記事を書くとカードのような形で表示されるようにしたいです。
また、 `start_date` のみががある場合には、記事のタイトルに WIP を付けて、end_dateがある場合には記事のタイトルにDONEを付けてPage一覧に表示したいです。
また、記事のLabelをTop PageのIndexなどに追加したいです。
layout名をタグのようにして、Blogのトップページの記事のカード内に追加したいです。

---
title: Openstack Designateの調査
layout: scrap
start_date: 2024-12-20
end_date: 2024-12-30
---

## 2024-12-20 14:30 - 調査開始

start

---

## 2024-12-21 10:00 - DesignateのCodeを確認

調べた事

---

## 2024-12-21 10:00 - PowerDNSのCodeを確認

LinkとかCodeとか

---

## 2024-12-22 16:45 - 解決策発見

### 次のステップ
- [ ] パフォーマンステスト
- [ ] ドキュメント作成
```

---

## 2025-12-30 10:30 - 動作確認

```
docker compose up -d
```

--- 

## 2025-12-30 11:00 - いろいろ調整して完了

残ったタスク
- [ ] もうちょっと記事を増やしてみる
- [ ] Layoutでfilterとか出来たりすると良いかもしれない

--- 

## 2025-12-30 12:48 - index.htmlをちょっと修正

index.htmlに最初のセクションのh1しか表示されなかったので修正

```
index.htmlにlayoutがscrapだった場合に各分割secionの h1 をリスト表示に数件程度表示させる事は出来ますか?
```
