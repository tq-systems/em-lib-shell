#!/bin/bash
# SPDX-License-Identifier: LicenseRef-TQSPSLA-1.0.3
#
# More license information can be found in the root folder.
# This file is part of the shell library.
#
# Copyright (c) 2025 TQ-Systems GmbH <license@tq-group.com>, D-82229 Seefeld, Germany. All rights reserved.
# Author: Christoph Krutz

CUR_DIR="$(dirname "$0")"
# shellcheck disable=SC1091
. "$CUR_DIR/common.sh"

SOURCE_DIR="$CUR_DIR/copy/source"
DEST_DIR="$CUR_DIR/copy/dest"

# Start without links in the source directory as they need to be created during the test
find "$SOURCE_DIR" -type l -exec rm {} \;

# Start with an empty destination directory
rm -rf "$DEST_DIR"

fail_on_diff() {
	local source="$1"
	local dest="$2"

	# Wait a bit for slow systems
	sleep 0.2

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

########################################
log_topic_title "Directory to directory"
########################################

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

log_test_title "Copy directory content of a relative link to inexistent directory"
(
	cd "$SOURCE_DIR" || exit 1
	ln -s dir rel_link
)
SOURCE="$SOURCE_DIR/rel_link"
DEST="$DEST_DIR/dir2dir_3"
if ! tqem-copy.sh "$SOURCE" "$DEST"; then
	log_success_expected
fi
# Check that the manipulated file is overwritten
fail_on_diff "$SOURCE" "$DEST"

log_test_title "Copy directory content of a absolute link to inexistent directory"
ln -s "$(realpath "$SOURCE_DIR/dir")" "$SOURCE_DIR/abs_link"
SOURCE="$SOURCE_DIR/abs_link"
DEST="$DEST_DIR/dir2dir_4"
if ! tqem-copy.sh "$SOURCE" "$DEST" -o; then
	log_success_expected
fi
# Check that the manipulated file is overridden
fail_on_diff "$SOURCE" "$DEST"

###################################
log_topic_title "File to directory"
###################################

log_test_title "Copy file to inexistent directory"
SOURCE="$SOURCE_DIR/file/test78.txt"
DEST="$DEST_DIR/file2dir_1"
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

log_test_title "Copy file of a relative link to inexistent directory"
(
	cd "$SOURCE_DIR/file" || exit 1
	ln -s test78.txt rel_link
)
SOURCE="$SOURCE_DIR/file/rel_link"
DEST="$DEST_DIR/file2dir_2"
if ! tqem-copy.sh "$SOURCE" "$DEST"; then
	log_success_expected
fi
fail_on_diff "$SOURCE" "$DEST/rel_link"

log_test_title "Copy file of a absolute link to inexistent directory"
SOURCE="$SOURCE_DIR/file/abs_link"
DEST="$DEST_DIR/file2dir_3"
ln -s "$(realpath "$SOURCE_DIR/file/test78.txt")" "$SOURCE"
if ! tqem-copy.sh "$SOURCE" "$DEST"; then
	log_success_expected
fi
fail_on_diff "$SOURCE" "$DEST/abs_link"

##################################
log_topic_title "copy link option"
##################################

log_test_title "Copy relative link and corresponding file to inexistent directory"
SOURCE="$SOURCE_DIR/file/abs_link"
DEST="$DEST_DIR/copy_link_1"
if ! tqem-copy.sh "$SOURCE" "$DEST" -l; then
	log_success_expected
fi
[ -L "$DEST/abs_link" ] || log_success_expected
[ "$(cat "$SOURCE")" = "$(cat "$DEST/abs_link")" ] || log_success_expected
[ "$(cat "$SOURCE_DIR/file/test78.txt")" = "$(cat "$DEST/test78.txt")" ] || log_success_expected

log_test_title "Copy relative link and corresponding file to existent directory with overwrite option"
echo 99 > "$DEST/test78.txt"
SOURCE="$SOURCE_DIR/file/abs_link"
DEST="$DEST_DIR/copy_link_1"
if ! tqem-copy.sh "$SOURCE" "$DEST" --links --overwrite; then
	log_success_expected
fi
[ -L "$DEST/abs_link" ] || log_success_expected
[ "$(cat "$SOURCE")" = "$(cat "$DEST/abs_link")" ] || log_success_expected
[ "$(cat "$SOURCE_DIR/file/test78.txt")" = "$(cat "$DEST/test78.txt")" ] || log_success_expected

log_test_title "Copy relative link and corresponding file to inexistent directory"
SOURCE="$SOURCE_DIR/file/rel_link"
DEST="$DEST_DIR/copy_link_2"
if ! tqem-copy.sh "$SOURCE" "$DEST" --links; then
	log_success_expected
fi
[ -L "$DEST/rel_link" ] || log_success_expected
[ "$(cat "$SOURCE")" = "$(cat "$DEST/rel_link")" ] || log_success_expected
[ "$(cat "$SOURCE_DIR/file/test78.txt")" = "$(cat "$DEST/test78.txt")" ] || log_success_expected

log_test_title "Try to copy relative link and corresponding file without overwrite option"
echo 99 > "$DEST/test78.txt"
if tqem-copy.sh "$SOURCE" "$DEST" --links; then
	log_error_expected
fi

####################################
log_topic_title "create link option"
####################################

log_test_title "Copy and link a file in an inexistent directory"
SOURCE="$SOURCE_DIR/dir/test12.txt"
DEST="$DEST_DIR/create_link_1"
LINK="latest.txt"
if ! tqem-copy.sh "$SOURCE" "$DEST" -L "$LINK"; then
	log_success_expected
fi
check_link_path "$DEST/test12.txt" "$LINK"

log_test_title "Copy a file in an existent directory and overwrite the link"
SOURCE="$SOURCE_DIR/dir/test34.txt"
if ! tqem-copy.sh "$SOURCE" "$DEST" --create-link="$LINK"; then
	log_success_expected
fi
check_link_path "$DEST/test34.txt" "$LINK"

log_test_title "Try to copy and link a directory"
SOURCE="$SOURCE_DIR/dir"
DEST="$DEST_DIR/create_link_2"
if tqem-copy.sh "$SOURCE" "$DEST" -L dir; then
	log_error_expected
fi

log_test_title "Forget link in link option"
if tqem-copy.sh "one" "two" -L; then
	log_error_expected
fi
if tqem-copy.sh "one" "two" --create-link=; then
	log_error_expected
fi

#################################
log_topic_title "Argument errors"
#################################

log_test_title "Pass an unsupported number of arguments"
if tqem-copy.sh 1; then
	log_error_expected
fi
if tqem-copy.sh 1 2 3 4 5 6 7; then
	log_error_expected
fi

log_test_title "Pass unknown option"
if tqem-copy.sh "one" "two" -z; then
	log_error_expected
fi

######################
log_topic_title "Help"
######################

log_test_title "Show help"
if ! tqem-copy.sh -h; then
	log_success_expected
fi
# Supress 2nd help output for better readability of the test log
if ! tqem-copy.sh --help > /dev/null; then
	log_success_expected
fi

####################
log_successful_tests
####################
