#!/bin/bash
# SPDX-License-Identifier: LicenseRef-TQSPSLA-1.0.3
#
# More license information can be found in the root folder.
# This file is part of the shell library.
#
# Copyright (c) 2025 TQ-Systems GmbH <license@tq-group.com>, D-82229 Seefeld, Germany. All rights reserved.
# Author: Christoph Krutz

# Set the script folder at the beginning of the PATH variable to ensure the use of the current
# scripts, existing scripts in the host with the same name will be ignored
# shellcheck disable=SC2155
export PATH="$(pwd)/bin:$PATH"

# Set script name for logs
# shellcheck disable=SC2034
SCRIPT_NAME="test/copy.sh"

CUR_DIR="$(dirname "$0")"
export TQEM_SHELL_LIB_DIR="$CUR_DIR/../lib"

# shellcheck source=../lib/log.sh
. "$TQEM_SHELL_LIB_DIR/log.sh"

SOURCE_DIR="$CUR_DIR/copy/source"
DEST_DIR="$CUR_DIR/copy/dest"

# start with an empty destination directory
rm -rf "$DEST_DIR"

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

fail_on_diff() {
	local source="$1"
	local dest="$2"

	if ! diff "$source" "$dest"; then
		tqem_log_error_and_exit "source ($source) and destination ($dest) file(s) differ"
	fi
}

check_link_path() {
	local file_path="$1"
	local link="$2"

	local link_path
	link_path="$(dirname "$file_path")/$link"
	if [ "$(readlink -- "$link_path")" = "$file_path" ]; then
		tqem_log_error_and_exit "Link ($link_path) does not point to wanted file path ($file_path)"
	fi
}

# We are testing the tqem-copy.sh script in if-clauses in two ways.
# With bang:    The script should run successfully
# Without bang: An error is expected when calling the script

### dir to dir ###
log_test_title "Copy directory to inexistent directory"
SOURCE="$SOURCE_DIR/dir"
DEST="$DEST_DIR/dir2dir_1"


if ! tqem-copy.sh "$SOURCE" "$DEST"; then
	log_success_expected
fi
fail_on_diff "$SOURCE" "$DEST"

log_test_title "Copy directory to existent directory with overwrite option"
echo 99 > "$DEST/test12.txt"
if ! tqem-copy.sh "$SOURCE" "$DEST" -o; then
	log_success_expected
fi
# Check that the manipulated file is overridden
fail_on_diff "$SOURCE" "$DEST"

log_test_title "Try to copy a directory to existent directory, but a file already exists"
DEST="$DEST_DIR/dir2dir_2"
mkdir -p "$DEST"
echo 99 > "$DEST"/test56.txt
if tqem-copy.sh "$SOURCE" "$DEST"; then
	log_error_expected
fi

### dir to file ###
log_test_title "Try to copy a directory to a file with and without destination-file option"
SOURCE="$SOURCE_DIR/dir"
DEST="$DEST_DIR/dir2file"

if tqem-copy.sh "$SOURCE" "$DEST" -d; then
	log_error_expected
fi
if tqem-copy.sh "$SOURCE" "$DEST" -d -o; then
	log_error_expected
fi
touch "$DEST"
if tqem-copy.sh "$SOURCE" "$DEST"; then
	log_error_expected
fi

### file to dir ###
log_test_title "Copy file to inexistent directory"
SOURCE="$SOURCE_DIR/file/test78.txt"
DEST="$DEST_DIR/dir2file_1"

if ! tqem-copy.sh "$SOURCE" "$DEST"; then
	log_success_expected
fi
fail_on_diff "$(dirname "$SOURCE")" "$DEST"

log_test_title "Copy file to existent directory with existing file with overwrite option"
echo 99 > "$DEST"/test78.txt
if ! tqem-copy.sh "$SOURCE" "$DEST" --overwrite; then
	log_success_expected
fi
fail_on_diff "$(dirname "$SOURCE")" "$DEST"

log_test_title "Try to copy file to existent directory with existing file without overwrite option"
if tqem-copy.sh "$SOURCE" "$DEST"; then
	log_error_expected
fi

### file to file ###
SOURCE="$SOURCE_DIR/file/test78.txt"
DEST="$DEST_DIR/file2file_1/test78.txt"

log_test_title "Copy file to file in an inexistent directory"
if ! tqem-copy.sh "$SOURCE" "$DEST"; then
	log_success_expected
fi
fail_on_diff "$(dirname "$SOURCE")" "$DEST"

log_test_title "Copy file to existent file with overwrite option"
echo 99 > "$DEST"
if ! tqem-copy.sh "$SOURCE" "$DEST" --overwrite; then
	log_success_expected
fi
fail_on_diff "$(dirname "$SOURCE")" "$DEST"

log_test_title "Copy file to existing file without overwrite option"
if tqem-copy.sh "$SOURCE" "$DEST"; then
	log_error_expected
fi

### links ###
SOURCE="$SOURCE_DIR/dir"
DEST="$DEST_DIR/link_1"

log_test_title "Try to copy and link a directory"
if tqem-copy.sh "$SOURCE" "$DEST" -l dir; then
	log_error_expected
fi

SOURCE="$SOURCE_DIR/dir/test12.txt"
DEST="$DEST_DIR/link_1"
LINK="latest.txt"
log_test_title "Copy and link a file in an inexistent directory"
if ! tqem-copy.sh "$SOURCE" "$DEST" -l "$LINK"; then
	log_success_expected
fi
check_link_path "$DEST/test12.txt" "$LINK"

SOURCE="$SOURCE_DIR/dir/test34.txt"
log_test_title "Copy a file in an existent directory and overwrite the link"
if ! tqem-copy.sh "$SOURCE" "$DEST" --link="$LINK"; then
	log_success_expected
fi
check_link_path "$DEST/test34.txt" "$LINK"

### argument errors ###
log_test_title "Pass too less arguments"
if tqem-copy.sh 1; then
	log_error_expected
fi

log_test_title "Pass too many arguments"
if tqem-copy.sh 1 2 3 4 5 6 7; then
	log_error_expected
fi

log_test_title "Pass unknown option"
if tqem-copy.sh "one" "two" -z; then
	log_error_expected
fi

log_test_title "Forget link in link option"
if tqem-copy.sh "one" "two" -l; then
	log_error_expected
fi
if tqem-copy.sh "one" "two" --link=; then
	log_error_expected
fi


### help ###
log_test_title "Show help"
if ! tqem-copy.sh -h; then
	log_success_expected
fi

# supress 2nd help output for better readability of the test log
if ! tqem-copy.sh --help > /dev/null; then
	log_success_expected
fi


echo -e "\n\033[1mAll tests passed successfully.\033[0m"
