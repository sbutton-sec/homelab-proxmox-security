# 08 – Backup & Recovery

## Current state

| Item | Method | Stored where | Off-host copy? |
|---|---|---|---|
| OPNsense config | Automatic configuration history (12 versions) | On the firewall VM | ❌ |
| Proxmox VMs | VM snapshots | Same SSD as the VMs | ❌ |
| Pi-hole | Teleporter export | – | ❌ |
| Proxmox host config | none | – | ❌ |

### Assessment

Snapshots and config history make it easy to **roll back a bad change**, but they are not backups: they live on the same SSD as the systems they protect. A disk failure, ransomware on the host, or a failed upgrade would lose the VMs and their snapshots together. This fails the **3-2-1 rule** (3 copies, 2 media, 1 off-site).

## Recovery tests

| Date | Test | Result |
|---|---|---|
| 2026 | Rolled back OPNsense to a previous config version after the Proton VPN change ([06](06-vpn.md)) | ✅ Known-good state restored in one step |
| – | Rolled back VMs using Proxmox snapshots | ✅ |
| – | Full restore of a VM from a backup file to new storage | ⬜ not yet tested |

## Recovery order

1. **Proxmox host** – reinstall, recreate bridges from the documented config ([02](02-proxmox-setup.md)).
2. **OPNsense VM** – internet, DHCP and remote access back.
3. **Pi-hole VM** – DNS back. Until then, devices with static DNS settings can't resolve names; temporarily point them (and DHCP) at a public resolver.
4. **Wazuh VM** – monitoring back.

## Planned improvements

- Scheduled `vzdump` backups of all VMs to a second disk or NAS, with retention.
- Off-site copy of the OPNsense config XML and Pi-hole Teleporter export (encrypted).
- Back up the Proxmox host configuration (`/etc/pve`, `/etc/network/interfaces`).
- Test a full VM restore and record the result here.
- All of the above **before** the Proxmox 8 → 9 upgrade.
