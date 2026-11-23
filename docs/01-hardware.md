# 01 – Hardware

I repurposed the components from my old gaming PC. Reusing hardware kept the cost down, and the platform supports the virtualisation features Proxmox needs.

## Parts

| Part | Model | Notes / why |
|---|---|---|
| CPU | Intel Core i7 (6th gen, Skylake), overclocked to a stable 4.5 GHz | Supports VT-x and VT-d (IOMMU), required for Proxmox virtualisation and PCIe/NIC passthrough |
| Motherboard | ASUS Maximus VIII Hero (Z170) | VT-d support in BIOS; spare PCIe slots for additional network cards |
| RAM | 16 GB DDR4 | Enough for OPNsense (~2–4 GB) and Pi-hole (~1 GB), with headroom for future VMs |
| Storage | 512 GB SSD | Proxmox boot drive and VM storage. ZFS |
| NICs | 3 × 1 Gbps | Physical WAN/LAN separation for the virtual firewall, plus one spare port for management. 
| Power | 550W Modular PSU | on backup power / inverter so the network survives load-shedding |

## Physical topology

```
ISP ONT ── [NIC 1: WAN] Proxmox host [NIC 2: LAN] ── Switch / AP ── clients [NIC 3: Managment]
```

## Design considerations

- Three physical NICs minimum so WAN and LAN are physically separated before they reach the firewall VM. Backup NIC for fail safe management. 
- Power Resiliance to LoadSheeding / Outages via Battery Backup.
