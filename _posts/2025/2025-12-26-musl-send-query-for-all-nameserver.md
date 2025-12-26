---
layout: post
title: muslは `resolve.conf` に設定されている全てのNameserverに同時にQueryを投げる
date: 2025-12-26
tags: [DNS, Linux]
categorise: DNS
---

軽量なLinuxコンテナ用のLinuxディストリビューションとして利用される、Alpine Linuxはlibcの実装として、muslを利用している。
このmuslが自分の想像と異なる、DNS Queryを投げてくる。
具体的には、`resolve.conf` に設定されている全てのNameserverに同時にQueryを投げる動作をする。
`glibc` などでは順番にQueryを投げるので、DNS Cacheを運用しているとmuslのコンテナのみDNS Queryが多かった事があったのでちょっとびっくりした。

```c
		if (t2-t1 >= retry_interval) {
			/* Query all configured namservers in parallel */
			for (i=0; i<nqueries; i++)
				if (!alens[i])
					for (j=0; j<nns; j++)
						sendto(fd, queries[i],
							qlens[i], MSG_NOSIGNAL,
							(void *)&ns[j], sl);
			t1 = t2;
			servfail_retry = 2 * nqueries;
		}

		/* Wait for a response, or until time to retry */
		if (poll(pfd, nqueries+1, t1+retry_interval-t2) <= 0) continue;
```

[github.com/kraj/msul/src/network/res_msend.c#L184-L197](https://github.com/kraj/musl/blob/ff441c9ddfefbb94e5881ddd5112b24a944dc36c/src/network/res_msend.c#L184-L197)

retryの範囲内で、nameserversに書かれている対象全てに同時にQueryを投げている。
これにより、muslを利用していると、`resolv.conf` に書かれているnameserversの数だけQueryが増える事になる。
glibcは順番にtimeoutとretryをするのでそれを期待すると凄い数のqueryが送信される事になりびっくりする。

本件とは関係ないが、個人的には、muslはCのプログラムの性能も落ちる事が多いし、Golangとかでglibcに依存しないバイナリが吐ける言語以外では使わない方が良いかなぁと思う。
GolangのDocker Imageのサイズは小さければ小さいほど良いので、どしどし使えば良い。