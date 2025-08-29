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
SCRIPT_NAME="test/device.sh"

CUR_DIR="$(dirname "$0")"
export TQEM_SHELL_LIB_DIR="$CUR_DIR/../lib"

# shellcheck disable=SC1091
. "$CUR_DIR/common.sh"

fail_if_not_equal() {
	local cmd="$1"
	local device="$2"
	local expected="$3"

	if [ "$(tqem-device.sh "$cmd" "$device")" != "$expected" ]; then
		log_success_expected
	fi
}

### Commands
log_test_title "Get device type"
fail_if_not_equal type em310 hw0100
fail_if_not_equal type em4xx hw0200
fail_if_not_equal type em-cb30 hw0210
fail_if_not_equal type em-aarch64 hw02xx

log_test_title "Get device subtype"
fail_if_not_equal subtype em310 ''
fail_if_not_equal subtype em4xx ''
fail_if_not_equal subtype em-cb30 ''
fail_if_not_equal subtype em-aarch64 '{"tq,em4xx": "hw0200", "tq,am625-em-cb30": "hw0210"}'

log_test_title "Get machine"
fail_if_not_equal machine hw0100 em310
fail_if_not_equal machine hw0200 em-aarch64
fail_if_not_equal machine hw0210 em-aarch64
fail_if_not_equal machine hw02xx em-aarch64

log_test_title "Get arch"
fail_if_not_equal arch em310 armv5e
fail_if_not_equal arch em4xx aarch64
fail_if_not_equal arch em-cb30 aarch64
fail_if_not_equal arch em-aarch64 aarch64

log_test_title "Get product ID"
fail_if_not_equal product-id em310 '{"tq,em310": 18514}'
fail_if_not_equal product-id em4xx '{"tq,em4xx": 18530}'
fail_if_not_equal product-id em-cb30 '{"tq,am625-em-cb30": 18546}'
fail_if_not_equal product-id em-aarch64 '{"tq,em4xx": 18530, "tq,am625-em-cb30": 18546}'

log_test_title "Get bootloaders"
fail_if_not_equal bootloaders em310 \
	'tq_em310_256m=u-boot.sb-em310 tqs_energymanager310_256m=u-boot.sb-em310'
BOOTLOADERS_em4xx='tq_em4xx_512m=bootloader-em4xx-512m.bin tq_em4xx_1024m=bootloader-em4xx-1g.bin'
fail_if_not_equal bootloaders em4xx "$BOOTLOADERS_em4xx"
BOOTLOADERS_em_cb30='tq_am625-em-cb30_512m=bootloader-em-cb30-512m.bin tq_am625-em-cb30_1024m=bootloader-em-cb30-1g.bin tq_am625-em-cb30_2048m=bootloader-em-cb30-2g.bin'
fail_if_not_equal bootloaders em-cb30 "$BOOTLOADERS_em_cb30"
fail_if_not_equal bootloaders em-aarch64 "$BOOTLOADERS_em4xx $BOOTLOADERS_em_cb30"

log_test_title "Test that the device OR the machine can be passed as DEVICE"
fail_if_not_equal machine em310 em310
fail_if_not_equal machine em4xx em-aarch64
fail_if_not_equal machine em-cb30 em-aarch64
fail_if_not_equal machine em-aarch64 em-aarch64
fail_if_not_equal type hw0100 hw0100
fail_if_not_equal type hw0200 hw0200
fail_if_not_equal type hw0210 hw0210
fail_if_not_equal type hw02xx hw02xx

### Errors ###
log_test_title "Pass a wrong number of arguments"
if tqem-device.sh 1; then
	log_error_expected
fi
if tqem-device.sh 1 2 3; then
	log_error_expected
fi

log_test_title "Pass an unknown command"
if tqem-device.sh fail em-aarch64; then
	log_error_expected
fi

log_test_title "Pass an unknown device"
if tqem-device.sh type fail; then
	log_error_expected
fi

### Help ###
log_test_title "Show help"
if ! tqem-device.sh -h; then
	log_success_expected
fi

# Supress 2nd help output for better readability of the test log
if ! tqem-device.sh --help > /dev/null; then
	log_success_expected
fi

log_successful_tests
