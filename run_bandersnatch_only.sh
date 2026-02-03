#!/bin/bash
set -e

# Activate bandersnatch environment
conda activate bandersnatch

# Add packages to mirror
CONF=$(mktemp)
cp mirror-linux.conf $CONF
sed 's/^/    /' pkgs_in_mirror.txt >> $CONF
bandersnatch -c $CONF mirror --force-check
rm $CONF

# Exit bandersnatch environment
conda deactivate
