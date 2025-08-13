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

