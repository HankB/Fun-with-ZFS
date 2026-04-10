#!/usr/bin/env bash
# Bash3 Boilerplate. Copyright (c) 2014, kvz.io

set -o errexit
set -o pipefail
set -o nounset
# set -o xtrace   # display commands as they are executed
############### end of Boilerplate

syncoid --version
syncoid_opts=(--quiet --no-stream)
snap_opts=(-H -o name)

echo;echo Copy A to B/A
syncoid "${syncoid_opts[@]}" --identifier=A2B A B/A
echo "A snapshots"
zfs list -t snap -r "${snap_opts[@]}" A
echo "B snapshots"
zfs list -t snap -r "${snap_opts[@]}" B
sleep 1 # Allow for differentiation of snapshots

echo;echo Copy A to C/A
syncoid "${syncoid_opts[@]}"  --identifier=A2C A C/A
echo
echo "A snapshots"
zfs list -t snap -r "${snap_opts[@]}" A
echo "C snapshots"
zfs list -t snap -r "${snap_opts[@]}" C
sleep 1 # Allow for differentiation of snapshots

echo;echo Copy A to B/A
syncoid "${syncoid_opts[@]}"  --identifier=A2B A B/A || : # prevent exit on error
echo "A snapshots"
zfs list -t snap -r "${snap_opts[@]}" A
echo "B snapshots"
zfs list -t snap -r "${snap_opts[@]}" B
sleep 1 # Allow for differentiation of snapshots

