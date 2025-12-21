---
layout: post
title: Podmanがresolv.confをうまく読み込めなかったらDefaultのDNSでは8.8.8.8を使う
date: 2025-12-21
tags: [Linux, container, podman]
categorise: Linux
---

PodmanのDNS設定はDNSの設定を読みとれたり出来なかった場合は、defaultで8.8.8.8(Google Public DNS)を利用するらしい。

```go
var (
	// Note: the default IPv4 & IPv6 resolvers are set to Google's Public DNS.
	defaultIPv4Dns = []string{"nameserver 8.8.8.8", "nameserver 8.8.4.4"}
	defaultIPv6Dns = []string{"nameserver 2001:4860:4860::8888", "nameserver 2001:4860:4860::8844"}
	ipv4NumBlock   = `(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)`
	ipv4Address    = `(` + ipv4NumBlock + `\.){3}` + ipv4NumBlock
```

[https://github.com/containers/common/blob/a5ccdae846b629b5ceaefa6ffd5c6511409c3487/libnetwork/resolvconf/resolvconf.go#L20-L22](https://github.com/containers/common/blob/a5ccdae846b629b5ceaefa6ffd5c6511409c3487/libnetwork/resolvconf/resolvconf.go#L20-L22)

なので、何も設定せずにいると利用すると、8.8.8.8を利用してしまう事がある。
(一応、 `/etc/resolv.conf` などを見てくれる挙動をしてくれる事もあるようだが、いったんLocalにDNSが向いてるような状態だったりすると、default DNSが利用されるっぽい)
個人のLaptopなどで開発してる時は問題ないが、会社で使うと内部向けのZoneが引けなくなったりして困る。

とりあえず、会社で使う時とかは、 `/etc/containers/containers.conf` を更新しておいた方が無難。

```/etc/containers/containers.conf
dns_servers = [
    '127.0.0.1',
    '127.0.0.2'
]

dns_searches = [
    'hoge.internal
]
```

普段は問題ないがたまに問題が起きる人がいるのでサポートする時には知識として知っておいた方が良い。
