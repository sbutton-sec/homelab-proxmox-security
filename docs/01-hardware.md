# 01 – Hardware

> TODO: fill in your actual parts. Recruiters like to see *why* you chose something, not just the list.

| Part | Model | Notes / why |
|---|---|---|
| CPU | TODO | e.g. must support VT-x/AMD-V and VT-d/AMD-Vi (IOMMU) for passthrough |
| RAM | TODO GB | sizing: OPNsense ~2–4 GB, Pi-hole ~1 GB, headroom for future VMs |
| Boot/VM storage | TODO | e.g. SSD/NVMe; ZFS or LVM-thin |
| NICs | TODO | how many ports; which is WAN, which is LAN |
| Case / PSU | TODO | |
| Power | TODO | e.g. on backup power / inverter so the network survives load-shedding |

## Physical topology

```
ISP ONT ── [NIC 1: WAN] Proxmox host [NIC 2: LAN] ── Switch / AP ── clients
```

TODO: confirm NIC mapping and add a photo of the build to `screenshots/`.

## Design considerations

- **Two physical NICs minimum** so WAN and LAN are physically separated before they reach the firewall VM.
- **Power resilience:** TODO — note if the host runs on an inverter/UPS and how it handles outages.
