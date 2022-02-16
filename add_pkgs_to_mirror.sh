#!/bin/bash
set -e

# Record start time for use to detect new files later
START_DATETIME=$(date +"%F %T")

# Setup conda
source $HOME/miniconda3/etc/profile.d/conda.sh

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

# Create bandersnatch environment if required
RESULT=$(conda env list | grep -c bandersnatch)
if [ $RESULT -eq 0 ]
    then
        conda env create -f environment.yml
        conda activate bandersnatch
    else
        conda activate bandersnatch
fi

# Add packages to mirror
CONF=$(mktemp)
cp mirror.conf $CONF
sed 's/^/    /' pkgs_in_mirror.txt >> $CONF
bandersnatch -c $CONF mirror

# Exit bandersnatch environment
conda deactivate
if [ $RESULT -eq 0 ]
    then
        conda remove -n bandersnatch --all -y
fi

# Copy new files to modified folder to ease file transfers
if [ -d to_transfer ]
    then
	    rm -rf to_transfer/
fi
mkdir to_transfer
find \
    $(grep 'directory' mirror.conf | cut -d "=" -f 2 | sed -e 's/^ *//' -e 's/ *$//') \
    -type f \
    -newermt "$START_DATETIME" \
    -exec rsync -R {} to_transfer \;
