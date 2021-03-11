#!/usr/bin/env bash

# replicate A -> B/A and B -> C
# Following initial replication, repeat the cycle uysing incremental send/recv

# Modified to use `sudo` where required and `zfs allow`
# so operations will be performed as a non-root user.

# probably skip these if copy/past commands to shell
set -o xtrace   # display commands as they are executed
set -o errexit  # bail on any errors
set -o nounset  # bail if undeclared variable

# create disk files to use as physical devices
starting_point=$(pwd)
truncate -s 64MiB ./fakedisk_original
truncate -s 64MiB ./fakedisk_add

# create pools using these devices
sudo zpool create -m "$starting_point"/original original  \
    "$starting_point"/fakedisk_original

zpool status original
zpool list original
sudo zpool add original "$starting_point"/fakedisk_add
zpool status original
zpool list original

sudo zpool destroy -f original
rm ./fakedisk_original ./fakedisk_add
sudo rm -r original
