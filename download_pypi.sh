#!/bin/bash

# Define variables
DIR_DOWNLOADS=$(mktemp -d)
DIR_MIRROR="simple/"

# Setup conda
source $HOME/anaconda3/etc/profile.d/conda.sh

# Create pypi-miror environment if required
RESULT=$(conda env list | grep -c pypi-mirror)
if [ $RESULT -eq 0 ]
then
    conda env create --file environment.yml
    conda activate pypi-mirror
else
    conda activate pypi-mirror
fi

# Download python packages
while read PKG
do
  BINARY=0
  for PLATFORM in win_amd64 manylinux1_x86_64 linux_x86_64 manylinux2014_x86_64 manylinux2010_x86_64 any
  do
    for ABI in none abi3 cp37m
    do
      for IMPL in py cp
      do
        for VER in 37 36 35 34 33 32 3 30
        do
          pypi-mirror download \
            -d $DIR_DOWNLOADS \
            --platform $PLATFORM \
            --abi $ABI \
            --implementation $IMPL \
            --python-version $VER \
            $PKG && BINARY=1
        done
      done
    done
  done
    if [ $BINARY-eq 0 ]
    then
        pypi-mirror download -d $DIR_DOWNLOADS $pkg
    fi
done < ./packages.txt

# Create mirror structure
pypi-mirror create -d $DIR_DOWNLOADS -m $DIR_MIRROR

# Exit pypi-mirror environment and return to previous directory
rm -R $DIR_DOWNLOADS
conda deactivate
if [ $RESULT -eq 0 ]
then
    conda remove -y -n pypi-mirror --all
fi
