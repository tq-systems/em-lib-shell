#!/bin/bash
# SPDX-License-Identifier: LicenseRef-TQSPSLA-1.0.3
#
# More license information can be found in the root folder.
# This file is part of the shell library.
#
# Copyright (c) 2025 TQ-Systems GmbH <license@tq-group.com>, D-82229 Seefeld, Germany. All rights reserved.
# Author: Christoph Krutz

set -e

BIN_DIR="bin"
README_FILE="$BIN_DIR/README.md"

create_bin_readme() {
	# Title
	echo "# Executables" > "$README_FILE"

	# Create documentation from help
	for bin in "$BIN_DIR/"*".sh"; do
		if [ -e "$bin" ]; then
			echo "## $(basename "$bin")" >> "$README_FILE"
			bash "$bin" --help >> "$README_FILE"
		fi
	done
}

fail_with_dirty_repo() {
	if [[ -n $(git status --porcelain) ]]; then
		echo "ERROR: Found untracked or changed files:"
		git status --short
		exit 1
	fi
}

create_bin_readme
fail_with_dirty_repo
