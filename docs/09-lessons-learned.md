# 09 – Lessons Learned

This lab was built about three years ago. In November 2026 I audited and documented the whole setup from the live system (`pfctl`, `ss`, `sockstat`, Proxmox CLI) for this repository. The review turned up the issues below – the most useful part of the exercise.

---

### 1. A bridge that only existed in memory
**Symptom:** The Proxmox network page showed no `vmbr1`, but the OPNsense VM had a NIC attached to it and the LAN was working.
**Investigation:** `/etc/network/interfaces` had a stray `#LAN` comment but no `vmbr1` definition. `ip -br link` showed `vmbr1` was up; `bridge link` showed `enp4s0`, OPNsense's LAN NIC and the Wazuh VM attached to it.
**Root cause:** The bridge's config had been removed from the file, but the running bridge stayed up because the host hadn't rebooted.
**Fix:** Recreated `vmbr1` on `enp4s0` in the Proxmox GUI so it's written to the config again.
**Takeaway:** Running state and saved config can drift apart. A reboot would have taken down the router and the LAN. Check the config files, not just whether things currently work.

### 2. Rolling back a VPN change with config history
**Symptom:** TODO – what went wrong with Proton VPN egress.
**Fix:** Restored a previous OPNsense configuration from the built-in config history (12 versions kept), returning to a known-good state in one step.
**Takeaway:** Version every firewall change. Being able to roll back cleanly made it safe to experiment.

### 3. A firewall rule that silently did nothing
**Symptom:** WireGuard peers were meant to reach only three internal hosts (`WireGuardAllowedHosts` alias).
**Investigation:** `pfctl -sr` showed a pass-all rule on the WireGuard **interface group** loaded *above* the restrictive `wg0` rules.
**Root cause:** OPNsense evaluates group rules before interface rules, with first match winning, so the least-privilege rule was never reached.
**Fix:** Disabled the group rule; tested that peers can still reach the allowed hosts and nothing else.
**Takeaway:** Read the compiled ruleset, not just the GUI. Rule order across floating, group and interface tabs decides what actually happens.

### 4. Debug logging left on
**Symptom:** Found while reviewing the Unbound config.
**Investigation:** A `debug.conf` file still enabled `log-queries: yes` from earlier troubleshooting.
**Root cause:** A temporary troubleshooting change was never reverted.
**Fix:** Removed the file and restarted Unbound.
**Takeaway:** Debug settings undermine the privacy goal of running your own resolver. Revert troubleshooting changes when the problem is solved, and note them while they're active.

### 5. End-of-life hypervisor
**Symptom:** `pveversion` reported Proxmox VE 8.4.
**Investigation:** Proxmox VE 8 reached end of life in August 2026 and no longer receives security fixes.
**Fix:** TODO – upgrade to Proxmox VE 9 after backing up all VMs and running `pve8to9 --full`.
**Takeaway:** "It works" isn't the same as "it's supported". Track lifecycle dates for every component, including the hypervisor.

### 6. Rules for traffic that never reaches the firewall
**Symptom:** A LAN rule allowed UDP 3000 to the Pi-hole, but the service there listens on TCP 3000.
**Root cause:** Two errors: wrong protocol, and the rule could never match anyway, because traffic between hosts on the same subnet is switched directly and never passes through the router.
**Takeaway:** Know which path a packet actually takes before writing a rule for it. Segmentation (VLANs) is what makes inter-host rules enforceable – see roadmap.

### 7. Shell differences
**Symptom:** A command using `2>/dev/null` reported "SSH not configured" on OPNsense even though SSH was running.
**Root cause:** OPNsense's root shell is `csh`, where `2>` doesn't mean "redirect errors". The output was silently thrown away.
**Takeaway:** Verify a surprising result another way (`sockstat` showed `sshd` listening) before trusting it.