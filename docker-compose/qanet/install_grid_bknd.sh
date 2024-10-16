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
                sh ../../apps/prep-env-prereq.sh
                break;;
        [nN] ) echo "OK! Moving to the next step...";
                break;;
        * ) echo "Your answer is invalid.";;
esac
done

## Create directories
mkdir -p /srv/tfchain/chains/tfchain_qa_net/db /srv/indexer /srv/processor /srv/caddy /srv/caddy/data /srv/caddy/config /srv/caddy/log /srv/grid_snapshots_tmp

## Download snapshots, extract and remove archives
cd /srv/grid_snapshots_tmp
rsync -Lv --progress --partial rsync://bknd.snapshot.grid.tf:34873/gridsnapshotsqa/tfchain-qanet-latest.tar.gz .
#tar xvf tfchain-qanet-latest.tar.gz -C /srv/tfchain/chains/tfchain_qa_net/db/
tar -I pigz -xf tfchain-qanet-latest.tar.gz -C /srv/tfchain/chains/tfchain_qa_net/db/
rm tfchain-qanet-latest.tar.gz
rsync -Lv --progress --partial rsync://bknd.snapshot.grid.tf:34873/gridsnapshotsqa/indexer-qanet-latest.tar.gz .
#tar xvf indexer-qanet-latest.tar.gz -C /srv/indexer/
tar -I pigz -xf indexer-qanet-latest.tar.gz -C /srv/indexer/
rm indexer-qanet-latest.tar.gz
rsync -Lv --progress --partial rsync://bknd.snapshot.grid.tf:34873/gridsnapshotsqa/processor-qanet-latest.tar.gz .
#tar xvf processor-qanet-latest.tar.gz -C /srv/processor/
tar -I pigz -xf processor-qanet-latest.tar.gz -C /srv/processor/
rm processor-qanet-latest.tar.gz

## Clean up 
cd "$WD"
rm -r /srv/grid_snapshots_tmp

# Copy Cadyfile from example
cp Caddyfile-example Caddyfile

## Start Grid backed services with docker-compose
docker compose --env-file .secrets.env --env-file .env up -d
