# 05 – DNS: Pi-hole + Unbound

## Why

- **Pi-hole** blocks ads, trackers and known-malicious domains for every device on the network, including ones where you can't install an ad blocker (TVs, IoT).
- **Unbound** acts as a local **recursive resolver**: instead of sending every query to Google/Cloudflare, it asks the root servers and authoritative servers directly. No single upstream provider has my complete DNS history.

## Setup

| Item | Value |
|---|---|
| VM OS | TODO |
| Pi-hole IP | 10.66.66.50 |
| Unbound | same VM, listening on `127.0.0.1#5335` |
| Pi-hole upstream | `127.0.0.1#5335` only (all public upstreams unticked) |

Query path:

```
client → Pi-hole (:53) → Unbound (127.0.0.1:5335) → root / TLD / authoritative servers
                                                     (leaves via Proton VPN tunnel)
```

Example Unbound config: [`configs/pihole/unbound-pi-hole.conf.example`](../configs/pihole/unbound-pi-hole.conf.example)

## Validation

```bash
# Unbound resolves on its own
dig example.com @127.0.0.1 -p 5335

# DNSSEC: this should FAIL (SERVFAIL)
dig fail01.dnssec.works @127.0.0.1 -p 5335

# DNSSEC: this should succeed with the 'ad' flag
dig dnssec.works @127.0.0.1 -p 5335
```

TODO: paste your actual output (redacted) here — it proves it works.

## Blocklists

- TODO: list the adlists you use and roughly how many domains are blocked.
- TODO: note any domains you had to allowlist and why (shows troubleshooting).
