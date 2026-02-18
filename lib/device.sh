#!/bin/bash
# SPDX-License-Identifier: LicenseRef-TQSPSLA-1.0.3
#
# More license information can be found in the root folder.
# This file is part of the shell library.
#
# Copyright (c) 2025 TQ-Systems GmbH <license@tq-group.com>, D-82229 Seefeld, Germany. All rights reserved.
# Author: Christoph Krutz

set -eo pipefail

# shellcheck source=log.sh
. "$TQEM_SHELL_LIB_DIR/log.sh"

print_device_info() {
	local command="$1"
	local device="$2"

	# tqs,energymanager310 needed for upgrades from old kernels
	local bootloaders_em310='
	tq_em310_256m=u-boot.sb-em310
	tqs_energymanager310_256m=u-boot.sb-em310
'
	local bootloaders_em4xx='
	tq_em4xx_512m=bootloader-em4xx-512m.bin
	tq_em4xx_1024m=bootloader-em4xx-1g.bin
'

	local device_type device_subtype machine device_arch product_id bootloaders

	case "$device" in
	em310|hw0100)
		device_type='hw0100'
		machine='em310'
		device_arch='armv5e'
		product_id='{"tq,em310": 18514}'
		bootloaders="$bootloaders_em310"
		;;
	em4xx|hw0200)
		device_type='hw0200'
		machine='em-aarch64'
		device_arch='aarch64'
		product_id='{"tq,em4xx": 18530}'
		bootloaders="$bootloaders_em4xx"
		;;
	em-aarch64|hw02xx)
		device_type='hw02xx'
		device_subtype='{"tq,em4xx": "hw0200"}'
		machine='em-aarch64'
		device_arch='aarch64'
		product_id='{"tq,em4xx": 18530}'
		bootloaders="$bootloaders_em4xx"
		;;
	*)
		tqem_log_error_and_exit "Unknown device: $device"
		;;
	esac

	case "$command" in
	type)
		echo "$device_type"
		;;
	subtype)
		echo "$device_subtype"
		;;
	machine)
		echo "$machine"
		;;
	arch)
		echo "$device_arch"
		;;
	product-id)
		echo "$product_id"
		;;
	bootloaders)
		# pipe through xargs for consistent formatting
		echo "$bootloaders" | xargs
		;;
	*)
		tqem_log_error_and_exit "Unknown command: $command"
		;;
	esac
}
