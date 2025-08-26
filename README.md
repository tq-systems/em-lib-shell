# Shell library
## Description
This shell library provides basic functions that can be sourced through the library files.
Executable scripts are also provided that make these functions available to existing applications.

## Structure of the project
The project is organized into the following directories:

- `bin`: Contains the executable scripts.
- `lib`: Contains the library files.
- `scripts`: Contains helper scripts to maintain the project.
- `test`: Contains the test scripts.

See `bin/README.md` or `lib/README.md` for more information.

## Usage
Every executable script in the `bin` directory can be run from the command line.
A help can be displayed by using the `-h` or `--help` option.

The library functions can be sourced in other scripts or applications as needed.

## Installation
The libraries with the associated scripts can be installed as follows:

    sudo make install

## License information
This project is licensed under the TQSPSLA-1.0.3 license, see LICENSE file for further details.

    SPDX-License-Identifier: LicenseRef-TQSPSLA-1.0.3

All files in this project are classified as product-specific software and bound
to the use with the TQ-Systems GmbH product: EM400
