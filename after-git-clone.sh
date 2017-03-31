#!/bin/sh

# Authorised users should sign their commit with PGP to allow the deployment of
# the code to production

case "$USER" in
  mirco|ludovic)
    git config commit.gpgsign true
    ;;
esac
