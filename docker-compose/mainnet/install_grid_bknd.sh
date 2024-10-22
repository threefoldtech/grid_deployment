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
mkdir -p /srv/tfchain/chains/tfchain_mainnet/db /srv/indexer /srv/processor /srv/caddy/data /srv/caddy/config /srv/caddy/log /srv/grid_snapshots_tmp

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

# Download and extract tfchain snapshot
download_with_retry "rsync://bknd.snapshot.grid.tf:34873/gridsnapshots/tfchain-mainnet-latest.tar.gz" "tfchain-mainnet-latest.tar.gz"
if [ $? -eq 0 ]; then
  pv tfchain-mainnet-latest.tar.gz | tar -I pigz -x -C /srv/tfchain/chains/tfchain_mainnet/db/
  rm tfchain-mainnet-latest.tar.gz
fi

# Download and extract indexer snapshot
download_with_retry "rsync://bknd.snapshot.grid.tf:34873/gridsnapshots/indexer-mainnet-latest.tar.gz" "indexer-mainnet-latest.tar.gz"
if [ $? -eq 0 ]; then
  pv indexer-mainnet-latest.tar.gz | tar -I pigz -x -C /srv/indexer/
  rm indexer-mainnet-latest.tar.gz
fi

# Download and extract processor snapshot
download_with_retry "rsync://bknd.snapshot.grid.tf:34873/gridsnapshots/processor-mainnet-latest.tar.gz" "processor-mainnet-latest.tar.gz"
if [ $? -eq 0 ]; then
  pv processor-mainnet-latest.tar.gz | tar -I pigz -x -C /srv/processor/
  rm processor-mainnet-latest.tar.gz
fi

## Clean up 
cd "$WD"
rm -r /srv/grid_snapshots_tmp

# Copy Caddyfile from example
cp Caddyfile-example Caddyfile

## Start Grid backend services with docker-compose
docker compose --env-file .secrets.env --env-file .env up -d