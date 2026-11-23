# 03 – Network Design

## Interfaces (OPNsense VM)

| OPNsense interface | Proxmox bridge | Physical NIC | Role |
|---|---|---|---|
| `vtnet1` | `vmbr1` | `enp4s0` | LAN |
| `vtnet2` → `pppoe1` | `vmbr2` | `enp7s0` | WAN (PPPoE) |
| `wg0` | – | – | WireGuard remote-access tunnel |
| `vtnet0` | `vmbr0` | `enp2s0` | attached, not in use |

## Addressing

| Network | Subnet | Gateway | Notes |
|---|---|---|---|
| LAN | 10.66.66.0/24 | 10.66.66.1 (OPNsense) | Servers and workstations use static IPs |
| WireGuard remote access | 10.10.10.0/24 | 10.10.10.1 (OPNsense) | One /32 per peer |

## Hosts

| Host | Type | IP | Role |
|---|---|---|---|
| OPNsense | VM 101 | 10.66.66.1 | firewall, router, WireGuard server |
| Pi-hole + Unbound | VM 102 | 10.66.66.50 | DNS filtering + recursive resolver |
| Wazuh | VM 100 | LAN | SIEM – log collection, alerting, active response |
| Docker web server | VM 105 | LAN | web hosting (stopped) |
| Proxmox VE | bare metal | 10.66.66.22 | hypervisor management |

Private RFC 1918 addresses only; no public IPs are published.

## Design goals

1. **Filtered DNS for every device** – clients use Pi-hole as their DNS server.
2. **No inbound exposure except WireGuard** – a single UDP port, which ignores unauthenticated packets.
3. **Least-privilege remote access** – remote devices reach only approved internal hosts and the internet.
4. **Visibility and response** – logs are collected centrally in Wazuh, which can block offending IPs at the firewall.
5. **Privacy from the ISP** – route LAN traffic through Proton VPN with a kill switch. Built and rolled back; see [06](06-vpn.md).

## Threat model

| Threat | Mitigation | Status |
|---|---|---|
| Ads, trackers, malware and phishing domains | Pi-hole blocklists | ✅ |
| Exposed admin interfaces | Web GUIs and SSH bound to LAN only; no port forwards | ✅ |
| Known-malicious IPs | CrowdSec, GeoIP and threat-intel aliases on the firewall | ✅ |
| Lost/stolen remote device | Revoke that device's WireGuard peer key | ✅ |
| Compromised remote device reaching the whole LAN | `WireGuardAllowedHosts` restriction | ❌ not enforced – see [04](04-opnsense-firewall.md) finding 1 |
| Undetected compromise of a host | Wazuh agents | ⚠️ partial – firewall only so far |
| Devices bypassing Pi-hole with hard-coded DNS | Redirect port 53; block outbound 53/853 | ⬜ planned |
| Lateral movement between devices | VLAN segmentation | ⬜ planned |
| ISP monitoring of traffic | Proton VPN egress | ⏸ rolled back |

## Planned segmentation

The LAN is currently flat. Planned VLANs ([roadmap](10-roadmap.md)):

| VLAN | Name | Purpose |
|---|---|---|
| 10 | MGMT | Proxmox, OPNsense, Wazuh, switch management |
| 20 | TRUSTED | laptops, phones |
| 30 | IOT | TVs, smart devices, inverter/solar monitoring |
| 40 | LAB | test VMs and web server – isolated, no access to other VLANs |

Segmentation comes **before** any intentionally vulnerable lab machines are added.
