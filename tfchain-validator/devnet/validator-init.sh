#/bin/bash
# Insert the aura and grandpa session keys of a NEW validator, based on the
# TFchain wallet mnemonic in .secrets.env.
#
# Skip this when moving an EXISTING validator to another machine: copy its
# keystore instead, see the readme.
#
# Interactive by default; pass -y / --yes or set ASSUME_YES=1 to run unattended.

ASSUME_YES="${ASSUME_YES:-0}"

for arg in "$@"; do
  case "$arg" in
    -y|--yes) ASSUME_YES=1 ;;
    -h|--help)
      echo "usage: $0 [-y|--yes]"
      echo "  -y, --yes   assume yes to all questions (unattended install)"
      echo "  ASSUME_YES=1 in the environment does the same."
      exit 0 ;;
  esac
done

# Ask a yes/no question, unless we are running unattended.
confirm() {
  [ "$ASSUME_YES" = "1" ] && return 0
  while true; do
    read -p "$1 (y/n) " yn
    case $yn in
      [yY] ) return 0 ;;
      [nN] ) return 1 ;;
      * ) echo "Your answer is invalid." ;;
    esac
  done
}

confirm "This script requires you to have created a .secrets.env file that contains your TFchain validator wallet mnemonic. Proceed?" || {
  echo "OK! Exiting the script."
  exit 0
}

## Create directories
mkdir -p /srv/tfchain/

## Insert the keys
docker compose --env-file .secrets.env --env-file .env -f validator-init.yml up

echo
echo "Keys inserted. Remove the MNEMONIC line from .secrets.env now — it is not"
echo "needed to run the validator."
