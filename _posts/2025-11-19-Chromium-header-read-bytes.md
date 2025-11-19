---
layout: post
title: ChromiumはHTTPのHeaderを256KBまで読み込んでくれる
date: 2025-11-19
tags: [HTTP, Network]
categorise: HTTP
---

HTTPのPerserがまずどの程度、サーバからの応答をみるべきか確認するために、Chromiumはどうなっているのか確認した。
256KBまで読み込んでくれるらしい。

```cpp
  // The number of bytes by which the header buffer is grown when it reaches
  // capacity.
  static const int kHeaderBufInitialSize = 4 * 1024;  // 4K

  // |kMaxHeaderBufSize| is the number of bytes that the response headers can
  // grow to. If the body start is not found within this range of the
  // response, the transaction will fail with ERR_RESPONSE_HEADERS_TOO_BIG.
  // Note: |kMaxHeaderBufSize| should be a multiple of |kHeaderBufInitialSize|.
  static const int kMaxHeaderBufSize = kHeaderBufInitialSize * 64;  // 256K
```
[https://github.com/chromium/chromium/blob/87bd27c78a69b4736576b3b7f8dd17055c871b08/net/http/http_stream_parser.h#L161-L169](https://github.com/chromium/chromium/blob/87bd27c78a69b4736576b3b7f8dd17055c871b08/net/http/http_stream_parser.h#L161-L169)

まず最初は4KBで確保して、その後は最大で256KBまで拡張出来る。

その他、読んで分かったHeader解析まわり無駄知識。

```cpp
std::string HttpUtil::AssembleRawHeaders(std::string_view input) {
  std::string raw_headers;
  raw_headers.reserve(input.size());

  // Skip any leading slop, since the consumers of this output
  // (HttpResponseHeaders) don't deal with it.
  size_t status_begin_offset =
      LocateStartOfStatusLine(base::as_byte_span(input));
  if (status_begin_offset != std::string::npos)
    input.remove_prefix(status_begin_offset);

```
[https://github.com/chromium/chromium/blob/75efbead8ef55821994c2889bd0bc9fe28eafcaa/net/http/http_util.cc#L687-L692](https://github.com/chromium/chromium/blob/75efbead8ef55821994c2889bd0bc9fe28eafcaa/net/http/http_util.cc#L687-L692)

Headerでstatusが来るまでのDataは無視する。


Stack Over Flowにも近い質問があったのでソースコードを確認する必要は無かった。
[Can HTTP headers be too big for browsers? - Stack Overflow](https://stackoverflow.com/questions/3326210/can-http-headers-be-too-big-for-browsers)
