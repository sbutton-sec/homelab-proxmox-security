# 04 – OPNsense Firewall

## Version

OPNsense 26.7.x, running as a VM on Proxmox.

## WAN – PPPoE

- WAN interface on `vmbr1`, type **PPPoE**.
- Credentials from the ISP (not stored in this repo).
- TODO: MTU/MSS values if you had to tune them (common with PPPoE: MTU 1492).

## LAN

- Static IP on `vmbr0`.
- DHCP server enabled; **DNS server option set to the Pi-hole (10.66.66.50)** so all clients use filtered DNS automatically.

## Firewall rules (LAN)

Rules are processed top-down; first match wins.

| # | Action | Source | Destination | Port | Gateway | Purpose |
|---|---|---|---|---|---|---|
| 1 | Pass | LAN net | Pi-hole | 53 | default | allow DNS to Pi-hole |
| 2 | Block | LAN net | any | 53, 853 | — | TODO: stop DNS bypass |
| 3 | Pass | LAN net | LAN net | any | default | local traffic |
| 4 | Pass | LAN net | any | any | **Proton VPN gateway** | policy-route internet out via VPN |
| — | (implicit) Block | any | any | any | — | default deny |

> TODO: export your real rules (redacted) and replace this table, or add a screenshot.

## WAN rules

| Action | Protocol | Destination | Port | Purpose |
|---|---|---|---|---|
| Pass | UDP | WAN address | TODO (WireGuard port) | HomeWireGuard remote access |

Everything else inbound is dropped by default. No port forwards.

## Outbound NAT

Set to **Hybrid/Manual** so traffic from the LAN subnet is NATed out the Proton VPN interface, not just the WAN.

## System settings

- Web GUI on HTTPS only, listening on LAN only.
- TODO: SSH disabled, or key-only from LAN.
- TODO: MFA (TOTP) enabled on the admin account.
- Firmware updated through *System → Firmware*; changelog read before major upgrades.

Sanitised config notes: [`configs/opnsense/`](../configs/opnsense/)
