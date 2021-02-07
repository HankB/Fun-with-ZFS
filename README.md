# Fun-with-ZFS

Explore simple ZFS operations

## Motivation

Some operations that should be simple and straightforward have not been so simple for me. I found it convenient to set up some simple scripts to work through the operations and allow me to explore the results and try different options. The plan is that each subdirectory will include one or more scripts related to a particular operation or scenario along with a README with appropriate comments.

## Status

First script complete. More to come.

## Testing

Not really. Scripts are checked using `shellcheck` to provide a minimal level of error checking.

## Contributing

I'd be delighted to have additional scenarios added. I reserve the right to add requirements to PRs as I identify the need. I'll need to research what to do about copyright for projects of this type.

## Errata

Testing is performed on hosts running Debian Buster (ZFS 0.8.5) and Debian Stretch (ZFS 0.7.12) using `bash`.

