# 04 – OPNsense Firewall

## Version

OPNsense **26.7.9** (amd64), running as VM 101 (`opnrouter`) on Proxmox.

## Interfaces

| Interface | Device | Role |
|---|---|---|
| WAN | `pppoe1` over `vtnet2` | PPPoE to ISP |
| LAN | `vtnet1` | 10.66.66.0/24, gateway 10.66.66.1 |
| WireGuard | `wg0` | 10.10.10.0/24, remote-access tunnel |

## Services running on the firewall

| Service | Listening on | Purpose |
|---|---|---|
| Web GUI (lighttpd) | LAN (10.66.66.1) + localhost only | Management – **not reachable from WAN** |
| SSH | LAN (10.66.66.1) + localhost only | Management – **not reachable from WAN** |
| DHCP (ISC dhcpd) | LAN | Address assignment |
| WireGuard | UDP 51820 | Remote access, 3 peers |
| CrowdSec | localhost | Community threat intelligence; blocklists enforced in and out |
| ClamAV | localhost | Antivirus engine |
| NetFlow (Insight) | localhost | Traffic flow reporting |
| NTP | all interfaces | Time sync (WAN access blocked by firewall) |

## Defence layers (in processing order)

1. **Built-in protections**
   - Anti-spoofing: traffic claiming to be from a local subnet is dropped unless it arrives on that subnet's interface.
   - **Block bogon and private networks on WAN** (RFC 1918, CGNAT 100.64.0.0/10, link-local).
   - Brute-force lockout tables for SSH and the web GUI (`sshlockout`, `virusprot`).
2. **Threat-intelligence blocking**
   - **CrowdSec** blocklists – blocked both inbound *and* outbound (stops infected hosts calling out).
   - **Wazuh active response** – the Wazuh SIEM can push offending IPs into a firewall block table automatically.
   - Custom `MaliciousIPs` alias blocked on all interfaces.
3. **Interface rules** (below).

## WAN rules (`pppoe1`)

| Action | Source | Destination | Port | Purpose |
|---|---|---|---|---|
| Pass | any | WAN address | UDP 51820 | WireGuard remote access |
| Pass | `Cloudflare_IPs` | LAN | TCP 80/443 | Web server reachable only via Cloudflare proxy (inactive – no port forward, VM stopped) |
| Block | any | web server | TCP 80/443 | Direct access to web server blocked for non-Cloudflare sources |
| Block | any | WAN address | any | Explicit default deny (logged) |
| Block | any | WAN address | ICMP | No ping response – host invisible to ping sweeps |
| Block | any | Proxmox host | any | Hypervisor never reachable from WAN |
| Block | `MaliciousIPs` | any | any | Known-bad IPs |
| Block | GeoIP: USA, UK, Germany, France, Russia, China, Iran, Seychelles | any | any | Country-level blocking (logged) |

No port forwards are active.

## LAN rules (`vtnet1`)

| Action | Source | Destination | Port | Purpose |
|---|---|---|---|---|
| Pass | LAN net | any | TCP/UDP 80 | HTTP |
| Pass | LAN net | any | TCP 22 | SSH |
| Pass | LAN net | Pi-hole | UDP 3000 | TODO: purpose |
| Pass | LAN net | any | any | General outbound |
| Block | any | any | any | Default deny (anything not from LAN net) |

## WireGuard rules

| Scope | Action | Source | Destination | Purpose |
|---|---|---|---|---|
| WireGuard group | Pass | any | any | Allow tunnel traffic |
| `wg0` | Pass | WG network | `WireGuardAllowedHosts` | Peers reach only approved internal hosts |
| `wg0` | Pass | WG network | not `PrivateNetworks` | Peers can use the internet through home |

## NAT

- **Outbound:** hybrid – automatic rules for LAN, WireGuard and the firewall itself, plus manual rules for the WireGuard network. TODO: confirm under Firewall → NAT → Outbound.
- **Port forwards:** none.

## Management access

- Web GUI and SSH bound to the **LAN interface only** – neither is reachable from WAN.
- **SSH is enabled only when needed** and disabled from the web GUI at the end of each session, so the service isn't listening most of the time.
- While enabled: port 22, root login and password authentication allowed, with brute-force lockout (`sshlockout`) active.
- MFA: TODO
- configuration backups kept on the firewall; used to roll back the Proton VPN change (see [06-vpn](06-vpn.md)).

| # | Finding | Risk | Fix | Status |
|---|---|---|---|---|
| 1 | WireGuard **group** rule passes all traffic. Group rules are evaluated before `wg0` rules, so the least-privilege `WireGuardAllowedHosts` rule never takes effect. | A compromised remote device has full LAN access | Disable the group pass-all rule; keep the `wg0` rules | ⬜ |
| 2 | GeoIP block rules sit below the WireGuard pass rule. | GeoIP doesn't restrict who can reach WireGuard | Move GeoIP blocks above the WireGuard rule (or to Floating) | ⬜ |
| 3 | No rule forces DNS through Pi-hole. | Devices with hard-coded DNS bypass filtering | NAT redirect port 53 to Pi-hole; block outbound 53/853 | ⬜ |
| 4 | LAN HTTP/SSH rules are redundant (shadowed by "LAN → any"). | None – housekeeping | Remove, or replace allow-any with specific rules | ⬜ |
| 5 | Cloudflare WAN rules remain with no port forward. | None while inactive | Remove, or document as disabled until the web server returns | ⬜ |