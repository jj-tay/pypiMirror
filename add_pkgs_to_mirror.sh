#!/bin/bash
set -e

# Install packages
while read pkg
    do
      # Create throwaway conda env to figure out package dependencies
      CONDA_ENV=bandersnatch$RANDOM
      conda create -y -n $CONDA_ENV pip conda
      conda activate $CONDA_ENV

      pip install --no-input $pkg

      # Stage packages to be mirrored
      pip list | awk '{print $1}' | sed '1,2d' >> pkgs_in_mirror.txt
      sort -uio pkgs_in_mirror.txt pkgs_in_mirror.txt

      # Delete throwaway conda env
      conda deactivate
      conda remove -n $CONDA_ENV --all -y
done < pkgs_to_add.txt

# Activate bandersnatch environment
conda activate bandersnatch

# Add packages to mirror
# Use AWS shared credentials via profile
export AWS_PROFILE=hdbba-s3fs
# Optional if credentials/config are in non-default locations:
# export AWS_SHARED_CREDENTIALS_FILE="$HOME/.aws/credentials"
# export AWS_CONFIG_FILE="$HOME/.aws/config"
CONF=$(mktemp)
cp mirror-linux.conf $CONF
sed 's/^/    /' pkgs_in_mirror.txt >> $CONF
bandersnatch -c $CONF mirror --force-check

# Exit bandersnatch environment
conda deactivate
