# 01 – Hardware

I repurposed the components from my old gaming PC. Reusing hardware kept the cost down, and the platform supports the virtualisation features Proxmox needs.

## Parts

| Part | Model | Notes / why |
|---|---|---|
| CPU | Intel Core i7 (6th gen, Skylake), overclocked to a stable 4.5 GHz | Supports VT-x and VT-d (IOMMU), required for Proxmox virtualisation and PCIe passthrough |
| Motherboard | ASUS Maximus VIII Hero (Z170) | VT-d support in BIOS; spare PCIe slots for additional network cards |
| RAM | 16 GB DDR4 | Fully allocated to the running VMs – see note below |
| Storage | 512 GB SSD | Proxmox boot drive and VM storage (LVM-thin, `local-lvm`) |
| NICs | 3 × 1 Gbps | WAN, LAN and a dedicated management port |
| Power | 550 W modular PSU, on battery backup | Network stays up through load-shedding and outages |

## NIC assignment

| NIC | Role | Proxmox bridge |
|---|---|---|
| `enp7s0` | WAN – to ISP | `vmbr2` |
| `enp4s0` | LAN – to switch / AP | `vmbr1` |
| `enp2s0` | Management (Proxmox host) | `vmbr0` |

## Physical topology

```
ISP ── [enp7s0: WAN] ┐
                     ├─ Proxmox host
Switch / AP ── [enp4s0: LAN]
Switch ─────── [enp2s0: Management]
     │
  clients
```

## Design considerations

- **Three NICs** so WAN and LAN are physically separated before they reach the firewall VM, with a separate port for host management. If the firewall VM fails, the host is still reachable on the management port.
- **Power resilience** against load-shedding and outages through battery backup.

## Known limitations

- **Memory:** the running VMs are allocated the full 16 GB (Wazuh 8 GB, OPNsense 7 GB, Pi-hole 1 GB), leaving no headroom for the host or the stopped web-server VM. Planned: right-size OPNsense or add RAM ([roadmap](10-roadmap.md)).
- **Single disk:** VMs and snapshots share one SSD, so a disk failure would lose both ([08](08-backup-recovery.md)).
