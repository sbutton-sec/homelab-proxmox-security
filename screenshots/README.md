# Screenshots

Evidence from the live system, captured November 2026. No public IPs, keys or account details are shown.

| File | Shows | Doc |
|---|---|---|
| `04-crowdsec-metrics-summary.png` | CrowdSec activity: ~8,000 active bans, 72,000+ packets dropped, 26 local port-scan alerts | [04](../docs/04-opnsense-firewall.md) |
| `04-crowdsec-metrics-parsers.png` | CrowdSec parsing the OPNsense firewall log and detecting multi-port scans | [04](../docs/04-opnsense-firewall.md) |
| `04-crowdsec-decisions.png` | Community blocklist bans for TCP scanning (attackers' IPs) | [04](../docs/04-opnsense-firewall.md) |
| `05-unbound-dnssec-valid.png` | Correctly signed domain resolves with the `ad` flag | [05](../docs/05-dns-pihole-unbound.md) |
| `05-unbound-dnssec-invalid.png` | Deliberately broken signature rejected with `SERVFAIL` | [05](../docs/05-dns-pihole-unbound.md) |
| `05-pihole-dashboard.png` | 13 clients, ~35,000 queries a day, 13% blocked, Unbound as the only upstream | [05](../docs/05-dns-pihole-unbound.md) |
| `06-shieldsup-external-scan.png` | External scan: no open TCP ports (0–1055 all stealth) | [06](../docs/06-vpn.md) |

---

## OPNsense – CrowdSec

![CrowdSec metrics summary](https://github.com/sbutton-sec/homelab-proxmox-security/blob/main/screenshots/OPNsense%20CrowSec%20cscli%20metrics_clean.png)
*`cscli metrics` – about 8,000 active community bans, 72,000+ packets dropped since 11 Nov 2026, and 26 local port-scan alerts.*

![CrowdSec parser and scenario metrics](https://github.com/sbutton-sec/homelab-proxmox-security/blob/main/screenshots/OPNsense%20CrowSec%20cscli%20metrics%202_clean.png)
*CrowdSec reads the OPNsense firewall log and detects multi-port scans with the `pf-scan-multi_ports` scenario.*

![CrowdSec decisions list](https://github.com/sbutton-sec/homelab-proxmox-security/blob/main/screenshots/Crowdsec%20cscli%20decisions%20list%20-a%20_clean.png)
*`cscli decisions list -a` – IPs banned from the CrowdSec community blocklist for TCP scanning.*

## DNS – Pi-hole + Unbound

![DNSSEC valid signature](https://github.com/sbutton-sec/homelab-proxmox-security/blob/main/screenshots/Pihole%20Unbound%20Test2_clean.png)
*`sigok.verteiltesysteme.net` – correctly signed domain resolves with the `ad` (authenticated data) flag.*

![DNSSEC invalid signature](https://github.com/sbutton-sec/homelab-proxmox-security/blob/main/screenshots/Pihole%20Unbound%20Test_clean.png)
*`sigfail.verteiltesysteme.net` – deliberately broken signature is rejected with `SERVFAIL`.*

![Pi-hole dashboard](https://github.com/sbutton-sec/homelab-proxmox-security/blob/main/screenshots/Pihole%20Dashboard_clean.png)
*Pi-hole dashboard: 13 clients, ~35,000 queries in 24 hours, 13% blocked, 3.4M domains on blocklists. Upstream is `localhost#5335` (Unbound) only.*

## Remote access

![WireGuard from mobile](https://github.com/sbutton-sec/homelab-proxmox-security/blob/main/screenshots/WireGuard%20From%20Mobile_clean.png)
*WireGuard client connected over mobile data, with a /32 tunnel address. Keys, endpoint and port are redacted.*

## External exposure

![ShieldsUP external scan](https://github.com/sbutton-sec/homelab-proxmox-security/blob/main/screenshots/No%20Ports%20Open_clean.png)
*GRC ShieldsUP scan of the WAN address: 0 open and 0 closed ports – all 1,056 tested TCP ports (0–1055) are stealth, so the firewall gives no response to unsolicited connections.*
