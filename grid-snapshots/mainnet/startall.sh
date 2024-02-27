#/bin/bash
docker start tfchain-public-node
docker start indexer_db
docker start indexer_ingest
docker start indexer_gateway
docker start indexer_explorer
docker start processor_db
docker start processor
docker start processor_query_node
