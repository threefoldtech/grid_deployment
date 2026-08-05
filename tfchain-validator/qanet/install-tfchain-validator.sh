#/bin/bash
# Install and start a TFchain qanet validator.
#
# Interactive by default. For unattended installs (CI, Terraform, config
# management) pass -y / --yes, or set ASSUME_YES=1 in the environment.

WD=$(pwd)

CHAIN_DB="/srv/tfchain/chains/tfchain_qa_net/db"
SNAPSHOT_TMP="/srv/grid_snapshots_tmp"
SNAPSHOT_FILE="tfchain-qanet-validator-latest.tar.gz"
SNAPSHOT_URL="rsync://bknd.snapshot.grid.tf:34873/gridsnapshotsqa/$SNAPSHOT_FILE"

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

confirm "This script will make changes to your Linux installation. Do you want to proceed?" || {
  echo "OK! Exiting the script."
  exit 0
}

if confirm "Do you want to run the prerequisites script? This will prepare your environment to run the TFchain validator."; then
  sh ../../apps/prep-env-prereq.sh
fi

## Create directories
mkdir -p "$CHAIN_DB" "$SNAPSHOT_TMP"

## Download the snapshot and extract it, unless this node already has a chain
## database — re-running the installer must not destroy a synced node.
if [ -n "$(ls -A "$CHAIN_DB" 2>/dev/null)" ]; then
  echo "Chain database already present in $CHAIN_DB, skipping the snapshot restore."
else
  cd "$SNAPSHOT_TMP"
  rsync -Lv --progress --partial "$SNAPSHOT_URL" .
  tar -I pigz -xf "$SNAPSHOT_FILE" -C "$CHAIN_DB/"
  rm -f "$SNAPSHOT_FILE"
fi

## Clean up
cd "$WD"
rm -rf "$SNAPSHOT_TMP"

## Start the validator with docker-compose
docker compose --env-file .secrets.env --env-file .env up -d
