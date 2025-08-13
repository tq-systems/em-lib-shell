# Executables
## tqem-copy.sh
NAME

       tqem-copy.sh - copy file or directory

SYNOPSIS

       tqem-copy.sh SOURCE DESTINATION [OPTIONS]

DESCRIPTION

       Copy SOURCE to DESTINATION.

       -o, --overwrite
              overwrite existing destination file(s) without errors

       -d, --destination-file
              treat DESTINATION as a normal file (requires a file in SOURCE)

       -l LINK, --link=LINK
              create a symbolic link (requires a file in SOURCE)
              LINK is a mandatory argument for this option

## tqem-version.sh
NAME

       tqem-version.sh - generate version string

SYNOPSIS

       tqem-version.sh

DESCRIPTION

       Generate a version string for the current repository and print it to stdout.

       TQEM_FORCE_VERSION - Environmental variable to use as predefined version string

