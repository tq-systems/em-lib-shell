#!/bin/bash
# SPDX-License-Identifier: LicenseRef-TQSPSLA-1.0.3
#
# More license information can be found in the root folder.
# This file is part of the shell library.
#
# Copyright (c) 2025 TQ-Systems GmbH <license@tq-group.com>, D-82229 Seefeld, Germany. All rights reserved.
# Author: Michael Krummsdorf

set -euo pipefail

# Functions
tqem_log_info() {
	local message="$1"
	echo "[$SCRIPT_NAME]:INFO: $message"
}

tqem_warning() {
	local message="$1"
	echo >&2 "[$SCRIPT_NAME]:WARNING: $message"
}


tqem_log_error_and_exit() {
	local message="$1"
	echo >&2 "[$SCRIPT_NAME]:ERROR: $message"
	exit 1
}

tqem_log_journal() {
	local loglevel="$1"
	local message="$2"
	echo "$message" | systemd-cat -t "$SCRIPT_NAME" -p "$loglevel"
}
