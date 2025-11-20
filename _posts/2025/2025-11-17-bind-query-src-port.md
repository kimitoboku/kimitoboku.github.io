---
layout: post
title: Bind9が反復問い合わせで利用するDNS Queryのsrc port
date: 2025-11-17
tags: [DNS, Network]
categorise: DNS
---

結論、 `/proc/sys/net/ipv4/ip_local_port_range` に指定されている範囲が利用される。

```console
$ cat /proc/sys/net/ipv4/ip_local_port_range
32768   60999
```

2の15条から16乗の範囲が一般的に許可されるらしい。

```c
isc_result_t
isc_net_getudpportrange(int af, in_port_t *low, in_port_t *high) {
	int result = ISC_R_FAILURE;
#if !defined(USE_SYSCTL_PORTRANGE) && defined(__linux)
	FILE *fp;
#endif /* if !defined(USE_SYSCTL_PORTRANGE) && defined(__linux) */

	REQUIRE(low != NULL && high != NULL);

#if defined(USE_SYSCTL_PORTRANGE)
	result = getudpportrange_sysctl(af, low, high);
#elif defined(__linux)

	UNUSED(af);

	/*
	 * Linux local ports are address family agnostic.
	 */
	fp = fopen("/proc/sys/net/ipv4/ip_local_port_range", "r");
	if (fp != NULL) {
		int n;
		unsigned int l, h;

		n = fscanf(fp, "%u %u", &l, &h);
		if (n == 2 && (l & ~0xffff) == 0 && (h & ~0xffff) == 0) {
			*low = l;
			*high = h;
			result = ISC_R_SUCCESS;
		}
		fclose(fp);
	}
#else  /* if defined(USE_SYSCTL_PORTRANGE) */
	UNUSED(af);
#endif /* if defined(USE_SYSCTL_PORTRANGE) */

	if (result != ISC_R_SUCCESS) {
		*low = ISC_NET_PORTRANGELOW;
		*high = ISC_NET_PORTRANGEHIGH;
	}

	return ISC_R_SUCCESS; /* we currently never fail in this function */
}
```

- [https://github.com/isc-projects/bind9/blob/723439908acb4522274184b49428c86551bd2937/lib/isc/net.c#L178-L219](https://github.com/isc-projects/bind9/blob/723439908acb4522274184b49428c86551bd2937/lib/isc/net.c#L178-L219)


`use-v4-udp-ports` などのoptionはconfigは動くがもう動作しないっぽい

