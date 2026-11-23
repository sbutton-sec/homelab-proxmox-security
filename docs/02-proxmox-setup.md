# 02 – Proxmox VE Setup

## Version

- Proxmox VE **8.4.21**, installed bare metal from ISO
- Proxmox VE 8 reached end of life in August 2026; upgrade to 9.x is planned ([roadmap](10-roadmap.md))

## Installation steps

1. Enabled virtualisation (VT-x) in BIOS.
2. Installed Proxmox VE from USB and set a static management IP on the management NIC.
3. Switched from the enterprise repo to the no-subscription repo and fully updated:
   ```bash
   apt update && apt full-upgrade -y
   ```
4. Created network bridges (see below).
5. Created the VMs.

## Network bridges

| Bridge | Physical NIC | Purpose |
|---|---|---|
| `vmbr0` | `enp2s0` | Management – Proxmox host interface |
| `vmbr1` | `enp4s0` | LAN – OPNsense LAN interface and LAN-side VMs |
| `vmbr2` | `enp7s0` | WAN – OPNsense only; **the host has no IP on this bridge**, so Proxmox is never exposed to the internet |

Example `/etc/network/interfaces` (sanitised): [`configs/proxmox/interfaces.example`](../configs/proxmox/interfaces.example)

## Virtual machines

| VM ID | Name | OS | vCPU | RAM | Disk | Bridges | State |
|---|---|---|---|---|---|---|---|
| 100 | Wazuh-Siem | Ubuntu | 4 | 8 GB | 80 GB | `vmbr1` | running |
| 101 | opnrouter | OPNsense 26.7 | 3 (host CPU type) | 7 GB | 20 GB | `vmbr0`, `vmbr1` (LAN), `vmbr2` (WAN) | running |
| 102 | Pi-hole | Ubuntu 24.04 LTS | 1 | 1 GB | 120 GB | `vmbr0` | running |
| 105 | WebserverDocker | – | – | 6 GB | 200 GB | – | stopped |

All VMs use VirtIO network and disk devices.
