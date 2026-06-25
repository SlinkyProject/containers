#!/usr/bin/env bash
# SPDX-FileCopyrightText: Copyright (C) SchedMD LLC.
# SPDX-License-Identifier: Apache-2.0

set -euo pipefail

# Additional arguments to pass to sssd.
export SSSD_OPTIONS="${SSSD_OPTIONS:-}"

mkdir -p /etc/sssd /run/sssd /var/lib/sss/pipes

exec sssd -i ${SSSD_OPTIONS}
