#/bin/bash

WD=$(pwd)

# Ask user to make system changes
while true; do
read -p "This script will make changes to your Linux installation. Do you want to proceed? (y/n) " yn
case $yn in 
        [yY] ) echo "OK! We will proceed.";
                break;;
        [nN] ) echo "OK! Exiting the script.";
                exit;;
        * ) echo "Your answer is invalid.";;
esac
done

# Ask user to run prerequisites script
while true; do
read -p "Do you want to run the prerequisites script? This will prepare your environment to run the Grid backend. (y/n) " yn
case $yn in 
        [yY] ) echo "OK! We will run the prerequisites script.";
                sh ../prep-env-prereq.sh
                break;;
        [nN] ) echo "OK! Moving to the next step...";
                break;;
        * ) echo "Your answer is invalid.";;
esac
done

## Create directories
mkdir -p /srv/tfchain/chains/tfchain_testnet/db /srv/indexer /srv/processor /srv/caddy/data /srv/caddy/config /srv/caddy/log ~/grid_snapshots_tmp

## Download snapshots, extract and remove archives
cd ~/grid_snapshots_tmp
rsync -Lv --progress --partial rsync://bknd.snapshot.grid.tf:34873/gridsnapshotstest/tfchain-testnet-latest.tar.gz .
tar xvf tfchain-testnet-latest.tar.gz -C /srv/tfchain/chains/tfchain_testnet/db/
rm tfchain-testnet-latest.tar.gz
rsync -Lv --progress --partial rsync://bknd.snapshot.grid.tf:34873/gridsnapshotstest/indexer-testnet-latest.tar.gz .
tar xvf indexer-testnet-latest.tar.gz -C /srv/indexer/
rm indexer-testnet-latest.tar.gz
rsync -Lv --progress --partial rsync://bknd.snapshot.grid.tf:34873/gridsnapshotstest/processor-testnet-latest.tar.gz .
tar xvf processor-testnet-latest.tar.gz -C /srv/processor/
rm processor-testnet-latest.tar.gz

## Clean up 
cd "$WD"
rm -r ~/grid_snapshots_tmp

# Copy Cadyfile from example
cp Caddyfile-example Caddyfile

## Start Grid backed services with docker-compose
docker compose --env-file .secrets.env --env-file .env up -d
