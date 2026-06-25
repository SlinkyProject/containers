#!/usr/bin/env bash
# SPDX-FileCopyrightText: Copyright (C) SchedMD LLC.
# SPDX-License-Identifier: Apache-2.0

set -euo pipefail

# Additional arguments to pass to daemons.
export SSHD_OPTIONS="${SSHD_OPTIONS:-""}"
export SACKD_OPTIONS="${SACKD_OPTIONS:-""}"
export SSSD_OPTIONS="${SSSD_OPTIONS:-""}"

function configure_sssd() {
	local sssd_mode="${SSSD_MODE:-embedded}"
	local available_conf="/etc/supervisor/conf.available/sssd.conf"
	local enabled_conf="/etc/supervisor/conf.d/sssd.conf"

	rm -f "$enabled_conf"

	case "$sssd_mode" in
	embedded)
		ln -s "$available_conf" "$enabled_conf"
		;;
	sidecar | disabled) ;;
	*)
		echo "unsupported SSSD_MODE: ${sssd_mode}" >&2
		exit 1
		;;
	esac
}

function main() {
	mkdir -p /run/sshd/
	chmod 0755 /run/sshd/
	mkdir -p /run/dbus/
	rm -f /var/run/dbus/pid

	ssh-keygen -A
	configure_sssd

	exec supervisord -c /etc/supervisor/supervisord.conf
}
main
