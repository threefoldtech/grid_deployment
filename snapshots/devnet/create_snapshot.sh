#/bin/bash
printf "Stopping tfchain public node / graphql stack and sleep for 10 sec\n"
docker stop tfchain_graphql_processor_1
docker stop tfchain_graphql_query-node_1
docker stop tfchain_graphql_db_1
docker stop indexer_ingest_1
docker stop indexer_gateway_1
docker stop indexer_explorer_1
docker stop indexer_db_1
docker stop tfchain-dev-snapshot
sleep 10


##TFchain node
printf "Creating tfchain snapshot\n"
cd /srv/tfchain/chains/tfchain_devnet/db/
tar -cv -I 'xz -9 -T0' -f "/storage/rsync-public/tfchain-devnet-$(date '+%Y-%m-%d').tar.gz" *

printf "Starting public node again\n"
docker start tfchain-dev-snapshot
sleep 10

printf "Removing and recreating ln to latest\n"
cd /storage/rsync-public
rm tfchain-devnet-latest.tar.gz
ln -s tfchain-devnet-$(date '+%Y-%m-%d').tar.gz tfchain-devnet-latest.tar.gz


## Graphql - Indexer
printf "Creating indexer snapshot\n"
cd /srv/indexer/
tar -cv -I 'xz -9 -T0' -f "/storage/rsync-public/indexer-devnet-$(date '+%Y-%m-%d').tar.gz" *

printf "Starting indexer again\n"
docker start indexer_db_1
docker start indexer_explorer_1
docker start indexer_gateway_1
docker start indexer_ingest_1

#printf "Removing and recreating ln to latest\n"
cd /storage/rsync-public
rm indexer-devnet-latest.tar.gz
ln -s indexer-devnet-$(date '+%Y-%m-%d').tar.gz indexer-devnet-latest.tar.gz


## Graphql - Processor
printf "Creating processor snapshot\n"
cd /srv/processor/
tar -cv -I 'xz -9 -T0' -f "/storage/rsync-public/processor-devnet-$(date '+%Y-%m-%d').tar.gz" *

printf "Starting processor again\n"
docker start tfchain_graphql_db_1
docker start tfchain_graphql_query-node_1
docker start tfchain_graphql_processor_1

printf "Removing and recreating ln to latest\n"
cd /storage/rsync-public
rm processor-devnet-latest.tar.gz
ln -s processor-devnet-$(date '+%Y-%m-%d').tar.gz processor-devnet-latest.tar.gz


## Send over to Grid-snapshots server and set ln
scp /storage/rsync-public/tfchain-devnet-$(date '+%Y-%m-%d').tar.gz grid-snapshots:/storage/rsync-public/devnet/
scp /storage/rsync-public/indexer-devnet-$(date '+%Y-%m-%d').tar.gz grid-snapshots:/storage/rsync-public/devnet/
scp /storage/rsync-public/processor-devnet-$(date '+%Y-%m-%d').tar.gz grid-snapshots:/storage/rsync-public/devnet/
ssh grid-snapshots sh /opt/snapshots/devnet-set-ln.sh
