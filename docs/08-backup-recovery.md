# 08 – Backup & Recovery

> TODO: fill this in honestly. If you don't have backups yet, say so and put it on the roadmap. Employers value people who think about recovery.

## What gets backed up

| Item | Method | Frequency | Stored where |
|---|---|---|---|
| OPNsense config | System → Configuration → Backups (XML export) | before every change | TODO |
| Pi-hole | Teleporter export | TODO | TODO |
| VMs | Proxmox `vzdump` snapshot backups | TODO | TODO |

## Recovery test

TODO: document one real restore you've done (e.g. restored OPNsense config to a fresh VM). A tested backup is the only kind that counts.

## Recovery order

1. Proxmox host
2. OPNsense VM (internet + DHCP back)
3. Pi-hole VM (DNS back; until then clients can't resolve — temporarily point DHCP DNS at OPNsense if needed)
