#!/bin/bash
# SPDX-License-Identifier: LicenseRef-TQSPSLA-1.0.3
#
# More license information can be found in the root folder.
# This file is part of the shell library.
#
# Copyright (c) 2025 TQ-Systems GmbH <license@tq-group.com>, D-82229 Seefeld, Germany. All rights reserved.
# Author: Christoph Krutz

set -e

# shellcheck source=log.sh
. "$TQEM_SHELL_LIB_DIR/log.sh"

# Default values
OVERWRITE="false" # If true, files can be overwritten without throwing an error
DEST_IS_FILE="false" # If true, the destination is treated as a file (not as a directory)


fail_if_src_file_exists_in_dest_dir() {
	local source="$1"
	local dest="$2"

	# Normalize to absolute paths
	source="$(realpath "$source")"
	dest="$(realpath "$dest")"

	# Find files in source
	(cd "$source" && find . -type f -printf "%P\n") | while IFS= read -r file; do
		if [ -e "$dest/$file" ]; then
			tqem_log_error_and_exit "file already exist: $dest/$file"
		fi
	done
}

create_dest_dir() {
	local dest="$1"

	if [ -e "$dest" ]; then
		if [ ! -d "$dest" ]; then
			ls -l "$dest"
			tqem_log_error_and_exit "cannot create a directory here: $dest"
		fi
	else
		if [ "$DEST_IS_FILE" = "true" ]; then
				mkdir -p "$(dirname "$dest")"
		else
			mkdir -p "$dest"
		fi
	fi
}

copy_source_to_dest() {
	local source="$1"
	local dest="$2"

	# Validate arguments
	if [ -z "$source" ]; then
		tqem_log_error_and_exit "missing mandatory SOURCE argument"
	fi

	if [ -z "$dest" ]; then
		tqem_log_error_and_exit "missing mandatory DESTINATION argument"
	fi

	if [ ! -e "$source" ]; then
		tqem_log_error_and_exit "source does not exist: $source"
	fi

	# Copy a directory
	if [ -d "$source" ]; then
		if [ "$DEST_IS_FILE" = "true" ]; then
			tqem_log_error_and_exit "cannot copy a directory into a file (source: $source, dest: $dest)"
		fi

		if [ -n "$LINK" ]; then
			tqem_log_error_and_exit "only a file can be linked (source: $source)"
		fi

		if [ -d "$dest" ] && [ "$OVERWRITE" != "true" ]; then
			fail_if_src_file_exists_in_dest_dir "$source" "$dest"
		fi

		create_dest_dir "$dest"
		# Append a slash to source - copy only the content of a source directory
		rsync -zav --recursive "${source}/" "$dest"

	# Copy a file
	elif [ -f "$source" ]; then
		if [ "$DEST_IS_FILE" = "true" ] && [ -d "$dest" ]; then
			tqem_log_error_and_exit "cannot copy to an existing directory in destination-file mode: $dest"
		fi

		if [ "$OVERWRITE" != "true" ] && [ -d "$dest" ] && [ -f "$dest/$(basename "$source")" ]; then
			tqem_log_error_and_exit "file already exists (source: $source, dest: $dest)"
		fi

		if [ "$OVERWRITE" != "true" ] && [ -f "$dest" ]; then
			tqem_log_error_and_exit "file already exists (source: $source, dest: $dest)"
		fi

		create_dest_dir "$dest"
		rsync -zav "$source" "$dest"

		# always overwrite links for workflows with latest/stable builds
		if [ -n "$LINK" ]; then
			if [ "$DEST_IS_FILE" = "true" ]; then
				(cd "$(dirname "$dest")" && ln -sf "$(basename "$source")" "$(basename "$LINK")")
			else
				(cd "$dest" && ln -sf "$(basename "$source")" "$(basename "$LINK")")
			fi
		fi
	else
		tqem_log_error_and_exit "source is neither a file nor a directory: $source"
	fi

	# Ensure the data is written to disk
	sync
}
