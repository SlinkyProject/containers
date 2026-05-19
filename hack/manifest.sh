#!/usr/bin/env bash
# SPDX-FileCopyrightText: Copyright (C) SchedMD LLC.
# SPDX-License-Identifier: Apache-2.0

set -euo pipefail

function log::info() {
	echo "[$(date)] $*"
}

function log::error() {
	log::info "$*" >&2
}

function help() {
	cat <<EOF
$(basename "$0") - Generate a manifest for multi-arch images

	usage: $(basename "$0") [--dir DIR] [--amd64][--arm64] [--push] [--sign]

OPTIONS:
	--dir DIR           Directory containing docker-bake.hcl and image HCL files.
	--push              Push manifest to registry.
	--sign              Sign the pushed manifest by digest with cosign keyless. Requires --push.
	--amd64             Add amd64/x86_64 images to manifest.
	--arm64             Add arm64/aarch64 images to manifest.

HELP OPTIONS:
	--debug             Display trace logging.
	-h, --help          Show this help message.

EOF
}

OPT_DEBUG=false
OPT_AMD64=false
OPT_ARM64=false
OPT_PUSH=false
OPT_SIGN=false
OPT_DIR="."

function parse_opts() {
	SHORT="+h"
	LONG="amd64,arm64,debug,dir:,push,sign,help"
	OPTS="$(getopt -a --options "$SHORT" --longoptions "$LONG" -- "$@")"
	eval set -- "${OPTS}"
	while :; do
		case "$1" in
		--dir)
			OPT_DIR="$2"
			shift 2
			log::info "dir set to $OPT_DIR"
			;;
		--push)
			OPT_PUSH=true
			shift
			log::info "push enabled"
			;;
		--sign)
			OPT_SIGN=true
			shift
			log::info "sign enabled"
			;;
		--amd64)
			OPT_AMD64=true
			shift
			log::info "amd64/x86_64 enabled"
			;;
		--arm64)
			OPT_ARM64=true
			shift
			log::info "arm64/aarch64 enabled"
			;;
		--debug)
			OPT_DEBUG=true
			shift
			log::info "debug enabled"
			;;
		-h | --help)
			help
			exit 0
			;;
		--)
			shift
			break
			;;
		*)
			log::error "Unknown option: $1"
			help
			exit 1
			;;
		esac
	done

	if "$OPT_SIGN" && ! "$OPT_PUSH"; then
		log::error "--sign requires --push"
		exit 1
	fi
}

function main() {
	parse_opts "$@"

	if [[ ! -d $OPT_DIR ]]; then
		log::error "manifest directory does not exist: $OPT_DIR"
		exit 1
	fi
	cd "$OPT_DIR"

	IMAGES=()

	"$OPT_DEBUG" && set -x

	# For each target, construct a list of images to add to the manifest -- same tag, different architecture/platform.
	# Assume the architecture registries follow the schema: '${REGISTRY}/${ARCH}/${TARGET}:${TAG}'
	# Assume the index of each image/tag list aligns.
	local target
	for target in $(docker buildx bake $BAKE_IMPORTS $BAKE_TARGET --print 2>/dev/null | jq -r '.target | keys[]' | sort -u); do
		local tags=()
		readarray -t tags < <(docker buildx bake $BAKE_IMPORTS $target --print 2>/dev/null | jq -r --arg target "$target" '.target[$target].tags[]' | sort -u)

		local amd64=()
		if "$OPT_AMD64"; then
			local registry="${REGISTRY:-"ghcr.io/slinkyproject"}/amd64"
			mapfile -t amd64 < <(REGISTRY="$registry" docker buildx bake $BAKE_IMPORTS $target --print 2>/dev/null | jq -r --arg target "$target" '.target[$target].tags[]' | sort -u)
		fi

		local arm64=()
		if "$OPT_ARM64"; then
			local registry="${REGISTRY:-"ghcr.io/slinkyproject"}/arm64"
			mapfile -t arm64 < <(REGISTRY="$registry" docker buildx bake $BAKE_IMPORTS $target --print 2>/dev/null | jq -r --arg target "$target" '.target[$target].tags[]' | sort -u)
		fi

		local size=0
		((${#amd64[@]} >= ${#arm64[@]})) && size="${#amd64[@]}"
		((${#arm64[@]} >= ${#amd64[@]})) && size="${#arm64[@]}"

		local i
		for ((i = 0; i < "$size"; i++)); do
			IMAGES=()
			"$OPT_AMD64" && IMAGES+=("${amd64["$i"]}")
			"$OPT_ARM64" && IMAGES+=("${arm64["$i"]}")
			manifest "${tags["$i"]}"
		done
	done
	unset target
}

function manifest() {
	local tag="$1"
	manifest::create "$tag"
	manifest::inspect "$tag"
	if "$OPT_SIGN"; then
		manifest::sign "$tag"
	fi
}

function manifest::create() {
	local tag="$1"
	local cmd=(
		"docker"
		"buildx"
		"imagetools"
		"create"
		"--tag $tag"
	)
	for image in "${IMAGES[@]}"; do
		cmd+=("$image")
	done
	! "$OPT_PUSH" && cmd+=("--dry-run")
	log::info "${cmd[*]}"
	eval "${cmd[*]}"
}

function manifest::inspect() {
	local tag="$1"
	local cmd=(
		"docker"
		"buildx"
		"imagetools"
		"inspect"
		"$tag"
		"--raw"
	)
	if "$OPT_PUSH"; then
		log::info "${cmd[*]}"
		eval "${cmd[*]}"
		echo ""
	fi
}

# Sign the pushed manifest list by digest (not tag) with cosign keyless signing.
# Signing the index digest covers all per-arch manifests it references, so one
# signature per tag is sufficient for consumers who verify the tag they pulled.
function manifest::sign() {
	local tag="$1"
	local repo="${tag%:*}"
	local digest
	digest="$(docker buildx imagetools inspect "$tag" | awk '/^Digest:/ {print $2; exit}')"
	if [[ -z $digest ]]; then
		log::error "failed to resolve digest for $tag"
		return 1
	fi
	log::info "cosign sign --yes ${repo}@${digest}"
	cosign sign --yes "${repo}@${digest}"
}

main "$@"
