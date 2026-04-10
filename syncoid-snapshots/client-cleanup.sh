#!/usr/bin/env bash

# replicate A -> B/A and B -> C
# Following initial replication, repeat the cycle uysing incremental send/recv

# Modified to use `sudo` where required and `zfs allow`
# so operations will be performed as a non-root user.

# probably skip these if copy/past commands to shell
set -o xtrace   # display commands as they are executed
set -o errexit  # bail on any errors
set -o nounset  # bail if undeclared variable

starting_point=$(pwd)

# cleanup
cd "$starting_point"
for i in A 
do
    sudo zpool destroy -f "$i"
    rm "fakedisk_${i}"
    sudo rm -r "$i"
done
