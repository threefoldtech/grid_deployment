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
mkdir -p /srv/tfchain/chains/tfchain_mainnet/db ~/grid_snapshots_tmp

## Download snapshots, extract and remove archives
cd ~/grid_snapshots_tmp
rsync -Lv --progress --partial rsync://bknd.snapshot.grid.tf:34873/gridsnapshots/tfchain-mainnet-latest.tar.gz .
tar -I pigz -xf tfchain-mainnet-latest.tar.gz -C /srv/tfchain/chains/tfchain_mainnet/db/
rm tfchain-mainnet-latest.tar.gz

## Clean up 
cd "$WD"
rm -r ~/grid_snapshots_tmp

## Start Grid backed services with docker-compose
docker compose --env-file .secrets.env --env-file .env up -d
