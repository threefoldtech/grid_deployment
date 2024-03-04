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

## Remove files older then 4 days - for all nets
find /storage/rsync-public/mainnet/ -mtime +4 -exec rm {} \;
find /storage/rsync-public/testnet/ -mtime +4 -exec rm {} \;
find /storage/rsync-public/devnet/ -mtime +4 -exec rm {} \;

## TFchain node
printf "Creating tfchain snapshot\n"
cd /srv/tfchain/chains/tfchain_mainnet/db/
tar -cv -I 'xz -9 -T0' -f "/storage/rsync-public/mainnet/tfchain-mainnet-$(date '+%Y-%m-%d').tar.gz" *

printf "Starting public node again\n"
docker start tfchain-public-node
sleep 10

printf "Removing and recreating ln to latest\n"
cd /storage/rsync-public/mainnet/
rm tfchain-mainnet-latest.tar.gz
ln -s tfchain-mainnet-$(date '+%Y-%m-%d').tar.gz tfchain-mainnet-latest.tar.gz


## Graphql - Indexer
printf "Creating indexer snapshot\n"
cd /srv/indexer/
tar -cv -I 'xz -9 -T0' -f "/storage/rsync-public/mainnet/indexer-mainnet-$(date '+%Y-%m-%d').tar.gz" *

printf "Starting indexer again\n"
docker start indexer_db
docker start indexer_ingest
docker start indexer_gateway
docker start indexer_explorer

#printf "Removing and recreating ln to latest\n"
cd /storage/rsync-public/mainnet/
rm indexer-mainnet-latest.tar.gz
ln -s indexer-mainnet-$(date '+%Y-%m-%d').tar.gz indexer-mainnet-latest.tar.gz


## Graphql - Processor
printf "Creating processor snapshot\n"
cd /srv/processor/
tar -cv -I 'xz -9 -T0' -f "/storage/rsync-public/mainnet/processor-mainnet-$(date '+%Y-%m-%d').tar.gz" *

printf "Starting processor again\n"
docker start processor_db
docker start processor
docker start processor_query_node

printf "Removing and recreating ln to latest\n"
cd /storage/rsync-public/mainnet
rm processor-mainnet-latest.tar.gz
ln -s processor-mainnet-$(date '+%Y-%m-%d').tar.gz processor-mainnet-latest.tar.gz
