#!/usr/bin/env bash
# Rough scrub of an OPNsense config.xml before publishing.
# Usage: ./sanitise.sh config.xml > config.sanitised.xml
# ALWAYS review the output by hand afterwards - this is a safety net, not a guarantee.
set -euo pipefail

[[ $# -eq 1 && -f "$1" ]] || { echo "usage: $0 config.xml" >&2; exit 1; }

sed -E \
  -e 's#<(password|bcrypt-hash|privkey|prv|pubkey|psk|presharedkey|apikey|secret|authorizedkeys|otp_seed|crt|key|username)>[^<]*</\1>#<\1>REDACTED</\1>#g' \
  -e 's#<(ipaddr|subnet|gateway|endpoint|serveraddress)>([0-9]{1,3}\.){3}[0-9]{1,3}</\1>#<\1>x.x.x.x</\1>#g' \
  -e 's#([0-9a-fA-F]{2}:){5}[0-9a-fA-F]{2}#xx:xx:xx:xx:xx:xx#g' \
  "$1"
