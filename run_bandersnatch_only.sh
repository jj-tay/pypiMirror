#!/bin/bash
set -e

# Activate bandersnatch environment
conda activate bandersnatch

# Add packages to mirror
CONF=$(mktemp)
cp mirror-linux.conf $CONF
sed 's/^/    /' pkgs_in_mirror.txt >> $CONF
bandersnatch -c $CONF mirror
bandersnatch -c $CONF mirror
bandersnatch -c $CONF mirror

# Exit bandersnatch environment
conda deactivate

# Sync to S3
aws s3 sync bandersnatch/web s3://s3fs-mount-s3-prod/hdbpypi --delete --debug --profile hdbba-s3fs
