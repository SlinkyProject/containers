#!/usr/bin/env bash
# SPDX-FileCopyrightText: Copyright (c) 2026 NVIDIA CORPORATION & AFFILIATES. All rights reserved.
# SPDX-License-Identifier: Apache-2.0

set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

usage() {
	cat <<USAGE
Usage: $0 [--apply FAMILY TAG]

With no arguments, report available updates as tab-separated columns:
family, current version, new version, upstream tag. No files are changed.
--apply updates the Dockerfiles and slurm.hcl files for one existing family.
USAGE
}

parse_tag() {
	local tag=$1 patch revision stable
	[[ $tag =~ ^slurm-([0-9]{2})-([0-9]{2})-([0-9]+)-([0-9]+|0rc[0-9]+)$ ]] || return 1
	release_family="${BASH_REMATCH[1]}.${BASH_REMATCH[2]}"
	patch=${BASH_REMATCH[3]}
	revision=${BASH_REMATCH[4]}
	release_version="${release_family}.${patch}"
	stable=1
	if [[ $revision == 0rc* ]]; then
		release_version+="-${revision}"
		revision=${revision#0rc}
		stable=0
	elif [[ $revision != 1 ]]; then
		release_version+="-${revision}"
	fi
	printf -v release_key '%09d%d%09d' "$((10#$patch))" "$stable" "$((10#$revision))"
}

read_family() {
	local family=$1 config version dockerfile
	local configs=("schedmd/slurm/$family"/*/slurm.hcl)
	current_version=
	for config in "${configs[@]}"; do
		[[ -f $config ]] || {
			echo "No configurations for $family" >&2
			return 1
		}
		version=$(sed -nE 's/^slurm_version = "([^"]+)"$/\1/p' "$config")
		if [[ ! $version =~ ^${family//./\.}\.[0-9]+(-([0-9]+|0rc[0-9]+))?$ ]] ||
			[[ -n $current_version && $version != "$current_version" ]]; then
			echo "Invalid or inconsistent Slurm version in $config" >&2
			return 1
		fi
		current_version=$version
		current_tag="slurm-${version//./-}"
		[[ $version == *-* ]] || current_tag+=-1
		dockerfile=${config%/*}/Dockerfile
		if ! grep -Fxq "ARG SLURM_VERSION=$current_version" "$dockerfile" ||
			! grep -Fxq "ARG SLURM_VERSION_ARCHIVE=$current_tag" "$dockerfile"; then
			echo "Version mismatch between $config and $dockerfile" >&2
			return 1
		fi
	done
	parse_tag "$current_tag"
	current_key=$release_key
}

apply_update() {
	local family=$1 tag=$2 config dockerfile
	[[ $family =~ ^[0-9]{2}\.[0-9]{2}$ ]] || return 1
	read_family "$family"
	parse_tag "$tag"
	if [[ $release_family != "$family" || ! $release_key > $current_key ]] ||
		[[ $current_version != *rc* && $release_version == *rc* ]]; then
		echo "Not a permitted update: $current_version -> $tag" >&2
		return 1
	fi
	for config in "schedmd/slurm/$family"/*/slurm.hcl; do
		dockerfile=${config%/*}/Dockerfile
		sed -E "s/^slurm_version = .*/slurm_version = \"$release_version\"/" "$config" >"$config.tmp"
		mv "$config.tmp" "$config"
		sed -E \
			-e "s/^ARG SLURM_VERSION=.*/ARG SLURM_VERSION=$release_version/" \
			-e "s/^ARG SLURM_VERSION_ARCHIVE=.*/ARG SLURM_VERSION_ARCHIVE=$tag/" \
			"$dockerfile" >"$dockerfile.tmp"
		mv "$dockerfile.tmp" "$dockerfile"
	done
}

case ${1:-} in
-h | --help)
	usage
	exit 0
	;;
--apply)
	[[ $# == 3 ]] || {
		usage >&2
		exit 1
	}
	apply_update "$2" "$3"
	exit 0
	;;
'') ;;
*)
	usage >&2
	exit 1
	;;
esac

export LC_ALL=C
tags=$(git ls-remote --tags --refs https://github.com/SchedMD/slurm.git 'slurm-*')
for directory in schedmd/slurm/[0-9][0-9].[0-9][0-9]; do
	[[ -d $directory ]] || continue
	family=${directory##*/}
	read_family "$family"
	latest_key=$current_key
	latest_version=$current_version
	latest_tag=$current_tag
	while read -r _ ref; do
		tag=${ref##*/}
		parse_tag "$tag" || continue
		[[ $release_family == "$family" ]] || continue
		[[ $current_version == *rc* || $release_version != *rc* ]] || continue
		if [[ $release_key > $latest_key ]]; then
			latest_key=$release_key
			latest_version=$release_version
			latest_tag=$tag
		fi
	done <<<"$tags"
	if [[ $latest_key > $current_key ]]; then
		printf '%s\t%s\t%s\t%s\n' "$family" "$current_version" "$latest_version" "$latest_tag"
	fi
done
