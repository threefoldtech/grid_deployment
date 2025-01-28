#!/bin/bash

WD=$(pwd)

# Ask user to make system changes
while true; do
    read -p "This script will make changes to your Linux installation. Do you want to proceed? (y/n) " yn
    case $yn in
        [yY] ) echo "OK! We will proceed."; break;;
        [nN] ) echo "OK! Exiting the script."; exit;;
        * ) echo "Your answer is invalid.";;
    esac
done

# Ask user to run prerequisites script
while true; do
    read -p "Do you want to run the prerequisites script? This will prepare your environment to run the Grid backend. (y/n) " yn
    case $yn in
        [yY] ) echo "OK! We will run the prerequisites script."; sh ../../apps/prep-env-prereq.sh; break;;
        [nN] ) echo "OK! Moving to the next step..."; break;;
        * ) echo "Your answer is invalid.";;
    esac
done

## Create directories
mkdir -p /srv/tfchain/chains/tfchain_testnet/db /srv/indexer /srv/processor /srv/caddy/data /srv/caddy/config /srv/caddy/log /srv/grid_snapshots_tmp

## Retry mechanism
max_retries=3
retry_delay=5

# Function to download with retry
download_with_retry() {
  local file_url=$1
  local output_file=$2
  local retry_count=0
  
  while [ $retry_count -lt $max_retries ]; do
    echo "Attempting to download $output_file (Attempt $((retry_count+1))/$max_retries)..."
    
    if rsync -Lv --progress --partial "$file_url" "$output_file"; then
      echo "Download succeeded!"
      return 0
    else
      echo "Download failed. Retrying in $retry_delay seconds..."
      retry_count=$((retry_count + 1))
      sleep $retry_delay
    fi
  done
  
  echo "Failed to download $output_file after $max_retries attempts."
  return 1
}

# Directory for temporary snapshots
cd /srv/grid_snapshots_tmp

# Download and extract snapshots with retry

# Download and extract tfchain snapshot for testnet
download_with_retry "rsync://bknd.snapshot.grid.tf:34873/gridsnapshotstest/tfchain-testnet-latest.tar.gz" "tfchain-testnet-latest.tar.gz"
if [ $? -eq 0 ]; then
  pv tfchain-testnet-latest.tar.gz | tar -I pigz -x -C /srv/tfchain/chains/tfchain_testnet/db/
  rm tfchain-testnet-latest.tar.gz
fi

## Clean up 
cd "$WD"
rm -r /srv/grid_snapshots_tmp

# Copy Caddyfile from example
cp Caddyfile-example Caddyfile

## Start Grid backend services with docker-compose
docker compose --env-file .secrets.env --env-file .env up -d
