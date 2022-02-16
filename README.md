# pypiMirror
Bash script to mirror some PyPi packages

## How to use

The script requires 2 input files placed in the same directory as where the script is.

1. The first input file is called `pkgs_to_add.txt` and contains the packages to be added to the local mirror. Each package is one line.

2. The second file is called `mirror.conf` and is a bandersnatch configuration file. As the packages and its dependencies will be appended to this configuration file at runtime to mirror PyPi, the file must end with `packages =` as part of `[allowlist]`. Please see `sample_mirror.conf` as an example.

## How it works

1. The script creates a throwaway conda environment and install the packages in `pkgs_to_add.txt` individually to figure out the full set of dependencies required.

2. The list of required packages and its dependencies is added to a file called `pkgs_in_mirror.txt` which serves as a master list of packages in the mirror. This file is sorted and have unique entries. Please see Note 1 for more details.

3. The script activates a conda environment with bandersnatch installed.

4. `pkgs_in_mirror.txt` is appended to `mirror.conf` to form a complete bandersnatch configuration file.

5. The script uses bandernatch to mirror the all editions of the whitelised packages from PyPi via the provided configuration file.

6. Finally, the script locates the newly added files and copies them to a folder called `to_transfer` to minimise transfer requirements.

## Note

1. The list of required packages and its dependencies can be added to mirror.conf directly. However there may be duplicate packages as the maintainer of the local mirror add packages over time. Hence an intermediate file `pkgs_in_mirror.txt` was used. 
