# 07 – Hardening Checklist

Status of each control as verified on the live system, November 2026.
✅ done · ⚠️ partial / mitigated · ❌ not yet · ❓ to verify

## Proxmox VE host

| Control | Status | Evidence / notes |
|---|---|---|
| Supported version | ❌ | 8.4.21 – Proxmox VE 8 reached end of life Aug 2026. Upgrade to 9.x planned |
| Hypervisor not reachable from internet | ✅ | No IP on the WAN bridge; explicit WAN block rule to the host |
| Management UI (8006) LAN-only | ✅ | Host only has an address on the management bridge |
| Proxmox firewall enabled | ✅ | `pve-firewall status`: enabled/running |
| Two-factor authentication | ❌ | No TFA entries configured |
| Non-root admin account | ⚠️ | Separate `@pve` admin user exists; root@pam still enabled |
| SSH key-only, no root password login | ❌ | `permitrootlogin yes`, `passwordauthentication yes` |
| Unneeded services disabled | ⚠️ | rpcbind (NFS) listening – not required |
| Updates applied | ❌ | 16 pending |

## OPNsense

| Control | Status | Evidence / notes |
|---|---|---|
| Default deny inbound on WAN | ✅ | Only UDP 51820 (WireGuard) permitted |
| No port forwards | ✅ | No `rdr` rules active |
| Web GUI + SSH bound to LAN only | ✅ | `sockstat`: listening on LAN address and localhost only |
| SSH disabled when not in use | ✅ | Enabled per session, disabled at logout |
| SSH key-only, no root password login | ❌ | Root + password allowed while enabled |
| Brute-force protection | ✅ | Lockout tables active |
| Threat-intel blocking | ✅ | CrowdSec (in + out), Wazuh active response, malicious-IP alias, GeoIP |
| Bogon / private-range blocking on WAN | ✅ | Enabled |
| MFA on admin account | ❓ | |
| Firmware current | ❓ | 26.7.9 – check for updates |
| Config versioning | ✅ | 12 versions kept; used for a successful rollback |

## Pi-hole / Unbound VM

| Control | Status | Evidence / notes |
|---|---|---|
| Unbound bound to localhost only | ✅ | `127.0.0.1:5335` |
| DNSSEC validation | ✅ | Tested with dnssec.works ([05](05-dns-pihole-unbound.md)) |
| Query logging minimised | ❌ | Debug query logging still enabled ([05](05-dns-pihole-unbound.md) finding 1) |
| Pi-hole up to date | ❌ | Core/FTL one release behind |
| SSH key-only | ❓ | |
| Automatic security updates | ❓ | |
| Host firewall (ufw) | ❓ | |

## VPN

| Control | Status | Evidence / notes |
|---|---|---|
| One key pair per device | ✅ | 3 peers |
| Remote peers limited to approved hosts | ❌ | Intended via `WireGuardAllowedHosts`; bypassed by group rule ([06](06-vpn.md) finding 1) |
| Private keys never committed | ✅ | `.gitignore` + manual review |

## Monitoring

| Control | Status | Evidence / notes |
|---|---|---|
| Central SIEM | ✅ | Wazuh (VM 100) |
| Hosts reporting to SIEM | ⚠️ | OPNsense only; Proxmox, Pi-hole and workstations planned |
| Automated response | ✅ | Wazuh active response feeds an OPNsense block table |
