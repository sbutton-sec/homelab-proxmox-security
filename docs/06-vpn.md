# 06 – VPN: Proton VPN Egress & WireGuard Remote Access

Two VPNs with two different jobs:

| VPN | Direction | Purpose | Status |
|---|---|---|---|
| HomeWireGuard (WireGuard server on OPNsense) | inbound | secure access to the home network from anywhere | ✅ in use |
| Proton VPN (WireGuard client on OPNsense) | outbound | hide LAN traffic and DNS from the ISP | ⏸ built, rolled back |

---

## Part A – HomeWireGuard remote access

### Configuration

| Item | Value |
|---|---|
| Interface | `wg0` on OPNsense |
| Tunnel network | 10.10.10.0/24 – server 10.10.10.1, one /32 per peer |
| Listen port | UDP 51820 (the only port open on WAN) |
| Peers | 3 – one key pair per device |
| Client DNS | TODO: 10.66.66.50 (Pi-hole)? |
| Client AllowedIPs | TODO: full tunnel (0.0.0.0/0) or split? |

### Why WireGuard

- **Small attack surface:** WireGuard doesn't respond to packets that aren't signed by a known peer key, so to an internet scanner the port looks closed.
- **Modern cryptography** (Curve25519, ChaCha20-Poly1305) with no cipher negotiation to misconfigure.
- **Per-device keys:** a lost or stolen device is cut off by deleting its peer; no shared password to rotate.

### Firewall and NAT

| Layer | Rule | Purpose |
|---|---|---|
| WAN | Pass UDP 51820 to WAN address | Allow tunnel handshakes |
| `wg0` | Pass WG network → `WireGuardAllowedHosts` | Peers reach only approved internal hosts (TODO: list) |
| `wg0` | Pass WG network → not `PrivateNetworks` | Peers can use the internet through home |
| Outbound NAT | WG network → WAN address | Peer internet traffic leaves via the home connection |

Design intent: **least privilege** – a remote device can browse the internet through home and reach only specific LAN services, not the whole network.

### Verification

- Port scan of the WAN address from outside: UDP 51820 shows `open|filtered` (no response) – indistinguishable from closed.
- Peer connected on mobile data: TODO (e.g. can reach Pi-hole admin, public IP shows home connection).

---

## Part B – Proton VPN egress (rolled back)

### Goal
Route all LAN traffic, including Unbound's DNS lookups, through Proton VPN so the ISP sees only encrypted tunnel traffic.

### What was built
1. Generated a WireGuard config in the Proton VPN dashboard.
2. Created a WireGuard instance (local) and peer (Proton endpoint) in OPNsense.
3. Assigned the tunnel as an interface and created a gateway for it.
4. LAN firewall rule with the Proton gateway set (policy-based routing).
5. Outbound NAT rule for the LAN subnet on the Proton interface.
6. Verified with ipleak.net / dnsleaktest.com: Proton IP shown, no ISP DNS servers.

### Why it was rolled back
Work machinces were unable to access resources, when I have time I will add them to an exclusion rule. 

### How it was rolled back
Restored a previous OPNsense configuration backup from *System → Configuration → History*, returning the firewall to a known-good state in one step. Confirmed afterwards that no Proton interface, gateway or NAT rule remained.

### If re-enabled
- Add a **kill switch**: tag policy-routed LAN traffic and block tagged traffic on WAN, so a dropped tunnel fails closed instead of leaking to the ISP.
- Decide whether WireGuard peers should also exit through Proton.




