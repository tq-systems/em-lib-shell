#!/bin/bash
# SPDX-License-Identifier: LicenseRef-TQSPSLA-1.0.3
#
# More license information can be found in the root folder.
# This file is part of the shell library.
#
# Copyright (c) 2025 TQ-Systems GmbH <license@tq-group.com>, D-82229 Seefeld, Germany. All rights reserved.
# Author: Michael Krummsdorf

set -e

# shellcheck source=log.sh
. "$TQEM_SHELL_LIB_DIR/log.sh"

tqem_version_git_create_version() {
	# There are differences between a local repository and a repository in the CI,
	# e.g. the CI only fetches the last 20 commits of a project by default.
	# Commands like 'git describe', 'git rev-parse' or 'git branch' may fail in the CI
	# in some cases, so we implemented commands which work in both environments.

	local git_last_tag git_branch_short timestamp git_commit_short

	# Enforce a semantic version
	git_last_tag=$(git tag --list --merged | grep -Eo '^v([0-9]+)\.([0-9]+)\.([0-9]+).*' | sort -V | tail -n1)
	if [ -z "$git_last_tag" ]; then
		git_last_tag="v0.0.0"
	fi

	git_branch_short="$(git rev-parse --abbrev-ref HEAD | head -c 13)"

	timestamp="$(date -u "+%Y%m%d%H%M%S")"
	git_commit_short="$(git rev-parse --short=8 HEAD)"

	echo "${git_last_tag}+${git_branch_short}-${timestamp}-${git_commit_short}"
}

tqem_version_get_version() {
	# FORCE_VERSION enables to specify an own version layout
	if [ -n "$TQEM_FORCE_VERSION" ]; then
		VERSION="$TQEM_FORCE_VERSION"
	else
		# Get version from tag (git repository)
		GIT_HEAD_TAG="$(git describe --exact-match --tags HEAD 2>/dev/null || true)"
		if [ -n "$GIT_HEAD_TAG" ]; then
			GIT_VERSION="$GIT_HEAD_TAG"
		else
			# Derive version from git information
			GIT_VERSION="$(tqem_version_git_create_version)"
		fi

		# Set and adjust the version if it was created by git information
		# Remove the v-prefix and replace slashes with a minus signs
		# Slashes are not allowed in a version, a slash may break the path of a file
		VERSION="$(echo "$GIT_VERSION" | sed -e 's/^v//i' -e 's/\//-/')"
	fi

	# Always mark dirty states from local changes with a '+' suffix
	if ! git diff --quiet HEAD; then
		VERSION+='+'
	fi

	echo "$VERSION"
}
