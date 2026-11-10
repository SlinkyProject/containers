#!/usr/bin/env bash
# SPDX-FileCopyrightText: Copyright (C) SchedMD LLC.
# SPDX-License-Identifier: Apache-2.0

set -euo pipefail

# Fix NVIDIA proc mount for GPUs
mount -t proc none /proc 2>/dev/null || true
mount -t tmpfs tmpfs /tmp 2>/dev/null || true
