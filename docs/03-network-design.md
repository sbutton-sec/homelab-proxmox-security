# 03 – Network Design

## Addressing

| Network | Subnet | Gateway | Notes |
|---|---|---|---|
| LAN | 10.66.66.0/24 (TODO confirm) | TODO (OPNsense LAN IP) | DHCP from OPNsense |
| WireGuard remote access | TODO (e.g. 10.66.70.0/24) | OPNsense | HomeWireGuard tunnel |
| Proton VPN tunnel | assigned by Proton | — | egress only |

## Static assignments

| Host | IP | Role |
|---|---|---|
| OPNsense | TODO | gateway, DHCP |
| Pi-hole | 10.66.66.50 | DNS |
| Proxmox | TODO | hypervisor management |

## Design goals

1. **Privacy from the ISP** – all LAN traffic (including DNS) leaves through Proton VPN.
2. **Filtered DNS for every device** – handed out via DHCP, so nothing needs per-device setup.
3. **No inbound exposure except WireGuard** – a single UDP port, which ignores unauthenticated packets (no response to scans).
4. **Fail closed** – if the VPN drops, LAN traffic should stop rather than leak out the plain WAN. See [06-vpn](06-vpn.md).

## Threat model (short)

| Threat | Mitigation |
|---|---|
| ISP / upstream monitoring of browsing and DNS | Proton VPN egress; DNS forced through Pi-hole → Unbound over the tunnel |
| Ads, trackers, known-malicious domains | Pi-hole blocklists |
| Devices bypassing Pi-hole with hard-coded DNS (e.g. 8.8.8.8) | TODO: NAT redirect of port 53 to Pi-hole / block outbound 53 & DoT 853 |
| Exposed admin interfaces | Web GUIs reachable from LAN only; no port forwards |
| Lost/stolen remote device | Revoke that device's WireGuard peer key |

## Future: segmentation

Planned VLANs (see [10-roadmap](10-roadmap.md)):

| VLAN | Name | Purpose |
|---|---|---|
| 10 | MGMT | Proxmox, OPNsense, switch management |
| 20 | TRUSTED | laptops, phones |
| 30 | IOT | TVs, smart devices, inverter/solar monitoring |
| 40 | LAB | intentionally vulnerable / test VMs |
