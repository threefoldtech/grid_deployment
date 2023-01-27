#/bin/bash
printf "Stopping tfchain public node / graphql stack and sleep for 10 sec\n"
docker stop tfchain_graphql_processor_1
docker stop tfchain_graphql_query-node_1
docker stop tfchain_graphql_db_1
docker stop indexer_indexer_1
docker stop indexer_indexer-gateway_1
docker stop indexer_indexer-status-service_1
docker stop indexer_redis_1
docker stop indexer_db_1
docker stop tfchain-main-pub-snapshot-current
sleep 10


## TFchain node
printf "Creating tfchain snapshot\n"
cd /srv/tfchain/chains/tfchain_mainnet/db/
tar -cv -I 'xz -9 -T0' -f "/storage/rsync-public/mainnetcurrent/tfchain-mainnet-$(date '+%Y-%m-%d').tar.gz" *

printf "Starting public node again\n"
docker start tfchain-main-pub-snapshot-current
sleep 10

printf "Removing and recreating ln to latest\n"
cd /storage/rsync-public/mainnetcurrent/
rm tfchain-mainnet-latest.tar.gz
ln -s tfchain-mainnet-$(date '+%Y-%m-%d').tar.gz tfchain-mainnet-latest.tar.gz


## Graphql - Indexer
printf "Creating indexer snapshot\n"
cd /srv/indexer/
tar -cv -I 'xz -9 -T0' -f "/storage/rsync-public/mainnetcurrent/indexer-mainnet-$(date '+%Y-%m-%d').tar.gz" *

printf "Starting indexer again\n"
docker start indexer_db_1
docker start indexer_redis_1
docker start indexer_indexer-status-service_1
docker start indexer_indexer-gateway_1
docker start indexer_indexer_1

printf "Removing and recreating ln to latest\n"
cd /storage/rsync-public/mainnetcurrent/
rm indexer-mainnet-latest.tar.gz
ln -s indexer-mainnet-$(date '+%Y-%m-%d').tar.gz indexer-mainnet-latest.tar.gz


## Graphql - Processor
printf "Creating processor snapshot\n"
cd /srv/processor/
tar -cv -I 'xz -9 -T0' -f "/storage/rsync-public/mainnetcurrent/processor-mainnet-$(date '+%Y-%m-%d').tar.gz" *

#printf "Starting processor again\n"
docker start tfchain_graphql_db_1
docker start tfchain_graphql_query-node_1
docker start tfchain_graphql_processor_1

printf "Removing and recreating ln to latest\n"
cd /storage/rsync-public/mainnetcurrent/
rm processor-mainnet-latest.tar.gz
ln -s processor-mainnet-$(date '+%Y-%m-%d').tar.gz processor-mainnet-latest.tar.gz


## Remove files older then 7 days
find /storage/rsync-public/mainnetcurrent/ -mtime +7 -exec rm {} \;


## Send over to Grid-snapshots server and set ln
scp /storage/rsync-public/mainnetcurrent/tfchain-mainnet-$(date '+%Y-%m-%d').tar.gz grid-snapshots:/storage/rsync-public/mainnetcurrent/
scp /storage/rsync-public/mainnetcurrent/indexer-mainnet-$(date '+%Y-%m-%d').tar.gz grid-snapshots:/storage/rsync-public/mainnetcurrent/
scp /storage/rsync-public/mainnetcurrent/processor-mainnet-$(date '+%Y-%m-%d').tar.gz grid-snapshots:/storage/rsync-public/mainnetcurrent/
ssh grid-snapshots sh /opt/snapshots/mainnet-current-set-ln.sh
