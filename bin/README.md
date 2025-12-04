# Executables
## tqem-copy-safe.sh
NAME

       tqem-copy-safe.sh - safely copy file or directory without overwriting

SYNOPSIS

       tqem-copy-safe.sh SOURCE DESTINATION [OPTIONS]

DESCRIPTION

       Copy SOURCE to DESTINATION.

       SOURCE can be a file, a directory or a link.
       If SOURCE is directory, only the content of it will be copied.
       DESTINATION is always a directory.
       The target files are created without write permissions to prevent
       accidental deleting/overwriting.

       -L LINK, --create-link=LINK
              create a relative symbolic link (requires a file in SOURCE)
              LINK is a mandatory argument for this option

       -l, --links
              copy the link and the corresponding file (requires a file in SOURCE)
              the link in the destination directory is relative

## tqem-copy.sh
NAME

       tqem-copy.sh - copy file or directory

SYNOPSIS

       tqem-copy.sh SOURCE DESTINATION [OPTIONS]

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

## tqem-device.sh
NAME

       tqem-device.sh - print device information

SYNOPSIS

       tqem-device.sh COMMAND DEVICE

DESCRIPTION

       Print specific device information to stdout.

       The following commands exist:

       arch        - print the architecture
       bootloaders - print the bootloaders
       machine     - print the machine
       product-id  - print the product ID
       subtype     - print the device subtype (if existent)
       type        - print the device type

## tqem-version.sh
NAME

       tqem-version.sh - generate version string

SYNOPSIS

       tqem-version.sh

DESCRIPTION

       Generate a version string for the current repository and print it to stdout.

       TQEM_FORCE_VERSION - Environmental variable to use as predefined version string

