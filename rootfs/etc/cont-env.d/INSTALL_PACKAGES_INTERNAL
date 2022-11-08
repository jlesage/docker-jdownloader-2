#!/bin/sh

set -e # Exit immediately if a command exits with a non-zero status.
set -u # Treat unset variables as an error.

if [ -z "${INSTALL_PACKAGES:-}" ] && [ -n "${INSTALL_EXTRA_PKGS:-}" ]
then
    >&2 echo "Usage of INSTALL_EXTRA_PKGS environment variable is deprecated.  INSTALL_PACKAGES should be used instead."
    echo "$INSTALL_EXTRA_PKGS"
else
    exit 100
fi

# vim:ft=sh:ts=4:sw=4:et:sts=4
