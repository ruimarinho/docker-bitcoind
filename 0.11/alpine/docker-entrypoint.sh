#!/bin/sh
set -e

if [[ -n "${UID+x}" ]]; then
  usermod -o -u "$UID" bitcoin
fi

if [[ -n "${GID+x}" ]]; then
  groupmod -o -g "$GID" bitcoin
fi

echo "$0: assuming bitcoin user:group $(id -u bitcoin):$(id -g bitcoin)"

if [ $(echo "$1" | cut -c1) = "-" ]; then
  echo "$0: assuming arguments for bitcoind"

  set -- bitcoind "$@"
fi

if [ $(echo "$1" | cut -c1) = "-" ] || [ "$1" = "bitcoind" ]; then
  mkdir -p "$BITCOIN_DATA"
  chmod 700 "$BITCOIN_DATA"
  chown -R bitcoin:bitcoin "$BITCOIN_DATA"

  echo "$0: setting data directory to $BITCOIN_DATA"

  set -- "$@" -datadir="$BITCOIN_DATA"
fi

if [ "$1" = "bitcoind" ] || [ "$1" = "bitcoin-cli" ] || [ "$1" = "bitcoin-tx" ]; then
  echo
  exec su-exec bitcoin "$@"
fi

echo
exec "$@"
