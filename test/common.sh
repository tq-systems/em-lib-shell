#!/bin/bash
# SPDX-License-Identifier: LicenseRef-TQSPSLA-1.0.3
#
# More license information can be found in the root folder.
# This file is part of the shell library.
#
# Copyright (c) 2025 TQ-Systems GmbH <license@tq-group.com>, D-82229 Seefeld, Germany. All rights reserved.
# Author: Christoph Krutz

set -eu

# Set the script folder at the beginning of the PATH variable to ensure the use of the current
# scripts, existing scripts in the host with the same name will be ignored
export PATH="$TQEM_SHELL_BIN_DIR:$PATH"

# Set script name for logs
SCRIPT_NAME="test/$(basename "$0")"

# shellcheck source=../lib/log.sh
. "$TQEM_SHELL_LIB_DIR/log.sh"

TEST_COUNT=1

log_topic_title() {
	local msg="$1"
	echo -e "\n\e[1;34m$SCRIPT_NAME tests: $msg\e[0m"
}

log_test_title() {
	local msg="$1"
	echo -e "\n\e[1mTest $TEST_COUNT: $msg\e[0m"
	TEST_COUNT=$((TEST_COUNT + 1))
}

log_success_expected() {
	tqem_log_error_and_exit "The script did not run without errors as expected"
}

log_error_expected() {
	tqem_log_error_and_exit "The script did not generate an error as expected"
}

log_successful_tests() {
	echo -e "\n\e[1;32mAll tests of $SCRIPT_NAME passed successfully.\e[0m\n"
}
