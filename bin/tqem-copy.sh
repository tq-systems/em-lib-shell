#!/bin/bash
# SPDX-License-Identifier: LicenseRef-TQSPSLA-1.0.3
#
# More license information can be found in the root folder.
# This file is part of the shell library.
#
# Copyright (c) 2025 TQ-Systems GmbH <license@tq-group.com>, D-82229 Seefeld, Germany. All rights reserved.
# Author: Christoph Krutz

SCRIPT_NAME="$(basename "$0")"

# Enable to use the local library
TQEM_SHELL_LIB_DIR="${TQEM_SHELL_LIB_DIR:-/usr/local/lib/tqem/shell}"

# shellcheck source=../lib/copy.sh
. "$TQEM_SHELL_LIB_DIR/copy.sh"

set -u

usage() {
	echo "NAME

       $SCRIPT_NAME - copy file or directory

SYNOPSIS

       $SCRIPT_NAME SOURCE DESTINATION [OPTIONS]

DESCRIPTION

       Copy SOURCE to DESTINATION.

       SOURCE can be a file, a directory or a link.
       If SOURCE is directory, only the content of it will be copied.
       DESTINATION is always a directory.

       -o, --overwrite
              overwrite existing destination file(s) without errors

       -L LINK, --create-link=LINK
              create a relative symbolic link (requires a file in SOURCE)
              LINK is a mandatory argument for this option

       -l, --links
              copy the link and the corresponding file (requires a file in SOURCE)
              the link in the destination directory is relative
"
}

if [ "${1:-}" = "-h" ] || [ "${1:-}" = "--help" ]; then
	usage; exit 0
fi

if [ $# -lt 2 ] || [ $# -gt 6 ]; then
	tqem_log_error_and_exit "Unsupported number of arguments: $#"
fi

SOURCE="$1"
DEST="$2"
shift; shift

set_copy_options "$@"
copy_source_to_dest "$SOURCE" "$DEST"
