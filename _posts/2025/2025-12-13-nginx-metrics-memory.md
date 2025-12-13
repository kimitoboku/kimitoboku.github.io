---
layout: post
title: Nginxのreload時にmetricsはどう保持されるのか
date: 2025-12-13
tags: [HTTP, Network, Nginx]
categorise: HTTP
---

# TL;DR
NginxはreloadされてProcessが複数になった場合にも正しくMetricsが共有される  
Metricsに関してはReloadを気にしなくて良い


# 背景
HAProxyではreload時に、古いProcessへのトラヒックが一時的に残っている場合に、新しいProcessのMetricsしか取れないという問題があった。  
[Envoyではこの問題をshared memoryで解決している](https://blog.envoyproxy.io/envoy-stats-b65c7f363342)


Nginxではどのように解決しているのか情報が見つからなかったので調べる。
Nginxで統計は[http_stub_status_module](https://nginx.org/en/docs/http/ngx_http_stub_status_module.html)を用いて収集する事が出来る。
データの取得自体は、 [ngx_stat_active](https://github.com/nginx/nginx/blob/ef96f5835468ff8d40df29b0ddbc04ec1e5e1582/src/http/modules/ngx_http_stub_status_module.c#L119-L147) といった変数から呼び込んでいる。
```c
    ap = *ngx_stat_accepted;
    hn = *ngx_stat_handled;
    ac = *ngx_stat_active;
    rq = *ngx_stat_requests;
    rd = *ngx_stat_reading;
    wr = *ngx_stat_writing;
    wa = *ngx_stat_waiting;
    b->last = ngx_sprintf(b->last, "Active connections: %uA \n", ac);
    b->last = ngx_cpymem(b->last, "server accepts handled requests\n",
                         sizeof("server accepts handled requests\n") - 1);
    b->last = ngx_sprintf(b->last, " %uA %uA %uA \n", ap, hn, rq);
    b->last = ngx_sprintf(b->last, "Reading: %uA Writing: %uA Waiting: %uA \n",
                          rd, wr, wa);
    r->headers_out.status = NGX_HTTP_OK;
    r->headers_out.content_length_n = b->last - b->pos;
    b->last_buf = (r == r->main) ? 1 : 0;
    b->last_in_chain = 1;
    rc = ngx_http_send_header(r);
    if (rc == NGX_ERROR || rc > NGX_OK || r->header_only) {
        return rc;
    }
```
この `ngx_stat_active` などのメモリはどうなっているのかというとnginxの[shared memoryデータ構造の中で確保されている](https://github.com/nginx/nginx/blob/ef96f5835468ff8d40df29b0ddbc04ec1e5e1582/src/event/ngx_event.c#L606-L612)。
 ```c
    ngx_stat_accepted = (ngx_atomic_t *) (shared + 3 * cl);
    ngx_stat_handled = (ngx_atomic_t *) (shared + 4 * cl);
    ngx_stat_requests = (ngx_atomic_t *) (shared + 5 * cl);
    ngx_stat_active = (ngx_atomic_t *) (shared + 6 * cl);
    ngx_stat_reading = (ngx_atomic_t *) (shared + 7 * cl);
    ngx_stat_writing = (ngx_atomic_t *) (shared + 8 * cl);
    ngx_stat_waiting = (ngx_atomic_t *) (shared + 9 * cl);
```
そして、このshared構造体は、全てのProcessで共用なので、reload時にも同じメモリが利用される。
つまり、reload時にもMetricsは問題無く加算される。
Nginxのshared memoryは[mmapを用いて以下のように確保されている](https://github.com/nginx/nginx/blob/ef96f5835468ff8d40df29b0ddbc04ec1e5e1582/src/os/unix/ngx_shmem.c#L15-L28)。
```c
ngx_int_t
ngx_shm_alloc(ngx_shm_t *shm)
{
    shm->addr = (u_char *) mmap(NULL, shm->size,
                                PROT_READ|PROT_WRITE,
                                MAP_ANON|MAP_SHARED, -1, 0);
    if (shm->addr == MAP_FAILED) {
        ngx_log_error(NGX_LOG_ALERT, shm->log, ngx_errno,
                      "mmap(MAP_ANON|MAP_SHARED, %uz) failed", shm->size);
        return NGX_ERROR;
    }
    return NGX_OK;
}
```

そして、Nginxのreloadは以下のように行われる。
NginxはSIGHUPを受け取ると[ngx_reconfigureを1に設定する](https://github.com/nginx/nginx/blob/ef96f5835468ff8d40df29b0ddbc04ec1e5e1582/src/os/unix/ngx_process.c#L364-L367)。
そうすると[main Processはngx_spawn_processをconfigと一緒に実行しその中でforkが実行される](https://github.com/nginx/nginx/blob/ef96f5835468ff8d40df29b0ddbc04ec1e5e1582/src/os/unix/ngx_process_cycle.c#L211-L244)。
forkで作成されたProcessはshread memoryを共有するので、Nginxはreload前と後で、同じshared memory空間を利用する。  
これにより、Nginxはreloadされた場合にも、metricsのMemoryを共有出来ている。
Metricsが少なすぎる気もするがこれは、OSS版のNginxの仕様なので仕方ない。  
LBaaSを作るにはMetricsが少なすぎる。  
これは、商用版では提供さており、[1.13.10からOSS版から削除された機能である](https://nginx.org/en/docs/http/ngx_http_status_module.html)。

過去に公開されていたnginxのMetricsから[moduleを取り出したcodeもある](https://github.com/sysulq/status-nginx-module/tree/master)。
このCodeを使うとupstreamのMetricsなんかもとれたりする。  
このCodeでも同様にsharedメモリを使っている。
