# 02 – Proxmox VE Setup

## Version

- Proxmox VE: TODO (e.g. 9.x)
- Install type: bare metal from ISO

## Installation steps

1. Enabled virtualisation (VT-x/AMD-V) and IOMMU (VT-d/AMD-Vi) in BIOS.
2. Installed Proxmox VE from USB, set a static management IP on the LAN.
3. Switched from the enterprise repo to the no-subscription repo and fully updated:
   ```bash
   apt update && apt full-upgrade -y
   ```
4. Created network bridges (see below).
5. Created VMs for OPNsense and Pi-hole.

## Network bridges

| Bridge | Physical NIC | Purpose |
|---|---|---|
| `vmbr0` | TODO (e.g. `enp2s0`) | LAN – Proxmox management + LAN side of OPNsense + Pi-hole |
| `vmbr1` | TODO (e.g. `enp1s0`) | WAN – connected only to OPNsense, no host IP |

Key point: **`vmbr1` (WAN) has no IP address on the Proxmox host**, so the hypervisor itself is never exposed directly to the internet. Only the OPNsense VM sits on that bridge.

Example `/etc/network/interfaces` (sanitised): [`configs/proxmox/interfaces.example`](../configs/proxmox/interfaces.example)

## Virtual machines

| VM ID | Name | OS | vCPU | RAM | Disk | NICs |
|---|---|---|---|---|---|---|
| TODO | opnsense | OPNsense 26.7 | TODO | TODO | TODO | vmbr1 (WAN), vmbr0 (LAN) |
| TODO | pihole | TODO (e.g. Debian 12) | TODO | TODO | TODO | vmbr0 |

VM settings worth noting:

- **OPNsense starts first** (`Start at boot` + boot order 1) so the network is up before other guests.
- VirtIO NICs and disks for performance.
- QEMU guest agent enabled where supported.

## Screenshots

TODO: add `screenshots/proxmox-summary.png` (redacted).
