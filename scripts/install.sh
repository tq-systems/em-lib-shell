#!/bin/bash
# SPDX-License-Identifier: LicenseRef-TQSPSLA-1.0.3
#
# More license information can be found in the root folder.
# This file is part of the shell library.
#
# Copyright (c) 2025 TQ-Systems GmbH <license@tq-group.com>, D-82229 Seefeld, Germany. All rights reserved.
# Author: Christoph Krutz

set -e

LIB_DIR="/usr/local/lib/tqem/shell"
BIN_DIR="/usr/local/bin"

mkdir -p "$LIB_DIR" "$BIN_DIR"

cp -f lib/*.sh "$LIB_DIR"/
cp -f bin/*.sh "$BIN_DIR"/
