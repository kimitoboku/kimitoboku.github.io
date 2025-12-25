---
layout: post
title: OpenStack DesignateでPoolの値を更新したらどのように反映されるのか。
date: 2025-12-25
tags: [OpenStack, Designate, DNS]
categorise: OpenStack
---

# TL;DR
- Poolを更新するとPoolを利用している全てのZoneのSerialが更新される
- Serialが更新されるとNotifyが飛びZone転送が行なわれて全てのセカンダリーにデータだ同期される
- NSの変更などを個別に行いたい場合にはPoolの変更などを1 Zoneずつ実施する必要がある
- ただ、DesignateにPoolを操作するAPIはないので、作るかDB操作を頑張るしかない

# ここから先はCode Reading log

## Pool操作時のDesignateの動作

DesingateはZone作成時にSOAとNSレコードを作成する
- [designate/central/service.py#L736](https://github.com/openstack/designate/blob/643fa563647a5aa74ac1db84aab2d0bcffaebff0/designate/central/service.py#L736)

関数の呼び出しの長れ
create_zoen → `_create_zone` → `_create_zone_in_storage`
`_create_zone_in_storage` の中でNSレコードの作成と、SOAレコードの作成が行われる
- [designate/central/service.py#L849-L850](https://github.com/openstack/designate/blob/643fa563647a5aa74ac1db84aab2d0bcffaebff0/designate/central/service.py#L849-L850)

SOAレコードはZoneの情報とPoolのNSの情報から作成される。
`_create_soa` → `_build_soa_record`
- [designate/central/service.py#L357-L366](https://github.com/openstack/designate/blob/643fa563647a5aa74ac1db84aab2d0bcffaebff0/designate/central/service.py#L357-L366)

NNAMEはPoolのNSの値から取得される。

SOAのserialは、ZoneがUpdateされたタイミングで呼び出される。
- [designate/central/service.py#L357-L366](https://github.com/openstack/designate/blob/643fa563647a5aa74ac1db84aab2d0bcffaebff0/designate/central/service.py#L357-L366)

`increment_zone_serial` → `_update_soa`
- [designate/central/service.py#L385-L404](https://github.com/openstack/designate/blob/643fa563647a5aa74ac1db84aab2d0bcffaebff0/designate/central/service.py#L385-L404)

SOAの値を最新の値でbuildする。
MNAMEを更新したい場合には、SOAを触らなくて良い。

NSはPoolをUpdateしたら全体で更新される。
- [designate/central/service.py#L2387-L2443](https://github.com/openstack/designate/blob/643fa563647a5aa74ac1db84aab2d0bcffaebff0/designate/central/service.py#L2387-L2443)

なので、個別のZone毎にUpdateといった処理は出来ない。  
Poolを更新した瞬間にそのPoolを利用している全てのZoneがUpdateしてしまうので、結構、危険な操作になる。

PoolをUpdateしたら追加するNSと削除するNSの管理が行われて、Zone毎に順番に適用される。
この時にに、 `_update_zone_in_storage` が呼ばれるのでSerialがUpdateされ、SOAも更新される。
なので、Poolの更新をするとそのPoolを利用している全てのZoneでZone転送が行なわれる。

designate-manage `pool update`のタイミングでpoolのupdateは呼ばれるのでデプロイのタイミングで呼ばれる。
- [designate/manage/pool.py#L127-L167](https://github.com/openstack/designate/blob/643fa563647a5aa74ac1db84aab2d0bcffaebff0/designate/manage/pool.py#L127-L167)
- `update` → `_create_or_update_pool` → `_update_pool` → `self.central_api.update_pool`
    - [designate/central/rpcapi.py#L320-L321](https://github.com/openstack/designate/blob/643fa563647a5aa74ac1db84aab2d0bcffaebff0/designate/central/rpcapi.py#L320-L321)
    - [designate/central/service.py#L2387](https://github.com/openstack/designate/blob/643fa563647a5aa74ac1db84aab2d0bcffaebff0/designate/central/service.py#L2387)

なのでまとめると、Poolを更新すると、全てのZoneのNSやSOAが更新される事になる。  


## Poolの割り当て

Poolの割り当てはDesignateのPool schedulerによって行なわれる。
何も設定していないと、Default pool schedulerが利用される。
- [designate/scheduler/filters/default_pool_filter.py#L41](https://github.com/openstack/designate/blob/7c785e72c3936d89531a8866384f19172b1e1111/designate/scheduler/filters/default_pool_filter.py#L41)
    - configに書いてあるdefaultを利用する。

config中にfilterが指定してあれば、その[Pool Scheudler Filter](https://docs.openstack.org/designate/latest/admin/pool-scheduler.html)を利用出来る。

```conf
[service:central]
scheduler_filters = attribute, pool_id_attribute, fallback
```

`attribute` filterが一般的で、Zoneのattributesに応じてpoolの選択をしてくれる。
Poolを複数作ってチームだとかテナントをattributesで割り当てるのが一般的かと思う。

そして、調べた限り、1度設定したPoolを操作する、APIは無さそう。