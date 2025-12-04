#!/bin/bash
# SPDX-License-Identifier: LicenseRef-TQSPSLA-1.0.3
#
# More license information can be found in the root folder.
# This file is part of the shell library.
#
# Copyright (c) 2025 TQ-Systems GmbH <license@tq-group.com>, D-82229 Seefeld, Germany. All rights reserved.
# Author: Michael Krummsdorf

SCRIPT_NAME="$(basename "$0")"

# Enable to use the local library
TQEM_SHELL_LIB_DIR="${TQEM_SHELL_LIB_DIR:-/usr/local/lib/tqem/shell}"

# shellcheck source=../lib/version.sh
. "$TQEM_SHELL_LIB_DIR/version.sh"

usage() {
	echo "NAME

       $SCRIPT_NAME - generate version string

SYNOPSIS

       $SCRIPT_NAME

DESCRIPTION

       Generate a version string for the current repository and print it to stdout.

       TQEM_FORCE_VERSION - Environmental variable to use as predefined version string
"
}

if [ "${1:-}" = "-h" ] || [ "${1:-}" = "--help" ]; then
	usage; exit 0
fi

if [ $# -gt 2 ]; then
	tqem_log_error_and_exit "Unsupported number of arguments"
fi

tqem_version_get_version "$@"
