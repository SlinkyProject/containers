#!/usr/bin/env bash
# SPDX-FileCopyrightText: Copyright (C) SchedMD LLC.
# SPDX-License-Identifier: Apache-2.0

set -euo pipefail

# Additional arguments to pass to daemons.
export SSHD_OPTIONS="${SSHD_OPTIONS:-""}"
export SACKD_OPTIONS="${SACKD_OPTIONS:-""}"
export SSSD_OPTIONS="${SSSD_OPTIONS:-""}"

function entrypointd() {
	if [ -d /usr/local/entrypoint.d/ ]; then
		echo "[entrypoint.d] Files: $(ls -laF /usr/local/entrypoint.d/)"
	fi
	for file in /usr/local/entrypoint.d/*; do
		if [ -f "$file" ] && [ -x "$file" ]; then
			echo "[entrypoint.d] Run: $file"
			"$file"
		fi
	done
}

function main() {
	# Keep SSH sessions at the runtime's original OOM adjustment.
	SLINKY_SSH_OOM_SCORE_ADJ="$(cat /proc/self/oom_score_adj)"
	export SLINKY_SSH_OOM_SCORE_ADJ

	mkdir -p /run/sshd/
	chmod 0755 /run/sshd/
	mkdir -p /run/dbus/
	rm -f /var/run/dbus/pid

	ssh-keygen -A

	entrypointd

	# OOM protection is best effort when SYS_RESOURCE is unavailable.
	if ! choom -n -999 -p "$$"; then
		echo "[supervisord] WARNING: unable to set oom_score_adj=-999. Continuing with existing score (requires CAP_SYS_RESOURCE and writable procfs)." >&2
	fi
	exec supervisord -c /etc/supervisor/supervisord.conf
}
main
