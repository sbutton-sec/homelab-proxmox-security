# 07 – Hardening Checklist

Tick only what you've actually done. An honest partial list beats an inflated one; interviewers will ask about it.

## Proxmox host

- [ ] Management interface reachable from LAN only (no WAN IP on host)
- [ ] Root login with strong password + **TOTP 2FA** in Datacenter → Permissions → Two Factor
- [ ] Non-root admin user for day-to-day use
- [ ] SSH key authentication only (`PasswordAuthentication no`)
- [ ] Proxmox firewall enabled at datacenter level
- [ ] Regular `apt update && apt full-upgrade`
- [ ] Unused services disabled

## OPNsense

- [ ] Default-deny on WAN, no port forwards except WireGuard
- [ ] GUI on HTTPS, LAN interface only
- [ ] Admin TOTP enabled
- [ ] SSH disabled or key-only from LAN
- [ ] Anti-lockout rule reviewed
- [ ] Config backup before every change
- [ ] Firmware kept current

## Pi-hole VM

- [ ] Admin password set
- [ ] OS auto security updates (`unattended-upgrades`)
- [ ] SSH key-only
- [ ] Only ports 53 (and web admin from LAN) reachable

## VPN

- [ ] One WireGuard key pair per device
- [ ] AllowedIPs restricted per peer
- [ ] Private keys never leave the device / never committed

## Verification

- [ ] External port scan of WAN IP (e.g. `nmap` from outside) shows nothing open except — and silently — WireGuard
- [ ] Internal `nmap` of LAN to confirm only expected services are listening

TODO: add redacted nmap output.
