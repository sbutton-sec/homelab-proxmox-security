# 05 – DNS: Pi-hole + Unbound

## Why

- **Pi-hole** blocks ads, trackers, malware, phishing and ransomware domains for every device on the network, including ones where you can't install a blocker (TVs, IoT).
- **Unbound** is a local **recursive, DNSSEC-validating resolver**: instead of sending every query to Google or Cloudflare, it queries the root, TLD and authoritative servers directly. No single upstream provider sees my full DNS history, and forged (spoofed) DNS answers are rejected.

## Setup

| Item | Value |
|---|---|
| Pi-hole | v6 (Core 6.5, Web 6.6.1, FTL 6.8), IP 10.66.66.50 |
| Pi-hole listens on | port 53 (DNS), 80/443 (admin web UI) |
| Unbound | same VM, **127.0.0.1:5335 only** – not reachable from the network |
| Pi-hole upstream | `127.0.0.1#5335` |

Query path:

    client → Pi-hole :53 → (blocked? return 0.0.0.0) → Unbound 127.0.0.1:5335 → root → TLD → authoritative

Clients receive 10.66.66.50 as their only DNS server.

## Unbound hardening

| Setting | Effect |
|---|---|
| `interface: 127.0.0.1` | Only Pi-hole can query Unbound |
| `auto-trust-anchor-file` | DNSSEC validation using the root trust anchor |
| `harden-dnssec-stripped: yes` | Rejects answers where DNSSEC data was stripped (downgrade attack) |
| `harden-glue: yes` | Ignores out-of-zone glue records (cache poisoning) |
| `private-address: …` | Public names may not resolve to private IPs (DNS rebinding protection) |
| `edns-buffer-size: 1232` | Avoids IP fragmentation (DNS Flag Day 2020 recommendation) |
| `prefetch: yes` | Refreshes popular records before they expire |

## Validation

    $ dig example.com @127.0.0.1 -p 5335
    status: NOERROR   flags: qr rd ra ad      ← resolves, DNSSEC-validated (ad flag)

    $ dig fail01.dnssec.works @127.0.0.1 -p 5335
    status: SERVFAIL                          ← deliberately broken signature is rejected

    $ dig dnssec.works @127.0.0.1 -p 5335
    status: NOERROR   flags: qr rd ra ad      ← valid signature accepted

## Blocklists

**15 lists, ~3.4 million unique domains**, covering:

| Category | Sources |
|---|---|
| Ads | StevenBlack hosts, OISD Big, AdGuard Base/Mobile, anudeepND, Block List Project |
| Tracking | AdGuard Spyware (third-party, first-party, mobile) |
| Malware / ransomware | Block List Project – malware, ransomware |
| Phishing / fraud | Block List Project – phishing, abuse, redirect |
| Cryptojacking | Block List Project – crypto |

## Allow and deny lists

Aggressive blocklists break legitimate services, so the allowlist is maintained from the query log:

- **Allowlisted (regex):** Microsoft 365 / Entra ID sign-in, Outlook, Teams, OneDrive, SharePoint and Windows Update; Google sign-in and YouTube; banking, insurance and government portals; Proton; certification exam provider.
- **Denylisted (regex):** shopping and social apps (Temu, Shein, 9gag), vendor telemetry, and suspicious domains spotted in the query log.

Full lists are not published, as they reveal which personal services are in use.

