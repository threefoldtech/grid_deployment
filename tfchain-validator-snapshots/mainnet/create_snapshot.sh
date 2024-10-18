#/bin/bash
printf "Stopping tfchain validator\n"
docker stop tfchain-validator
sleep 10

## Remove files older then 2 days
find /storage/rsync-public/ -mtime +2 -exec rm {} \;

## TFchain node
printf "Creating tfchain validator snapshot\n"
cd /srv/tfchain/chains/tfchain_mainnet/db/
tar --use-compress-program="pigz -k --best --recursive | pv " -cf "/storage/rsync-public/tfchain-mainnet-validator-$(date '+%Y-%m-%d').tar.gz" *

printf "Starting validator again\n"
docker start tfchain-validator
sleep 10

printf "Removing and recreating ln to latest\n"
cd /storage/rsync-public/
rm tfchain-mainnet-validator-latest.tar.gz
ln -s tfchain-mainnet-validator-$(date '+%Y-%m-%d').tar.gz tfchain-mainnet-validator-latest.tar.gz

## Send over to Grid-snapshots server and set ln
scp /storage/rsync-public/tfchain-mainnet-validator-$(date '+%Y-%m-%d').tar.gz grid-backend-snapshots:/storage/rsync-public/mainnet/
ssh grid-backend-snapshots sh /opt/snapshots/mainnet-validator-set-ln.sh
