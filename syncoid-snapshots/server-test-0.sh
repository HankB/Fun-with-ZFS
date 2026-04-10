#!/usr/bin/env bash
# Bash3 Boilerplate. Copyright (c) 2014, kvz.io

set -o errexit
set -o pipefail
set -o nounset
# set -o xtrace   # display commands as they are executed
############### end of Boilerplate
# 
# Usage ./server-test-0.sh client_host server_pool
# e.g. ./server-test-0.sh olive B

syncoid --version
syncoid_opts=(--quiet)
snap_opts=(-H -o name)

echo;echo Copy A to {client_host}:{server_pool}/A
syncoid "${syncoid_opts[@]}" --identifier=${1}2${2} A B/A
echo "${2} snapshots"
zfs list -t snap -r "${snap_opts[@]}" ${2}
