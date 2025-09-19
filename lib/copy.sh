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
COPY_FILE_LINK="false" # If true, the source link and the corresponding file are copied

fail_if_src_file_exists_in_dest_dir() {
	local source="$1"
	local dest_dir="$2"

	# Normalize to absolute paths
	source="$(realpath "$source")"
	dest_dir="$(realpath "$dest_dir")"

	# Find files in source
	(cd "$source" && find . -type f -printf "%P\n") | while IFS= read -r file; do
		if [ -e "$dest_dir/$file" ]; then
			tqem_log_error_and_exit "file already exist: $dest_dir/$file"
		fi
	done
}

create_dest_dir() {
	local dest_dir="$1"

	if [ -e "$dest_dir" ] && [ ! -d "$dest_dir" ]; then
			tqem_log_error_and_exit "destination exists ($dest_dir), but it is not a directory"
	fi

	mkdir -p "$dest_dir"
}

copy_source_to_dest() {
	local origin_source="$1"
	local dest_dir="$2"

	# Validate arguments
	if [ -z "$origin_source" ]; then
		tqem_log_error_and_exit "missing mandatory SOURCE argument"
	fi

	if [ -z "$dest_dir" ]; then
		tqem_log_error_and_exit "missing mandatory DESTINATION argument"
	fi

	# set -x

	# Enable to copy files or directories from symlinks
	local source origin_name follow_name
	if [ -L "$origin_source" ]; then
		source="$(realpath "$origin_source")"
		tqem_log_info "follow symlink from $origin_source to $source"

		follow_name="$(basename "$source")"
	else
		source="$origin_source"
	fi
	origin_name="$(basename "$origin_source")"

	if [ ! -e "$source" ]; then
		tqem_log_error_and_exit "source does not exist: $source"
	fi

	# Copy a directory
	if [ -d "$source" ]; then
		if [ -n "$CREATE_LINK" ]; then
			tqem_log_error_and_exit "only a file can be linked (source: $source)"
		fi

		if [ "$COPY_FILE_LINK" = "true" ]; then
			tqem_log_error_and_exit "the -l option does not support directories"
		fi

		if [ -d "$dest_dir" ] && [ "$OVERWRITE" != "true" ]; then
			fail_if_src_file_exists_in_dest_dir "$source" "$dest_dir"
		fi

		create_dest_dir "$dest_dir"
		# Append a slash to source - copy only the content of a source directory
		rsync -zav --recursive "${source}/" "$dest_dir"

	# Copy a file
	elif [ -f "$source" ]; then
		if [ -n "$CREATE_LINK" ] && [ "$COPY_FILE_LINK" = "true" ]; then
			tqem_log_error_and_exit "the -l option cannot be combined with the -L option"
		fi

		if [ ! -L "$origin_source" ] && [ "$COPY_FILE_LINK" = "true" ]; then
			tqem_log_error_and_exit "the -L option needs a link in SOURCE"
		fi

		local dest_filepath="$dest_dir/$origin_name"
		if [ -L "$origin_source" ] && [ "$COPY_FILE_LINK" = "true" ]; then
			dest_filepath="$dest_dir/$follow_name"
		fi

		if [ -d "$dest_dir" ] && [ "$OVERWRITE" != "true" ]; then
			if [ -f "$dest_filepath" ]; then
				tqem_log_error_and_exit "file already exists (source: $source, dest: $dest_filepath)"
			fi
		fi

		create_dest_dir "$dest_dir"
		rsync -zav "$source" "$dest_filepath"

		# always overwrite links for workflows with latest/stable builds
		if [ -n "$CREATE_LINK" ]; then
			(cd "$dest_dir" && ln -sf "$(basename "$source")" "$(basename "$CREATE_LINK")")
		fi

		if [ -L "$origin_source" ] && [ "$COPY_FILE_LINK" = "true" ]; then
			(cd "$dest_dir" && ln -sf "$follow_name" "$origin_name")
		fi
	else
		tqem_log_error_and_exit "source is neither a file nor a directory: $source"
	fi

	# Ensure the data is written to disk
	sync
}
