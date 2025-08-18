#!/bin/bash
# SPDX-License-Identifier: LicenseRef-TQSPSLA-1.0.3
#
# More license information can be found in the root folder.
# This file is part of the shell library.
#
# Copyright (c) 2025 TQ-Systems GmbH <license@tq-group.com>, D-82229 Seefeld, Germany. All rights reserved.
# Author: Michael Krummsdorf

# shellcheck disable=SC2155
export PATH="$(pwd)/bin:$PATH"

# Set script name for logs
# shellcheck disable=SC2034
SCRIPT_NAME="test/version.sh"

CUR_DIR="$(dirname "$0")"
export TQEM_SHELL_LIB_DIR="$(realpath "$CUR_DIR"/../lib)"

# shellcheck source=../lib/log.sh
. "$TQEM_SHELL_LIB_DIR/log.sh"

TESTREPO="$CUR_DIR/repo-version"
TESTTAG="v1.1.2"

# create a fresh repository
rm -rf "$TESTREPO"
mkdir "$TESTREPO"
cd "$TESTREPO" || tqem_log_error_and_exit "Testrepo not found!"
echo "123" > file.123
git init -b main;
git config user.email "test@version.com"
git config user.name "Version Tester"
git add file.123; git commit -m "Testcommit"; git tag -a $TESTTAG -m "Testrepo"

TEST_COUNT=1

log_test_title() {
	local msg="$1"
	echo -e "\n\033[1mTest $TEST_COUNT: $msg\033[0m"
	TEST_COUNT=$((TEST_COUNT + 1))
}

log_success_expected() {
	tqem_log_error_and_exit "The script did not create the expected output"
}

log_error_expected() {
	tqem_log_error_and_exit "The script did not generate an error as expected"
}

log_test_title "Check forced version"
export TQEM_FORCE_VERSION="9.9.9-forced"
if [ "$(tqem-version.sh)" != "9.9.9-forced" ]; then
	log_success_expected
fi
export TQEM_FORCE_VERSION=""

log_test_title "Check last tag"
if [ "v$(tqem-version.sh)" != "$TESTTAG" ]; then
	log_success_expected
fi

echo "456" > file.123
git add file.123;

log_test_title "Check marker for uncommitted changes"
VERSION=$(tqem-version.sh)
if [ "${VERSION: -1}" != "+" ]; then
	log_success_expected
fi

log_test_title "Check commits above last tag"
git commit -m "Testcommit 2"
if [[ ! "v$(tqem-version.sh)" == $TESTTAG+$(git branch --show-current)-* ]]; then
	log_success_expected
fi

cd ".."
rm -rf "$TESTREPO"

### argument errors ###
log_test_title "Pass too many arguments"
if tqem-version.sh 1 2 3 4 5 6 7; then
	log_error_expected
fi

### help ###
log_test_title "Show help"
if ! tqem-version.sh -h; then
	log_success_expected
fi

# supress 2nd help output for better readability of the test log
if ! tqem-version.sh --help > /dev/null; then
	log_success_expected
fi

echo -e "\n\033[1mAll tests passed successfully.\033[0m"
