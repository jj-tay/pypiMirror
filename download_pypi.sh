#!/bin/bash

# Define variables
DIR_DOWNLOADS="downloads/"
DIR_MIRROR="mirror/"

# Setup conda
source $HOME/anaconda3/etc/profile.d/conda.sh

# Create conda-miror environment if required
RESULT=$(conda env list | grep -c pypi-mirror)
if [ $RESULT -eq 0 ]
then
    conda env create --file environment.yml
    conda activate pypi-mirror
else
    conda activate pypi-mirror
fi

# Download python packages
while read pkg
do
    if pypi-mirror download -bd $DIR_DOWNLOADS $pkg
    then
        :
    else
        pypi-mirror download -d $DIR_DOWNLOADS $pkg
    fi
done < ./packages.txt

# Create mirror structure
pypi-mirror create -d $DIR_DOWNLOADS -m $DIR_MIRROR

# Exit pypi-mirror environment and return to previous directory
conda deactivate
if [ $RESULT -eq 0 ]
then
    conda remove -y -n pypi-mirror --all
fi