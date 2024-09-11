#/bin/bash
printf "Stopping tfchain validator\n"
docker stop tfchain-validator
sleep 10

## Remove files older then 2 days
find /storage/rsync-public/ -mtime +2 -exec rm {} \;

## TFchain node
printf "Creating tfchain snapshot\n"
cd /srv/tfchain/chains/tfchain_mainnet/db/
#tar -cv -I 'xz -9 -T0' -f "/storage/rsync-public/mainnet/tfchain-mainnet-$(date '+%Y-%m-%d').tar.gz" *
tar --use-compress-program="pigz -k --best --recursive | pv " -cf "/storage/rsync-public/tfchain-mainnet-$(date '+%Y-%m-%d').tar.gz" *

printf "Starting validator again\n"
docker start tfchain-validator
sleep 10

printf "Removing and recreating ln to latest\n"
cd /storage/rsync-public/mainnet/
rm tfchain-mainnet-latest.tar.gz
ln -s tfchain-mainnet-$(date '+%Y-%m-%d').tar.gz tfchain-mainnet-latest.tar.gz
