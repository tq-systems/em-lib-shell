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

# shellcheck source=../lib/device.sh
. "$TQEM_SHELL_LIB_DIR/device.sh"

set -u

usage() {
	echo "NAME

       $SCRIPT_NAME - print device information

SYNOPSIS

       $SCRIPT_NAME COMMAND DEVICE

DESCRIPTION

       Print specific device information to stdout.

       The following commands exist:

       arch        - print the architecture
       bootloaders - print the bootloaders
       machine     - print the machine
       product-id  - print the product ID
       subtype     - print the device subtype (if existent)
       type        - print the device type
"
}

if [ "${1:-}" = "-h" ] || [ "${1:-}" = "--help" ]; then
	usage; exit 0
fi

if [ $# -ne 2 ]; then
	tqem_log_error_and_exit "Unsupported number of arguments: $#"
fi

COMMAND="$1"
DEVICE="$2"

print_device_info "$COMMAND" "$DEVICE"
