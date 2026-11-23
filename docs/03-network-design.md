# 03 – Network Design

## Interfaces (OPNsense VM)

| OPNsense interface | Proxmox bridge | Physical NIC | Role |
|---|---|---|---|
| `vtnet1` | `vmbr1` | `enp4s0` | LAN |
| `vtnet2` → `pppoe1` | `vmbr2` | `enp7s0` | WAN (PPPoE, MTU 1492) |
| `wg0` | — | — | HomeWireGuard remote-access tunnel |
| `vtnet0` | `vmbr0` | `enp2s0` | not in use (Proxmox management bridge) |

## Addressing

| Network | Subnet | Gateway | Notes |
|---|---|---|---|
| LAN | 10.66.66.0/24 | 10.66.66.1 (OPNsense) | Servers and workstations use static IPs |
| WireGuard remote access | 10.10.10.0/24 | 10.10.10.1 (OPNsense) | One /32 per peer; 3 peers configured |
| Proton VPN tunnel | assigned by Proton | — | TODO: verify / re-enable |

## Hosts

| Host | Type | IP | Role |
|---|---|---|---|
| OPNsense (`opnrouter`) | VM 101 | 10.66.66.1 | firewall, router, WireGuard server |
| Pi-hole + Unbound | VM TODO | 10.66.66.50 | DNS filtering + recursive resolver |
| Wazuh | VM 100 | TODO | SIEM – log collection, alerting |
| Docker web server | VM 105 | TODO | web hosting (currently stopped) |
| Proxmox VE (`pve`) | bare metal | 10.66.66.22 | hypervisor management |

Private RFC 1918 addresses only; no public IPs are published.

## Design goals

1. **Filtered DNS for every device** – clients use Pi-hole (10.66.66.50) as their DNS server.
2. **No inbound exposure except WireGuard** – a single UDP port, which ignores unauthenticated packets (no response to scans).
3. **Secure remote access** – remote devices join the 10.10.10.0/24 tunnel network and reach the LAN as if they were at home.
4. **Visibility** – logs from hosts are collected centrally in Wazuh for monitoring and alerting.
5. **Privacy from the ISP** – route LAN traffic through Proton VPN, failing closed if the tunnel drops. TODO: status.

## Threat model (short)

| Threat | Mitigation | Status |
|---|---|---|
| Ads, trackers, known-malicious domains | Pi-hole blocklists | ✅ |
| Exposed admin interfaces | Web GUIs reachable from LAN only; no port forwards | ✅ |
| Lost/stolen remote device | Revoke that device's WireGuard peer key | ✅ |
| Undetected compromise of a host | Wazuh agents report to the SIEM | ✅ |
| Devices bypassing Pi-hole with hard-coded DNS (e.g. 8.8.8.8) | NAT redirect port 53 to Pi-hole; block outbound 53/853 | ⬜ gap – no rule in place yet |
| ISP monitoring of browsing and DNS | Proton VPN egress | TODO |

## Future: segmentation

Planned VLANs (see [10-roadmap](10-roadmap.md)):

| VLAN | Name | Purpose |
|---|---|---|
| 10 | MGMT | Proxmox, OPNsense, Wazuh, switch management |
| 20 | TRUSTED | laptops, phones |
| 30 | IOT | TVs, smart devices, inverter/solar monitoring |
| 40 | LAB | intentionally vulnerable / test VMs, Docker web server |