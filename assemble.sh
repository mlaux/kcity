#!/bin/sh

AS="../64tass-1.59.3120-src/64tass"
"$AS" -a -x -X -b src/kcity.asm -o out.sfc -l out.vice -L out.list --verbose-list
