# 09 – Lessons Learned & Troubleshooting

This is the most useful page in the repo for an interviewer: it shows how I think when things break.

Use this format for each issue:

---

### Issue: TODO short title (e.g. "No internet after routing LAN through Proton VPN")

**Symptom:** what you saw.
**Investigation:** what you checked (logs, `ping`, `traceroute`, `dig`, firewall live view, packet capture).
**Root cause:** what was actually wrong.
**Fix:** what you changed.
**Takeaway:** what you'd do differently / what it taught you.

---

### Ideas for entries you've likely already hit

- PPPoE WAN setup on a virtualised firewall (MTU, VLAN tag from ISP, NIC mapping)
- Getting Proton VPN policy routing working (gateway, outbound NAT, rule order)
- DNS not resolving after pointing Pi-hole at Unbound
- DNS leaking to the ISP while traffic went through the VPN
- Locking yourself out of a GUI and recovering via the Proxmox console
- Getting WireGuard remote clients to reach the LAN / use Pi-hole
