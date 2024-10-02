#/bin/bash
printf "Stopping tfchain validator\n"
docker stop tfchain-validator
sleep 10

## Remove files older then 2 days
find /storage/rsync-public/ -mtime +2 -exec rm {} \;

## TFchain node
printf "Creating tfchain validator snapshot\n"
cd /srv/tfchain/chains/tfchain_devnet/db
tar --use-compress-program="pigz -k --best --recursive | pv " -cf "/storage/rsync-public/tfchain-devnet-validator-$(date '+%Y-%m-%d').tar.gz" *

printf "Starting validator again\n"
docker start tfchain-validator
sleep 10

printf "Removing and recreating ln to latest\n"
cd /storage/rsync-public/
rm tfchain-devnet-validator-latest.tar.gz
ln -s tfchain-devnet-validator-$(date '+%Y-%m-%d').tar.gz tfchain-devnet-validator-latest.tar.gz
