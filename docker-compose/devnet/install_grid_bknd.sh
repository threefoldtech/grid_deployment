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
mkdir -p /storage/srv/tfchain/chains/tfchain_devnet/db /storage/srv/indexer /storage/srv/processor /storage/srv/caddy/data /storage/srv/caddy/config /storage/srv/caddy/log /storage/grid_snapshots_tmp /storage/tmp/webpage

## Download snapshots, extract and remove archives
cd /storage/grid_snapshots_tmp

echo '<h1>Step 1 of 6: Downloading TFChain Snapshot</h1>' > /storage/tmp/webpage/heading.html
rsync -Lv --progress --partial rsync://bknd.snapshot.grid.tf:34873/gridsnapshots/tfchain-devnet-latest.tar.gz . > /storage/tmp/webpage/log
echo '<h1>Step 2 of 6: Extracting TFChain Snapshot</h1>' > /storage/tmp/webpage/heading.html
pv -f tfchain-devnet-latest.tar.gz 2> /storage/tmp/webpage/log | tar xJ -C /storage/srv/tfchain/chains/tfchain_devnet/db/
rm tfchain-devnet-latest.tar.gz

echo '<h1>Step 3 of 6: Downloading Indexer Snapshot</h1>' > /storage/tmp/webpage/heading.html
rsync -Lv --progress --partial rsync://bknd.snapshot.grid.tf:34873/gridsnapshots/indexer-devnet-latest.tar.gz . > /storage/tmp/webpage/log
echo '<h1>Step 4 of 6: Extracting Indexer Snapshot</h1>' > /storage/tmp/webpage/heading.html
pv -f indexer-devnet-latest.tar.gz 2> /storage/tmp/webpage/log | tar xJ -C /storage/srv/indexer/
rm indexer-devnet-latest.tar.gz

echo '<h1>Step 5 of 6: Downloading Processor Snapshot</h1>' > /storage/tmp/webpage/heading.html
rsync -Lv --progress --partial rsync://bknd.snapshot.grid.tf:34873/gridsnapshots/processor-devnet-latest.tar.gz . > /storage/tmp/webpage/log
echo '<h1>Step 6 of 6: Extracting Processor Snapshot</h1>' > /storage/tmp/webpage/heading.html
pv -f processor-devnet-latest.tar.gz 2> /storage/tmp/webpage/log | tar xJ -C /storage/srv/processor/
rm processor-devnet-latest.tar.gz

## Clean up 
cd "$WD"
rm -r /storage/tmp/grid_snapshots_tmp
zinit stop webpage
zinit stop caddy
zinit forget webpage
zinit forget caddy
mv /etc/zinit/caddy.yaml /etc/zinit/caddy.yaml.inactive
mv /etc/zinit/webpage.yaml /etc/zinit/webpage.yaml.inactive
rm -r mnt/disk/tmp/webpage

# Copy Cadyfile from example
cp Caddyfile-example Caddyfile

## Start Grid backed services with docker-compose
docker compose --env-file .secrets.env --env-file .env up -d
