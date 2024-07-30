#/bin/bash
printf "Stopping tfchain public node / graphql stack and sleep for 10 sec\n"
docker stop processor_query_node
docker stop processor
docker stop processor_db
docker stop indexer_explorer
docker stop indexer_gateway
docker stop indexer_ingest
docker stop indexer_db
docker stop tfchain-public-node
sleep 10

## Remove files older then 1 day
find /storage/rsync-public/ -mtime +1 -exec rm {} \;

## TFchain node
printf "Creating tfchain snapshot\n"
cd /srv/tfchain/chains/tfchain_testnet/db/
#tar -cv -I 'xz -9 -T0' -f "/storage/rsync-public/tfchain-testnet-$(date '+%Y-%m-%d').tar.gz" *
tar --use-compress-program="pigz -k --best --recursive | pv " -cf "/storage/rsync-public/tfchain-testnet-$(date '+%Y-%m-%d').tar.gz" *

printf "Starting public node again\n"
docker start tfchain-public-node
sleep 10

printf "Removing and recreating ln to latest\n"
cd /storage/rsync-public/
rm tfchain-testnet-latest.tar.gz
ln -s tfchain-testnet-$(date '+%Y-%m-%d').tar.gz tfchain-testnet-latest.tar.gz


## Graphql - Indexer
printf "Creating indexer snapshot\n"
cd /srv/indexer/
#tar -cv -I 'xz -9 -T0' -f "/storage/rsync-public/indexer-testnet-$(date '+%Y-%m-%d').tar.gz" *
tar --use-compress-program="pigz -k --best --recursive | pv " -cf "/storage/rsync-public/indexer-testnet-$(date '+%Y-%m-%d').tar.gz" *

printf "Starting indexer again\n"
docker start indexer_db
docker start indexer_ingest
docker start indexer_gateway
docker start indexer_explorer

printf "Removing and recreating ln to latest\n"
cd /storage/rsync-public/
rm indexer-testnet-latest.tar.gz
ln -s indexer-testnet-$(date '+%Y-%m-%d').tar.gz indexer-testnet-latest.tar.gz


## Graphql - Processor
printf "Creating processor snapshot\n"
cd /srv/processor/
#tar -cv -I 'xz -9 -T0' -f "/storage/rsync-public/processor-testnet-$(date '+%Y-%m-%d').tar.gz" *
tar --use-compress-program="pigz -k --best --recursive | pv " -cf "/storage/rsync-public/processor-testnet-$(date '+%Y-%m-%d').tar.gz" *

printf "Starting processor again\n"
docker start processor_db
docker start processor
docker start processor_query_node

printf "Removing and recreating ln to latest\n"
cd /storage/rsync-public/
rm processor-testnet-latest.tar.gz
ln -s processor-testnet-$(date '+%Y-%m-%d').tar.gz processor-testnet-latest.tar.gz


## Send over to Grid-snapshots server and set ln
scp /storage/rsync-public/tfchain-testnet-$(date '+%Y-%m-%d').tar.gz grid-snapshots:/storage/rsync-public/testnet/
scp /storage/rsync-public/indexer-testnet-$(date '+%Y-%m-%d').tar.gz grid-snapshots:/storage/rsync-public/testnet/
scp /storage/rsync-public/processor-testnet-$(date '+%Y-%m-%d').tar.gz grid-snapshots:/storage/rsync-public/testnet/
ssh grid-snapshots sh /opt/snapshots/testnet-set-ln.sh
