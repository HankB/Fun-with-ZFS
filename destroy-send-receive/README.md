# destroy, send and receive

## Motivation

Determine what happens to backup snapshots if malware encrypts local files, deletes snapshots and these get sent to the remote. Note: current policy is to send incremental snapshots so the hacker would need to not remove the most recent snapshot or the send/recv would fail and remote files would not be altered. This effort will test two scenarios: One where the entire local filesystem is sent to the remote and another where the oldest snapshot remains and an incremental send is performed.

A second security issue is to have the remote pull the backups rather than the local system push so that the backup process cannot be tampered with from the local system.

For the purpose of demonstration, the files will be compressed (`gzip`) rather than encrypted.

## requirements

* sudo
* passwordless login to `localhost`

## 2024-09-26 Status

Files date to May of this year. Not sure if this is complete but starting on another task so I'll commit/push as is. Not `shellcheck` clean.
