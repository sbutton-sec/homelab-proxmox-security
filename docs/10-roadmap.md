# 10 – Roadmap

| Status | Item | Security value |
|---|---|---|
| ✅ | Proxmox host with virtual OPNsense | |
| ✅ | Pi-hole + Unbound recursive DNS | DNS privacy, filtering |
| ✅ | All LAN traffic via Proton VPN | ISP privacy |
| ✅ | WireGuard remote access | secure remote access, no exposed services |
| 🚧 | Route WireGuard clients via Proton VPN | privacy on untrusted networks |
| ⬜ | VPN kill switch, verified | fail-closed design |
| ⬜ | Force all DNS to Pi-hole (block/redirect port 53, 853) | prevents bypass |
| ⬜ | VLAN segmentation: MGMT / TRUSTED / IOT / LAB | lateral-movement containment |
| ⬜ | Suricata IDS/IPS on OPNsense | intrusion detection |
| ⬜ | Central logging (syslog → Wazuh or Graylog) | SIEM / blue-team practice |
| ⬜ | Automated Proxmox backups + tested restore | resilience |
| ⬜ | LAB VLAN with Kali + vulnerable VMs (Metasploitable, DVWA) | pentest practice, isolated |
| ⬜ | Infrastructure as code (Ansible / Python scripts for config) | automation |
