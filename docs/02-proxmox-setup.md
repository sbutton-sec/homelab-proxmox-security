# 02 – Proxmox VE Setup

## Version

- Proxmox VE: 8.4.21
- Install type: bare metal from ISO

## Installation steps

1. Enabled virtualisation (VT-x) in BIOS.
2. Installed Proxmox VE from USB, set a static management IP on the spare NIC.
3. Switched from the enterprise repo to the no-subscription repo and fully updated:
   ```bash
   apt update && apt full-upgrade -y
   ```
4. Created network bridges (see below).
5. Created VMs for OPNsense and Pi-hole.

## Network bridges

| Bridge | Physical NIC | Purpose |
|---|---|---|
| `vmbr0` | `enp2s0` | VM Control – Proxmox management interface; OPNsense net0 |
| `vmbr1` | `enp4s0` | LAN – OPNsense net1, connects to the switch / AP |
| `vmbr2` | `enp7s0` | WAN – OPNsense net2 only; the host has no IP on this bridge, so Proxmox is never exposed to the internet |


Example `/etc/network/interfaces` (sanitised): [`configs/proxmox/interfaces.example`](../configs/proxmox/interfaces.example)

## Virtual machines

| VM ID | Name | OS | vCPU | RAM | Disk | NICs |
|---|---|---|---|---|---|---|
| 100 | opnsense | OPNsense 26.7 | 3 Cores  | 7GB | 20GB | vmbr1 (WAN), vmbr0 (LAN) |
| 101 | pihole | Ubuntu | 1 Core | 1GB| 20GB | vmbr0 |
|102 | Wazuh SIEM | Ubuntu | 4 Cores | 8GB | 80GB | vmbr1 (WAN)


