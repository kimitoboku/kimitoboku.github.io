---
layout: post
title: HTTP ServerでConnectionのCloseをサーバ側から実施するのを遅延させる実装がいくつかあるらしい
date: 2025-11-20
tags: [HTTP, Network]
categorise: HTTP
---

HTTPでRPCをHandlingする上で、サーバ側で処理が終わったらcloseするのではなく、それをちょっとまつ実装があるらしい。
これは、HTTPで巨大なJSONが帰って来たり、Responseがserialに処理されるなど、client側で処理に時間がかかるタイミングなどで、Clientでの例外の発生などを抑制するために使われるらし。
EnvoyとArmeriaのHTTP Serverがそう動作するっぽい。


```
    static final long DEFAULT_HTTP1_CONNECTION_CLOSE_DELAY_MILLIS = 3000;
```
[https://github.com/line/armeria/blob/a9e3e4c97372d7f802cfd958d08a44bab48030e5/core/src/main/java/com/linecorp/armeria/common/DefaultFlagsProvider.java#L103C66-L103C67](https://github.com/line/armeria/blob/a9e3e4c97372d7f802cfd958d08a44bab48030e5/core/src/main/java/com/linecorp/armeria/common/DefaultFlagsProvider.java#L103C66-L103C67)

ArmeriaはCloseを3秒感待つ。


[mitigate delayed close timeout race with connection write buffer flush - reopen #6616](https://github.com/envoyproxy/envoy/issues/6616)
Envoyは1秒待つ。

これは、WebではClientがどんな挙動をするのか分からないから面倒ではあるが、Service Mesh的な用途であれば良い実装のようだ。
具体的には、HTTPのReponseの処理中にサーバ側からCloseがされて、例外などが飛んだ時に、処理が途中でStopする可能性がある。

処理の実装が悪いという話ではあるが、おうおうにしてある、話である。

HTTPのRFCでは、サーバ側は `Connection: close` を受け取った時にcloseするのは `SHOULD` だが、Client側は `MUST` になっており、Clientが必ずCloseすることを期待している。
ただ、サーバ側のCloseを遅延させることについても言及がないため禁止されていない。

> A client that sends a "close" connection option MUST NOT send further requests on that connection (after the one containing the "close") and MUST close the connection after reading the final response message corresponding to this request.[¶](https://datatracker.ietf.org/doc/html/rfc9112#section-9.6-5)
>
>A server that receives a "close" connection option MUST initiate closure of the connection (see below) after it sends the final response to the request that contained the "close" connection option. The server SHOULD send a "close" connection option in its final response on that connection. The server MUST NOT process any further requests received on that connection.[¶](https://datatracker.ietf.org/doc/html/rfc9112#section-9.6-6)
>
>A server that sends a "close" connection option MUST initiate closure of the connection (see below) after it sends the response containing the "close" connection option. The server MUST NOT process any further requests received on that connection.[¶](https://datatracker.ietf.org/doc/html/rfc9112#section-9.6-7)
>
>A client that receives a "close" connection option MUST cease sending requests on that connection and close the connection after reading the response message containing the "close" connection option; if additional pipelined requests had been sent on the connection, the client SHOULD NOT assume that they will be processed by the server.[¶](https://datatracker.ietf.org/doc/html/rfc9112#section-9.6-8)

[RFC 9112](https://datatracker.ietf.org/doc/html/rfc9112#section-9.6-2)

