#!/bin/sh

# Authorised users should sign their commit with PGP to allow the deployment of
# the code to production

if [ "$USER" = "ludovic" ]; then
  git config commit.gpgsign true
fi

