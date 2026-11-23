# 10 – Roadmap

Consolidated from the audit findings in docs 04–09.
✅ done · 🚧 in progress · ⬜ planned

## Done

| Item | Doc |
|---|---|
| Proxmox host built from repurposed hardware; WAN bridge with no host IP | [01](01-hardware.md), [02](02-proxmox-setup.md) |
| Virtualised OPNsense firewall: PPPoE WAN, default deny, no port forwards | [04](04-opnsense-firewall.md) |
| Pi-hole + Unbound recursive resolver with DNSSEC validation, 15 blocklists (~3.4M domains) | [05](05-dns-pihole-unbound.md) |
| WireGuard remote access (3 peers, per-device keys) | [06](06-vpn.md) |
| Threat-intel blocking: CrowdSec (in + out), GeoIP, malicious-IP alias, bogons | [04](04-opnsense-firewall.md) |
| Wazuh SIEM with active response feeding an OPNsense block table | [04](04-opnsense-firewall.md), [07](07-hardening.md) |
| Firewall config versioning – used for a successful rollback | [06](06-vpn.md), [08](08-backup-recovery.md) |
| Full audit and documentation of the live system | [09](09-lessons-learned.md) |

## Priority 1 – Risk reduction

| Status | Item | Why | Doc |
|---|---|---|---|
| ⬜ | Persist `vmbr1` in `/etc/network/interfaces` | A reboot would take down the LAN and router | [09](09-lessons-learned.md) |
| ⬜ | Disable the WireGuard group pass-all rule so `WireGuardAllowedHosts` is enforced | A remote peer currently has full LAN access | [04](04-opnsense-firewall.md), [06](06-vpn.md) |
| ⬜ | Off-host backups: scheduled `vzdump` to a second disk/NAS + off-site copy of firewall and Pi-hole config | VMs and snapshots share one SSD | [08](08-backup-recovery.md) |
| ⬜ | Back up the Proxmox host config | Host rebuild currently from documentation only | [08](08-backup-recovery.md) |
| ⬜ | Upgrade Proxmox VE 8 → 9 (after backups; run `pve8to9 --full` first) | Proxmox VE 8 is end of life – no security fixes | [07](07-hardening.md), [09](09-lessons-learned.md) |
| ⬜ | Fix RAM over-allocation – right-size OPNsense (7 GB → ~4 GB) or add RAM | All 16 GB assigned; no room for the host or VM 105 | [01](01-hardware.md) |

## Priority 2 – Hardening

| Status | Item | Doc |
|---|---|---|
| ⬜ | 2FA (TOTP) on Proxmox and OPNsense admin accounts | [07](07-hardening.md) |
| ⬜ | SSH key-only, no root password login – Proxmox and OPNsense | [04](04-opnsense-firewall.md), [07](07-hardening.md) |
| ⬜ | Apply pending Proxmox updates and Pi-hole updates | [05](05-dns-pihole-unbound.md), [07](07-hardening.md) |
| ⬜ | Disable rpcbind on Proxmox (NFS not used) | [07](07-hardening.md) |
| ⬜ | Move GeoIP blocks above the WireGuard pass rule | [04](04-opnsense-firewall.md) |
| ⬜ | Force DNS through Pi-hole: redirect port 53, block outbound 53/853 | [03](03-network-design.md), [04](04-opnsense-firewall.md) |
| ⬜ | Unbound: remove debug logging, restore `192.168.0.0/16` to `private-address` | [05](05-dns-pihole-unbound.md) |
| ⬜ | Narrow broad CDN/cloud allowlist entries to specific hostnames | [05](05-dns-pihole-unbound.md) |
| ⬜ | Pi-hole VM: verify SSH config, automatic updates, host firewall | [07](07-hardening.md) |
| ⬜ | External port scan of the WAN address to verify exposure | [06](06-vpn.md) |

## Priority 3 – Projects

| Status | Item | Skills | Doc |
|---|---|---|---|
| ⬜ | VLAN segmentation: MGMT / TRUSTED / IOT / LAB | Segmentation, inter-VLAN rules | [03](03-network-design.md) |
| ⬜ | Deploy Wazuh agents to Proxmox, Pi-hole and workstations | SIEM coverage, detection | [07](07-hardening.md) |
| ⬜ | Re-enable Proton VPN egress with a device exclusion rule and kill switch | Policy routing, fail-closed design | [06](06-vpn.md) |
| ⬜ | Suricata IDS/IPS on OPNsense | Intrusion detection | – |
| ⬜ | Isolated LAB VLAN with Kali and vulnerable VMs – **only after segmentation** | Penetration testing | [03](03-network-design.md) |
| ⬜ | Web server (VM 105) via Cloudflare Tunnel instead of open WAN ports | Zero inbound exposure | [04](04-opnsense-firewall.md) |
| ⬜ | Automate config backups and checks with Python / Ansible | Scripting, automation | – |

## Housekeeping

| Status | Item | Doc |
|---|---|---|
| ⬜ | Remove redundant LAN rules (HTTP, SSH, UDP 3000) | [04](04-opnsense-firewall.md) |
| ⬜ | Remove inactive Cloudflare WAN rules | [04](04-opnsense-firewall.md) |
| ⬜ | Consolidate duplicate WireGuard NAT rules | [06](06-vpn.md) |
