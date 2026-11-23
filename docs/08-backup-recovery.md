# 08 – Backup & Recovery

OPNsense is backed up using configuration files. 
Proxmox VMs are backed up using Snapshots.
Proxmox itself still needs to be backedup. 

## What gets backed up

| Item | Method | Frequency | Stored where |
|---|---|---|---|
| OPNsense config | System → Configuration → Backups (XML export) | before every change | TODO |
| Pi-hole | Teleporter export 
| VMs | Proxmox `vzdump` snapshot backups 

## Recovery test

Restored OPNsense config to a fresh VM. 
Restored Proxmox VMs using Snapshots

## Recovery order

1. Proxmox host
2. OPNsense VM (internet + DHCP back)
3. Pi-hole VM (DNS back; until then clients can't resolve — temporarily point DHCP DNS at OPNsense if needed)
