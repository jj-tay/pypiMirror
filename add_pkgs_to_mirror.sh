#!/bin/bash
set -e

# Create throwaway conda env to figure out package dependencies
CONDA_ENV=bandersnatch$RANDOM
conda create -y -n $CONDA_ENV pip
conda activate $CONDA_ENV

# Install packages
while read pkg
    do
        pip install --no-input $pkg
done < pkgs_to_add.txt

# Stage packages to be mirrored
pip list | awk '{print $1}' | sed '1,2d' >> pkgs_in_mirror.txt
sort -uio pkgs_in_mirror.txt pkgs_in_mirror.txt

# Delete throwaway conda env
conda deactivate
conda remove -n $CONDA_ENV --all -y

# Activate bandersnatch environment
conda activate bandersnatch

# Add packages to mirror
CONF=$(mktemp)
cp mirror-linux.conf $CONF
sed 's/^/    /' pkgs_in_mirror.txt >> $CONF
bandersnatch -c $CONF mirror --force-check

# Exit bandersnatch environment
conda deactivate

# Sync to S3
aws s3 sync bandersnatch/web s3://s3fs-mount-s3-prod/hdbpypi --delete --debug --profile hdbba-s3fs
