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
mkdir -p /srv/tfchain/chains/tfchain_qanet/db /srv/indexer /srv/processor /srv/caddy/data /srv/caddy/config /srv/caddy/log ~/grid_snapshots_tmp /tmp/webserver

## Download snapshots, extract and remove archives
cd ~/grid_snapshots_tmp

echo '<h1>Step 1 of 6: Downloading TFChain Snapshot</h1>' > /tmp/webserver/heading.html
rsync -Lv --progress --partial rsync://bknd.snapshot.grid.tf:34873/gridsnapshots/tfchain-qanet-latest.tar.gz . > /tmp/webserver/log
echo '<h1>Step 2 of 6: Extracting TFChain Snapshot</h1>' > /tmp/webserver/heading.html
pv tfchain-qanet-latest.tar.gz 2> /tmp/webserver/log | tar xJ -C /srv/tfchain/chains/tfchain_qanet/db/
rm tfchain-qanet-latest.tar.gz

echo '<h1>Step 3 of 6: Downloading Indexer Snapshot</h1>' > /tmp/webserver/heading.html
rsync -Lv --progress --partial rsync://bknd.snapshot.grid.tf:34873/gridsnapshots/indexer-qanet-latest.tar.gz . > /tmp/webserver/log
echo '<h1>Step 4 of 6: Extracting Indexer Snapshot</h1>' > /tmp/webserver/heading.html
pv indexer-qanet-latest.tar.gz 2> /tmp/webserver/log | tar xJ -C /srv/indexer/
rm indexer-qanet-latest.tar.gz

echo '<h1>Step 5 of 6: Downloading Processor Snapshot</h1>' > /tmp/webserver/heading.html
rsync -Lv --progress --partial rsync://bknd.snapshot.grid.tf:34873/gridsnapshots/processor-qanet-latest.tar.gz . > /tmp/webserver/log
echo '<h1>Step 6 of 6: Extracting Processor Snapshot</h1>' > /tmp/webserver/heading.html
pv processor-qanet-latest.tar.gz 2> /tmp/webserver/log | tar xJ -C /srv/processor/
rm processor-qanet-latest.tar.gz

## Clean up 
cd "$WD"
rm -r ~/grid_snapshots_tmp
zinit stop webserver
rm /scripts/webserver.sh
rm /etc/zinit/webserver.yaml

# Copy Cadyfile from example
cp Caddyfile-example Caddyfile

## Start Grid backed services with docker-compose
docker compose --env-file .secrets.env --env-file .env up -d
