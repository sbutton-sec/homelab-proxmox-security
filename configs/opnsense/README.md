# OPNsense config

Do **not** commit the raw `config-*.xml` backup. It contains password hashes, PPPoE credentials and WireGuard private keys.

If you want to include it:

1. Export from *System → Configuration → Backups*.
2. Run `../sanitise.sh config.xml > config.sanitised.xml`.
3. Open the output and check it by hand before committing.

Otherwise, redacted screenshots of rules/interfaces in `../../screenshots/` are enough.
