# 04 – OPNsense Firewall

## Version

OPNsense **26.7.9** (amd64), running as VM 101 on Proxmox.

## Interfaces

| Interface | Device | Role |
|---|---|---|
| WAN | `pppoe1` over `vtnet2` | PPPoE to ISP |
| LAN | `vtnet1` | 10.66.66.0/24, gateway 10.66.66.1 |
| WireGuard | `wg0` | 10.10.10.0/24, remote-access tunnel |

## Services running on the firewall

| Service | Listening on | Purpose |
|---|---|---|
| Web GUI | LAN + localhost only | Management – not reachable from WAN |
| SSH | LAN + localhost only (when enabled) | Management – not reachable from WAN |
| DHCP | LAN | Address assignment |
| WireGuard | UDP 51820 | Remote access, 3 peers |
| CrowdSec | localhost | Community threat intelligence; blocklists enforced in and out |
| ClamAV | localhost | Antivirus engine |
| NetFlow (Insight) | localhost | Traffic flow reporting |
| NTP | all interfaces | Time sync (WAN access blocked by firewall) |

## Defence layers (in processing order)

1. **Built-in protections**
   - Anti-spoofing: traffic claiming to be from a local subnet is dropped unless it arrives on that subnet's interface.
   - Bogon and private-network blocking on WAN (RFC 1918, CGNAT, link-local).
   - Brute-force lockout tables for SSH and the web GUI.
2. **Threat-intelligence blocking**
   - **CrowdSec** blocklists – blocked inbound *and* outbound (stops infected hosts calling out).
   - **Wazuh active response** – the SIEM pushes offending IPs into a firewall block table automatically.
   - Custom malicious-IP alias blocked on all interfaces.
3. **Interface rules** (below).

## WAN rules

| Action | Source | Destination | Port | Purpose |
|---|---|---|---|---|
| Pass | any | WAN address | UDP 51820 | WireGuard remote access |
| Pass | Cloudflare IP ranges | web server | TCP 80/443 | Web server reachable only via Cloudflare proxy (inactive – no port forward, VM stopped) |
| Block | any | web server | TCP 80/443 | Direct access to web server blocked |
| Block | any | WAN address | any | Explicit default deny (logged) |
| Block | any | WAN address | ICMP | No ping response |
| Block | any | Proxmox host | any | Hypervisor never reachable from WAN |
| Block | malicious-IP alias | any | any | Known-bad IPs |
| Block | GeoIP: selected high-risk countries | any | any | Country-level blocking (logged) |

No port forwards are active.

## LAN rules

| Action | Source | Destination | Port | Purpose |
|---|---|---|---|---|
| Pass | LAN net | any | TCP/UDP 80 | HTTP (redundant – finding 4) |
| Pass | LAN net | any | TCP 22 | SSH (redundant – finding 4) |
| Pass | LAN net | Pi-hole | UDP 3000 | Misconfigured – finding 7 |
| Pass | LAN net | any | any | General outbound |
| Block | any | any | any | Default deny (anything not from LAN net) |

## WireGuard rules

| Scope | Action | Source | Destination | Purpose |
|---|---|---|---|---|
| WireGuard group | Pass | any | any | Allow tunnel traffic (overly broad – finding 1) |
| `wg0` | Pass | WG network | `WireGuardAllowedHosts` | Peers reach only approved internal hosts |
| `wg0` | Pass | WG network | not private networks | Peers can use the internet through home |

## NAT

- **Outbound:** automatic rules for LAN, WireGuard and the firewall itself, plus manual rules for the WireGuard network.
- **Port forwards:** none.

## Management access

- Web GUI and SSH bound to the **LAN interface only** – neither is reachable from WAN.
- **SSH is enabled only when needed** and disabled at the end of each session.
- While enabled, SSH allows root login with a password (finding 6).
- **12 configuration versions** kept in config history; used to roll back the Proton VPN change ([06](06-vpn.md)).

## Audit findings

Found by reviewing the compiled ruleset (`pfctl -sr`, `pfctl -s nat`) and listening services (`sockstat`), November 2026.

| # | Finding | Risk | Fix | Status |
|---|---|---|---|---|
| 1 | A pass-all rule on the WireGuard **interface group** is evaluated before the `wg0` rules, so the `WireGuardAllowedHosts` restriction never applies | A compromised remote device has full LAN access | Disable the group rule; test peers | ⬜ planned |
| 2 | GeoIP block rules sit below the WireGuard pass rule | GeoIP doesn't restrict who can reach WireGuard | Move GeoIP blocks above it | ⬜ planned |
| 3 | No rule forces DNS through Pi-hole | Devices with hard-coded DNS bypass filtering | Redirect port 53 to Pi-hole; block outbound 53/853 | ⬜ planned |
| 4 | LAN HTTP/SSH rules are shadowed by "LAN → any" | None – housekeeping | Remove | ⬜ planned |
| 5 | Cloudflare WAN rules remain with no port forward | None while inactive | Remove, or replace with Cloudflare Tunnel | ⬜ planned |
| 6 | SSH allows root login with a password (mitigated: LAN-only, off when not in use, brute-force lockout) | Password guessing from a compromised LAN device | Key-only auth, non-root admin | ⬜ planned |
| 7 | LAN rule allows UDP 3000 to Pi-hole, but the service is TCP, and same-subnet traffic never passes the firewall | None – rule has no effect | Remove; enforce with VLANs later | ⬜ planned |
