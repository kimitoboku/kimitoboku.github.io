---
layout: post
title: dnsdistのfirstAvailableがqps指定されてない時にどう動くのか
date: 2025-11-17
tags: [DNS, Network]
categorise: DNS
---

QPSを使って、一番最初の可用性の高いDNSにbalancingするよと書かれているが、QPSがない場合だったりだとか、それがどう動作するのかについては書かれてないので確認する。

> ### `firstAvailable`[](https://www.dnsdist.org/guides/serverselection.html#firstavailable "Permalink to this headline")
>
>The `firstAvailable` policy, picks the first available server that has not exceeded its QPS limit, ordered by increasing ‘order’. If all servers are above their QPS limit, a server is selected based on the `leastOutstanding` policy. For now this is the only policy using the QPS limit.
>
> [Loadbalancing and Server Policies](https://www.dnsdist.org/guides/serverselection.html)

公式の、docにはQPSの定義がserverにない時の動作は未記載だった。

とりあえず、試したら期待通りに(最初に登録したやつがDownしたら次のやつにトラヒックが流れる形で)動いたCode

```lua
setLocal("0.0.0.0:53")    
setACL({"0.0.0.0/0", "::/0"})
  
newServer{
  address = "127.0.0.1:1053",
  name = "test1",
  checkType = "A",
  checkName = "example.com.",
  checkInterval = 2,  
  maxCheckFailures = 2,         
  tcpCheck = true          
}
  
newServer{
  address = "127.0.0.1:2053",
  name = "test2",
  checkType = "A",
  checkName = "example.com.",
  checkInterval = 2,
  maxCheckFailures = 2,
  tcpCheck = true
}
  
setServerPolicy(firstAvailable)
```



まず、orderがない場合のserverの順序って何?

```cpp
void ServerPool::addServer(std::shared_ptr<DownstreamState>& server)
{
  auto count = static_cast<unsigned int>(d_servers.size());
  d_servers.emplace_back(++count, server);
  /* we need to reorder based on the server 'order' */
  std::stable_sort(d_servers.begin(), d_servers.end(), [](const std::pair<unsigned int,std::shared_ptr<DownstreamState> >& lhs, const std::pair<unsigned int,std::shared_ptr<DownstreamState> >& rhs) {
      return lhs.second->d_config.order < rhs.second->d_config.order;
    });
  /* and now we need to renumber for Lua (custom policies) */
  size_t idx = 1;
  for (auto& serv : d_servers) {
    serv.first = idx++;
  }

  updateConsistency();
}

```

- [https://github.com/PowerDNS/pdns/blob/f324028a23107ba154b744d4681891f462883ba0/pdns/dnsdistdist/dnsdist-backend.cc#L1058-L1074](https://github.com/PowerDNS/pdns/blob/f324028a23107ba154b744d4681891f462883ba0/pdns/dnsdistdist/dnsdist-backend.cc#L1058-L1074)
- 安定sort(`std::stable_sort`)でorderを入れてsortしているので追加している物が先
- なので、newServerのlua codeは上の行から順番に評価されるので、書かれている順序がserversの順序になる。  


QPSがない場合の動作って?

```cpp
std::optional<ServerPolicy::SelectedServerPosition> firstAvailable(const ServerPolicy::NumberedServerVector& servers, const DNSQuestion* dnsQuestion)
{
  for (const auto& server : servers) {
    if (server.second->isUp() && (!server.second->d_qpsLimiter || server.second->d_qpsLimiter->checkOnly())) {
      return server.first;
    }
  }
  return leastOutstanding(servers, dnsQuestion);
}
```

- firstAvailableはqpsが許可される最初の物を利用する(serverがsortされているのでorder順番 or 追加順で前から選ばれる)
- [https://github.com/PowerDNS/pdns/blob/52db76c3cb35de55f9a598d897eeb3938c92707b/pdns/dnsdistdist/dnsdist-lbpolicies.cc#L83-L91](https://github.com/PowerDNS/pdns/blob/52db76c3cb35de55f9a598d897eeb3938c92707b/pdns/dnsdistdist/dnsdist-lbpolicies.cc#L83-L91)
- `!server.second->d_qpsLimiter` の動作しだいで、qpsが定義されていなかったら、常にtrueになりそう
    


Serverの型は `DownstreamState`なのでその中の `d_qpsLimiter` を確認する

```cpp
public:
  std::shared_ptr<TLSCtx> d_tlsCtx{nullptr};
  std::vector<int> sockets;
  StopWatch sw;
  std::optional<QPSLimiter> d_qpsLimiter;
```

- https://github.com/PowerDNS/pdns/blob/652d49ede7486a0472ee52a99b7dc9769c7b4931/pdns/dnsdistdist/dnsdist.hh#L713
-  `optional` を使っている
    - optionalなので、noneの場合はfalseになる
    - [optional - cpprefjp C++日本語リファレンス](https://cpprefjp.github.io/reference/optional/optional.html)
    - https://cpprefjp.github.io/reference/optional/nullopt_t.html
    - nulloptになり、これは有効な値ではないのでfalseになる
- なので、`(!server.second->d_qpsLimiter || server.second->d_qpsLimiter->checkOnly())` はqpsのlimitが設定されていなければ常にTrue


という事で、qpsを設定しなえれば、H/CにDownした場合に次のサーバにリクエストという事になる。
ので、このconfigは期待通りの動作になっている。
ただ、出来ればconfigの読みやすさのためにnewServerにorderを追加しても良いと思う。

