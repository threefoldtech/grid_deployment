#/bin/bash

WD=$(pwd)

# Ask user to make system changes
while true; do
read -p "This script will make changes to your Linux installation, are you sure you want to proceed? (y/n) " yn
case $yn in 
        [yY] ) echo ok, we will proceed;
                break;;
        [nN] ) echo exiting...;
                exit;;
        * ) echo invalid response;;
esac
done

# Ask user to run prerequisites script
while true; do
read -p "Do you want to run the prerequisites script? This will prepare your environment to run the Grid backend. (y/n) " yn
case $yn in 
        [yY] ) echo ok, we will proceed;
                sh ../prep-env-prereq.sh;;
        [nN] ) echo exiting...;
                break;;
        * ) echo invalid response;;
esac
done

## Create directories
mkdir -p /srv/tfchain /srv/tfchain/chains /srv/tfchain/chains/tfchain_mainnet /srv/tfchain/chains/tfchain_mainnet/db /srv/indexer /srv/processor /srv/caddy /srv/caddy/data /srv/caddy/config /srv/caddy/log ~/grid_snapshots_tmp

## Download snapshots, extract and remove archives
cd ~/grid_snapshots_tmp
rsync -Lv --progress --partial rsync://bknd.snapshot.grid.tf:34873/gridsnapshots/tfchain-mainnet-latest.tar.gz .
tar xvf tfchain-mainnet-latest.tar.gz -C /srv/tfchain/chains/tfchain_mainnet/db/
rm tfchain-mainnet-latest.tar.gz
rsync -Lv --progress --partial rsync://bknd.snapshot.grid.tf:34873/gridsnapshots/indexer-mainnet-latest.tar.gz .
tar xvf indexer-mainnet-latest.tar.gz -C /srv/indexer/
rm indexer-mainnet-latest.tar.gz
rsync -Lv --progress --partial rsync://bknd.snapshot.grid.tf:34873/gridsnapshots/processor-mainnet-latest.tar.gz .
tar xvf processor-mainnet-latest.tar.gz -C /srv/processor/
rm processor-mainnet-latest.tar.gz

## Clean up 
cd "$WD"
rm -r ~/grid_snapshots_tmp

# Copy Cadyfile from example
cp Caddyfile-example Caddyfile

## Start Grid backed services with docker-compose
docker compose --env-file .secrets.env --env-file .env up -d
