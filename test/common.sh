#!/bin/bash
# SPDX-License-Identifier: LicenseRef-TQSPSLA-1.0.3
#
# More license information can be found in the root folder.
# This file is part of the shell library.
#
# Copyright (c) 2025 TQ-Systems GmbH <license@tq-group.com>, D-82229 Seefeld, Germany. All rights reserved.
# Author: Christoph Krutz

# shellcheck source=../lib/log.sh
. "$TQEM_SHELL_LIB_DIR/log.sh"

TEST_COUNT=1

log_test_title() {
	local msg="$1"
	echo -e "\n\033[1mTest $TEST_COUNT: $msg\033[0m"
	TEST_COUNT=$((TEST_COUNT + 1))
}

log_success_expected() {
	tqem_log_error_and_exit "The script did not run without errors as expected"
}

log_error_expected() {
	tqem_log_error_and_exit "The script did not generate an error as expected"
}

log_successful_tests() {
	echo -e "\n\033[1mAll tests of $SCRIPT_NAME passed successfully.\033[0m"
}
