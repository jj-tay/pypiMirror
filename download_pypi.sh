#!/bin/bash

# Setup conda
source $HOME/anaconda3/etc/profile.d/conda.sh

# Create conda-miror environment if required
RESULT=$(conda env list | grep -c pypi-mirror)
if [ $RESULT -eq 0 ]
then
    conda create --file environment.yml
    conda activate pypi-mirror
    pip install -r requirement.txt
else
    conda activate pypi-mirror
fi

# Download python packages
while read pkg
do
    pypi-mirror download -bd download/ $pkg
    pypi-mirror download -d download/ $pkg
done < ./packages.txt

# Create mirror structure
pypi-mirror create -d download/ -m mirror/

# Exit pypi-mirror environment and return to previous directory
conda deactivate
if [ $RESULT -eq 0 ]
then
    conda remove -y -n pypi-mirror --all
fi