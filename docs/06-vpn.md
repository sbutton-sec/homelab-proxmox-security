# 06 – VPN: Proton VPN Egress & WireGuard Remote Access

Two separate VPNs with two different jobs:

| VPN | Direction | Purpose |
|---|---|---|
| Proton VPN (WireGuard client on OPNsense) | outbound | hide LAN traffic and DNS from the ISP |
| HomeWireGuard (WireGuard server on OPNsense) | inbound | let my own devices securely reach the home network from anywhere |

---

## Part A – Routing all LAN traffic through Proton VPN

### Steps

1. Generated a WireGuard config in the Proton VPN account dashboard.
2. In OPNsense, created a WireGuard **instance** (local) and **peer** (Proton endpoint) from that config.
3. Assigned the tunnel as an interface and created a **gateway** for it.
4. Added a LAN firewall rule that sets the gateway to the Proton VPN gateway (policy-based routing).
5. Added an **outbound NAT** rule for the LAN subnet on the Proton VPN interface.
6. Made sure Pi-hole/Unbound traffic also leaves through the tunnel, so DNS doesn't leak to the ISP.

### Kill switch (fail closed)

TODO: describe how you stop traffic leaking via WAN if the tunnel drops. Common OPNsense approach:
- Tag LAN traffic on the policy-routing rule, and add a floating rule blocking tagged traffic on WAN, **or**
- Disable "Skip rules when gateway is down" behaviour so rules with a down gateway don't fall back to the default route.

### Verification

- `https://ipleak.net` / `dnsleaktest.com` from a LAN client shows a Proton IP and no ISP DNS servers.
- Took the tunnel down and confirmed clients lost internet instead of falling back to WAN. (TODO: confirm once kill switch is in place.)

Status: ✅ working (Nov 2026).

---

## Part B – HomeWireGuard remote access

- WireGuard server instance on OPNsense, one peer per device (phone, laptop).
- Single UDP port open on WAN; WireGuard doesn't respond to unauthenticated packets, so the port looks closed to scanners.
- Remote peers get DNS = Pi-hole, so I get ad-blocking on mobile data too.
- Lost device → delete that peer; nothing else changes.

### Next step

Route remote WireGuard clients **out through Proton VPN** as well, so a phone on public Wi-Fi gets the same privacy as the LAN. Status: 🚧 in progress.

---

## Problems hit

See [09-lessons-learned](09-lessons-learned.md).
