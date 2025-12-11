#!/usr/bin/env bash
# SPDX-FileCopyrightText: Copyright (C) SchedMD LLC.
# SPDX-License-Identifier: Apache-2.0

set -euo pipefail

# Additional arguments to pass to daemons.
export SLURMCTLD_OPTIONS="${SLURMCTLD_OPTIONS:-} $*"
export SSSD_OPTIONS="${SSSD_OPTIONS:-}"

function main() {
	mkdir -p /run/slurmctld/
	chown slurm:slurm /run/slurmctld/
	mkdir -p /run/dbus/
	rm -f /var/run/dbus/pid

	# Copy SSSD config with correct permissions if mounted
	# The operator mounts it to /run/sssd-mounted/ with fsGroup (group-readable)
	# We copy to /etc/sssd/ and set strict permissions (SSSD requires root:root 0600)
	if [[ -f /run/sssd-mounted/sssd.conf ]]; then
		mkdir -p /etc/sssd
		cp /run/sssd-mounted/sssd.conf /etc/sssd/sssd.conf
		chmod 0600 /etc/sssd/sssd.conf
		chown root:root /etc/sssd/sssd.conf
	fi

	exec supervisord -c /etc/supervisor/supervisord.conf
}
main
