#!/usr/bin/env bash
# SPDX-FileCopyrightText: Copyright (C) SchedMD LLC.
# SPDX-License-Identifier: Apache-2.0

set -euo pipefail

# Additional arguments to pass to slurmctld.
export SLURMCTLD_OPTIONS="${SLURMCTLD_OPTIONS:-} $*"

# Additional arguments to pass to daemons.
export SSSD_OPTIONS="${SSSD_OPTIONS:-}"

function main() {
	mkdir -p /run/slurmctld/

	# OOM protection is best effort when SYS_RESOURCE is unavailable.
	if ! choom -n -999 -p "$$"; then
		echo "[supervisord] WARNING: unable to set oom_score_adj=-999. Continuing with existing score (requires CAP_SYS_RESOURCE and writable procfs)." >&2
	fi
	exec supervisord -c /etc/supervisord.conf
}
main
