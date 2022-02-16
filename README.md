# pypiMirror
Bash script to mirror some PyPi packages

## How to use

The script requires 2 input files placed in the same directory as where the script is.

1. The first input file is called `pkgs_to_add.txt` which contains the packages to be added to the local mirror. Each package is one line.
2. The second file is called `mirror.conf` and is bandersnatch configuration file. As the packages and its dependencies will be appended to this configuration file at runtime for mirroring PyPi, the file must end with `packages =` as part of `[allowlist]`. Please see `sample_mirror.conf` as an example.
