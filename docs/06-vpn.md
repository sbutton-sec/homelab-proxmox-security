# 06 – VPN: WireGuard Remote Access & Proton VPN Egress

Two VPNs with two different jobs:

| VPN | Direction | Purpose | Status |
|---|---|---|---|
| WireGuard server on OPNsense | inbound | secure access to the home network from anywhere | ✅ in use |
| Proton VPN (WireGuard client on OPNsense) | outbound | hide LAN traffic and DNS from the ISP | ⏸ built, rolled back |

---

## Part A – WireGuard remote access

### Configuration

| Item | Value |
|---|---|
| Interface | `wg0` on OPNsense |
| Tunnel network | 10.10.10.0/24 – server 10.10.10.1, one /32 per peer |
| Listen port | UDP 51820 (the only port open on WAN) |
| Peers | 3 – one key pair per device |

### Why WireGuard

- **Small attack surface:** WireGuard doesn't respond to packets that aren't signed by a known peer key, so to an internet scanner the port looks closed.
- **Modern cryptography** (Curve25519, ChaCha20-Poly1305) with no cipher negotiation to misconfigure.
- **Per-device keys:** a lost or stolen device is cut off by deleting its peer; no shared password to rotate.

### Firewall and NAT

| Layer | Rule | Purpose |
|---|---|---|
| WAN | Pass UDP 51820 to WAN address | Allow tunnel handshakes |
| `wg0` | Pass WG network → `WireGuardAllowedHosts` (Pi-hole + 2 internal hosts) | Peers reach only three approved internal hosts |
| `wg0` | Pass WG network → not private networks | Peers can use the internet through home |
| Outbound NAT | WG network → WAN address | Peer internet traffic leaves via the home connection |

Design intent: **least privilege** – a remote device can browse through home and reach the Pi-hole (filtered DNS) and two internal services, but not Proxmox, the firewall GUI, Wazuh or other LAN devices. This is not yet enforced – see finding 1.

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

### Why it was rolled back
Some devices could no longer reach services they depend on once their traffic left through Proton.

### How it was rolled back
Restored a previous version from OPNsense's configuration history, returning the firewall to a known-good state in one step. Afterwards, `ifconfig` and `pfctl -s nat` confirmed no Proton interface or NAT rule remained.

### Plan to re-enable
- **Exclusion rule:** a policy-routing rule above the Proton rule that sends the affected devices out the normal WAN gateway.
- **Kill switch:** tag policy-routed LAN traffic and block tagged traffic on WAN, so a dropped tunnel fails closed instead of leaking to the ISP.
- Decide whether WireGuard peers should also exit through Proton.

---

## Audit findings

| # | Finding | Risk | Fix | Status |
|---|---|---|---|---|
| 1 | A pass-all rule on the **WireGuard interface group** is evaluated before the `wg0` rules, so the `WireGuardAllowedHosts` restriction never applies | A compromised peer device has full LAN access | Disable the group rule; test that peers reach only allowed hosts | ⬜ planned |
| 2 | GeoIP blocks are below the WireGuard pass rule | Handshakes accepted from blocked countries | Move GeoIP blocks above it | ⬜ planned |
| 3 | Duplicate WireGuard NAT rules (group-level rule, plus NAT on `wg0` itself) | None – housekeeping | Keep one outbound NAT rule for the WG network | ⬜ planned |
| 4 | External port scan not yet performed | Exposure assumed, not verified | Scan UDP 51820 from outside; expect no response | ⬜ planned |
